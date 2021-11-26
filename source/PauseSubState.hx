package;

import Controls.Control;
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

#if sys
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

	public static var modifierNames:Array<String> = [
		"MODIFIERS:",
		"Botplay",
		"Chaos",
		"Hidden",
		"No Miss",
		"Sicks Only",
		"Goods Only",
		"Both Sides",
		"Enemy's Side",
		"Flash Notes",
		"Death Notes",
		"Lifesteal Notes"
	];

	public function new()
	{
		super();

		persistentDraw = true;
		persistentUpdate = false; 

		if (PlayState.loadRep)
			menuItems = ['Resume', 'Exit to menu'];

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

		var modLoops:Int = 0;
		var currentMod:Int = 0;

		var modifiers:Array<Bool> = [
			true,
			FlxG.save.data.botplay,
			FlxG.save.data.chaosMode, 
			FlxG.save.data.hiddenMode, 
			FlxG.save.data.fcOnly, 
			FlxG.save.data.sicksOnly,  
			FlxG.save.data.goodsOnly,
			FlxG.save.data.bothSides,
			FlxG.save.data.enemySide,
			FlxG.save.data.flashNotes != 0,
			FlxG.save.data.deathNotes != 0,
			FlxG.save.data.lifestealNotes != 0
		];

		for (mod in modifiers)
		{
			if (mod)
			{
				modLoops++;
				var modText:FlxText = new FlxText(20, 79 + (32 * modLoops), 0, modifierNames[currentMod], 32);
				modText.scrollFactor.set();
				modText.alignment = RIGHT;
				modText.setFormat(Paths.font('vcr.ttf'), 32);
				modText.updateHitbox();
				modText.x = FlxG.width - (modText.width + 20);
				add(modText);

				modText.alpha = 0;
				FlxTween.tween(modText, {alpha: 1, y: modText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: (0.7 + (0.2 * modLoops))});
			}
			currentMod++;
		}

		if (modLoops == 1) 
		{
			var ahYes:FlxText = new FlxText(0, 143, FlxG.width - 20, "None, go activate\nsome in the\noptions menu!", 32);
			ahYes.scrollFactor.set();
			ahYes.alignment = RIGHT;
			ahYes.setFormat(Paths.font('vcr.ttf'), 32);
			ahYes.updateHitbox();
			add(ahYes);

			ahYes.alpha = 0;
			FlxTween.tween(ahYes, {alpha: 1, y: ahYes.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.1});
		}

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		
		perSongOffset = new FlxText(5, FlxG.height - 5, FlxG.width - 10, "Song Offset: " + PlayState.songOffset + "\n(SHIFT + LEFT or RIGHT to change)", 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		perSongOffset.setPosition(5, FlxG.height - perSongOffset.height - 5);
		
		#if cpp
		add(perSongOffset);
		#end

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
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		#if cpp
		if (FlxG.keys.pressed.SHIFT)
		{
			if (controls.LEFT_P)
				changeOffset(-1);
			else if (controls.RIGHT_P)
				changeOffset(1);
		}
		#end

		if (accepted && !resuming)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
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

				case "Restart Song":
					FlxG.resetState();
					
				case "Exit to menu":
					if(PlayState.loadRep)
					{
						FlxG.save.data.botplay = false;
						FlxG.save.data.scrollSpeed = 1;
						FlxG.save.data.downscroll = false;
					}
					PlayState.loadRep = false;
					
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					
					FlxG.switchState(new MainMenuState());
			}
		}
	}

	var originalOffset:Null<Float>;

	#if sys
	function changeOffset(huh:Float = 0)
	{
		if (originalOffset == null)
			originalOffset = PlayState.songOffset;

		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase().replace(" ", "-") + '/.offset';

		if (Paths.currentMod != null && FileSystem.exists(Sys.getCwd() + "mods/" + Paths.currentMod + "/" + songPath))
			songPath = Sys.getCwd() + "mods/" + Paths.currentMod + "/" + songPath;

		if(FileSystem.exists(songPath))
		{
			PlayState.songOffset += huh;
			File.saveContent(songPath, PlayState.songOffset + '');
			perSongOffset.text = "Song Offset: " + PlayState.songOffset + "\n(SHIFT + LEFT or RIGHT to change)";
			perSongOffset.setPosition(5, FlxG.height - perSongOffset.height - 5);
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
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}