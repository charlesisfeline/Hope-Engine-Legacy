package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import stats.CustomFPS;
import stats.CustomMEM;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	/**
	 * Global max hold time for most "left-right" option stuff
	 */
	public static var globalMaxHoldTime:Float = 0.5;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if FILESYSTEM
		initialState = Caching;
		#else
		initialState = TitleState;
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);

		FlxGraphic.defaultPersist = true;
		addChild(game);

		#if !mobile
		fpsCounter = new CustomFPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		#if debug
		var ramCount = new CustomMEM(10, 16, 0xffffff);
		addChild(ramCount);
		#end

		toggleFPS(Settings.fps);

		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		FlxG.save.bind('save', 'hopeEngine');
		PlayerSettings.init();
		Settings.init();
		Achievements.init();
		#end

		#if html5
		FlxG.autoPause = false;
		#end

		// WHAT????
		openfl.Assets.cache.enabled = !Settings.cacheImages && !Settings.cacheMusic;
		
		MainMenuState.hopeEngineVer = Assets.getText('version.awesome');
	}

	var game:FlxGame;
	var fpsCounter:CustomFPS;

	public function toggleFPS(fpsEnabled:Bool):Void
		fpsCounter.visible = fpsEnabled;
}
