package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class LoadReplayState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

    var songs:Array<FreeplayState.SongMetadata> = [];

	var controlsStrings:Array<String> = [];
    var actualNames:Array<String> = [];

	var grpControls:FlxTypedGroup<Alphabet>;
	var grpInfo:FlxTypedGroup<FlxText>;
	var grpDiff:FlxTypedGroup<Alphabet>;
	
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        #if sys
		controlsStrings = FileSystem.readDirectory(Sys.getCwd() + "/assets/replays/");
        #end

        controlsStrings.sort(Reflect.compare);


        for(i in 0...controlsStrings.length)
        {
            var string:String = controlsStrings[i];
            actualNames[i] = string;
            controlsStrings[i] = string.split("-")[0] + " ";
        }

        if (controlsStrings.length == 0)
            controlsStrings.push("No Replays...");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		grpDiff = new FlxTypedGroup<Alphabet>();
		add(grpDiff);

		grpInfo = new FlxTypedGroup<FlxText>();
		add(grpInfo);

		if (actualNames.length > 0)
		{
			for (i in 0...controlsStrings.length)
			{
				var rep:Replay = Replay.LoadReplay(actualNames[i]);
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, StringTools.replace(rep.replay.properties.get("name"), "-", " "), true);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
	
				var diffBullshit:Alphabet = new Alphabet(0, 0, CoolUtil.difficultyFromInt(rep.replay.properties.get("difficulty")), false);
	
				switch (diffBullshit.text.toLowerCase())
				{
					case "easy":
						diffBullshit.color = 0xFF00FF00;
					case "normal":
						diffBullshit.color = 0xFFFFFF00;
					case "hard":
						diffBullshit.color = 0xFFFF0000;
					default:
						diffBullshit.color = 0xFF000000;
				}
	
				grpDiff.add(diffBullshit);
	
				var controlInfoBullshit:FlxText = new FlxText(0, (70 * 1), 0, "");
				controlInfoBullshit.setFormat(null, 24, FlxColor.WHITE, LEFT, OUTLINE, 0xFF000000);
				controlInfoBullshit.borderSize = 3;
				controlInfoBullshit.text = "Date Created: " + rep.replay.properties.get("timestamp") + " - Replay Version: " + Replay.version + (rep.replay.properties.get("version") != Replay.version ? " (Outdated)" : " (Latest)");
	
				grpInfo.add(controlInfoBullshit);
			}
		}
		else
		{
			var controlLabel:Alphabet = new Alphabet(0, 0, "No Replays...", true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = 0;
			grpControls.add(controlLabel);
		}
		

		var deleteBullshit:FlxText = new FlxText(0, 0, 0, "DEL to delete selected replay\nCTRL+DEL to delete all replays.\nReplay Version " + Replay.version);
		deleteBullshit.setFormat(null, 24, FlxColor.WHITE, RIGHT, OUTLINE, 0xFF000000);
		deleteBullshit.borderSize = 3;
		deleteBullshit.setPosition(FlxG.width - deleteBullshit.width - 10, FlxG.height - deleteBullshit.height - 10);
		add(deleteBullshit);

		changeSelection(0);

		super.create();
	}

    public function getWeekNumbFromSong(songName:String):Int
    {
        var week:Int = 0;
        for (i in 0...songs.length)
        {
            var pog:FreeplayState.SongMetadata = songs[i];
            if (pog.songName.toLowerCase() == songName)
                week = pog.week;
        }
        return week;
    }

	public function addSong(songName:String, weekNum:Int, songCharacter:String, bpm:Float = 102)
	{
		songs.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter, bpm));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}
    

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			FlxG.switchState(new OptionsMenu());
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (FlxG.keys.justPressed.DELETE && grpControls.members[curSelected].text != "No Replays...")
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				ConfirmationPrompt.confirmThing = deleteAllReplays;
				ConfirmationPrompt.confirmDisplay = 'Yeah!';
				ConfirmationPrompt.denyDisplay = 'Nah.';

				ConfirmationPrompt.titleText = 'HOLD UP!';
				ConfirmationPrompt.descText = 'Are you sure you want to delete ALL replays?'
										   + '\nThey all will be gone forever!'
										   + '\n(a really long time!)';
			}
			else
			{
				ConfirmationPrompt.confirmThing = deleteReplay;
				ConfirmationPrompt.confirmDisplay = 'Yeah!';
				ConfirmationPrompt.denyDisplay = 'Nah.';

				ConfirmationPrompt.titleText = 'HOLD UP!';
				ConfirmationPrompt.descText = 'Deleting a replay will make you lose'
										+ '\nall it\'s data, and it will be gone forever!'
										+ '\n(a really long time!)';
			}
							  
			openSubState(new ConfirmationPrompt());
		}
	

		if (controls.ACCEPT && grpControls.members[curSelected].text != "No Replays...")
		{
			trace('loading ' + actualNames[curSelected]);
			PlayState.rep = Replay.LoadReplay(actualNames[curSelected]);

			PlayState.loadRep = true;

			var poop:String = Highscore.formatSong(PlayState.rep.replay.properties.get("name").toLowerCase(), PlayState.rep.replay.properties.get("difficulty"));

			trace("mod set :) " + actualNames[curSelected].split("#")[0]);
			Paths.setCurrentMod(actualNames[curSelected].split("#")[0]);
			
			PlayState.SONG = Song.loadFromJson(poop, PlayState.rep.replay.properties.get("name").toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = PlayState.rep.replay.properties.get("difficulty");
			PlayState.storyWeek = getWeekNumbFromSong(PlayState.rep.replay.properties.get("name"));
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (grpInfo.members.length > 0 && grpDiff.members.length > 0)
		{
			for (i in 0...grpControls.members.length)
			{
				var item = grpInfo.members[i];
				var diffItem = grpDiff.members[i];
	
				item.x = grpControls.members[i].x = 25;
				item.y = grpControls.members[i].y + grpControls.members[i].height;
				item.alpha = diffItem.alpha = 0.6;
				
				diffItem.x = grpControls.members[i].x + grpControls.members[i].width + 25;
				diffItem.y = grpControls.members[i].y + (grpControls.members[i].height / 2)- (diffItem.height / 2);
	
				if (grpControls.members[i].targetY == 0)
					item.alpha = diffItem.alpha = 1;
			}
		}
	}

	function deleteReplay()
	{
		#if sys
		FileSystem.deleteFile(Sys.getCwd() + "/assets/replays/" + actualNames[curSelected]);
        #end
		FlxG.switchState(new LoadReplayState());
	}

	function deleteAllReplays()
	{
		#if sys
		for (name in actualNames)
		{
			FileSystem.deleteFile(Sys.getCwd() + "/assets/replays/" + name);
		}
        #end
		FlxG.switchState(new LoadReplayState());
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.x = 25;

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


