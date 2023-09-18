package;

<<<<<<< HEAD
import achievements.Achievements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
=======
import flixel.FlxG;
import flixel.FlxSprite;
>>>>>>> upstream
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
<<<<<<< HEAD
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
=======
import flixel.util.FlxTimer;
import lime.utils.Assets;
import openfl.Lib;
>>>>>>> upstream

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;

	var offsetChanged:Bool = false;

<<<<<<< HEAD
	var skipText:FlxText;
	var skipToOption:Alphabet;

=======
>>>>>>> upstream
	public function new()
	{
		super();

		persistentDraw = true;
		persistentUpdate = false;

		if (PlayState.openedCharting)
<<<<<<< HEAD
		{
			menuItems.insert(2, 'Toggle Botplay');

			if (PlayState.instance.songStarted)
				menuItems.insert(3, 'Skip To');
		}
=======
			menuItems = ['Resume', 'Restart Song', 'Toggle Botplay', 'Exit to menu'];
>>>>>>> upstream

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

<<<<<<< HEAD
		perSongOffset = new FlxText(0, 0, FlxG.width - 20, "Song Offset (in MS): < " + PlayState.songOffset + " >\n(Hold CTRL to change!)", 12);
=======
		perSongOffset = new FlxText(0, 0, FlxG.width - 20, "Song Offset: < " + PlayState.songOffset + " >\n(Hold CTRL to change!)", 12);
>>>>>>> upstream
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		perSongOffset.setPosition(0, FlxG.height - perSongOffset.height - 15);
		perSongOffset.alpha = 0;

		#if FILESYSTEM
		add(perSongOffset);
		perSongOffset.y += 5;
		FlxTween.tween(perSongOffset, {alpha: 1, y: perSongOffset.y - 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		#end

		if (PlayState.openedCharting)
		{
<<<<<<< HEAD
			var chartingText = new FlxText(0, levelDifficulty.y + 32, FlxG.width - 20, "CHARTING", 12);
=======
			var chartingText = new FlxText(0, 15 + 64, FlxG.width - 20, "CHARTING", 12);
>>>>>>> upstream
			chartingText.scrollFactor.set();
			chartingText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
			chartingText.alpha = 0;

			add(chartingText);
<<<<<<< HEAD
			FlxTween.tween(chartingText, {alpha: 1, y: chartingText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		}

		generateMenu();
=======
			chartingText.y -= 5;
			FlxTween.tween(chartingText, {alpha: 1, y: chartingText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		}

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.x = 25;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
>>>>>>> upstream

		if (FlxG.random.bool(0.001))
		{
			var ooohhhHeFunkin:FlxSprite = new FlxSprite();
			ooohhhHeFunkin.frames = Paths.getSparrowAtlas("he funkin", "preload");
			ooohhhHeFunkin.animation.addByPrefix("funk", "boyfried dooodle boiled", 24);
			ooohhhHeFunkin.animation.play("funk");
			ooohhhHeFunkin.scale.set(0.75, 0.75);
			ooohhhHeFunkin.updateHitbox();
			ooohhhHeFunkin.antialiasing = true;
			ooohhhHeFunkin.x = FlxG.width - ooohhhHeFunkin.width - 20;
			ooohhhHeFunkin.y = perSongOffset.y - ooohhhHeFunkin.height - 20;
			ooohhhHeFunkin.alpha = 0;
<<<<<<< HEAD
			FlxTween.tween(ooohhhHeFunkin, {alpha: 1}, 5, {
				ease: FlxEase.expoInOut,
				startDelay: 0.5,
				onComplete: function(twn:FlxTween)
				{
					Achievements.give('funky_guy');
				}
			});
=======
			FlxTween.tween(ooohhhHeFunkin, {alpha: 1}, 5, {ease: FlxEase.expoInOut, startDelay: 0.5});
>>>>>>> upstream
			add(ooohhhHeFunkin);
		}
	}

	var resuming:Bool = false;
<<<<<<< HEAD
	var curTime:Float = Math.max(0.0, Conductor.songPosition);
	var origTime:Float = Math.max(0.0, Conductor.songPosition);
=======
>>>>>>> upstream

	var holdTimer:Float = 0;

	override function update(elapsed:Float)
	{
<<<<<<< HEAD
		super.update(elapsed);

=======
>>>>>>> upstream
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		for (item in grpMenuShit)
			item.x = FlxMath.lerp(item.x, (item.targetY * 20) + 90, Helper.boundTo(elapsed * 9.6, 0, 1));

<<<<<<< HEAD
		if (skipText != null)
		{
			if (skipToOption != null)
			{
				skipText.x = skipToOption.x + skipToOption.width + 48;
				skipText.y = skipToOption.y + (skipToOption.height / 2) - (skipText.height / 2);
				skipText.alpha = skipToOption.alpha;
				skipText.visible = true;
			}
			else
				skipText.visible = false;

			if (!grpMenuShit.members.contains(skipToOption))
				skipText.visible = false;

			skipText.text = '< ${FlxStringUtil.formatTime(curTime / 1000)} / ${FlxStringUtil.formatTime(FlxG.sound.music.length / 1000)} >';
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.UI_ACCEPT;
		var backed = controls.UI_BACK;

		if (!resuming)
		{
			if (upP)
			{
				FlxG.sound.play(Paths.sound("scrollMenu", "preload"));
				changeSelection(-1);
			}
			else if (downP)
			{
				FlxG.sound.play(Paths.sound("scrollMenu", "preload"));
				changeSelection(1);
			}
		}

		if (backed)
		{
			changeSelection(-curSelected);
			accepted = true;
		}
		
		var multi:Float = 0.1;

		if (FlxG.keys.pressed.CONTROL)
		{
			#if FILESYSTEM
			if (FlxG.keys.pressed.SHIFT)
				multi = 1;

			if (controls.UI_LEFT_P)
				changeOffset(-1 * multi);
			else if (controls.UI_RIGHT_P)
				changeOffset(1 * multi);

			if (controls.UI_LEFT || controls.UI_RIGHT)
			{
				if (holdTimer > Main.globalMaxHoldTime)
				{
					if (controls.UI_LEFT)
						changeOffset(-1 * multi);
					else if (controls.UI_RIGHT)
=======
		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			FlxG.sound.play(Paths.sound("scrollMenu", "preload"));
			changeSelection(-1);
		}
		else if (downP)
		{
			FlxG.sound.play(Paths.sound("scrollMenu", "preload"));
			changeSelection(1);
		}

		#if FILESYSTEM
		var multi:Float = 0.1;
		if (FlxG.keys.pressed.CONTROL)
		{
			if (FlxG.keys.pressed.SHIFT)
				multi = 1;

			if (controls.LEFT_P)
				changeOffset(-1 * multi);
			else if (controls.RIGHT_P)
				changeOffset(1 * multi);

			if (controls.LEFT || controls.RIGHT)
			{
				if (holdTimer > Main.globalMaxHoldTime)
				{
					if (controls.LEFT)
						changeOffset(-1 * multi);
					else if (controls.RIGHT)
>>>>>>> upstream
						changeOffset(1 * multi);
				}
				else
					holdTimer += elapsed;
			}
			else
				holdTimer = 0;

<<<<<<< HEAD
			if (controls.UI_RESET)
			{
				if (FlxG.keys.pressed.ALT)
				{
					PlayState.songOffset = originalOffset;
					changeOffset();
				}
				else
				{
					PlayState.songOffset = 0;
					changeOffset();
				}
			}
			#end
		}
		else
		{
			if (menuItems[curSelected] == 'Skip To')
			{
				if (controls.UI_LEFT_P)
					curTime -= 1000;
				else if (controls.UI_RIGHT_P)
					curTime += 1000;
	
				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					if (holdTimer > Main.globalMaxHoldTime)
					{
						if (controls.UI_LEFT)
							curTime -= 1000;
						else if (controls.UI_RIGHT)
							curTime += 1000;
					}
					else
						holdTimer += elapsed;
				}
				else
					holdTimer = 0;
	
				if (curTime > FlxG.sound.music.length)
					curTime = 0;
				if (curTime < 0)
					curTime = FlxG.sound.music.length;

				if (controls.UI_RESET)
					curTime = origTime;
			}
		}
=======
			if (controls.RESET)
				changeOffset(PlayState.songOffset * -1);
		}
		#end
>>>>>>> upstream

		if (accepted && !resuming)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
<<<<<<< HEAD
					resume();
				case "Restart Song":
					CustomTransition.reset();
				case "Exit to menu":
					exitToMenu();
				case "Toggle Botplay":
					toggleBotplay();
				case "Skip To":
					if (curTime == Conductor.songPosition)
						close();
					else
					{
						FlxTransitionableState.skipNextTransIn = false;
						FlxTransitionableState.skipNextTransOut = false;
						PlayState.startAt = curTime;
						CustomTransition.reset();
					}
=======
					if (Settings.resumeCountdown && PlayState.instance.songStarted)
					{
						resuming = true;
						var swagCounter:Int = 0;

						forEachOfType(FlxSprite, function(spr:FlxSprite)
						{
							spr.visible = false;
						}, true);

						new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
						{
							PlayState.instance.countdownThing(swagCounter);
							swagCounter += 1;

							if (swagCounter > 4)
								close();
						}, 5);
					}
					else
						close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
					PlayState.openedCharting = false;
					Settings.botplay = false;
				case "Toggle Botplay":
					Settings.botplay = !Settings.botplay;

					@:privateAccess // shoutout to private access for being so sexy
					PlayState.instance.botPlayState.visible = PlayState.instance.scrollSpeedText.visible = Settings.botplay;
>>>>>>> upstream
			}
		}
	}

<<<<<<< HEAD
	function resume():Void
	{
		if (Settings.resumeCountdown && PlayState.instance.songStarted)
		{
			resuming = true;
			var swagCounter:Int = 0;

			forEachOfType(FlxSprite, function(spr:FlxSprite)
			{
				spr.visible = false;
			}, true);

			new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				PlayState.instance.countdownThing(swagCounter);
				swagCounter += 1;

				if (swagCounter > 4)
				{
					close();
				}
			}, 5);
		}
		else
			close();
	}

	function exitToMenu():Void
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		Conductor.changeBPM(102);
		
		if (PlayState.isStoryMode)
			CustomTransition.switchTo(new StoryMenuState());
		else
			CustomTransition.switchTo(new FreeplayState());
		
		PlayState.openedCharting = false;
		PlayState.startAt = 0;
		Settings.botplay = false;
		PlayState.seenCutscene = false;
	}

	function toggleBotplay():Void
	{
		Settings.botplay = !Settings.botplay;

		@:privateAccess // shoutout to private access for being so sexy
		{
			PlayState.instance.botPlayState.visible = PlayState.instance.scrollSpeedText.visible = Settings.botplay;
			var npsShit = (Settings.npsDisplay ? "NPS: " + PlayState.instance.nps + " (Max " + PlayState.instance.maxNPS + ") | " : "");
			PlayState.instance.scoreTxt.text = npsShit + Ratings.CalculateRanking(PlayState.songScore, PlayState.instance.songScoreDef, 
				PlayState.instance.nps, PlayState.instance.maxNPS, PlayState.accuracy);
		}

		if (PlayState.instance.iconP1.char.startsWith('bf'))
			PlayState.instance.iconP1.changeIcon((Settings.botplay ? 'bf-bot' : 'bf') + (PlayState.SONG.noteStyle == "pixel" ? "-pixel" : ""));
	}

=======
>>>>>>> upstream
	var originalOffset:Null<Float>;

	#if FILESYSTEM
	function changeOffset(huh:Float = 0)
	{
		if (originalOffset == null)
			originalOffset = PlayState.songOffset;

<<<<<<< HEAD
		var songPath = 'assets/data/' + Paths.toSongPath(PlayState.SONG.song) + '/.offset';
=======
		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase().replace(" ", "-") + '/.offset';
>>>>>>> upstream

		if (Paths.currentMod != null && FileSystem.exists(Sys.getCwd() + "mods/" + Paths.currentMod + "/" + songPath))
			songPath = Sys.getCwd() + "mods/" + Paths.currentMod + "/" + songPath;

		if (FileSystem.exists(songPath))
		{
			PlayState.songOffset += huh;
			PlayState.songOffset = FlxMath.roundDecimal(PlayState.songOffset, 2);
			File.saveContent(songPath, PlayState.songOffset + '');
			perSongOffset.text = "Song Offset: < " + PlayState.songOffset + " >\n(Hold CTRL to change!)";
			perSongOffset.setPosition(0, FlxG.height - perSongOffset.height - 15);
		}

		var oldMenuItemsLength = menuItems.length;

		if (PlayState.songOffset == originalOffset)
			menuItems = ["Resume", "Restart Song", "Exit to menu"];
		else
			menuItems = ["Restart Song", "Exit to menu"];

		if (PlayState.openedCharting)
		{
			if (PlayState.songOffset == originalOffset)
<<<<<<< HEAD
			{
				menuItems = ["Resume", "Restart Song", "Toggle Botplay", "Exit to menu"];
				
				if (PlayState.instance.songStarted)
					menuItems.insert(3, 'Skip To');
			}
=======
				menuItems = ["Resume", "Restart Song", "Toggle Botplay", "Exit to menu"];
>>>>>>> upstream
			else
				menuItems = ["Restart Song", "Toggle Botplay", "Exit to menu"];
		}

		if (oldMenuItemsLength != menuItems.length)
<<<<<<< HEAD
			generateMenu();
	}
	#end

	function generateMenu():Void
	{
		grpMenuShit.clear();
		if (skipText != null)
			skipText.destroy();
		skipToOption = null;

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.x = 25;
			songText.targetY = i;

			if (menuItems[i] == 'Skip To')
			{
				skipToOption = songText;
				
				skipText = new FlxText();
				skipText.setFormat('Funkerin Regular', 72, OUTLINE, FlxColor.BLACK);
				skipText.borderSize = 3;
				skipText.antialiasing = true;
				skipText.visible = false;
				add(skipText);
			}

			grpMenuShit.add(songText);
		}

		changeSelection();
	}
=======
		{
			grpMenuShit.clear();

			for (i in 0...menuItems.length)
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
				songText.isMenuItem = true;
				songText.x = 25;
				songText.targetY = i;
				grpMenuShit.add(songText);
			}

			changeSelection();
		}
	}
	#end
>>>>>>> upstream

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
