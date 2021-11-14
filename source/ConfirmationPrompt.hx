package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class ConfirmationPrompt extends MusicBeatSubstate
{
	public static var confirmThing:Void->Void;
	public static var denyThing:Void->Void;

	public static var confirmDisplay:String = '';
	public static var denyDisplay:String = '';

	public static var titleText:String = '';
	public static var descText:String = '';

	var confirmButton:FlxButton;
	var denyButton:FlxButton;

	var confirmText:Alphabet;
	var denyText:Alphabet;

	/**
	 * Create a new prompt.
     * Be sure to set its' values before instancing a new one!
	 */
	public function new()
	{
		super();

		persistentDraw = true;
		persistentUpdate = false;
		FlxG.mouse.visible = true;

		if (denyThing == null)
			denyThing = close;

		var bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), 0xFF000000);
        bg.scrollFactor.set();
        bg.alpha = 0.6;
        bg.screenCenter();
        add(bg);

		var titleFlxText = new FlxText(0, 0, FlxG.width, titleText, 64);
        titleFlxText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        titleFlxText.screenCenter();
        titleFlxText.borderSize = 4;
        add(titleFlxText);

		var descFlxText = new FlxText(0, 0, FlxG.width, descText, 32);
        descFlxText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        descFlxText.screenCenter();
        descFlxText.borderSize = 4;
        add(descFlxText);

		descFlxText.screenCenter();
		titleFlxText.screenCenter(X);
		titleFlxText.y = descFlxText.y - (titleFlxText.height * 1.5);

		confirmButton = new FlxButton(0, 0, "", confirm);
		confirmButton.loadGraphic(Paths.image('confirmButton'));
		confirmButton.setGraphicSize(Std.int(confirmButton.width * 0.7));
		confirmButton.updateHitbox();
		confirmButton.x = FlxG.width / 2 - confirmButton.width - 25;
		confirmButton.y = FlxG.height - confirmButton.height - 25;
		confirmButton.antialiasing = true;
		add(confirmButton);

		denyButton = new FlxButton(0, 0, "", deny);
		denyButton.loadGraphic(Paths.image('denyButton'));
		denyButton.setGraphicSize(Std.int(denyButton.width * 0.7));
		denyButton.updateHitbox();
		denyButton.x = FlxG.width / 2 + 25;
		denyButton.y = FlxG.height - denyButton.height - 25;
		denyButton.antialiasing = true;
		add(denyButton);

		confirmText = new Alphabet(0, 0, confirmDisplay, false);
		add(confirmText);

		denyText = new Alphabet(0, 0, denyDisplay, false);
		add(denyText);

		forEachOfType(FlxSprite, function(spr:FlxSprite) 
		{
			var desiredAlpha:Float = 1;
			if (spr.alpha == 1)
				spr.alpha = 0;
			else
				desiredAlpha = spr.alpha;

			FlxTween.tween(spr, {alpha: desiredAlpha}, 0.5);
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (denyText != null && confirmText != null)
		{
			confirmText.x = confirmButton.x + (confirmButton.width / 2) - (confirmText.width / 2);
			confirmText.y = confirmButton.y + (confirmButton.height / 2) - (confirmText.height / 2);

			denyText.x = denyButton.x + (denyButton.width / 2) - (denyText.width / 2);
			denyText.y = denyButton.y + (denyButton.height / 2) - (denyText.height / 2);
		}
	}

	function confirm() 
	{
		confirmThing();
		forEachOfType(FlxSprite, function(spr:FlxSprite) 
		{
			FlxTween.tween(spr, {alpha : 0}, 0.5, {onComplete: function(twn:FlxTween) 
			{
				close();
			}});
		});

		FlxG.mouse.visible = false;
	}

	function deny() 
	{
		denyThing();
		forEachOfType(FlxSprite, function(spr:FlxSprite) 
		{
			FlxTween.tween(spr, {alpha : 0}, 0.5, {onComplete: function(twn:FlxTween) 
			{
				close();
			}});
		});

		FlxG.mouse.visible = false;
	}
}