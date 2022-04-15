package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import lime.app.Application;
import lime.system.System;
import openfl.Assets as OpenFlAssets;
import openfl.Lib;

using StringTools;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	private static var assets:Array<FlxSprite> = [];
	private static var toDestroy:Array<FlxSprite> = [];

	var usesMouse:Bool = false;

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		if (Std.isOfType(Object, FlxSprite))
		{
			var spr:FlxSprite = cast(Object, FlxSprite);

			if (spr.graphic != null)
			{
				assets.push(spr);
			}
		}

		var result = super.add(Object);
		return result;
	}

	public function clean()
	{
		for (i in assets)
		{
			assets.remove(i);
			remove(i, true);
			toDestroy.push(i);
		}
	}

	public function new()
	{
		#if !html5
		if (!Settings.cacheMusic)
		{
			for (sound in Paths.trackedSoundKeys)
			{
				OpenFlAssets.cache.clear(sound);
				Paths.trackedSoundKeys.remove(sound);
			}
		}
		#end

		if (!Settings.cacheImages)
		{
			for (image in Paths.trackedImageKeys)
			{
				OpenFlAssets.cache.clear(image);
				Paths.trackedImageKeys.remove(image);
			}
		}

		super();
		clean();
	}

	override function create()
	{
		for (i in toDestroy)
		{
			i.destroy();
			toDestroy.remove(i);
		}

		super.create();

		openfl.system.System.gc();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);

		if (usesMouse)
		{
			if (FlxG.mouse.justMoved && !FlxG.mouse.visible)
				FlxG.mouse.visible = true;
		}
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}
}
