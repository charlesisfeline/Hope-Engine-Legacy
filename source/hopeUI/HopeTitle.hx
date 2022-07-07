package hopeUI;

import achievements.Achievements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ShaderFilter;
import shaders.Grain;
import shaders.Mosaic;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end
#if FILESYSTEM
import sys.FileSystem;
#end

class HopeTitle extends MusicBeatState
{
	static var initialized:Bool = false;

	// version
	var requestedVersion:Null<String> = null;

	override public function create():Void
	{
		#if FILESYSTEM
		if (!FileSystem.exists(Sys.getCwd() + "/assets/skins"))
			FileSystem.createDirectory(Sys.getCwd() + "/assets/skins");

		if (!FileSystem.exists(Sys.getCwd() + "/mods"))
			FileSystem.createDirectory(Sys.getCwd() + "/mods");

		// quick check
		for (skinName in FileSystem.readDirectory(Sys.getCwd() + "/assets/skins"))
		{
			if (skinName.trim() == 'default')
				CustomTransition.switchTo(new WarningState("Uhoh!\n\nYou seem to have a folder in the note skins folder called \"default\".\n\nThe engine uses this name internally!\n\nPlease change it!",
					function()
					{
						Sys.exit(0);
					}));
		}

		for (mod in FileSystem.readDirectory(Sys.getCwd() + "/mods"))
		{
			if (mod.trim().toLowerCase() == 'hopeengine')
				CustomTransition.switchTo(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"hopeengine\".\n\nThe engine uses this name internally!\n\nPlease change it!",
					function()
					{
						Sys.exit(0);
					}));

			if (mod.trim().toLowerCase() == 'none')
				CustomTransition.switchTo(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"none\".\n\nThe engine uses this name internally!\n\nPlease change it!",
					function()
					{
						Sys.exit(0);
					}));
		}

		options.NoteSkinSelection.refreshSkins();
		#end

		#if desktop
		// only 1 thread
		if (!initialized)
		{
			DiscordClient.initialize();

			Application.current.onExit.add(function(exitCode)
			{
				DiscordClient.shutdown();
			});
		}
		#end

		Highscore.load();

		// Feeling dumb today
		Application.current.onExit.add(function(exitCode)
		{
			Settings.lastVolume = FlxG.sound.volume;
			Settings.lastMuted = FlxG.sound.muted;

			Settings.save();
			Achievements.save();
			FlxG.save.flush();
		});

		super.create();

		if (FlxG.sound.music != null && !initialized)
			FlxG.sound.music.stop();

		startIntro();
	}

	var titleText:FlxSprite;
	var credsText:FlxText;
	var hope1:FlxSprite;
	var hope2:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(1, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(0, 0, FlxG.width, FlxG.height));
			FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(1, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(0, 0, FlxG.width, FlxG.height));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			#if FILESYSTEM
			var prevMod = Paths.currentMod;

			for (mod in FileSystem.readDirectory('mods'))
			{
				Paths.setCurrentMod(mod);
				if (Paths.checkModLoad(mod))
					CoolUtil.loadCustomDifficulties();
			}

			Paths.setCurrentMod(prevMod);
			#end

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				Conductor.changeBPM(102);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			});

			var http = new haxe.Http('https://raw.githubusercontent.com/skuqre/Hope-Engine/master/version.awesome');

			http.onData = function(data:String)
			{
				requestedVersion = data.trim();
			}

			http.onError = function(data:String)
			{
				requestedVersion = null;
			}

			http.request();

			trace("latest ver get: v" + requestedVersion);
		}

		persistentUpdate = true;

		titleText = new FlxSprite(0, FlxG.height * 0.8).loadGraphic(Paths.image("hopeUI/pressEnter"));
		titleText.antialiasing = true;
		titleText.updateHitbox();
		titleText.screenCenter(X);
		titleText.visible = false;

		credsText = new FlxText(0, 0, FlxG.width);
		credsText.setFormat("VCR OSD Mono", 64, CENTER);
		add(credsText);

		hope2 = new FlxSprite().loadGraphic(Paths.image("hopeUI/hope"));
		hope2.setGraphicSize(Std.int(FlxG.width * 0.6));
		hope2.updateHitbox();
		hope2.screenCenter();
		hope2.alpha = 0.4;
		hope2.antialiasing = true;
		hope2Size = [hope2.scale.x, hope2.scale.y];
		hope2.visible = false;
		add(hope2);

		hope1 = new FlxSprite().loadGraphic(Paths.image("hopeUI/hope"));
		hope1.setGraphicSize(Std.int(FlxG.width * 0.5));
		hope1.updateHitbox();
		hope1.screenCenter();
		hope1.antialiasing = true;
		hope1Size = [hope1.scale.x, hope1.scale.y];
		hope1.visible = false;
		add(hope1);

		add(titleText);

		FlxG.mouse.visible = false;

		getFunny();

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	var hope1Size:Array<Float> = [];
	var hope2Size:Array<Float> = [];

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		if (controls.ACCEPT && !transitioning && skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 1, true);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			if (Settings.flashing)
			{
				titleText.scale.set(1.2, 1);
				FlxTween.tween(titleText, {"scale.x": 1}, 0.4, {ease: FlxEase.sineInOut});
			}

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				#if CHECK_LATEST
				if (requestedVersion != null)
				{
					// what (number strings)
					if (MainMenuState.hopeEngineVer.trim() < requestedVersion.trim())
					{
						trace("\noutdated lmao! currently at: " + MainMenuState.hopeEngineVer.trim() + "\nlatest: " + requestedVersion.trim());
						CustomTransition.switchTo(new OutdatedState());
					}
					else
						CustomTransition.switchTo(new hopeUI.HopeMainMenu());
				}
				else
				#end
				CustomTransition.switchTo(new hopeUI.HopeMainMenu());
			});
		}

		if (controls.ACCEPT && !skippedIntro && initialized)
			skipIntro();

		var lma = Helper.boundTo(1 - (elapsed * 3.125), 0, 1);
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, lma);

		var hope1Scalex = FlxMath.lerp(hope1Size[0], hope1.scale.x, lma);
		var hope1Scaley = FlxMath.lerp(hope1Size[1], hope1.scale.y, lma);
		hope1.scale.set(hope1Scalex, hope1Scaley);

		var hope2Scalex = FlxMath.lerp(hope2Size[0], hope2.scale.x, lma);
		var hope2Scaley = FlxMath.lerp(hope2Size[1], hope2.scale.y, lma);
		hope2.scale.set(hope2Scalex, hope2Scaley);
	}

	var funny:Array<String> = [];

	function getFunny():Void
	{
		var items = [];

		for (item in Assets.getText(Paths.txt("hopeIntroText")).trim().split("\n"))
			items.push(item.trim());

		var ass = FlxG.random.getObject(items).split('--');
		funny = [ass[0].trim(), ass[1].trim()];
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom += 0.015;

		hope1.scale.x += 0.015;
		hope1.scale.y += 0.015;

		hope2.scale.x -= 0.035;
		hope2.scale.y -= 0.035;

		if (!skippedIntro)
		{
			switch (curBeat)
			{
				case 1:
					credsText.text = "skuqre";
				case 3:
					credsText.text += "\npresents";
				case 4:
					credsText.text = "";
				case 5:
					credsText.text = "Another FNF";
				case 7:
					credsText.text += "\nEngine";
				case 8:
					credsText.text = "";
				case 9:
					credsText.text = funny[0];
				case 11:
					credsText.text += "\n" + funny[1];
				case 12:
					credsText.text = "";
				case 13:
					credsText.text = "Friday Night Funkin'";
				case 14:
					credsText.text += "\nHope";
				case 15:
					credsText.text += " Engine";
				case 16:
					credsText.text = "";
					skipIntro();
			}
		}

		credsText.screenCenter(Y);
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			titleText.visible = true;
			hope1.visible = true;
			hope2.visible = true;
			credsText.visible = false;
			skippedIntro = true;
		}
	}
}
