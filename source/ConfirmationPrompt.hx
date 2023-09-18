package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class ConfirmationPrompt extends MusicBeatSubstate
{
	public var confirmThing:Void->Void;
	public var denyThing:Void->Void;

	public var confirmDisplay:String = '';
	public var denyDisplay:String = '';

	public var titleText:String = '';
	public var descText:String = '';

	var confirmButton:FlxUIButton;
	var denyButton:FlxUIButton;

	var confirmText:Alphabet;
	var denyText:Alphabet;

	var prevCamZoom:Float;

	public function new(?title:String = "", ?desc:String = "", ?confirm:String = "Yes", ?deny:String = "No", confirmCallback:Void->Void,
			declineCallback:Void->Void)
	{
		super();

<<<<<<< HEAD
		if (!FlxG.mouse.visible)
			wasInvi = true;

=======
>>>>>>> upstream
		this.titleText = title;
		this.descText = desc;
		this.confirmDisplay = confirm;
		this.denyDisplay = deny;

		persistentDraw = true;
		persistentUpdate = false;
		FlxG.mouse.visible = true;
<<<<<<< HEAD
=======
		usesMouse = true;
>>>>>>> upstream

		this.confirmThing = confirmCallback;
		this.denyThing = declineCallback;

		prevCamZoom = FlxG.camera.zoom;
		FlxG.camera.zoom = 1;

		var bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), 0xFF000000);
		bg.scrollFactor.set();
		bg.alpha = 0.6;
		bg.screenCenter();
		add(bg);

		var frame = new FlxSprite();
		frame.frames = Paths.getSparrowAtlas("alert9Slice", "preload");
		frame.animation.addByPrefix("idle", "alert frame idle", 24);
		frame.animation.play("idle");
		frame.screenCenter();
		frame.antialiasing = true;
		add(frame);

		var title = new Alphabet(0, 0, titleText, true);
		title.screenCenter(X);
		title.y = frame.y - (title.height / 2);
		add(title);

		var desc = new FlxText(0, 0, Std.int(frame.width - 32), descText, 20);
		desc.setFormat('Funkerin Regular', 48, FlxColor.BLACK, CENTER);
		desc.antialiasing = true;
		desc.screenCenter();
		add(desc);

		confirmButton = new FlxUIButton(0, 0, "", this.confirm);
		confirmButton.loadGraphicSlice9([Paths.image("confirm9slice", "preload")], 241, 150, [[60, 38, 60 + 120, 38 + 75]], false, 241, 150);
		confirmButton.antialiasing = true;
		add(confirmButton);

		denyButton = new FlxUIButton(0, 0, "", this.deny);
		denyButton.loadGraphicSlice9([Paths.image("decline9slice", "preload")], 241, 150, [[60, 38, 60 + 120, 38 + 75]], false, 241, 150);
		denyButton.antialiasing = true;
		add(denyButton);

		confirmText = new Alphabet(0, 0, confirmDisplay, false);
		add(confirmText);

		denyText = new Alphabet(0, 0, denyDisplay, false);
		add(denyText);

		confirmButton.resize(128 * 2, 128);
		confirmButton.x = (FlxG.width / 2) - confirmButton.width - 25;
		confirmButton.y = frame.y + frame.height - (confirmButton.height / 2);

		denyButton.resize(128 * 2, 128);
		denyButton.x = (FlxG.width / 2) + 25;
		denyButton.y = frame.y + frame.height - (denyButton.height / 2);

		forEachOfType(FlxSprite, function(spr:FlxSprite)
		{
			spr.scrollFactor.set();

			spr.scale.x += 0.2;
			spr.scale.y += 0.2;

			var daAlpha = spr.alpha;
			spr.alpha = 0;
<<<<<<< HEAD
			FlxTween.tween(spr, {"scale.x": spr.scale.x - 0.2, "scale.y": spr.scale.y - 0.2}, 0.3, {ease: FlxEase.backOut});
			FlxTween.tween(spr, {alpha: daAlpha}, 0.3);
=======
			FlxTween.tween(spr, {"scale.x": spr.scale.x - 0.2, "scale.y": spr.scale.y - 0.2, alpha: daAlpha}, 0.3, {ease: FlxEase.backOut});
>>>>>>> upstream
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

<<<<<<< HEAD
	var wasInvi:Bool = false;

	function confirm()
	{
		if (wasInvi)
			FlxG.mouse.visible = false;
=======
	function confirm()
	{
		FlxG.mouse.visible = false;
>>>>>>> upstream

		if (confirmThing != null)
			confirmThing();

		forEachOfType(FlxSprite, function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {"scale.x": spr.scale.x - 0.2, "scale.y": spr.scale.y - 0.2, alpha: 0}, 0.3, {
				ease: FlxEase.backIn,
				onComplete: function(twn:FlxTween)
				{
					close();
				}
			});
		});

		FlxG.camera.zoom = prevCamZoom;
	}

	function deny()
	{
<<<<<<< HEAD
		if (wasInvi)
			FlxG.mouse.visible = false;
=======
		FlxG.mouse.visible = false;
>>>>>>> upstream

		if (denyThing != null)
			denyThing();

		forEachOfType(FlxSprite, function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {"scale.x": spr.scale.x - 0.2, "scale.y": spr.scale.y - 0.2, alpha: 0}, 0.3, {
				ease: FlxEase.backIn,
				onComplete: function(twn:FlxTween)
				{
					close();
				}
			});
		});

		FlxG.camera.zoom = prevCamZoom;
	}
}
