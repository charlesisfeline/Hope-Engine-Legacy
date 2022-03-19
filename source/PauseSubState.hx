package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;

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

	public function new()
	{
		super();

		persistentDraw = true;
		persistentUpdate = false; 

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
		
		perSongOffset = new FlxText(0, 0, FlxG.width - 20, "Song Offset: < " + PlayState.songOffset + " >\n(Hold CTRL to change!)", 12);
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
			var chartingText = new FlxText(0, 15 + 64, FlxG.width - 20, "CHARTING", 12);
			chartingText.scrollFactor.set();
			chartingText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
			chartingText.alpha = 0;

			add(chartingText);
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
	}

	var resuming:Bool = false;

	var holdTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		for (item in grpMenuShit)
			item.x = FlxMath.lerp(item.x, (item.targetY * 20) + 90, 9 / lime.app.Application.current.window.frameRate);

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
				if (holdTimer > 0.5)
				{
					if (controls.LEFT)
						changeOffset(-1 * multi);
					else if (controls.RIGHT)
						changeOffset(1 * multi);
				}
				else
					holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (controls.RESET)
				changeOffset(PlayState.songOffset * -1);
		}
		#end

		if (accepted && !resuming)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					if (Settings.resumeCountdown)
					{
						resuming = true;
						var swagCounter:Int = 0;

						forEachOfType(FlxSprite, function(spr:FlxSprite) {
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
			}
		}
	}

	var originalOffset:Null<Float>;

	#if FILESYSTEM
	function changeOffset(huh:Float = 0)
	{
		if (originalOffset == null)
			originalOffset = PlayState.songOffset;

		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase().replace(" ", "-") + '/.offset';

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

		if (oldMenuItemsLength != menuItems.length)
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