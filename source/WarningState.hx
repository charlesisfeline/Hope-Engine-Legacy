package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class WarningState extends MusicBeatState
{
	var bgAlpha:Float = 0.5;
	var colorBG:FlxColor = FlxColor.BLACK;
	var text:String = "balls lmao";
	var finishCallback:Void->Void;

	var pressEnter:FlxText;

	public function new(text:String, ?bgColor:FlxColor = 0xff000000, ?bgAlpha = 0.7, ?finishCallback:Void->Void)
	{
		super();

		this.bgAlpha = bgAlpha;
		this.colorBG = bgColor;
		this.text = text;
		this.finishCallback = finishCallback;
	}

	override function create()
	{
		FlxG.camera.zoom = 1;

		var bg:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), colorBG);
		bg.alpha = bgAlpha;
		bg.screenCenter();
		add(bg);

		var awesomeText:FlxText = new FlxText(0, 0, FlxG.width * 0.85, "");
		awesomeText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		awesomeText.text = text;
		awesomeText.screenCenter();
		awesomeText.borderSize = 3;
		add(awesomeText);

		pressEnter = new FlxText(0, 0, FlxG.width * 0.85, "");
		pressEnter.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pressEnter.text = "press ENTER to continue";
		pressEnter.screenCenter(X);
		pressEnter.y = FlxG.height * 0.9;
		pressEnter.borderSize = 3;
		pressEnter.visible = false;
		add(pressEnter);

		super.create();

		forEachOfType(FlxSprite, function(spr:FlxSprite)
		{
			spr.scrollFactor.set();

			var ass = spr.alpha;
			spr.alpha = 0;
			FlxTween.tween(spr, {alpha: ass}, 0.5, {ease: FlxEase.expoInOut});
		});
	}

	var wait:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (wait > 2.5 && !pressEnter.visible)
			pressEnter.visible = true;
		else
			wait += elapsed;

		if (controls.ACCEPT && pressEnter.visible)
		{
			if (finishCallback != null)
				finishCallback();

			forEachOfType(FlxSprite, function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.expoInOut});
			});
		}
	}
}
