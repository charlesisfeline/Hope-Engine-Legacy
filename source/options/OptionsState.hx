package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import openfl.Lib;
import options.OptionTypes;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class OptionsState extends MusicBeatState
{
	public static var acceptInput:Bool = true;

	var displayOptions:FlxTypedGroup<Option>;
	var displayCategories:FlxTypedGroup<OptionCategory>;
	var curSelected:Int = 0;
	var inCat:Bool = false;
	var highlightedAlphabet:Alphabet;
	var descText:FlxText;
	var descBG:FlxSprite;

	var categories:Array<OptionCategory> = [
		new OptionCategory("Preferences", [
			new OptionSubCategoryTitle("Gameplay"),
			new PressOption("Keybinds", "Change how YOU play.",
				function()
				{
					FlxG.state.openSubState(new KeybindSubstate());
					acceptInput = false;
				}),
			new ToggleOption("Downscroll", "Change the scroll direction from up to down (and vice versa)", "downscroll"),
			new ToggleOption("Ghost Tapping", "If activated, pressing while there's no notes to hit won't give you a miss penalty.", "ghostTapping"),
			new ToggleOption("Middlescroll", "Put the notes in the middle.", "middleScroll"),
			new ValueOptionFloat("Offset", "Feeling delayed/early? Change the notes offset here!\n(this is chart offset! negative values mean early!)",
				"offset", Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 0.1, 100, null, 0, "ms", 1),
			/*
				UNUSED UNTIL FURTHER NOTICE
				new PressOption("Test your offset", "Not sure how offset you are?", function() {
					FlxG.state.openSubState(new OffsetSubstate());
					acceptInput = false;
				}),
			 */
			new ValueOptionInt("Safe Frames", "Change how the game judges your timing.\n(Lower hit frames = Tighter ratings)", "safeFrames", 0, 20, 1,
				function()
				{
					Conductor.safeFrames = Settings.safeFrames;
					Conductor.recalculateTimings();
				}, 10),
			#if FILESYSTEM
			new ValueOptionInt("FPS Cap", "The maximum FPS the game can have", "fpsCap", Application.current.window.displayMode.refreshRate, 290, 1, 10,
				function()
				{
					FlxG.updateFramerate = FlxG.drawFramerate = Settings.fpsCap;
				}, 60, " FPS"),
			#end
			new ValueOptionFloat("Scroll Speed", "Change your scroll speed.\n(1 = chart-dependent)", "scrollSpeed", 1, Math.POSITIVE_INFINITY, 0.1, 10, null, 1, "", 2),
			new SelectionOption("Accuracy Mode", "Change how accuracy is calculated.\n(Accurate = Simple, Complex = Milisecond Based)", "accuracyMode", ["Accurate", "Complex"]),
			new ToggleOption("Reset Button", "If activated, pressing R while in a song will cause a game over.", "resetButton"),
			new OptionSubCategoryTitle("Appearance"),
			#if FILESYSTEM 
			new PressOption("Note Skins", "Change how your notes look.", function()
			{
				FlxG.state.openSubState(new options.NoteSkinSelection());
				acceptInput = false;
			}),
			#end
			new ValueOptionFloat("Lane Underlay", "Change the opacity of the lane underlay.\n(0 = invisible, 100 = visible)", "underlayAlpha", 0, 100, 0.1, 100, null, 0, "%", 2),
			new ValueOptionInt("Strumline Margin", "Change how far the strumline (the 4 grey notes) are from the edges of the screen.", "strumlineMargin", -2147483647, 2147483647, 1, 10, null, 100),
			new ValueOptionFloat("Dynamic Camera Multiplier", "Change how far the camera moves when a character sings. Set to 0 to disable.", "dynamicCamera", Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 0.1, 10, null, 0, "x", 2),
			new ToggleOption("Stationary Ratings", "Make the ratings and the combo count stationary.", "stationaryRatings"),
			new PressOption("Change Rating and Combo positions", "Change where YOU see the rating and combo count.",
				function()
				{
					FlxG.state.openSubState(new RatingPosSubstate());
					acceptInput = false;
				}),
			new ToggleOption("Note Splashes", "Toggle the splashes that show up when you hit a \"Sick!!\"", "noteSplashes"),
			new ToggleOption("Extensive Score Display", "Should the score text under the health bar have more info than just Score and Accuracy?", "extensiveDisplay"),
			new ToggleOption("Show NPS", "Shows your current Notes Per Second.", "npsDisplay"),
			new ToggleOption("Health Bar Colors", "Colors the health bar to fit the character's theme.\nLike boyfriend's bar side (right) will be cyan.", "healthBarColors"),
			new ToggleOption("Hide Health Icons", "Hide the icons on the health bar.", "hideHealthIcons"),
			new SelectionOption("Bar Type", "What should the song position bar show?", "posBarType", [
				"Name & Time Elapsed",
				"Name & Time Left",
				"Name",
				"Time Elapsed",
				"Time Left",
				"Nothing",
				"Disabled"
			])
		]),
		new OptionCategory("Accessibility", [
			new OptionSubCategoryTitle("Acessibility"),
			new ToggleOption("Flashing Lights", "If activated, flashing lights will appear.", "flashing"),
			new ToggleOption("Distractions", "Toggle stage distractions that can hinder your gameplay.\n(Train passing by, fast cars passing by, etc.)", "distractions"),
			new ToggleOption("Persistent Volume", "If activated, the game will save the volume and stay the same everytime you reopen.", "persistentVolume")
		]),
		new OptionCategory("Miscellaneous", [
			new OptionSubCategoryTitle("Miscellaneous"),
			new ToggleOption("Show FPS", "Display an FPS counter at the top-left of the screen", "fps", function() {(cast(Lib.current.getChildAt(0), Main)).toggleFPS(Settings.fps);}),
			new ToggleOption("Watermarks", "Show the watermark seen at the Main Menu", "watermarks"),
			new ToggleOption("Autopause", "If this is ticked, the game will \"pause\" when unfocused.", "autopause", function() {FlxG.autoPause = Settings.autopause;}),
			#if FILESYSTEM 
			new ToggleOption("Cache Music", "Keeps the music in memory for a smoother experience.\n(HIGH MEMORY!)", "cacheMusic"), 
			new ToggleOption("Cache Images", "Keeps the images in memory for faster loading times.\n(HIGH MEMORY!)", "cacheImages"),
			#end
			new ToggleOption("Resume Countdown", "If checked, there will be a countdown when you resume to gameplay.", "resumeCountdown"),
			new OptionSubCategoryTitle("Dangerous Stuff", FlxColor.RED),
			new PressOption("Reset Options", "Reset ALL options.\n(Prompted, be careful!)", function()
			{
				FlxG.state.openSubState(new ConfirmationPrompt(
					"HEYYY!",
					"Are you sure you want to RESET OPTIONS?\nThis will RESET OPTIONS ONLY\nThis is IRREVERSIBLE!", 
					"Yeah!", 
					"Nah.", 
					function()
					{
						Settings.setToDefaults();
						FlxG.state.switchTo(new OptionsState());
					}, null));
			}),
			new PressOption("Erase Scores", "Remove SONG data.\n(Prompted, be careful!)", function()
			{
				FlxG.state.openSubState(new ConfirmationPrompt(
					"HALT!",
					"Are you sure you want to delete ALL SCORES?\nThis will reset SCORES and RANKS.\nYou get to keep your settings.\nThis is IRREVERSIBLE!",
					"Yeah!", 
					"Nah.", 
					function()
					{
						FlxG.save.data.songScores = null;
						FlxG.save.data.songRanks = null;
						for (key in Highscore.songScores.keys())
						{
							Highscore.songScores[key] = 0;
						}
						for (key in Highscore.songAccuracies.keys())
						{
							Highscore.songAccuracies[key] = 0.0;
						}
					}, null));
			}),
			new PressOption("Erase Achievements", "Remove ACHIEVEMENTS data.\n(Prompted, be careful!)", function()
			{
				FlxG.state.openSubState(new ConfirmationPrompt(
					"HEY!",
					"Are you sure you want to delete ALL ACHIEVEMENTS?\nThis is IRREVERSIBLE!",
					"Yeah!", 
					"Nah.", 
					function()
					{
						Achievements.takeAll();
					}, null));
			}),
			new PressOption("Erase Data", "Remove ALL data.\n(Prompted, be careful!)", function()
			{
				FlxG.state.openSubState(new ConfirmationPrompt(
					"AYO!",
					"Are you sure you want to delete ALL DATA?\nThis will reset everything, from options to scores.\nThis is IRREVERSIBLE!", 
					"Yeah!", 
					"Nah.",
					function()
					{
						FlxG.save.erase();
						Application.current.window.alert("Erased data. Relaunch needed.", "Data erased.");
						Application.current.window.close();
					}, null));
			}),
		]),
		#if debug new OptionCategory("Debug", [
			new ToggleOption("Difficulty Based Vocals", "Vocals will fade out when you've hit a note. May sound weird.", "difficultyVocals")
		])
		#end
	];

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu");
		#end

		var menuBG = new FlxSprite().loadGraphic(Paths.image("menuBGBlue"));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		displayOptions = new FlxTypedGroup<Option>();
		displayCategories = new FlxTypedGroup<OptionCategory>();

		for (cat in categories)
			displayCategories.add(cat);

		add(displayOptions);
		add(displayCategories);

		descBG = new FlxSprite().makeGraphic(Std.int((FlxG.width * 0.85) + 8), 72, 0xFF000000);
		descBG.alpha = 0.6;
		descBG.screenCenter(X);
		descBG.visible = false;
		add(descBG);

		descText = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, "");
		descText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.screenCenter(X);
		descText.borderSize = 3;
		add(descText);

		descBG.setPosition(descText.x - 4, descText.y - 4);

		changeSelection();

		super.create();
	}

	var holdTimer:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!inCat)
		{
			for (option in displayCategories.members)
			{
				var i = displayCategories.members.indexOf(option);

				option.alphaDisplay.screenCenter(X);

				if (i == 0)
					displayCategories.members[i].alphaDisplay.y = 175;
				else
					displayCategories.members[i].alphaDisplay.y = displayCategories.members[i - 1].alphaDisplay.y
						+ displayCategories.members[i - 1].alphaDisplay.height + 10;
			}
		}
		else
		{
			for (option in displayOptions.members)
			{
				var i = displayOptions.members.indexOf(option);

				displayOptions.members[i].x = 125;

				if (option is OptionSubCategoryTitle)
				{
					option.screenCenter(X);
				}
			}
		}

		if (descText.text.trim() == '')
		{
			descBG.visible = false;
			descText.visible = false;
		}
		else
		{
			descBG.visible = true;
			descText.visible = true;
		}

		if (acceptInput)
		{
			if (controls.UP_P)
			{
				changeSelection(-1);
				if (highlightedAlphabet.isBold && inCat)
					changeSelection(-1);
			}

			if (controls.DOWN_P)
			{
				changeSelection(1);
				if (highlightedAlphabet.isBold && inCat)
					changeSelection(1);
			}

			if (controls.BACK)
			{
				if (!inCat)
				{
					// FlxG.save.flush();
					Settings.save();
					FlxG.switchState(new MainMenuState());
				}
				else
				{
					inCat = false;
					curSelected = 0;
					remove(displayOptions);
					add(displayCategories);

					changeSelection();
				}
			}

			if (inCat)
			{
				if (displayOptions.members[curSelected] is ToggleOption
					|| displayOptions.members[curSelected] is StateOption
					|| displayOptions.members[curSelected] is PressOption)
				{
					if (controls.ACCEPT)
						displayOptions.members[curSelected].press();
				}
				else if (displayOptions.members[curSelected] is ValueOptionFloat || displayOptions.members[curSelected] is ValueOptionInt)
				{
					if (controls.LEFT || controls.RIGHT)
					{
						if (holdTimer > Main.globalMaxHoldTime)
						{
							if (controls.LEFT)
								displayOptions.members[curSelected].left_H();
							if (controls.RIGHT)
								displayOptions.members[curSelected].right_H();
						}
						else
						{
							if (controls.LEFT_P)
								displayOptions.members[curSelected].left_H();
							if (controls.RIGHT_P)
								displayOptions.members[curSelected].right_H();

							holdTimer += elapsed;
						}
					}
					else
						holdTimer = 0;
				}
				else if (displayOptions.members[curSelected] is SelectionOption)
				{
					if (controls.LEFT_P)
						displayOptions.members[curSelected].left();
					if (controls.RIGHT_P)
						displayOptions.members[curSelected].right();
				}

				// changeSelection();
				if (highlightedAlphabet.isBold && inCat)
					changeSelection(1);
			}
			else
			{
				if (controls.ACCEPT)
				{
					var thing = displayCategories.members[curSelected];

					if (thing is StateCategory)
						thing.press();
					else if (thing is OptionCategory)
					{
						curSelected = 0;
						inCat = true;

						displayOptions.clear();

						for (option in thing.options)
							displayOptions.add(option);

						remove(displayCategories);
						add(displayOptions);
					}

					changeSelection();

					for (item in displayOptions.members)
						item.y = item.getTargetY();
				}
			}
		}
	}

	function changeSelection(huh:Int = 0)
	{
		curSelected += huh;

		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		var bullShit:Int = 0;

		if (inCat)
		{
			if (curSelected < 0)
				curSelected = displayOptions.length - 1;
			if (curSelected > displayOptions.length - 1)
				curSelected = 0;

			for (item in displayOptions.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;

				if (item.targetY == 0 || item.alphaDisplay.isBold)
				{
					item.alpha = 1;

					if (!item.alphaDisplay.isBold)
					{
						descText.text = item.desc;
						descText.y = (FlxG.height * 0.9) - (descText.height / 2);

						descBG.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 20));
						descBG.screenCenter(X);
						descBG.y = (FlxG.height * 0.9) - (descBG.height / 2);
						descBG.visible = true;
					}
				}
			}

			if (displayOptions.members.length > 0)
				highlightedAlphabet = displayOptions.members[curSelected].alphaDisplay;
		}
		else
		{
			if (curSelected < 0)
				curSelected = displayCategories.length - 1;
			if (curSelected > displayCategories.length - 1)
				curSelected = 0;

			for (item in displayCategories.members)
			{
				item.alpha = 0.6;

				if (item == displayCategories.members[curSelected])
				{
					item.alpha = 1;

					descText.text = '';
					descBG.visible = false;
				}
			}

			if (displayCategories.members.length > 0)
				highlightedAlphabet = displayCategories.members[curSelected].alphaDisplay;
		}
	}
}
