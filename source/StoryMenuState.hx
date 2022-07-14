package;


import editors.WeekEditor.Week;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames.TexturePackerObject;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.utils.Assets;

using StringTools;

#if FILESYSTEM
import editors.WeekEditor.Week;
import sys.FileSystem;
import sys.io.File;
#end
#if desktop
import Discord.DiscordClient;
#end

class StoryMenuState extends MusicBeatState
{
	static var curWeek:Int = 0;
	static var curDifficulty:Int = 1;

	var scoreText:FlxText;

	public static var weekUnlocked:Array<Bool> = [];

	var weekData:Array<Dynamic> = [];
	var weekCharacters:Array<Dynamic> = [];
	var weekNames:Array<String> = [];

	var weekMods:Array<String> = [];
	var weekJsonNames:Array<String> = [];

	var weekDifficultyLock:Array<Null<String>> = [];

	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;
	var yellowBG:FlxSprite;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		if (Paths.priorityMod != "hopeEngine")
		{
			if (Paths.exists(Paths.state("StoryMenuState")))
			{
				Paths.setCurrentMod(Paths.priorityMod);
				FlxG.switchState(new CustomState("StoryMenuState", STORYMENU));
				return;
			}
		}

		if (Paths.priorityMod == "hopeEngine")
			Paths.setCurrentMod(null);
		else
			Paths.setCurrentMod(Paths.priorityMod);

		#if desktop
		DiscordClient.changePresence("Story Menu");
		#end

		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		weekUnlocked = FlxG.save.data.weeksUnlocked == null ? [] : FlxG.save.data.weeksUnlocked;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}
		}

		for (i in CoolUtil.coolTextFile("assets/_weeks/_weekList.txt"))
		{
			#if FILESYSTEM
			var path = Sys.getCwd() + "assets/_weeks/" + i + ".json";
			var week:Week = cast Json.parse(File.getContent(path));
			#else
			var path = "assets/_weeks/" + i + ".json";
			var week:Week = cast Json.parse(Assets.getText(path));
			#end

			weekData.push(week.tracks);
			weekNames.push(week.weekName);
			weekCharacters.push(week.characters);
			weekJsonNames.push(i);
			weekMods.push(null);
			weekDifficultyLock.push(week.difficultyLock);
		}

		#if FILESYSTEM
		for (i in FileSystem.readDirectory(Sys.getCwd() + 'mods'))
		{
			if (FileSystem.exists(Sys.getCwd() + "mods/" + i + "/assets/_weeks/_weekList.txt") && Paths.checkModLoad(i))
			{
				var content = File.getContent(Sys.getCwd() + "mods/" + i + "/assets/_weeks/_weekList.txt");

				if (content.trim().length > 0)
				{
					for (jsonName in CoolUtil.coolStringFile(content))
					{
						var path = Sys.getCwd() + "mods/" + i + "/assets/_weeks/" + jsonName + ".json";
						var week:Week = cast Json.parse(File.getContent(path));
	
						weekData.push(week.tracks);
						weekNames.push(week.weekName);
						weekCharacters.push(week.characters);
						weekJsonNames.push(jsonName);
						weekMods.push(i);
						weekDifficultyLock.push(week.difficultyLock);
					}
				}
			}
		}
		#end

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var prevMod = Paths.currentMod;

		for (i in 0...weekData.length)
		{
			Paths.setCurrentMod(weekMods[i]);

			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekJsonNames[i]);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			#if UNLOCK_ALL_WEEKS
			weekUnlocked.insert(i, true);
			#end

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		Paths.setCurrentMod(prevMod);

		grpWeekCharacters.add(new MenuCharacter(0, 0, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(0, 0, 0.5, true));
		grpWeekCharacters.add(new MenuCharacter(0, 0, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.antialiasing = true;
		leftArrow.animation.addByPrefix('idle', "arrow menu left0000");
		leftArrow.animation.addByPrefix('press', "arrow menu left0001");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + leftArrow.width, leftArrow.y);
		sprDifficulty.antialiasing = true;

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(0, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.antialiasing = true;
		rightArrow.animation.addByPrefix('idle', 'arrow menu right0000');
		rightArrow.animation.addByPrefix('press', "arrow menu right0001");
		rightArrow.animation.play('idle');
		rightArrow.x = FlxG.width - rightArrow.width - 10;
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		// hi psych engine
		var tracksText:Alphabet = new Alphabet(0, 0, "TRACKS", false);
		tracksText.color = 0xFFe55777;
		tracksText.x = FlxG.width * 0.055;
		tracksText.y = txtTracklist.y;
		add(tracksText);

		changeDifficulty();
		changeWeek();
		updateText();

		super.create();
	}

	override function beatHit()
	{
		grpWeekCharacters.forEachOfType(MenuCharacter, function(char:MenuCharacter)
		{
			if (char.animation.getByName("danceLeft") != null)
			{
				char.danced = !char.danced;

				if (!char.animation.curAnim.name.startsWith("hey"))
					char.animation.play("dance" + (char.danced ? "Right" : "Left"));
			}
			else if (char.animation.getByName("idle") != null)
			{
				if (!char.animation.curAnim.name.startsWith("hey"))
					char.animation.play('idle', true);
			}
		});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UI_UP_P)
					changeWeek(-1);

				if (controls.UI_DOWN_P)
					changeWeek(1);

				if (controls.UI_RIGHT)
					rightArrow.animation.play('press');
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P && weekDifficultyLock[curWeek] == null)
					changeDifficulty(1);
				if (controls.UI_LEFT_P && weekDifficultyLock[curWeek] == null)
					changeDifficulty(-1);

				if (weekDifficultyLock[curWeek] != null)
				{
					leftArrow.visible = false;
					rightArrow.visible = false;
				}
				else
				{
					leftArrow.visible = true;
					rightArrow.visible = true;
				}
			}

			if (controls.UI_ACCEPT)
				selectWeek();
		}

		if (controls.UI_BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			CustomTransition.switchTo(new MainMenuState());
		}

		#if FILESYSTEM
		if (FlxG.keys.justPressed.SEVEN && !movedBack && !selectedWeek)
		{
			movedBack = true;
			CustomTransition.switchTo(new editors.WeekEditor());
		}
		#end

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			Paths.setCurrentMod(weekMods[curWeek]);

			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();

				if (grpWeekCharacters.members[0].animation.getByName("hey") != null)
					grpWeekCharacters.members[0].animation.play("hey");

				if (grpWeekCharacters.members[1].animation.getByName("hey") != null)
					grpWeekCharacters.members[1].animation.play("hey");

				if (grpWeekCharacters.members[2].animation.getByName("hey") != null)
					grpWeekCharacters.members[2].animation.play("hey");

				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.weekName = weekNames[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.difficultySuffixfromInt(curDifficulty);

			PlayState.storyDifficulty = curDifficulty;
			var lma = StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase();
			PlayState.SONG = Song.loadFromJson(lma + diffic, lma, (Paths.currentMod != null
				&& Paths.currentMod.length > 0 ? "mods/" + Paths.currentMod : ""));
			PlayState.EVENTS = Event.load(lma, (Paths.currentMod != null
				&& Paths.currentMod.length > 0 ? "mods/" + Paths.currentMod : ""));
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	var intendedScore:Int = 0;

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyArray.length - 1;
		if (curDifficulty > CoolUtil.difficultyArray.length - 1)
			curDifficulty = 0;

		var previousMod = Paths.currentMod;
		Paths.setCurrentMod(CoolUtil.difficultyArray[curDifficulty][2]);

		sprDifficulty.alpha = 0;
		sprDifficulty.loadGraphic(Paths.image("difficulties/" + CoolUtil.difficultyFromInt(curDifficulty)));
		sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.93));
		sprDifficulty.updateHitbox();
		// some long fuckin equation idk mate
		sprDifficulty.x = leftArrow.x + leftArrow.width + ((rightArrow.x - (leftArrow.x + leftArrow.width)) / 2) - (sprDifficulty.width / 2);
		sprDifficulty.y = leftArrow.y + (leftArrow.height / 2) - (sprDifficulty.height / 2) - 15;
		FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 15, alpha: 1}, 0.07);

		Paths.setCurrentMod(previousMod);

		var prevScore = intendedScore;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		FlxTween.num(prevScore, intendedScore, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			scoreText.text = "WEEK SCORE:" + Math.floor(v);
		});
	}

	function changeWeek(change:Int = 0):Void
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		Paths.setCurrentMod(weekMods[curWeek]);

		if (weekDifficultyLock[curWeek] != null)
		{
			curDifficulty = CoolUtil.difficultyIntFromString(weekDifficultyLock[curWeek]);
			changeDifficulty();
		}

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		var prevScore = intendedScore;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		FlxTween.num(prevScore, intendedScore, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			scoreText.text = "WEEK SCORE:" + Math.floor(v);
		});

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		grpWeekCharacters.members[0].y = yellowBG.y + yellowBG.height - grpWeekCharacters.members[0].height - 15;
		grpWeekCharacters.members[1].y = yellowBG.y + yellowBG.height - grpWeekCharacters.members[1].height - 30;
		grpWeekCharacters.members[2].y = yellowBG.y + yellowBG.height - grpWeekCharacters.members[2].height - 15;

		grpWeekCharacters.members[1].screenCenter(X);
		grpWeekCharacters.members[0].x = grpWeekCharacters.members[1].x - grpWeekCharacters.members[0].width - 5;
		grpWeekCharacters.members[2].x = grpWeekCharacters.members[1].x + grpWeekCharacters.members[1].width + 5;

		txtTracklist.text = "\n\n";
		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";
	}
}
