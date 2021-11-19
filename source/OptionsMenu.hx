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
		new OptionCategory("Gameplay", [
			new DFJKOption("Change how you play."),
			new Offset("Change your note's offset. (negative is early)\nIt's been migrated here for consistency."),
			new DownscrollOption("Changes the note scroll\ndirection from up to down (and vice versa)."),
			new GhostTapOption("If this is on, pressing while there's no\nnotes to hit won't give you a penalty."),
			new OffsetMenu("Not sure what offset you need? Play this!"),
			new Judgement("Customize your Hit Timings\n(Lower safe frames = tighter/harder gameplay)"),
			#if desktop
			new FPSCapOption("Cap your FPS"),
			#end
			new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated.\n(Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			new CustomizeGameplay("Drag'n'Drop Gameplay Modules\naround to your preference")
		]),

		new OptionCategory("Accessbility", [
			new FlashingLightsOption("Toggle flashing lights that can\ncause epileptic seizures and strain."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay.\n(Train passing by, fast cars passing by, etc.)"),
			new PlayfieldBGTransparency("Change the opacity of the playfield's background."),
			new StrumlineXOffset("Change the x-position of your strumline.\n(Use 367 to put it in the middle.)")
		]),

		new OptionCategory("Appearance", [
			#if sys
			new NoteSkins("Change your note skins here"),
			#end
			new AccuracyOption("Modify the info text under the health bar."),
			new NPSDisplayOption("Shows your current Notes Per Second.\n(\"Extensive\" info text is needed for this!)"),
			new RatingColors("Toggle rating colors\n(e.g. Good is colored green)"),
			new FancyHealthBar("Gets the health bar a bit of glow up."),
			new HealthBarColors("Colors the health bar to fit the character's theme. Like boyfriend's bar side (right) will be cyan!"),
			new HideHealthIcons("Hides the health icons."),
			new SongPositionOption("Show the songs current position (as a bar)"),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay.\n(Train passing by, fast cars passing by, etc.)")
		]),
		
		new OptionCategory("Misc", [
			new FPSOption("Toggle the FPS Counter"),
			new Watermarks("Toggle the Watermark at the top left"),
			#if desktop
			new ReplayOption("View replays\n(REVAMPED BETA! May be inaccurate.)"),
			new CacheImages("Preloads the characters for a smoother experience. (HIGH MEMORY)"),
			#end
			new SkipResultsScreen("Skips the results screen."),
			new FamilyFriendly("Recording a video? In a no-swearing stream? Enable this!"),
			new BotPlay("Automatically play charts for you\n(Useful for showcasing, looking at charts, etc.)")
		]),

		new OptionCategory("Modifiers", [
			new ChaosMode("Every time the camera zooms in, the arrow positions will change."),
			new FcOnly("Gets you blueballed if you miss."),
			new SicksOnly("Gets you blueballed if you hit anything but a \"Sick!!\".\n(Overrides \"Goods Only\")"),
			new GoodsOnly("Gets you blueballed if you hit anything but a \"Good\".\n(Even a \"Sick!!\" will get you blueballed!)"),
			new BothSides("Play both sides. Combines both sides into 1."),
			new EnemySide("Makes you play as the enemy.\n(BETA! Some aspects may not be reversed.)"),
			new FlashNotes("(FLASHING LIGHTS) Say cheese! Flash Notes (colored white)\nwill appear in the play field. Causes a flash when hit."),
			new DeathNotes("Tricky time. Death Notes (colored black-red) will appear \nin the play field. Cause an instant death when hit."),
			new LifestealNotes("Tabi time. Lifesteal notes (colored black + note color) will appear in the enemy's play field. Will damage you.")
		]),

		new OptionCategory("Data", [
			new EraseScores("WILL ERASE ALL SCORES AND RANKS!\n(prompted! be careful!)"),
			new EraseData("WILL ERASE ALL DATA!\n(prompted! be careful!)"),
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
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
		}
		
		currentDescription = " ";

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
		// FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		// FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});
		
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
					grpControls.members[i].x = FlxMath.lerp(grpControls.members[i].x, (grpControls.members[i].targetY * 20) + 265, 9 / lime.app.Application.current.window.frameRate);
					grpControls.members[i].checkBox.x = grpControls.members[i].x - grpControls.members[i].checkBox.width - 25;
				}
				else
					grpControls.members[i].x = FlxMath.lerp(grpControls.members[i].x, (grpControls.members[i].targetY * 20) + 90, 9 / lime.app.Application.current.window.frameRate);
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
					var controlLabel:Alphabet = new Alphabet(0, (70 * i), options[i].getName(), true);
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
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);
			
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
						descBackground.visible = true;
					}
				else
					{
						descriptionShit.text = currentDescription;
						optionShit.text = "";
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
						var ctrl:Alphabet = new Alphabet(0, (grpControls.members[curSelected].y), currentSelectedCat.getOptions()[curSelected].getDisplay(), true);
						ctrl.x = (ctrl.targetY * 20) + 90;
						ctrl.isMenuItem = true;
						
						if (currentSelectedCat.getOptions()[curSelected].getOption() != null)
							grpCheckBoxes.remove(grpControls.members[curSelected].checkBox);

						grpControls.remove(grpControls.members[curSelected]);
						grpControls.add(ctrl);

						if (currentSelectedCat.getOptions()[curSelected].getOption() != null)
						{
							ctrl.x = (ctrl.targetY * 20) + 265;
							var piss:CheckBox = new CheckBox(ctrl.x - 175, ctrl.y + (ctrl.height / 2) - (150 / 2), currentSelectedCat.getOptions()[curSelected].getOption());
							ctrl.checkBox = piss;
							grpCheckBoxes.add(piss);
						}
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i), currentSelectedCat.getOptions()[i].getDisplay(), true);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;

						if (currentSelectedCat.getOptions()[i].getOption() != null)
						{
							controlLabel.x = 175;
							var piss:CheckBox = new CheckBox(controlLabel.x - 175, controlLabel.y + (controlLabel.height / 2) - (150 / 2), currentSelectedCat.getOptions()[i].getOption());
							controlLabel.checkBox = piss;
							grpCheckBoxes.add(piss);
						}
							

						grpControls.add(controlLabel);
					}
					curSelected = 0;

					changeSelection();
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
			currentDescription = " ";
		
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

		loadGraphic(Paths.image("checkBox"), true, 150, 150);
		antialiasing = true;

		animation.add('unticked', [0, 2], 12);
		animation.add('ticked', [1, 3], 12);
		change(toggle);
	}

	public function change(huh:Bool)
	{
		if (huh)
			animation.play('ticked', true);
		else
			animation.play('unticked', true);
	}
}