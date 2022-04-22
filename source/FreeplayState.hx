package;

import Alphabet.AlphaCharacter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
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
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	// var metaShit:FlxText;
	var ratingText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var intendedAcc:Float = 0;
	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	var scoreBG:FlxSprite;

	override function create()
	{
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

		diffText = new FlxText(0, 0, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.x = scoreBG.x;
		diffText.y = scoreBG.y + scoreBG.height - 26;
		diffText.font = scoreText.font;

		add(diffText);
		add(scoreText);

		changeSelection();
		changeDiff();

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

	var tweensPlayed:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
			pastPosition = FlxG.sound.music.time;
		}

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		for (songLabel in grpSongs)
			songLabel.x = FlxMath.lerp(songLabel.x, (songLabel.targetY * 20) + 90, 9 / lime.app.Application.current.window.frameRate);

		if (controls.UP || controls.DOWN)
		{
			if (holdTime > Main.globalMaxHoldTime)
			{
				if (controls.UP)
					changeSelection(-1);

				if (controls.DOWN)
					changeSelection(1);
			}
			else
			{
				if (controls.UP_P)
					changeSelection(-1);

				if (controls.DOWN_P)
					changeSelection(1);
			}

			holdTime += elapsed;
		}
		else
			holdTime = 0;

		if (FlxG.keys.justPressed.V && Settings.cacheMusic)
			playMusic(false);

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		if (controls.ACCEPT)
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
		var accString = '(${FlxMath.roundDecimal(prevAcc, 2)}%)';
		FlxTween.num(prevAcc, intendedAcc, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			accString = '(${FlxMath.roundDecimal(v, 2)}%)';
		});
		FlxTween.num(prevScore, intendedScore, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			scoreText.text = "PERSONAL BEST: " + Math.floor(v) + " " + accString;
			updateScoreBox();
		});

		diffText.text = "< " + CoolUtil.difficultyFromInt(curDifficulty) + " >";
		diffText.x = scoreText.x + (scoreText.width / 2) - (diffText.width / 2);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

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
		var accString = '(${FlxMath.roundDecimal(prevAcc, 2)}%)';
		FlxTween.num(prevAcc, intendedAcc, 0.5, {ease: FlxEase.circOut}, function(v:Float)
		{
			accString = '(${FlxMath.roundDecimal(v, 2)}%)';
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

		#if PRELOAD_ALL
		if (Settings.cacheMusic)
		{
			FlxG.sound.music.stop();
			playMusic(true);
			Conductor.changeBPM(songs[curSelected].bpm);
		}
		#end

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

	var vocalsPlaying:Bool = false;
	var pastPosition:Float = 0.00;

	// VOCAL SWITCHING BULLSHIT
	function playMusic(justPlayIt:Bool = false)
	{
		if (!justPlayIt)
			vocalsPlaying = !vocalsPlaying;
		else
			pastPosition = 0.00;

		if (vocalsPlaying)
		{
			FlxG.sound.playMusic(Paths.voices(songs[curSelected].songName), 0);
			FlxG.sound.music.time = pastPosition;
		}
		else
		{
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
			FlxG.sound.music.time = pastPosition;
		}
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
