package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;

using StringTools;
#if windows
import llua.Lua;
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
		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
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
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;
		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);
		#if cpp
		else if (leftP && !resuming)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset -= 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

			// Prevent loop from happening every single time the offset changes
			if(!offsetChanged)
			{
				grpMenuShit.clear();

				menuItems = ['Restart Song', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				offsetChanged = true;
			}
		}
		else if (rightP && !resuming)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset += 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';
			if(!offsetChanged)
			{
				grpMenuShit.clear();

				menuItems = ['Restart Song', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				offsetChanged = true;
			}
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
					var curStage:String = PlayState.SONG.stage;

					// TO DO: REMAKE THIS SHIT GOD WHAT THE FUCKKKKKKKKK
					new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
					{
						var altSuffix:String = "";
						var pixel1:String = "";

						if (PlayState.SONG.noteStyle == "pixel")
						{
							pixel1 = "pixelUI/";
							altSuffix = "-pixel";
						}
						
						switch (swagCounter)
						{
							case 0:
								FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);

								forEachOfType(FlxSprite, function(spr:FlxSprite) {
									spr.visible = false;
								}, true);
							case 1:
								var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixel1 + "ready" + altSuffix));
								ready.scrollFactor.set();
								ready.updateHitbox();

								if (PlayState.SONG.noteStyle == "pixel")
									ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

								ready.screenCenter();
								add(ready);
								FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										ready.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
							case 2:
								var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixel1 + "set" + altSuffix));
								set.scrollFactor.set();

								if (PlayState.SONG.noteStyle == "pixel")
									set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

								set.screenCenter();
								add(set);
								FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										set.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
							case 3:
								var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixel1 + "go" + altSuffix));
								go.scrollFactor.set();

								if (PlayState.SONG.noteStyle == "pixel")
									go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

								go.updateHitbox();

								go.screenCenter();
								add(go);
								FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										go.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
							case 4:
								close();
						}
						swagCounter += 1;
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
					PlayState.flashNotesLeft = 0;
					PlayState.deathNotesLeft = 0;
					#if windows
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					
					FlxG.switchState(new MainMenuState());
			}
		}
	}

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