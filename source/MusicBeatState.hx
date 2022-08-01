package;

import lime.utils.Assets;
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

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
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

	override function destroy()
	{
		#if !html5
		if (!Settings.cacheMusic)
		{
			for (sound in Paths.trackedSoundKeys)
			{
				OpenFlAssets.cache.clear(sound);
				Paths.trackedSoundKeys.remove(sound);
			}

			Assets.cache.clear("assets/songs");
		}
		#end

		Assets.cache.clear("assets/sounds");
		Assets.cache.clear("assets/shared/sounds");

		if (!Settings.cacheImages)
		{
			for (image in Paths.trackedImageKeys)
			{
				OpenFlAssets.cache.clear(image);
				Paths.trackedImageKeys.remove(image);
			}

			forEachExists(function(basic:FlxBasic) {
				remove(basic);
				basic.exists = false;
				basic.kill();
				basic.destroy();
			}, true);
		}

		super.destroy();

		if (!Settings.cacheImages)
			FlxG.bitmap.clearCache();

		openfl.system.System.gc();
	}
}
