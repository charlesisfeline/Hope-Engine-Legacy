package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;
	public var checkBox:OptionsMenu.CheckBox;
	public var additive:Float = FlxG.height * 0.48;

	public var typeDelay:Float = 0.05;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var listOAlphabets:List<AlphaCharacter> = new List<AlphaCharacter>();

	var splitWords:Array<String> = [];

	public var isBold:Bool = false;
	var rightAligned:Bool = false;

	public var typedTimer:FlxTimer;
	public var currentTypedLetter:Int = 0;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, shouldMove:Bool = false, isRight:Bool = false)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;
		rightAligned = isRight;

		if (text != "")
			addText();
		
		if (!bold)
			color = 0xFF000000;
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		var curRow:Int = 0;
		for (character in splitWords)
		{

			if (character == " ")
			{
				lastWasSpace = true;
			}

			if (character == '\n')
			{
				xPos = 0;
				xPosResetted = true;
				curRow++;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(character);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(character);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(character) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(character) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1 || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(character.toLowerCase()))
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width;
				}
				else
					xPosResetted = false;

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);
				letter.row = curRow;
				listOAlphabets.add(letter);

				if (isBold && !isSymbol)
					letter.createBold(character);
				else if (isNumber)
					letter.createNumber(character);
				else if (isSymbol)
				{
					letter.createSymbol(character);
					if (isBold)
						letter.color = 0xFF000000;
				}
				else
					letter.createLetter(character);

				add(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
			y = FlxMath.lerp(y, (scaledY * 120) + additive, 9 / lime.app.Application.current.window.frameRate);
		}

		if (checkBox != null)
			checkBox.y = y + (height / 2) - (checkBox.height / 2);

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}
		
		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		
		updateHitbox();

		FlxG.log.add('the row ' + row);

		y = (110 - height);
		y += row * 60;
		y -= 55;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		
		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		y = (row * 60);
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 40;
			case ',':
				animation.addByPrefix(letter, 'comma', 24);
				animation.play(letter);
				y += 40;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
			case '_':
				animation.addByPrefix(letter, '_', 24);
				animation.play(letter);
				y += 40;
			case "#":
				animation.addByPrefix(letter, '#', 24);
				animation.play(letter);
			case "$":
				animation.addByPrefix(letter, '$', 24);
				animation.play(letter);
			case "%":
				animation.addByPrefix(letter, '%', 24);
				animation.play(letter);
			case "&":
				animation.addByPrefix(letter, '&', 24);
				animation.play(letter);
			case "(":
				animation.addByPrefix(letter, '(', 24);
				animation.play(letter);
			case ")":
				animation.addByPrefix(letter, ')', 24);
				animation.play(letter);
			case "+":
				animation.addByPrefix(letter, '+', 24);
				animation.play(letter);
			case "-":
				animation.addByPrefix(letter, '-', 24);
				animation.play(letter);
				y += 35;
			case '"':
				animation.addByPrefix(letter, '"', 24);
				animation.play(letter);
			case '@':
				animation.addByPrefix(letter, '@', 24);
				animation.play(letter);
			case "^":
				animation.addByPrefix(letter, '^', 24);
				animation.play(letter);
			case ' ':
				animation.addByPrefix(letter, 'space', 24);
				animation.play(letter);
			case ':':
				animation.addByPrefix(letter, ':', 24);
				animation.play(letter);
		}
		
		
		updateHitbox();
	}
}
