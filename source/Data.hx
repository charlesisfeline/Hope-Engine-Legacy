import flixel.FlxG;
import openfl.Lib;

class Data
{
    public static function initSave()
    {
        if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = false;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 60;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 60;
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.strumlineMargin == null)
			FlxG.save.data.strumlineMargin = 100;

		if (FlxG.save.data.middleScroll == null)
			FlxG.save.data.middleScroll = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = true;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;
		
		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		if (FlxG.save.data.familyFriendly == null)
			FlxG.save.data.familyFriendly = false;
		
		if (FlxG.save.data.skipResultsScreen == null)
			FlxG.save.data.skipResultsScreen = false;
		
		if (FlxG.save.data.fancyHealthBar == null)
			FlxG.save.data.fancyHealthBar = false;

		if (FlxG.save.data.healthBarColors == null)
			FlxG.save.data.healthBarColors = true;

		if (FlxG.save.data.hideHealthIcons == null)
			FlxG.save.data.hideHealthIcons = false;

		if (FlxG.save.data.cacheImages == null)
			FlxG.save.data.cacheImages = false;

		if (FlxG.save.data.ratingColor == null)
			FlxG.save.data.ratingColor = false;

		if (FlxG.save.data.watermarks == null)
			FlxG.save.data.watermarks = true;

		if (FlxG.save.data.pfBGTransparency == null)
			FlxG.save.data.pfBGTransparency = 0;

		if (FlxG.save.data.currentNoteSkin == null)
			FlxG.save.data.currentNoteSkin = "default";

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}