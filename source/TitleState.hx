package;

<<<<<<< HEAD
import shaders.LensDistortion;
import Discord.DiscordClient;
import achievements.Achievements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
=======
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
>>>>>>> upstream
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import hopeUI.HopeTitle;
import lime.app.Application;
import openfl.Assets;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ShaderFilter;
<<<<<<< HEAD
=======
import shaders.Grain;
import shaders.Mosaic;
>>>>>>> upstream

using StringTools;

#if desktop
import Discord.DiscordClient;
#end
<<<<<<< HEAD

=======
>>>>>>> upstream
#if FILESYSTEM
import sys.FileSystem;
#end

<<<<<<< HEAD
// #if VIDEOS_ALLOWED
// import vlc.MP4Handler;
// #end

=======
>>>>>>> upstream
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup = new FlxGroup();
	var credTextShit:Alphabet;
	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;

<<<<<<< HEAD
	// version
	public static var requestedVersion:Null<String> = null;

	override public function create():Void
	{	
		if (Paths.priorityMod != "hopeEngine")
		{
			if (Paths.exists(Paths.state("TitleState")))
			{
				Paths.setCurrentMod(Paths.priorityMod);
				FlxG.switchState(new CustomState("TitleState", TITLESTATE));

				DONTFUCKINGTRIGGERYOUPIECEOFSHIT = true;
				return;
			}
		}

		if (Paths.priorityMod == "hopeEngine")
			Paths.setCurrentMod(null);
		else
			Paths.setCurrentMod(Paths.priorityMod);
		
		#if FILESYSTEM
		if (!FileSystem.exists(Sys.getCwd() + "/skins"))
			FileSystem.createDirectory(Sys.getCwd() + "/skins");

		#if MODS_FEATURE
		if (!FileSystem.exists(Sys.getCwd() + "/mods"))
			FileSystem.createDirectory(Sys.getCwd() + "/mods");
		#end

		// quick check
		for (skinName in FileSystem.readDirectory(Sys.getCwd() + "/skins"))
		{
			if (skinName.trim() == 'default')
				CustomTransition.switchTo(new WarningState("Uhoh!\n\nYou seem to have a folder in the note skins folder called \"default\".\n\nThe engine uses this name internally!\n\nPlease change it!",
=======
	var code:Array<FlxKey> = [H, O, P, E];
	var typed:Array<FlxKey> = [];

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
				FlxG.switchState(new WarningState("Uhoh!\n\nYou seem to have a folder in the note skins folder called \"default\".\n\nThe engine uses this name internally!\n\nPlease change it!",
>>>>>>> upstream
					function()
					{
						Sys.exit(0);
					}));
		}

		for (mod in FileSystem.readDirectory(Sys.getCwd() + "/mods"))
		{
			if (mod.trim().toLowerCase() == 'hopeengine')
<<<<<<< HEAD
				CustomTransition.switchTo(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"hopeengine\".\n\nThe engine uses this name internally!\n\nPlease change it!",
=======
				FlxG.switchState(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"hopeengine\".\n\nThe engine uses this name internally!\n\nPlease change it!",
>>>>>>> upstream
					function()
					{
						Sys.exit(0);
					}));

			if (mod.trim().toLowerCase() == 'none')
<<<<<<< HEAD
				CustomTransition.switchTo(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"none\".\n\nThe engine uses this name internally!\n\nPlease change it!",
=======
				FlxG.switchState(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"none\".\n\nThe engine uses this name internally!\n\nPlease change it!",
>>>>>>> upstream
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
<<<<<<< HEAD
			Settings.botplay = false;
=======
>>>>>>> upstream

			Settings.save();
			Achievements.save();
			FlxG.save.flush();
		});

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var ngLogo:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
<<<<<<< HEAD
			// var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
			// diamond.persist = true;
			// diamond.destroyOnNoUse = false;

			// FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1),
			// 	{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));
			// FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, 1),
			// 	{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));

			// transIn = FlxTransitionableState.defaultTransIn;
			// transOut = FlxTransitionableState.defaultTransOut;
=======
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
>>>>>>> upstream

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

<<<<<<< HEAD
			#if (FILESYSTEM && MODS_FEATURE)
=======
			#if FILESYSTEM
>>>>>>> upstream
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

<<<<<<< HEAD
			var http = new haxe.Http('https://raw.githubusercontent.com/skuqre/Hope-Engine/main/version.awesome');
=======
			var http = new haxe.Http('https://raw.githubusercontent.com/skuqre/Hope-Engine/master/version.awesome');
>>>>>>> upstream

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

		logoBl = new FlxSprite(25, 25);
		logoBl.frames = Paths.getSparrowAtlas("logoBump");
		logoBl.animation.addByPrefix("bump", "logo bumpin", 24, false);
		logoBl.setGraphicSize(Std.int((FlxG.width / 2) - 50), 0);
		logoBl.antialiasing = true;
		logoBl.visible = false;
		logoBl.updateHitbox();
		logoBl.x += 25;
		logoBl.scale.set(1, 1);

		gfDance = new FlxSprite();
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		gfDance.visible = false;
		gfDance.scale.set(0.95, 0.95);
		gfDance.updateHitbox();
		gfDance.x = FlxG.width - gfDance.width - 10;
		gfDance.y = FlxG.height - gfDance.height - 10;
		add(gfDance);
		add(logoBl);

		ngLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('FUCK YEAHHHHH NEWGROUNDS'));
		ngLogo.setGraphicSize(0, 350);
		ngLogo.updateHitbox();
		ngLogo.screenCenter(X);
		ngLogo.antialiasing = true;
		ngLogo.visible = false;
		add(ngLogo);

		titleText = new FlxSprite(0, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(X);
		titleText.visible = false;
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	var hahaArray:Array<Array<BitmapFilter>> = [
		[],
<<<<<<< HEAD
		[new ShaderFilter(new shaders.VCR())],
=======
		[new ShaderFilter(new shaders.CRTCurve())],
>>>>>>> upstream
		[new ShaderFilter(new shaders.ChromaticAberration())],
		[new ShaderFilter(new shaders.Grain(1.0))],
		[new ShaderFilter(new shaders.Hq2x())],
		[new ShaderFilter(new shaders.Mosaic(8, 8))],
		[new ShaderFilter(new shaders.Scanline(2.0))],
<<<<<<< HEAD
		[new ShaderFilter(new shaders.LensDistortion())],
=======
>>>>>>> upstream
		[
			new ColorMatrixFilter([
				-1,  0,  0, 0, 255,
				 0, -1,  0, 0, 255,
				 0,  0, -1, 0, 255,
				 0,  0,  0, 1,   0,
			])
		]
	];

	var curFilter:Int = 0;
<<<<<<< HEAD
	var swing:Bool = FlxG.random.bool(0.004);

	var typed:String = "";

	var DONTFUCKINGTRIGGERYOUPIECEOFSHIT:Bool = false;

	override function update(elapsed:Float)
	{
		if (DONTFUCKINGTRIGGERYOUPIECEOFSHIT)
			return;
		
		if (swing)
			logoBl.angle = Math.sin(FlxG.game.ticks / 500) * -5;

=======

	override function update(elapsed:Float)
	{
>>>>>>> upstream
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

<<<<<<< HEAD
		if (FlxG.keys.justPressed.F4)
=======
		if (FlxG.keys.justPressed.G)
			FlxG.switchState(new hopeUI.HopeTitle());

		if (FlxG.keys.justPressed.F3)
>>>>>>> upstream
		{
			curFilter++;

			if (curFilter > hahaArray.length - 1)
				curFilter = 0;

			if (curFilter < 0)
				curFilter = hahaArray.length - 1;

			FlxG.game.setFilters(hahaArray[curFilter]);
		}

<<<<<<< HEAD
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.UI_ACCEPT;
=======
		if (FlxG.keys.anyJustPressed([ANY]))
		{
			typed.push(cast FlxG.keys.firstJustPressed());

			var cur = 0;
			
			for (key in typed) 
			{
				var curKey = code[cur];

				if (key != curKey)
				{
					for (k in typed)
						typed.remove(k);

					break;
				}

				cur++;
			}

			if (typed.length == code.length)
			{
				FlxG.sound.music.volume = 0;
				var a = FlxG.sound.play(Paths.sound("titleShoot"), 0.6).length / 1000;
				
				FlxG.camera.flash(FlxColor.WHITE, a, true);
				FlxG.camera.fade(0xff000000, a);
				new FlxTimer().start(a, function(tmr:FlxTimer) {
					FlxG.switchState(new HopeTitle());	
				});
			}
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
>>>>>>> upstream

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (FlxG.keys.justPressed.R)
		{
			if (FlxG.keys.pressed.CONTROL)
<<<<<<< HEAD
			{
				FlxG.resetGame();
				initialized = false;
			}
		}

		if (FlxG.keys.justPressed.ANY)
		{
			var a:Array<Bool> = [];
			var acceptableWords:Array<String> = [
				"hope",
				"pringles"
			];

			typed += FlxG.keys.getIsDown()[FlxG.keys.getIsDown().length - 1].ID.toString();
			typed = typed.trim().toLowerCase();

			for (word in acceptableWords)
				a.push(word.startsWith(typed));

			if (a.contains(true))
			{
				switch (typed.trim().toLowerCase())
				{
					case 'hope':
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.sound('Lights_Shut_off'), 1, function() {
							CustomTransition.switchTo(new HopeTitle());
						});
						FlxG.camera.fade(FlxColor.BLACK, 0);
					#if VIDEOS_ALLOWED
					case 'pringles':
						new VideoHandler().playVideo(Paths.video("ninjamuffin_eating_pringles", "preload"), true);
					#end
				}
			}
			else
				typed = '';
=======
				FlxG.resetGame();
>>>>>>> upstream
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			if (Settings.flashing)
			{
				titleText.animation.play('press');
				titleText.centerOffsets();
			}

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				#if CHECK_LATEST
				if (requestedVersion != null)
				{
					// what (number strings)
					if (MainMenuState.hopeEngineVer.trim() < requestedVersion.trim())
					{
						trace("\noutdated lmao! currently at: " + MainMenuState.hopeEngineVer.trim() + "\nlatest: " + requestedVersion.trim());
<<<<<<< HEAD
						CustomTransition.switchTo(new OutdatedState());
					}
					else
						CustomTransition.switchTo(new MainMenuState());
				}
				else
				#end
				CustomTransition.switchTo(new MainMenuState());
=======
						FlxG.switchState(new OutdatedState());
					}
					else
						FlxG.switchState(new MainMenuState());
				}
				else
				#end
				FlxG.switchState(new MainMenuState());
>>>>>>> upstream
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;

			credGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (credGroup.length * 60) + 200;

		credGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (credGroup.members.length > 0)
		{
			credGroup.remove(credGroup.members[0], true);
		}
	}

	var canBop:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (canBop)
		{
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');

			logoBl.animation.play("bump", true);
		}

		switch (curBeat)
		{
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8r']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				addMoreText('In association with');
			case 7:
				addMoreText('Newgrounds');
				if (!skippedIntro)
				{
					ngLogo.y = FlxG.height * 0.45;
					ngLogo.visible = true;
				}
			case 8:
				deleteCoolText();
				ngLogo.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText("Funkin'");
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		ngLogo.visible = false;

		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			titleText.visible = true;
			logoBl.visible = true;
			gfDance.visible = true;
			skippedIntro = true;
		}

		new FlxTimer().start(1.25, function(tmr:FlxTimer)
		{
			canBop = true;
		});
	}
}
