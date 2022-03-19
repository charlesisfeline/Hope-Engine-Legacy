import flixel.FlxG;
import openfl.Lib;

class Data
{
    public static function initSave()
    {
		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
			
		if (FlxG.save.data.extensiveDisplay == null)
			FlxG.save.data.extensiveDisplay = false;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.posBarType == null)
			FlxG.save.data.posBarType = 0;

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
		
		if (FlxG.save.data.skipResultsScreen == null)
			FlxG.save.data.skipResultsScreen = false;

		if (FlxG.save.data.healthBarColors == null)
			FlxG.save.data.healthBarColors = true;

		if (FlxG.save.data.hideHealthIcons == null)
			FlxG.save.data.hideHealthIcons = false;

		if (FlxG.save.data.cacheImages == null)
			FlxG.save.data.cacheImages = false;

		if (FlxG.save.data.cacheMusic == null)
			FlxG.save.data.cacheMusic = false;

		if (FlxG.save.data.watermarks == null)
			FlxG.save.data.watermarks = true;

		if (FlxG.save.data.noteSplashes == null)
			FlxG.save.data.noteSplashes = true;

		if (FlxG.save.data.resumeCountdown == null)
			FlxG.save.data.resumeCountdown = true;

		if (FlxG.save.data.underlayAlpha == null)
			FlxG.save.data.underlayAlpha = 0;

		if (FlxG.save.data.noteSkin == null)
			FlxG.save.data.noteSkin = "default";

		if (FlxG.save.data.ratingPos == null)
			FlxG.save.data.ratingPos = [(FlxG.width / 3 + 5), (FlxG.height / 2 + 5)];

		if (FlxG.save.data.comboPos == null)
			FlxG.save.data.comboPos = [(FlxG.width / 3 + 5), (FlxG.height / 2 + 155)];

		if (FlxG.save.data.stationaryRating == null)
			FlxG.save.data.stationaryRating = true;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}