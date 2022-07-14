package;

import Alphabet.AlphaCharacter;
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

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	var scoreBG:FlxSprite;
	var modifierTextBG:FlxSprite;

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

		#if FILESYSTEM
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

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFF9271FD;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		for (i in 0...songs.length)
		{
			Paths.setCurrentMod(songs[i].mod.split('/')[1]);

			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName.replace("-", " "), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.x = -songText.width;
			grpSongs.add(songText);

			if (songText.width > FlxG.width - 360)
			{
				var origWidth:Float = songText.width;
				var newScale:Float = (FlxG.width - 360) / songText.width;
				var prevLet:FlxSprite = null;

				for (let in songText.members)
				{
					let.scale.x = newScale;
					let.updateHitbox();

					if (prevLet != null)
						let.x = prevLet.x + prevLet.width;
					else
						let.x = -origWidth;

					var char:AlphaCharacter = cast let;
					if (char.lastWasSpace)
						let.x += 40 * newScale;

					prevLet = let;
				}
			}

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

		var instTxt:FlxText = new FlxText(5, FlxG.height - 29, FlxG.width - 10, "Press SPACE to listen to the song selected. Press M for the Modifier Menu!");
		instTxt.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, RIGHT);
		add(instTxt);

		changeSelection();
		changeDiff();

		if (vocals == null)
		{
			vocals = new FlxSound();
		}

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

	var holdTime:Float = 0;
	var exiting:Bool = false;

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
				if (Modifiers.modifierScores.exists(songs[curSelected].songName))
				{
					if (Modifiers.modifierScores.get(songs[curSelected].songName).length > 0)
						openSubState(new ModifierSaveSubstate(songs[curSelected].songName));
					else
						FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
				}
				else
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
			}
			else
				openSubState(new ModifierSubstate());
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.UI_BACK)
		{
			exiting = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			vocals.fadeOut(0.5, 0);
			CustomTransition.switchTo(new MainMenuState());
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
				LoadingState.loadAndSwitchState(new PlayState());
			}
		else
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
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
	}

	var maxThing:Float = (FlxG.sound.load(Paths.sound('scrollMenu'), 0.4).length / 1000) * 0.75;

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if FILESYSTEM
		if (songs[curSelected].mod != null)
			Paths.setCurrentMod(songs[curSelected].mod.split('/')[1]);
		#end

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

		if (Modifiers.modifierScores.exists(songs[curSelected].songName))
		{
			if (Modifiers.modifierScores.get(songs[curSelected].songName).length > 0)
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
