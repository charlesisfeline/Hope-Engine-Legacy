package;

import flixel.util.FlxSort;
import ui.InputTextFix;
import AlphabetRedux;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import modifiers.ModifierSaveSubstate;
import modifiers.ModifierSubstate;
import modifiers.Modifiers;
import openfl.utils.Assets;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
#if desktop
import Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	// difficulty checking stuff
	var registeredSongs:Array<String> = [];

	var selector:FlxText;
	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var modifierText:FlxText;
	// var metaShit:FlxText;
	var ratingText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var intendedAcc:Float = 0;
	var bg:FlxSprite;

	public static var vocals:FlxSound;

	private var grpSongs:FlxTypedGroup<AlphaReduxLine>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	var scoreBG:FlxSprite;
	var modifierTextBG:FlxSprite;

	var cachedSongsList:Array<SongMetadata> = [];

	var searchGroup:FlxSpriteGroup;
	var searchIconBG:FlxSprite;
	var searchIcon:FlxSprite;
	var searchModInput:InputTextFix;
	var inst:FlxText;

	var sortIcon:FlxSprite;
	var sortDisplay:FlxText;

	var curSortType:Int = 0;
	var sortTypes:Array<String> = [
		"No Sort",
		"A to Z",
		"Z to A",
		"Ascending (Score)",
		"Descending (Score)",
		"Ascending (Acc)",
		"Descending (Acc)"
	];

	override function create()
	{
		if (Paths.priorityMod != "hopeEngine")
		{
			if (Paths.exists(Paths.state("FreeplayState")))
			{
				Paths.setCurrentMod(Paths.priorityMod);
				FlxG.switchState(new CustomState("FreeplayState", FREEPLAY));
				return;
			}
		}

		if (Paths.priorityMod == "hopeEngine")
			Paths.setCurrentMod(null);
		else
			Paths.setCurrentMod(Paths.priorityMod);

		#if desktop
		DiscordClient.changePresence("Freeplay Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		Paths.setCurrentMod(null);

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			
			// just to be sure :)
			for (s in data)
				s.trim();

			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1], Std.parseFloat(data[3]), data[4]));
		}

		#if (FILESYSTEM && MODS_FEATURE)
		for (i in FileSystem.readDirectory(Sys.getCwd() + 'mods'))
		{
			Paths.setCurrentMod(i);
			var frepla = Paths.txt('freeplaySonglist');

			if (FileSystem.exists(frepla) && Paths.checkModLoad(i))
			{
				var songlist = CoolUtil.coolStringFile(File.getContent(frepla));

				for (i2 in 0...songlist.length)
				{
					var data:Array<String> = songlist[i2].split(':');

					for (s in data)
						s.trim();

					songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1], Std.parseFloat(data[3]), data[4], i));
				}
			}
		}

		Paths.setCurrentMod(null);
		#end

		var list = songs.copy();
		for (i in list)
			cachedSongsList.push(i);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFF9271FD;
		add(bg);

		grpSongs = new FlxTypedGroup<AlphaReduxLine>();
		add(grpSongs);

		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		for (i in 0...songs.length)
		{
			Paths.setCurrentMod(songs[i].mod.split('/')[1]);

			var songText:AlphaReduxLine = new AlphaReduxLine(0, (70 * i) + 30, songs[i].songName.toUpperCase(), true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > FlxG.width - 360)
				songText.setGraphicSize(FlxG.width - 360);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			grpIcons.add(icon);
		}

		Paths.setCurrentMod(null);

		scoreBG = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 0.4), 76, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.x = FlxG.width * 0.6;
		add(scoreBG);

		scoreText = new FlxText(0, 0, 0, "", 48);
		scoreText.x = scoreBG.x + 2;
		scoreText.y = 2;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		add(scoreText);

		diffText = new FlxText(0, 0, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.x = scoreBG.x;
		diffText.y = scoreBG.y + scoreBG.height - 26;
		diffText.font = scoreText.font;
		add(diffText);

		modifierTextBG = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 0.4), 76, 0xFF000000);
		modifierTextBG.alpha = 0.6;
		add(modifierTextBG);

		modifierText = new FlxText(0, 0, 0, "Press SHIFT and M to\nsee Modifier Scores.", 24);
		modifierText.alignment = CENTER;
		modifierText.font = scoreText.font;
		add(modifierText);

		var instBG:FlxSprite = new FlxSprite(0, FlxG.height - 34).makeGraphic(FlxG.width, 36, FlxColor.BLACK);
		instBG.alpha = 0.6;
		add(instBG);

		var instTxt:FlxText = new FlxText(5, FlxG.height - 29, FlxG.width - 10, "Press SPACE to listen to the song selected. Press M for the Modifier Menu. Press CTRL+F to open search!");
		instTxt.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, RIGHT);
		add(instTxt);

		searchGroup = new FlxSpriteGroup();

		searchIconBG = new FlxSprite(0, 16).makeGraphic(64, 64, 0xFF000000);
		searchIconBG.alpha = 0.6;

		searchIcon = new FlxSprite();
		searchIcon.frames = Paths.getSparrowAtlas(FlxG.random.bool(1) ? "search_glass_watson" : "search_glass");
		searchIcon.animation.addByPrefix("a", "", 24);
		searchIcon.animation.play("a");
		searchIcon.setGraphicSize(0, 54);
		searchIcon.updateHitbox();
		searchIcon.antialiasing = true;
		searchIcon.x = (searchIconBG.width / 2) - (searchIcon.width / 2);
		searchIcon.y = searchIconBG.y + 5;

		var searchBG = new FlxSprite(64, 0).makeGraphic(256, 80, 0xFF000000);
		searchBG.alpha = 0.6;

		var searchInputBG = new FlxSprite(64, 0).makeGraphic(10, 10, 0xFF000000);
		searchInputBG.alpha = 0.3;

		inst = new FlxText(searchBG.x + 10, searchBG.y + 10, "Click to input text...");
		inst.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, NONE);
		inst.alpha = 0.5;
		inst.offset.y = -2;

		searchModInput = new InputTextFix(searchBG.x + 10, searchBG.y + 10, Std.int(searchBG.width - 20), "", 16, FlxColor.WHITE);
		searchModInput.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, NONE);
		searchModInput.caretColor = FlxColor.WHITE;
		searchModInput.fieldBorderColor = FlxColor.TRANSPARENT;
		searchModInput.offset.y = -2;
		searchModInput.callback = updateSearch;
		@:privateAccess
		searchModInput.backgroundSprite.alpha = 0;

		searchInputBG.setGraphicSize(Std.int(searchBG.width - 18), 24);
		searchInputBG.updateHitbox();
		searchInputBG.setPosition(searchBG.x + 9, searchBG.y + 9);

		sortIcon = new FlxSprite();
		sortIcon.frames = Paths.getSparrowAtlas("sort_display");
		for (i in 0...sortTypes.length)
			sortIcon.animation.addByPrefix(i + "", sortTypes[i], 24);
		sortIcon.animation.play(curSortType + "", true);
		sortIcon.width = 32;
		sortIcon.height = 32;
		sortIcon.centerOffsets();

		sortIcon.x = 74;
		sortIcon.y = searchBG.height - sortIcon.height - 10;

		sortDisplay = new FlxText(sortTypes[curSortType]);
		sortDisplay.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		sortDisplay.borderSize = 2;
		sortDisplay.x = sortIcon.x + sortIcon.width + 5;
		sortDisplay.y = sortIcon.y + (sortIcon.height / 2) - (sortDisplay.height / 2);

		searchGroup.add(searchIconBG);
		searchGroup.add(searchIcon);
		searchGroup.add(searchBG);
		searchGroup.add(searchInputBG);
		searchGroup.add(searchModInput);
		searchGroup.add(inst);
		searchGroup.add(sortIcon);
		searchGroup.add(sortDisplay);

		sortIcon.antialiasing = true;
		
		searchGroup.x = FlxG.width - 64;
		searchGroup.y = instBG.y - searchGroup.height;
		add(searchGroup);

		changeSelection();
		changeDiff();

		if (vocals == null)
			vocals = new FlxSound();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		// selector = new FlxText();

		// selector.size = 40;
		// selector.text = ">";
		// add(selector);

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	var searchResults:Array<SongMetadata> = [];

	// FOR SEARCH FUNCTION
	function updateSearch(_, _):Void
	{
		searchResults.splice(0, searchResults.length);

		if (searchModInput.text.length < 1)
		{
			inst.visible = true;
			searchResults = cachedSongsList.copy();
			changeSort();
			return;
		}
		else
			inst.visible = false;

		var modsAllowed:Array<String> = [];
		var modregex:EReg = ~/mod:[a-zA-Z\-]+[^\\\/:*?"<>|]/g;

		var weeksAllowed:Array<Int> = [];
		var weekregex:EReg = ~/week:[0-9]+/g;

		for (mod in Helper.getERegMatches(modregex, searchModInput.text.trim(), true))
			modsAllowed.push(mod.split(":")[1].trim());

		for (week in Helper.getERegMatches(weekregex, searchModInput.text.trim(), true))
			weeksAllowed.push(Std.parseInt(week.split(":")[1].trim()));

		for (song in cachedSongsList.copy())
		{
			var search = searchModInput.text.trim().toLowerCase();
			var songName = song.songName.toLowerCase().trim();

			search = modregex.replace(search, "").trim();
			search = weekregex.replace(search, "").trim();

			if (songName.startsWith(search))
			{
				// know a better way? do tell!
				if (modsAllowed.length > 0 || weeksAllowed.length > 0)
				{
					if (modsAllowed.contains(song.mod.split("/")[1].trim()) ||
						weeksAllowed.contains(song.week))
						searchResults.push(song);
				}
				else
					searchResults.push(song);
			}
		}

		var matches = [];
		if (searchResults.length > 0)
		{
			for (i in 0...searchResults.length)
				matches.push(searchResults[i] == cachedSongsList[i]);
		}

		if (matches.length != cachedSongsList.length && matches.contains(false))
			changeSort();
	}

	var holdTime:Float = 0;
	var exiting:Bool = false;

	var searchExtended:Bool = false;
	var searchExtending:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.7 && !switching)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (vocals.volume < 0.7 * FlxG.sound.volume && !exiting && !switching)
			vocals.volume += 0.5 * FlxG.elapsed;
		else
		{
			if (!exiting)
				vocals.volume = 0.7 * FlxG.sound.volume * 2;
		}

		for (songLabel in grpSongs)
			songLabel.x = FlxMath.lerp(songLabel.x, (songLabel.targetY * 20) + 90, Helper.boundTo(elapsed * 9.6, 0, 1));

		if (!InputTextFix.isTyping)
		{
			if (controls.UI_UP || controls.UI_DOWN)
			{
				if (holdTime > maxThing)
				{
					if (controls.UI_UP)
						changeSelection(-1);
	
					if (controls.UI_DOWN)
						changeSelection(1);
	
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	
					holdTime = 0;
				}
				else
				{
					if (controls.UI_UP_P)
					{
						changeSelection(-1);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					}
	
					if (controls.UI_DOWN_P)
					{
						changeSelection(1);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					}
				}
	
				holdTime += elapsed;
			}
			else
				holdTime = 0;
	
			if (FlxG.keys.justPressed.M)
			{
				persistentUpdate = false;
				persistentDraw = true;
	
				if (FlxG.keys.pressed.SHIFT)
				{
					if (Modifiers.modifierScores.exists(Paths.currentMod + ":" + songs[curSelected].songName))
					{
						if (Modifiers.modifierScores.get(Paths.currentMod + ":" + songs[curSelected].songName).length > 0)
							openSubState(new ModifierSaveSubstate(Paths.currentMod + ":" + songs[curSelected].songName));
						else
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
					}
					else
						FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
				}
				else
					openSubState(new ModifierSubstate());
			}
	
			if (!FlxG.keys.pressed.SHIFT)
			{
				if (controls.UI_LEFT_P)
					changeDiff(-1);
				if (controls.UI_RIGHT_P)
					changeDiff(1);
			}
			else
			{
				if (controls.UI_LEFT_P)
					changeSort(-1);
				if (controls.UI_RIGHT_P)
					changeSort(1);
			}
	
			if (controls.UI_BACK)
			{
				exiting = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				vocals.fadeOut(0.5, 0);
				CustomTransition.switchTo(new MainMenuState());
				FlxG.mouse.visible = false;
			}

			if (FlxG.keys.justPressed.SPACE)
				playMusic();
	
			if (controls.UI_ACCEPT && !FlxG.keys.justPressed.SPACE)
			{
				var mod = (songs[curSelected].mod != null ? songs[curSelected].mod : "");
				var songLowercase = songs[curSelected].songName.replace(" ", "-").toLowerCase();
				var poop:String = songLowercase + CoolUtil.difficultySuffixfromInt(curDifficulty);
				var songPath = mod + (songs[curSelected].mod != null ? "/" : "") + 'assets/data/' + songLowercase + '/' + poop + ".json";
	
				#if FILESYSTEM
				if (FileSystem.exists(Sys.getCwd() + songPath))
				#else
				if (Assets.exists('assets/data/' + songLowercase + '/' + poop + ".json")) // crap fix i know shut UP
				#end
				{
					PlayState.SONG = Song.loadFromJson(poop, songLowercase, mod);
					PlayState.EVENTS = Event.load(songLowercase, mod);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
					PlayState.storyWeek = songs[curSelected].week;
					PlayState.resetWeekStats();
	
					if (FlxG.keys.pressed.CONTROL)
					{
						LoadingState.loadAndSwitchState(new editors.ChartingState());
						PlayState.openedCharting = true;
					}
					else
						LoadingState.loadAndSwitchState(new PlayState());

					FlxG.mouse.visible = false;
				}
				else
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
			}

			if (FlxG.mouse.justPressed && FlxG.mouse.visible)
			{
				if (FlxG.mouse.overlaps(searchIconBG))
					extendSearch();
				else if (FlxG.mouse.overlaps(sortIcon))
					changeSort(1);
			}

			if (FlxG.keys.justPressed.F)
			{
				if (FlxG.keys.pressed.CONTROL)
					extendSearch();
			}

			if (FlxG.mouse.justPressedRight && FlxG.mouse.visible)
			{
				if (FlxG.mouse.overlaps(sortIcon))
					changeSort(-1);
			}
	
			if (FlxG.mouse.wheel != 0 && FlxG.mouse.visible)
				changeSelection(-FlxG.mouse.wheel);
		}
	}

	function extendSearch():Void
	{
		if (!searchExtending)
		{
			searchExtending = true;

			if (searchExtended)
			{
				FlxTween.tween(searchGroup, {x: FlxG.width - 64}, 0.3, {
					onComplete: function(_) {
						searchExtending = false;
						searchExtended = false;
						FlxG.mouse.visible = false;
					}
				});
			}
			else
			{
				FlxTween.tween(searchGroup, {x: FlxG.width - searchGroup.width}, 0.3, {
					onComplete: function(_) {
						searchExtending = false;
						searchExtended = true;
						FlxG.mouse.visible = true;
					}
				});
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyArray.length - 1;
		if (curDifficulty > CoolUtil.difficultyArray.length - 1)
			curDifficulty = 0;

		if (songs.length < 1)
			return;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		var prevScore = intendedScore;
		var prevAcc = intendedAcc;
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		intendedAcc = Highscore.getAccuracy(songHighscore, curDifficulty);
		var accString = '(${Helper.completePercent(prevAcc, 2)}%)';
		FlxTween.num(prevAcc, intendedAcc, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			accString = '(${Helper.completePercent(v, 2)}%)';
		});
		FlxTween.num(prevScore, intendedScore, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			scoreText.text = "PERSONAL BEST: " + Math.floor(v) + " " + accString;
			updateScoreBox();
		});

		diffText.text = "< " + CoolUtil.difficultyFromInt(curDifficulty) + " >";
		diffText.x = scoreText.x + (scoreText.width / 2) - (diffText.width / 2);

		if (curSortType != 0 && change != 0)
			changeSort();
	}

	var maxThing:Float = (FlxG.sound.load(Paths.sound('scrollMenu'), 0.4).length / 1000) * 0.5;

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs.length < 1)
			return;

		#if FILESYSTEM
		if (songs[curSelected].mod != "")
			Paths.setCurrentMod(songs[curSelected].mod.split('/')[1]);
		else
		#end
			Paths.setCurrentMod(null);

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		var prevScore = intendedScore;
		var prevAcc = intendedAcc;
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		intendedAcc = Highscore.getAccuracy(songHighscore, curDifficulty);
		var accString = '(${Helper.completePercent(prevAcc, 2)}%)';
		FlxTween.num(prevAcc, intendedAcc, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			accString = '(${Helper.completePercent(v, 2)}%)';
		});
		FlxTween.num(prevScore, intendedScore, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			scoreText.text = "PERSONAL BEST: " + Math.floor(v) + " " + accString;
			updateScoreBox();
		});

		if (Settings.flashing)
		{
			FlxTween.cancelTweensOf(bg, ["color"]);
			FlxTween.color(bg, 0.5, bg.color, songs[curSelected].color);
		}

		modifierTextBG.visible = modifierText.visible = false;

		if (Modifiers.modifierScores.exists(Paths.currentMod + ":" + songs[curSelected].songName))
		{
			if (Modifiers.modifierScores.get(Paths.currentMod + ":" + songs[curSelected].songName).length > 0)
				modifierTextBG.visible = modifierText.visible = true;
		}

		var bullShit:Int = 0;

		for (i in 0...grpSongs.members.length)
		{
			var item = grpSongs.members[i];
			var icon = grpIcons.members[i];

			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = icon.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = icon.alpha = 1;
		}
	}

	var switching:Bool = false;

	function playMusic():Void
	{
		switching = true;

		var song = songs[curSelected].songName.replace(" ", "-").toLowerCase();
		var bpm = songs[curSelected].bpm;

		FlxG.sound.music.fadeOut(0.25, 0, function(twn:FlxTween)
		{
			Conductor.changeBPM(bpm);

			FlxG.sound.playMusic(Paths.inst(song));
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.fadeIn(0.25, 0, 0.7, function(twn:FlxTween)
			{
				switching = false;
			});
			vocals.loadEmbedded(Paths.voices(song), true);
			vocals.volume = 0;
			vocals.fadeIn(0.25, 0, 0.7);
		});
		vocals.fadeOut(0.25, 0);

		resyncVocals();
	}

	function updateScoreBox():Void
	{
		scoreText.setPosition(FlxG.width - scoreText.width - 5, 5);
		diffText.setPosition(scoreText.x + (scoreText.width / 2) - (diffText.width / 2), scoreText.y + scoreText.height + 5);

		var biggerObject = (scoreText.width > diffText.width ? scoreText : diffText);

		if (biggerObject == scoreText)
		{
			scoreText.setPosition(FlxG.width - scoreText.width - 5, 5);
			diffText.setPosition(scoreText.x + (scoreText.width / 2) - (diffText.width / 2), scoreText.y + scoreText.height + 5);
		}
		else if (biggerObject == diffText)
		{
			diffText.setPosition(FlxG.width - diffText.width - 5, scoreText.y + scoreText.height + 5);
			scoreText.setPosition(diffText.x + (diffText.width / 2) - (scoreText.width / 2), 5);
		}

		scoreBG.setGraphicSize(Std.int(biggerObject.width) + 10, Std.int(scoreText.height + diffText.height) + 15);
		scoreBG.updateHitbox();

		scoreBG.setPosition(biggerObject.x - 5, scoreText.y - 5);

		modifierTextBG.setGraphicSize(Std.int(scoreBG.width), Std.int(modifierText.height + 10));
		modifierTextBG.updateHitbox();
		modifierTextBG.x = scoreBG.x;
		modifierTextBG.y = scoreBG.y + scoreBG.height;

		modifierText.fieldWidth = modifierTextBG.width - 10;
		modifierText.setPosition(modifierTextBG.x + 5, modifierTextBG.y + 5);
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	// SORTING SHIT

	function changeSort(?huh:Int = 0)
	{
		curSortType += huh;

		if (curSortType > sortTypes.length - 1)
			curSortType = 0;
		if (curSortType < 0)
			curSortType = sortTypes.length - 1;

		sortIcon.animation.play(curSortType + "", true);
		sortIcon.centerOffsets();

		sortDisplay.text = sortTypes[curSortType];

		grpSongs.clear();
		grpIcons.clear();
		songs.splice(0, songs.length);

		if (searchResults.length > 0)
		{
			for (song in searchResults.copy())
				songs.push(song);
		}
		else
		{
			for (song in cachedSongsList.copy())
				songs.push(song);
		}

		songs.sort(sortSongs);

		for (i in 0...songs.length)
		{
			Paths.setCurrentMod(songs[i].mod.split('/')[1]);

			var songText:AlphaReduxLine = new AlphaReduxLine(0, (70 * i) + 30, songs[i].songName.toUpperCase(), true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > FlxG.width - 360)
				songText.setGraphicSize(FlxG.width - 360);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			grpIcons.add(icon);
		}

		Paths.setCurrentMod(null);

		changeSelection();
		changeDiff();
	}

	function sortSongs(a:SongMetadata, b:SongMetadata)
	{
		var prevMod = Paths.currentMod;
		if (a.mod != "")
			Paths.setCurrentMod(a.mod.split("/")[1]);
		else
			Paths.setCurrentMod(null);

		var aName = a.songName.replace(" ", "-");
		var score1:Int = Highscore.getScore(aName, curDifficulty);
		var acc1:Float = Highscore.getAccuracy(aName, curDifficulty);
		var name1:String = a.songName.replace(" ", "-").toUpperCase().trim();

		if (b.mod != "")
			Paths.setCurrentMod(b.mod.split("/")[1]);
		else
			Paths.setCurrentMod(null);

		var bName = b.songName.replace(" ", "-");
		var score2:Int = Highscore.getScore(bName, curDifficulty);
		var acc2:Float = Highscore.getAccuracy(bName, curDifficulty);
		var name2:String = b.songName.replace(" ", "-").toUpperCase().trim();

		Paths.setCurrentMod(prevMod);

		switch (curSortType)
		{
			case 1:
				if (name1 < name2)
					return -1;
				else if (name1 > name2)
					return 1;
				else
					return 0;
			case 2:
				if (name1 > name2)
					return -1;
				else if (name1 < name2)
					return 1;
				else
					return 0;
			case 3:
				return FlxSort.byValues(FlxSort.ASCENDING, score1, score2);
			case 4:
				return FlxSort.byValues(FlxSort.DESCENDING, score1, score2);
			case 5:
				return FlxSort.byValues(FlxSort.ASCENDING, acc1, acc2);
			case 6:
				return FlxSort.byValues(FlxSort.DESCENDING, acc1, acc2);
			default:
				return 0;
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 20
			|| Math.abs(vocals.time - Conductor.songPosition) > 20
			|| Math.abs(FlxG.sound.music.time - vocals.time) > 20)
			resyncVocals();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var bpm:Float = 0;
	public var mod:String = "";
	public var color:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, bpm:Float, color:String, ?mod:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.bpm = bpm;
		this.color = FlxColor.fromString("#" + color);

		if (mod != null)
			this.mod = "mods/" + mod;
	}
}
