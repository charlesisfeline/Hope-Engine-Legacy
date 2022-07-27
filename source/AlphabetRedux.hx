package;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

enum AlphabetAlignment
{
	CENTER;
	LEFT;
	RIGHT;
}

/**
 * A remade version of FNF's Alphabet object.
 * 
 * @author skuqre
 */
class AlphabetRedux extends FlxTypedSpriteGroup<AlphaReduxLine>
{
	public var alignment(default, set):AlphabetAlignment = LEFT;
	public var text(default, set):String = "";
	public var fieldWidth:Float = 0;

	public var bold(default, set):Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?fieldWidth:Float = 0, text:String)
	{
		super();

		if (fieldWidth > 0)
			this.fieldWidth = fieldWidth;

		this.text = text;
	}

	function addText():Void
	{
		clear();

		for (item in text.split("\n"))
		{
			var line = new AlphaReduxLine(0, members.length * 80, item.trim(), bold);
			add(line);
		}

		updateAlignment();
	}

	function updateAlignment():Void
	{
		var useWidth = fieldWidth > 0 ? fieldWidth : width;
			
		switch (alignment)
		{
			case CENTER:
				for (line in members)
					line.x = x + (useWidth / 2) - (line.width / 2);
			case LEFT:
				for (line in members)
					line.x = x;
			case RIGHT:
				for (line in members)
					line.x = x + useWidth - line.width;
		}
	}

	function set_text(value:String):String
	{
		if (text != value)
		{
			text = value;
			addText();
		}

		return value;
	}

	function set_alignment(value:AlphabetAlignment):AlphabetAlignment
	{
		if (alignment != value)
		{
			alignment = value;
			updateAlignment();
		}

		return value;
	}

	function set_bold(value:Bool):Bool
	{
		if (bold != value)
		{
			bold = value;
			addText();
		}

		return value;
	}
}

/**
 * Works *exactly* like the Alphabet class.
 *
 * Except like, it's more advanced and organized idk
 */
class AlphaReduxLine extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;
	public var additive:Float = FlxG.height * 0.48;
	public var text:String = "";

	public var isBold:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, text:String, ?bold:Bool = false)
	{
		super(x, y);

		this.text = text;
		isBold = bold;

		var xPos:Float = 0;
		var lastWasSpace = false;

		for (let in text.split(""))
		{
			if (let != " ")
			{
				var char = new AlphaReduxCharacter(let, bold);
				char.x = xPos;
				char.y = 0;

				if (lastWasSpace)
				{
					char.lastWasSpace = lastWasSpace;
					lastWasSpace = false;
				}

				add(char);
				xPos = width;
			}
			else
			{
				xPos += 40;
				lastWasSpace = true;
			}
		}

		// fix letters
		var ass = height;
		for (let in members)
		{
			var letter:AlphaReduxCharacter = null;

			if (let is AlphaReduxCharacter)
				letter = cast let;
			else
				continue;

			remove(letter);
			if (letter.isCentered)
				letter.y = (ass / 2) - (let.height / 2);
			if (letter.isGrounded || !letter.bold)
				letter.y = ass - let.height;
			add(letter);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
			y = FlxMath.lerp(y, (scaledY * 120) + additive, Helper.boundTo(elapsed * 9.6, 0, 1));
		}
	}

	override function setGraphicSize(Width:Int = 0, Height:Int = 0)
	{
		if (Width <= 0 && Height <= 0)
			return;

		var newScaleX:Float = Width / width;
		var newScaleY:Float = Height / height;

		var prevLet:FlxSprite = null;

		for (letter in members)
		{
			var let = remove(letter);
			let.scale.set(newScaleX, newScaleY);
			
			if (Width <= 0)
				let.scale.x = newScaleY;
			if (Height <= 0)
				let.scale.y = newScaleX;

			let.updateHitbox();

			if (prevLet != null)
				let.x = prevLet.x + prevLet.width;
			else
				let.x = 0;

			var char:AlphaReduxCharacter = cast let;
			if (char.lastWasSpace)
				let.x += 40 * newScaleX;

			let.updateHitbox();

			prevLet = let;
			add(let);
		}
	}

	public function getTargetY():Float
	{
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		return (scaledY * 120) + additive;
	}
}

class AlphaReduxCharacter extends FlxSprite
{
	var uppers = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	var lowers = "abcdefghijklmnopqrstuvwxyz";
	var digits = "0123456789";
	var symbols = "|~#$%()*+-:;<=>@[]^_.,'!&?";

	var grounded = "._,?!abcdefghijklmnopqrstuvwxyz";
	var centered = "|~#$%()+-:;<=>@[]&";

	public var bold:Bool = false;
	public var char:String = "";

	public var isLowerCase:Bool = false;
	public var isSymbol:Bool = false;
	public var isDigit:Bool = false;
	public var isGrounded:Bool = false;
	public var isCentered:Bool = false;

	public var lastWasSpace:Bool = false;

	public function new(letter:String, ?bold:Bool = false)
	{
		super();

		this.bold = bold;
		this.char = letter;
		this.isGrounded = grounded.contains(letter);
		this.isCentered = centered.contains(letter);

		isLowerCase = lowers.contains(letter);
		isDigit = digits.contains(letter);
		isSymbol = symbols.contains(letter);

		frames = Paths.getSparrowAtlas("alphabet_redux", "preload");

		if (isDigit)
			createNumber();
		else if (isSymbol)
			createSymbol();
		else
			createLetter();

		antialiasing = true;
	}

	var altNames:Map<String, String> = [
		"!" => "exclamation point",
		"?" => "question mark",
		"." => "period",
		"\\" => "backslash",
		"," => "comma",
		"'" => "apostraphie"
	];

	function createSymbol():Void
	{
		var prefix = char;

		if (altNames.exists(char))
			prefix = altNames.get(char);

		if (bold)
			prefix += " bold";

		prefix += "0";

		animation.addByPrefix(prefix, prefix, 24, true);
		animation.play(prefix);
		updateHitbox();

		if (bold)
		{
			setGraphicSize(Std.int(width * 1.15));
			updateHitbox();
		}
		else
			color = FlxColor.BLACK;
	}

	function createLetter():Void
	{
		var prefix = char;

		if (isLowerCase)
			prefix += " lowercase";

		if (!isLowerCase && !bold)
			prefix += " capital";

		if (bold)
			prefix += " bold";

		prefix += "0";

		animation.addByPrefix(prefix, prefix, 24, true);
		animation.play(prefix);
		updateHitbox();

		if (isLowerCase && bold)
		{
			setGraphicSize(Std.int(width * 1.35));
			updateHitbox();
		}

		if (!bold)
			color = FlxColor.BLACK;
	}

	function createNumber():Void
	{
		var prefix = char;

		if (bold)
			prefix += " bold";

		prefix += "0";

		animation.addByPrefix(prefix, prefix, 24, true);
		animation.play(prefix);
		updateHitbox();

		if (bold)
		{
			setGraphicSize(Std.int(width * 1.15));
			updateHitbox();
		}
		else
			color = FlxColor.BLACK;
	}
}
