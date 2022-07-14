package;

import scripts.ScriptConsole;
import lime.app.Application;
import haxe.CallStack;
import openfl.events.UncaughtErrorEvent;
import achievements.Achievements;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import modifiers.Modifiers;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import stats.CustomFPS;
import stats.CustomMEM;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
#end


class Main extends Sprite
{
	public static var console:ScriptConsole;

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

		// FlxGraphic.defaultPersist = true;
		addChild(game);
		CustomTransition.init();
		addChild(CustomTransition.trans);

		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		FlxG.save.bind('save', 'hopeEngine');
		PlayerSettings.init();
		Settings.init();
		Achievements.init();
		Modifiers.init();
		signalsShit();

		if (Paths.exists('mods/${FlxG.save.data.priority}'))
			Paths.priorityMod = FlxG.save.data.priority;
		else
			FlxG.save.data.priority = Paths.priorityMod = "hopeEngine";

		FlxG.save.flush();

		// WHAT????
		openfl.Assets.cache.enabled = !Settings.cacheImages && !Settings.cacheMusic;
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, crash);

		// init console :)
		console = new ScriptConsole();
		addChild(console);

		fpsCounter = new CustomFPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(Settings.fps);

		#if debug
		var ramCount = new CustomMEM(10, 16, 0xffffff);
		addChild(ramCount);
		#end

		MainMenuState.hopeEngineVer = Assets.getText('version.awesome');
	}
	var game:FlxGame;
	var fpsCounter:CustomFPS;

	public function toggleFPS(fpsEnabled:Bool):Void
		fpsCounter.visible = fpsEnabled;

	public static function signalsShit():Void
	{
		FlxG.signals.focusGained.add(function()
		{
			if (!Settings.autopause)
				fadeIn();
			else
			{
				if (FreeplayState.vocals != null)
				{
					if (!FreeplayState.vocals.playing)
						FreeplayState.vocals.play();
				}
			}
		});
		
		FlxG.signals.focusLost.add(function()
		{
			if (!Settings.autopause)
				fadeOut();
			else 
			{
				if (FreeplayState.vocals != null)
				{
					if (FreeplayState.vocals.playing)
						FreeplayState.vocals.pause();
				}
			}
		});
	}

	static var lmao:Float = 1;

	static function fadeOut():Void
	{
		FlxTween.cancelTweensOf(FlxG.sound, ["volume"]);
		lmao = FlxG.sound.volume;
		FlxTween.tween(FlxG.sound, {volume: lmao * 0.5}, 0.5);
	}

	static function fadeIn():Void
	{
		FlxTween.cancelTweensOf(FlxG.sound, ["volume"]);
		FlxTween.tween(FlxG.sound, {volume: lmao}, 0.5);
	}

	// hi izzy engine
	// gedehari is a swag guy like fr
	// never would i discover what the hell this is
	static function crash(err:UncaughtErrorEvent):Void
	{
		if (!FileSystem.exists("crashLogs"))
			FileSystem.createDirectory("crashLogs");

		var curTime = Date.now().toString();
		curTime = curTime.replace(":", " ");
		curTime = curTime.replace(" ", "_");

		var path = "crashLogs/hopeCrash_" + curTime + ".txt";

		var stack = CallStack.exceptionStack(true);
		stack.reverse();
		var calls = "";

		for (call in stack)
		{
			switch (call)
			{
				case FilePos(s, file, line, column):
					calls += file + " (line " + line + ")\n";
				default:
					trace("This needs to be here?! " + call);
			}
		}

		var saved:Bool = false;

		if (stack.length > 0)
		{
			File.saveContent(path, calls + "\nError: " + err.error);
			saved = true;
		}

		calls += "\n" + err.error + "\n\n" 
			   + (saved ? "Log has been saved in the crash logs folder." : "There was no call stack, so nothing was saved.") 
			   + "\nHope Engine is in a very early stage, bugs are just about to be expected."
			   + '\nIf error persists, report on the GitHub: https://github.com/skuqre/Hope-Engine';

		Application.current.window.alert(calls, "Error!");
		Application.current.window.close();
	}
}
