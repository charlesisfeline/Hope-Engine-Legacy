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

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120;
		
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

		if (FlxG.save.data.strumlineXOffset == null)
			FlxG.save.data.strumlineXOffset = 50;

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

		if (FlxG.save.data.answeredTheQuestion == null)
			FlxG.save.data.answeredTheQuestion = false;

		if (FlxG.save.data.completedDaWeek == null)
			FlxG.save.data.completedDaWeek = false;


		// Modifiers???
		// Some of these might contain old/outdated descriptions
		// I may have thought of cooler descriptions after adding them, lol
		
		if (FlxG.save.data.chaosMode == null)
			FlxG.save.data.chaosMode = false;
		// Everything goes wrong. Strumline notes will go to a random position every 5 seconds.

		if (FlxG.save.data.hiddenMode == null)
			FlxG.save.data.hiddenMode = false;
		// Notes will fade out before even hitting the strumline.

		if (FlxG.save.data.fcOnly == null)
			FlxG.save.data.fcOnly = false;
		// Gets you blueballed if you miss.

		if (FlxG.save.data.sicksOnly == null)
			FlxG.save.data.sicksOnly = false;
		// Gets you blueballed if you hit anything but a "Sick!!".

		if (FlxG.save.data.goodsOnly == null)
			FlxG.save.data.goodsOnly = false;
		// Gets you blueballed if you hit anything but a "Good". (even a "Sick!!" will get you blueballed!)

		if (FlxG.save.data.bothSides == null)
			FlxG.save.data.bothSides = false;
		// Play both sides. Combines both sides into 1.

		if (FlxG.save.data.flashNotes == null)
			FlxG.save.data.flashNotes = 0;
		// (FLASHING LIGHTS) Flash Notes (white notes) will appear in the play field.

		if (FlxG.save.data.deathNotes == null)
			FlxG.save.data.deathNotes = 0;
		// Tricky time. Death notes (black notes) will appear in the play field. Will instantly kill you.

		if (FlxG.save.data.lifestealNotes == null)
			FlxG.save.data.lifestealNotes = 0;
		// Tabi time. Tabi notes (black-ish) will appear in the enemy's play field. Will damage you with your given damage.
		// This has been renamed to "Lifesteal" notes because it sounds cooler. :)

		if (FlxG.save.data.enemySide == null)
			FlxG.save.data.enemySide = false;
		// "I wish I could play his side. It looks harder" or "We have unequal sides, it's unfair!"

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}