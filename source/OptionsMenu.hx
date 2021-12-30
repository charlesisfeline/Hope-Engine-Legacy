package;

import Controls.Control;
import Options;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.FPS;

#if windows
import Discord.DiscordClient;
#end

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Preferences", [
			new OptionSubCatTitle("GAMEPLAY"),
			new DFJKOption("Change how you play."),
			new Offset("Change your note's offset (negative is early).\nIt's been migrated here for consistency."),
			new DownscrollOption("Changes the note scroll\ndirection from up to down (and vice versa)."),
			new GhostTapOption("If this is on, pressing while there's no\nnotes to hit won't give you a penalty."),
			new OffsetMenu("Not sure what offset you need? Play this!"),
			new Judgement("Customize your Hit Timings\n(Lower safe frames = tighter/harder gameplay)"),
			#if FILESYSTEM
			new FPSCapOption("Cap your FPS"),
			#end
			new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated.\n(Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),

			new OptionSubCatTitle("APPEARANCE"),
			#if FILESYSTEM
			new NoteSkins("Change your note skins here"),
			#end
			new NoteSplashes("Toggle the splash effect when you hit a \"Sick!\""),
			new AccuracyOption("Modify the info text under the health bar."),
			new NPSDisplayOption("Shows your current Notes Per Second.\n(\"Extensive\" info text is needed for this!)"),
			new RatingColors("Toggle rating colors\n(e.g. Good is colored green)"),
			new FancyHealthBar("Gets the health bar a bit of glow up."),
			new HealthBarColors("Colors the health bar to fit the character's theme. Like boyfriend's bar side (right) will be cyan!"),
			new HideHealthIcons("Hides the health icons."),
			new SongPositionOption("Show the songs current position (as a bar)"),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay.\n(Train passing by, fast cars passing by, etc.)")
		]),

		#if FILESYSTEM
		new ModsMenu("Modifications", []),
		new ReplayMenu("Replays", []),
		#end

		new OptionCategory("Accessbility", [
			new FlashingLightsOption("Toggle flashing lights that can\ncause epileptic seizures and strain."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay.\n(Train passing by, fast cars passing by, etc.)"),
			new PlayfieldBGTransparency("Change the opacity of the playfield's background."),
			new StrumlineMargin("Change the how far away the notes should be from the side of the screen."),
			new Middlescroll("Put the notes in the middle.")
		]),
		
		new OptionCategory("Miscellaneous", [
			new OptionSubCatTitle("MISCELLANEOUS"),
			new FPSOption("Toggle the FPS Counter"),
			new Watermarks("Toggle the Watermark seen at the Story Menu"),
			#if FILESYSTEM
			new CacheMusic("Preloads the songs for a smoother freeplay menu experience. (HIGH MEMORY!)"),
			new CacheImages("Preloads the characters for a smoother experience. (HIGH MEMORY!)"),
			#end
			new SkipResultsScreen("Skips the results screen."),
			new FamilyFriendly("Recording a video? In a no-swearing stream? Enable this!"),
			new BotPlay("Automatically play charts for you\n(Useful for showcasing, looking at charts, etc.)"),

			new OptionSubCatTitle("DANGEROUS STUFF"),
			new EraseScores("WILL ERASE ALL SCORES AND RANKS!\n(prompted! be careful!)"),
			new EraseData("WILL ERASE ALL DATA!\n(prompted! be careful!)")
		])
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	private var grpCheckBoxes:FlxTypedGroup<FlxSprite>;

	var menuBG:FlxSprite;

	var descriptionShit:FlxText;
	var optionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var descBackground:FlxSprite;

	override function create()
	{
		instance = this;

		// Conductor.changeBPM(102);
		// persistentUpdate = true;

		persistentUpdate = persistentDraw = true;

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Options Menu", null);
		#end

		menuBG = new FlxSprite().loadGraphic(Paths.image("menuBGBlue"));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		grpCheckBoxes = new FlxTypedGroup<FlxSprite>();
		add(grpCheckBoxes);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), Std.isOfType(options[i], OptionSubCatTitle) || Std.isOfType(options[i], OptionCategory));
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
		}
		
		currentDescription = "";

		descBackground = new FlxSprite().makeGraphic(Std.int((FlxG.width * 0.85) + 8), 72, 0xFF000000);
		descBackground.alpha = 0.6;
		descBackground.screenCenter(X);
		descBackground.visible = false;
		add(descBackground);

		descriptionShit = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, " ");
		descriptionShit.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionShit.screenCenter(X);
		descriptionShit.borderSize = 3;
		add(descriptionShit);

		descBackground.setPosition(descriptionShit.x - 4, descriptionShit.y - 4);

		// Option shit (middle right)
		optionShit = new FlxText(FlxG.width - 655, 350, 630, "");
		optionShit.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionShit.borderSize = 3;
		optionShit.screenCenter(Y);
		add(optionShit);
		
		descriptionShit.alpha = 0;
		FlxTween.tween(descriptionShit, {y: FlxG.height - 80, alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		
		changeSelection();
		
		super.create();
	}

	var isCat:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		for (i in 0...grpControls.members.length)
		{
			if (!isCat)
			{
				grpControls.members[i].screenCenter(X);
				
				if (i == 0)
					grpControls.members[i].y = 175;
				else
					grpControls.members[i].y = grpControls.members[i - 1].y + grpControls.members[i - 1].height + 10;
			}
			else
			{
				if (grpControls.members[i].checkBox != null)
				{
					grpControls.members[i].x = 300;
					grpControls.members[i].checkBox.x = grpControls.members[i].x - grpControls.members[i].checkBox.width - 25;
				}
				else
				{
					if (grpControls.members[i].isBold)
						grpControls.members[i].screenCenter(X);
					else
						grpControls.members[i].x = 125;
				}
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
			{
				FlxG.switchState(new MainMenuState());
				FlxG.save.flush();
			}
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				grpCheckBoxes.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i), options[i].getName(), Std.isOfType(options[i], OptionSubCatTitle) || Std.isOfType(options[i], OptionCategory));
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
				}
				curSelected = 0;
				descriptionShit.text = "";
				optionShit.text = "";
				descBackground.visible = false;

				changeSelection();
			}
			if (controls.UP_P)
			{
				changeSelection(-1);
				if (grpControls.members[curSelected].isBold && isCat)
					changeSelection(-1);
			}

			if (controls.DOWN_P)
			{
				changeSelection(1);
				if (grpControls.members[curSelected].isBold && isCat)
					changeSelection(1);
			}
			
			if (isCat)
			{
				
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					{
						descriptionShit.text = currentDescription;
						optionShit.text = currentSelectedCat.getOptions()[curSelected].getValue();
						optionShit.screenCenter(Y);

						if (descriptionShit.text.length > 0)
							descBackground.visible = true;
					}
				else
					{
						descriptionShit.text = currentDescription;
						optionShit.text = "";

						if (descriptionShit.text.length > 0)
							descBackground.visible = true;
					}
			}
		

			if (controls.RESET)
				FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) 
					{
						var ctrl:Alphabet = new Alphabet(0, (grpControls.members[curSelected].y), currentSelectedCat.getOptions()[curSelected].getDisplay(), Std.isOfType(currentSelectedCat.getOptions()[curSelected], OptionSubCatTitle) || Std.isOfType(currentSelectedCat.getOptions()[curSelected], OptionCategory));
						ctrl.x = 125;
						ctrl.isMenuItem = true;
						
						if (currentSelectedCat.getOptions()[curSelected].getOption() != null)
							grpCheckBoxes.remove(grpControls.members[curSelected].checkBox);

						grpControls.remove(grpControls.members[curSelected]);
						grpControls.add(ctrl);

						if (currentSelectedCat.getOptions()[curSelected].getOption() != null)
						{
							ctrl.x = 300;
							var piss:CheckBox = new CheckBox(ctrl.x - 175, 0, currentSelectedCat.getOptions()[curSelected].getOption());
							piss.y = ctrl.y + (ctrl.height / 2) - (piss.height / 2);
							ctrl.checkBox = piss;
							grpCheckBoxes.add(piss);
						}
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					if (currentSelectedCat.getOptions().length == 0)
					{
						currentSelectedCat.press();
					}
					else
					{
						isCat = true;
						grpControls.clear();
						for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i), currentSelectedCat.getOptions()[i].getDisplay(), Std.isOfType(currentSelectedCat.getOptions()[i], OptionSubCatTitle) || Std.isOfType(currentSelectedCat.getOptions()[i], OptionCategory));
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;

							if (currentSelectedCat.getOptions()[i].getOption() != null)
							{
								controlLabel.x = 300;
								var piss:CheckBox = new CheckBox(controlLabel.x - 175, 0, currentSelectedCat.getOptions()[i].getOption());
								piss.y = controlLabel.y + (controlLabel.height / 2) - (piss.height / 2);
								controlLabel.checkBox = piss;
								grpCheckBoxes.add(piss);
							}
								

							grpControls.add(controlLabel);
						}
						curSelected = 0;

						changeSelection();
						if (grpControls.members[curSelected].isBold)
							changeSelection(1);
					}
				}
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "";
		
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					descriptionShit.text = currentDescription;
					optionShit.text = currentSelectedCat.getOptions()[curSelected].getValue();
					optionShit.screenCenter(Y);
				}
			else
				{
					descriptionShit.text = currentDescription;
					optionShit.text = "";
				}
		}
		else
		{
			descriptionShit.text = currentDescription;
			optionShit.text = "";
		}

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (isCat && item.isBold)
				item.alpha = 1;

			if (item.checkBox != null)
				item.checkBox.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;

				if (item.checkBox != null)
					item.checkBox.alpha = 1;
			}
		}
	}
}

/**
 * Basic checkbox sprite. For visual purposes only.
 */
class CheckBox extends FlxSprite 
{
	public function new(x:Float, y:Float, ?toggle:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxAwesome');
		antialiasing = true;

		animation.addByPrefix("ticked", "checkbox checked", 24, false);
		setGraphicSize(150);
		updateHitbox();
		change(toggle);
	}

	public function change(huh:Bool)
	{
		if (huh)
			animation.play('ticked', true);
		else
			animation.play('ticked', true, true);
	}
}