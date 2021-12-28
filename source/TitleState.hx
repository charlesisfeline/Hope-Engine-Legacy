package;

import DialogueSubstate.DialogueStyle;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
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
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
#if windows
import Discord.DiscordClient;
#end

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end


class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup = new FlxGroup();
	var credTextShit:Alphabet;
	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;
	var ifuseethis:FlxText;
	
	override public function create():Void
	{	
		#if FILESYSTEM
		if (!FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		
		if (!FileSystem.exists(Sys.getCwd() + "/assets/skins"))
			FileSystem.createDirectory(Sys.getCwd() + "/assets/skins");

		NoteSkinSelection.refreshSkins();
		#else
		FlxG.save.bind('save', 'hopeEngine');

        PlayerSettings.init();
		Data.initSave();
		#end
		
		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		Highscore.load();

		// Feeling dumb today
		Application.current.onExit.add(function(exitCode)
		{
			FlxG.save.flush();
		});

		curWacky = FlxG.random.getObject(getIntroTextShit());

		#if mobile
		ifuseethis = new FlxText(0, FlxG.height - 16, 0, "if u see this ur dumb LMAO", 16);
		add(ifuseethis);
		#end

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
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;
			
			FlxTransitionableState.defaultTransIn =  new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1), 
				{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			#if FILESYSTEM
			for (mod in FileSystem.readDirectory('mods'))
			{
				Paths.setCurrentMod(mod);
				if (FileSystem.exists(Sys.getCwd() + Paths.loadModFile(mod)))
					CoolUtil.loadCustomDifficulties();
			}

			Paths.setCurrentMod(null);
			#end

			MainMenuState.hopeEngineVer = Assets.getText('version.awesome');

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				Conductor.changeBPM(102);
				FlxG.sound.music.fadeIn(4, 0, 0.7);

				#if mobile
				remove(ifuseethis);
				#end
			});
		}
		
		persistentUpdate = true;

		logoBl = new FlxSprite(25, 25).loadGraphic(Paths.image('YEAHHH WE FUNKIN'));
		logoBl.setGraphicSize(0, 425);
		logoBl.antialiasing = true;
		logoBl.visible = false;
		logoBl.updateHitbox();

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

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

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

		if (pressedEnter && !transitioning && skippedIntro)
		{

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			if (FlxG.save.data.flashing)
			{
				titleText.animation.play('press');
				titleText.centerOffsets;
			}

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
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

		danceLeft = !danceLeft;

		if (canBop)
		{
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
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

		if (canBop)
		{
			logoBl.scale.set(logoBl.scale.x + 0.02, logoBl.scale.y + 0.02);
			FlxTween.tween(logoBl, {"scale.x": logoBl.scale.x - 0.02, "scale.y": logoBl.scale.y - 0.02}, Conductor.crochet / 1500, {ease: FlxEase.quadOut});
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