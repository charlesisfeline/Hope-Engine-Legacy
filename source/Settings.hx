package;

import flixel.FlxG;
import openfl.Lib;

class Settings
{
	// Default values for ALL settings
	// They get set upon initialization
	public static var downscroll:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var middleScroll:Bool = false;
	public static var underlayAlpha:Float = 0;
	public static var offset:Float = 0;
	public static var safeFrames:Int = 10;
	public static var fpsCap:Int = 60;
	public static var scrollSpeed:Float = 1;
	public static var accuracyMode:Int = 0;
	public static var resetButton:Bool = false;
	public static var noteSkin:String = "default";
	public static var strumlineMargin:Int = 100;
	public static var stationaryRatings:Bool = false;
	public static var ratingPos:Array<Float> = [431.667, 365];
	public static var comboPos:Array<Float> = [431.667, 515];
	public static var comboSprPos:Array<Float> = [581.667, 440];
	public static var noteSplashes:Bool = true;
	public static var npsDisplay:Bool = false;
	public static var healthBarColors:Bool = true;
	public static var hideHealthIcons:Bool = false;
	public static var posBarType:Int = 0;
	public static var hitsoundType:Int = 0;
	public static var hitsoundVolume:Float = 0;
	public static var consistencyBar:Bool = false;

	public static var flashing:Bool = true;
	public static var distractions:Bool = true;
	public static var fps:Bool = true;
	public static var watermarks:Bool = true;
	public static var cacheMusic:Bool = false;
	public static var cacheImages:Bool = false;
	public static var resumeCountdown:Bool = true;
	public static var botplay:Bool = false;
	public static var dynamicCamera:Float = 0;
	public static var videoCutscenes:Bool = false;

	public static var persistentVolume:Bool = true;
	public static var autopause:Bool = true;

	public static var lastVolume:Float = 1;
	public static var lastMuted:Bool = false;

	// experimental
	public static var difficultyVocals:Bool = false;

	/**
	 * Set all `Settings` values with its' specific `FlxG.save.data` slot.
	 */
	public static function load():Void
	{
		downscroll = FlxG.save.data.downscroll;
		ghostTapping = FlxG.save.data.ghost;
		middleScroll = FlxG.save.data.middleScroll;
		underlayAlpha = FlxG.save.data.underlayAlpha;
		offset = FlxG.save.data.offset;
		safeFrames = FlxG.save.data.safeFrames;
		fpsCap = FlxG.save.data.fpsCap;
		scrollSpeed = FlxG.save.data.scrollSpeed;
		accuracyMode = FlxG.save.data.accuracyMode;
		resetButton = FlxG.save.data.resetButton;
		noteSkin = FlxG.save.data.noteSkin;
		strumlineMargin = FlxG.save.data.strumlineMargin;
		stationaryRatings = FlxG.save.data.stationaryRatings;
		ratingPos = FlxG.save.data.ratingPos;
		comboPos = FlxG.save.data.comboPos;
		comboSprPos = FlxG.save.data.comboSprPos;
		noteSplashes = FlxG.save.data.noteSplashes;
		npsDisplay = FlxG.save.data.npsDisplay;
		healthBarColors = FlxG.save.data.healthBarColors;
		hideHealthIcons = FlxG.save.data.hideHealthIcons;
		posBarType = FlxG.save.data.posBarType;
		hitsoundType = FlxG.save.data.hitsoundType;
		hitsoundVolume = FlxG.save.data.hitsoundVolume;
		consistencyBar = FlxG.save.data.consistencyBar;

		///////////////////////////////////

		flashing = FlxG.save.data.flashing;
		distractions = FlxG.save.data.distractions;
		fps = FlxG.save.data.fps;
		watermarks = FlxG.save.data.watermarks;
		cacheMusic = FlxG.save.data.cacheMusic;
		cacheImages = FlxG.save.data.cacheImages;
		resumeCountdown = FlxG.save.data.resumeCountdown;
		botplay = FlxG.save.data.botplay;
		dynamicCamera = FlxG.save.data.dynamicCamera;
		videoCutscenes = FlxG.save.data.videoCutscenes;
		persistentVolume = FlxG.save.data.persistentVolume;
		autopause = FlxG.save.data.autopause;
		lastVolume = FlxG.save.data.lastVolume;
		lastMuted = FlxG.save.data.lastMuted;

		///////////////////////////////////

		difficultyVocals = FlxG.save.data.difficultyVocals;

		FlxG.log.add("Settings loaded!");
	}

	/**
	 * Set all `FlxG.save.data` slots with the values from `Settings.`
	 * 
	 * Also writes to disk.
	 */
	public static function save():Void
	{
		FlxG.save.data.downscroll = downscroll;
		FlxG.save.data.ghost = ghostTapping;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.underlayAlpha = underlayAlpha;
		FlxG.save.data.offset = offset;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.fpsCap = fpsCap;
		FlxG.save.data.scrollSpeed = scrollSpeed;
		FlxG.save.data.accuracyMode = accuracyMode;
		FlxG.save.data.resetButton = resetButton;
		FlxG.save.data.noteSkin = noteSkin;
		FlxG.save.data.strumlineMargin = strumlineMargin;
		FlxG.save.data.stationaryRatings = stationaryRatings;
		FlxG.save.data.ratingPos = ratingPos;
		FlxG.save.data.comboPos = comboPos;
		FlxG.save.data.comboSprPos = comboSprPos;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.npsDisplay = npsDisplay;
		FlxG.save.data.healthBarColors = healthBarColors;
		FlxG.save.data.hideHealthIcons = hideHealthIcons;
		FlxG.save.data.posBarType = posBarType;
		FlxG.save.data.hitsoundType = hitsoundType;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.consistencyBar = consistencyBar;

		///////////////////////////////////

		FlxG.save.data.flashing = flashing;
		FlxG.save.data.distractions = distractions;
		FlxG.save.data.fps = fps;
		FlxG.save.data.watermarks = watermarks;
		FlxG.save.data.cacheMusic = cacheMusic;
		FlxG.save.data.cacheImages = cacheImages;
		FlxG.save.data.resumeCountdown = resumeCountdown;
		FlxG.save.data.botplay = botplay;
		FlxG.save.data.dynamicCamera = dynamicCamera;
		FlxG.save.data.videoCutscenes = videoCutscenes;
		FlxG.save.data.persistentVolume = persistentVolume;
		FlxG.save.data.autopause = autopause;
		FlxG.save.data.lastVolume = lastVolume;
		FlxG.save.data.lastMuted = lastMuted;

		///////////////////////////////////

		FlxG.save.data.difficultyVocals = difficultyVocals;

		FlxG.save.flush();

		FlxG.log.add("Settings saved!");
	}

	public static function init():Void
	{
		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = downscroll;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = ghostTapping;

		if (FlxG.save.data.middleScroll == null)
			FlxG.save.data.middleScroll = middleScroll;

		if (FlxG.save.data.underlayAlpha == null)
			FlxG.save.data.underlayAlpha = underlayAlpha;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = offset;

		if (FlxG.save.data.safeFrames == null)
			FlxG.save.data.safeFrames = safeFrames;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = fpsCap;

		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = scrollSpeed;

		if (FlxG.save.data.accuracyMode == null)
			FlxG.save.data.accuracyMode = accuracyMode;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = resetButton;

		if (FlxG.save.data.noteSkin == null)
			FlxG.save.data.noteSkin = noteSkin;

		if (FlxG.save.data.strumlineMargin == null)
			FlxG.save.data.strumlineMargin = strumlineMargin;

		if (FlxG.save.data.stationaryRatings == null)
			FlxG.save.data.stationaryRatings = stationaryRatings;

		if (FlxG.save.data.ratingPos == null)
			FlxG.save.data.ratingPos = ratingPos;

		if (FlxG.save.data.comboPos == null)
			FlxG.save.data.comboPos = comboPos;

		if (FlxG.save.data.comboSprPos == null)
			FlxG.save.data.comboSprPos = comboSprPos;

		if (FlxG.save.data.noteSplashes == null)
			FlxG.save.data.noteSplashes = noteSplashes;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = npsDisplay;

		if (FlxG.save.data.healthBarColors == null)
			FlxG.save.data.healthBarColors = healthBarColors;

		if (FlxG.save.data.hideHealthIcons == null)
			FlxG.save.data.hideHealthIcons = hideHealthIcons;

		if (FlxG.save.data.posBarType == null)
			FlxG.save.data.posBarType = posBarType;

		if (FlxG.save.data.hitsoundType == null)
			FlxG.save.data.hitsoundType = hitsoundType;

		if (FlxG.save.data.hitsoundVolume == null)
			FlxG.save.data.hitsoundVolume = hitsoundVolume;

		if (FlxG.save.data.consistencyBar == null)
			FlxG.save.data.consistencyBar = consistencyBar;

		///////////////////////////////////

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = flashing;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = distractions;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = fps;

		if (FlxG.save.data.watermarks == null)
			FlxG.save.data.watermarks = watermarks;

		if (FlxG.save.data.cacheMusic == null)
			FlxG.save.data.cacheMusic = cacheMusic;

		if (FlxG.save.data.cacheImages == null)
			FlxG.save.data.cacheImages = cacheImages;

		if (FlxG.save.data.resumeCountdown == null)
			FlxG.save.data.resumeCountdown = resumeCountdown;

		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = botplay;

		if (FlxG.save.data.dynamicCamera == null)
			FlxG.save.data.dynamicCamera = dynamicCamera;

		if (FlxG.save.data.videoCutscenes == null)
			FlxG.save.data.videoCutscenes = videoCutscenes;

		if (FlxG.save.data.persistentVolume == null)
			FlxG.save.data.persistentVolume = persistentVolume;

		if (FlxG.save.data.autopause == null)
			FlxG.save.data.autopause = autopause;

		///////////////////////////////////

		if (FlxG.save.data.difficultyVocals == null)
			FlxG.save.data.difficultyVocals = difficultyVocals;

		if (FlxG.save.data.lastVolume == null)
			FlxG.save.data.lastVolume = lastVolume;

		if (FlxG.save.data.lastMuted == null)
			FlxG.save.data.lastMuted = lastMuted;

		// this is NULL?!?!?
		if (FlxG.save.data.windowSettings == null)
			FlxG.save.data.windowSettings = new Map<Dynamic, Dynamic>();

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		FlxG.log.add("Settings initialized!");

		initDefaults();
		load();
		save();

		FlxG.updateFramerate = FlxG.drawFramerate = fpsCap;
		FlxG.autoPause = autopause;

		if (Settings.persistentVolume)
		{
			FlxG.sound.volume = Settings.lastVolume;

			if (Settings.lastMuted)
			{
				FlxG.sound.muted = false;
				FlxG.sound.toggleMuted();
			}
		}
	}

	static var defaultSettings:Map<String, Dynamic> = new Map<String, Dynamic>();

	static function initDefaults():Void
	{
		var settings:Array<String> = Type.getClassFields(Settings);

		var cl = Type.resolveClass("Settings");

		for (setting in settings)
		{
			var shit = Reflect.field(cl, setting);

			if ((shit is Int || shit is Float || shit is Bool || shit is Array || shit is String) && setting != "defaultSettings")
				defaultSettings.set(setting, shit);
		}
	}

	public static function setToDefaults():Void
	{
		for (setting => value in defaultSettings.copy())
		{
			var cl = Type.resolveClass("Settings");
			Reflect.setField(cl, setting, value);
		}

		save();
		load();
	}
}
