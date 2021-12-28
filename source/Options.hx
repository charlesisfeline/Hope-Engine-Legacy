package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.system.DisplayMode;
import openfl.Lib;
import openfl.display.FPS;

#if FILESYSTEM
import Sys;
import sys.FileSystem;
#end


class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";
	public final function getName() {
		return _name;
	}

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}

	public function press():Bool { return throw "stub!"; }
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}
	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;					// Does the option have a changeable number value? (yes even the accuracy type counts)
	private var dependantOption:Null<Bool> = null;			// Is the option a switch? (on or off option)

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public final function getOption():Null<Bool>
	{
		return dependantOption;
	}

	public function getValue():String { return throw "stub!"; };
	
	// Returns whether the label is to be updated.
	public function press():Bool { return throw "stub!"; }
	private function updateDisplay():String { return throw "stub!"; }
	public function left():Bool { return throw "stub!"; }
	public function right():Bool { return throw "stub!"; }
}

class OptionSubCatTitle extends Option
{
	private var subcatName:String = "";
	
	public function new(name:String)
	{
		super();
		subcatName = name;
		display = updateDisplay();
	}

	public override function press():Bool
		return true;

	public override function left():Bool
		return true;

	public override function right():Bool
		return true;

	private override function updateDisplay():String
		return subcatName;
}



class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Key Bindings";
	}
}

class Offset extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "Offset";
	}
	
	override function right():Bool {
		if (FlxG.keys.pressed.CONTROL)
			FlxG.save.data.offset += 10;
		else if (FlxG.keys.pressed.SHIFT)
			FlxG.save.data.offset += 1;
		else
			FlxG.save.data.offset += 0.1;

		return true;
	}

	override function left():Bool {
		if (FlxG.keys.pressed.CONTROL)
			FlxG.save.data.offset -= 10;
		else if (FlxG.keys.pressed.SHIFT)
			FlxG.save.data.offset -= 1;
		else
			FlxG.save.data.offset -= 0.1;

		return true;
	}

	override function getValue():String
	{
		return "Current Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + "ms"
		+ "\n(LEFT or RIGHT to change)"
		+ "\n(Hold CTRL for 10s)"
		+ "\n(Hold SHIFT for 1s.)";
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.downscroll;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		dependantOption = FlxG.save.data.downscroll;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Downscroll";
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.ghost;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		dependantOption = FlxG.save.data.ghost;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Ghost Tapping";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Info Text: " + (!FlxG.save.data.accuracyDisplay ? "Simple" : "Extensive");
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.songPosition;
	}
	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		dependantOption = FlxG.save.data.songPosition;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Position";
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.distractions;
	}
	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		dependantOption = FlxG.save.data.distractions;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Distractions";
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.resetButton;
	}
	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		dependantOption = FlxG.save.data.resetButton;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Reset Button";
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.flashing;
	}
	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		dependantOption = FlxG.save.data.flashing;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Flashing Lights";
	}
}

class Judgement extends Option
{
	

	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}
	
	public override function press():Bool
	{
		return true;
	}

	private override function updateDisplay():String
	{
		return "Safe Frames";
	}

	override function left():Bool {

		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}

	override function getValue():String {
		return "Safe Frames: " + Conductor.safeFrames + "\n"
		+ "Sick!: " + HelperFunctions.truncateFloat(45 * Conductor.timeScale, 0) + "ms\n"
		+ "Good: " + HelperFunctions.truncateFloat(90 * Conductor.timeScale, 0) + "ms\n"
		+ "Bad: " + HelperFunctions.truncateFloat(135 * Conductor.timeScale, 0) + "ms\n"
		+ "Shit: " + HelperFunctions.truncateFloat(155 * Conductor.timeScale, 0) + "ms\n"
		+ "TOTAL: " + HelperFunctions.truncateFloat(Conductor.safeZoneOffset,0) + "ms\n"
		+ "(LEFT or RIGHT to change)";
	}

	override function right():Bool {

		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.fps;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		dependantOption = FlxG.save.data.fps;
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter";
	}
}



class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap";
	}
	
	override function right():Bool {
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return "Current FPS Cap: " + FlxG.save.data.fpsCap + 
		(FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Hz (Refresh Rate)" : "")
		+ "\n(LEFT or RIGHT to change)";
	}
}


class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Scroll Speed";
	}

	override function right():Bool {
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String {
		return "Current Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1)
		+ "\n(LEFT or RIGHT to change)";
	}

	override function left():Bool {
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.npsDisplay;
	}

	public override function press():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		dependantOption = FlxG.save.data.npsDisplay;
		return true;
	}

	private override function updateDisplay():String
	{
		return "NPS Display";
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Mode: " + (FlxG.save.data.accuracyMod == 0 ? "Accurate" : "Complex");
	}
}

class OffsetMenu extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		var poop:String = Highscore.formatSong("Tutorial", 1);

		PlayState.SONG = Song.loadFromJson(poop, "Tutorial");
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		PlayState.storyWeek = 0;
		PlayState.offsetTesting = true;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Time your offset";
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.botplay;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		display = updateDisplay();
		dependantOption = FlxG.save.data.botplay;
		return true;
	}
	
	private override function updateDisplay():String
		return "BotPlay";
}

class RatingColors extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.ratingColor;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.ratingColor = !FlxG.save.data.ratingColor;
		display = updateDisplay();
		dependantOption = FlxG.save.data.ratingColor;
		return true;
	}
	
	private override function updateDisplay():String
		return "Rating Colors";
}

class StrumlineMargin extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return true;
	}

	private override function updateDisplay():String
	{
		return "Strumline Margin";
	}
	
	override function right():Bool {
		if (!FlxG.save.data.middleScroll)
		{
			if (FlxG.keys.pressed.SHIFT)
				FlxG.save.data.strumlineMargin += 10;
			else
				FlxG.save.data.strumlineMargin += 1;
		}
		return true;
	}

	override function left():Bool {
		if (!FlxG.save.data.middleScroll)
		{
			if (FlxG.keys.pressed.SHIFT)
				FlxG.save.data.strumlineMargin -= 10;
			else
				FlxG.save.data.strumlineMargin -= 1;
		}
		return true;
	}

	override function getValue():String
	{
		return (!FlxG.save.data.middleScroll ? "Margin: " + FlxG.save.data.strumlineMargin
		+ "\n(LEFT or RIGHT to change)"
		+ "\n(Hold SHIFT to add 10s.)" : "DISABLED (Middle scroll is on!)");
	}
}

class Middlescroll extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.middleScroll;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
		display = updateDisplay();
		dependantOption = FlxG.save.data.middleScroll;
		return true;
	}
	
	private override function updateDisplay():String
		return "Middle Scroll";
}

class FamilyFriendly extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.familyFriendly;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.familyFriendly = !FlxG.save.data.familyFriendly;
		display = updateDisplay();
		dependantOption = FlxG.save.data.familyFriendly;
		return true;
	}
	
	private override function updateDisplay():String
		return "Family Friendly";
}

class SkipResultsScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.skipResultsScreen;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.skipResultsScreen = !FlxG.save.data.skipResultsScreen;
		display = updateDisplay();
		dependantOption = FlxG.save.data.skipResultsScreen;
		return true;
	}
	
	private override function updateDisplay():String
		return "Skip Results";
}

class EraseData extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		ConfirmationPrompt.confirmThing = function():Void {
			FlxG.save.erase();
			throw 'Erased data. Relaunch needed.';
		};
		ConfirmationPrompt.confirmDisplay = 'Yeah!';
		ConfirmationPrompt.denyDisplay = 'Nah.';

		ConfirmationPrompt.titleText = 'AYO!';
		ConfirmationPrompt.descText = 'Are you sure you want to delete ALL DATA?'
									+ '\nThis will reset everything, from options to scores.'
									+ '\nThis is IRREVERSIBLE!';

		OptionsMenu.instance.openSubState(new ConfirmationPrompt());
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "Erase Data";
}

class EraseScores extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		ConfirmationPrompt.confirmThing = function():Void {
			FlxG.save.data.songScores = null;
			FlxG.save.data.songRanks = null;
			for (key in Highscore.songScores.keys())
			{
				Highscore.songScores[key] = 0;
			}
			for (key in Highscore.songRanks.keys())
			{
				Highscore.songRanks[key] = 17;
			}
		};
		ConfirmationPrompt.confirmDisplay = 'Yeah!';
		ConfirmationPrompt.denyDisplay = 'Nah.';

		ConfirmationPrompt.titleText = 'HALT!';
		ConfirmationPrompt.descText = 'Are you sure you want to delete ALL SCORES?'
									+ '\nThis will reset SCORES and RANKS, you get to keep your settings.'
									+ '\nThis is IRREVERSIBLE!';

		OptionsMenu.instance.openSubState(new ConfirmationPrompt());
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "Erase Scores";
}

class FancyHealthBar extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.fancyHealthBar;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.fancyHealthBar = !FlxG.save.data.fancyHealthBar;
		display = updateDisplay();
		dependantOption = FlxG.save.data.fancyHealthBar;
		return true;
	}
	
	private override function updateDisplay():String
		return "Fancy Health Bar";
}

class HealthBarColors extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.healthBarColors;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.healthBarColors = !FlxG.save.data.healthBarColors;
		display = updateDisplay();
		dependantOption = FlxG.save.data.healthBarColors;
		return true;
	}
	
	private override function updateDisplay():String
		return "Health Bar Colors";
}

class HideHealthIcons extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.hideHealthIcons;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.hideHealthIcons = !FlxG.save.data.hideHealthIcons;
		display = updateDisplay();
		dependantOption = FlxG.save.data.hideHealthIcons;
		return true;
	}
	
	private override function updateDisplay():String
		return "Hide Health Icons";
}

#if FILESYSTEM
class CacheImages extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.cacheImages;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.cacheImages = !FlxG.save.data.cacheImages;
		display = updateDisplay();
		dependantOption = FlxG.save.data.cacheImages;
		return true;
	}
	
	private override function updateDisplay():String
		return "Preload Characters";
}

class CacheMusic extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.cacheMusic;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheMusic = !FlxG.save.data.cacheMusic;
		display = updateDisplay();
		dependantOption = FlxG.save.data.cacheMusic;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Preload Songs";
	}
}

class NoteSkins extends Option
{
	private var controls:Controls;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new NoteSkinSelection());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Note Skins";
	}
}
#end

class PlayfieldBGTransparency extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "Playfield BG Transparency";
	}
	
	override function right():Bool {
		if (FlxG.keys.pressed.SHIFT)
			FlxG.save.data.pfBGTransparency += 10;
		else
			FlxG.save.data.pfBGTransparency += 1;

		if (FlxG.save.data.pfBGTransparency < 0)
			FlxG.save.data.pfBGTransparency = 0;

		if (FlxG.save.data.pfBGTransparency > 100)
			FlxG.save.data.pfBGTransparency = 100;
		return true;
	}

	override function left():Bool {
		if (FlxG.keys.pressed.SHIFT)
			FlxG.save.data.pfBGTransparency -= 10;
		else
			FlxG.save.data.pfBGTransparency -= 1;

		if (FlxG.save.data.pfBGTransparency < 0)
			FlxG.save.data.pfBGTransparency = 0;

		if (FlxG.save.data.pfBGTransparency > 100)
			FlxG.save.data.pfBGTransparency = 100;
		return true;
	}

	override function getValue():String
	{
		return "Transparency: " + FlxG.save.data.pfBGTransparency + "%"
		+ "\n(LEFT or RIGHT to change)"
		+ "\n(Hold SHIFT to add 10s.)"
		+ "\n(100% = Fully opaque.)";
	}
}

class Watermarks extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		dependantOption = FlxG.save.data.watermarks;
	}
	public override function press():Bool
	{
		FlxG.save.data.watermarks = !FlxG.save.data.watermarks;
		display = updateDisplay();
		dependantOption = FlxG.save.data.watermarks;
		return true;
	}

	private override function updateDisplay():String
	{
		return "Watermarks";
	}
}

class ModsMenu extends OptionCategory
{
	public override function press():Bool
	{
		FlxG.switchState(new ModLoadingState());
		return false;
	}
}

class ReplayMenu extends OptionCategory
{
	public override function press():Bool
	{
		FlxG.switchState(new LoadReplayState());
		return false;
	}
}