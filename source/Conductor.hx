package;

import Song.SwagSong;
import flixel.FlxG;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

/**
 * Since everything is like so confusing about this,
 * this is the only class im gonna document some
 * stuff in
 */
class Conductor
{
	/**
	 * Beats per minute.
	 */
	public static var bpm:Float = 100;

	/**
	 * Time it takes to hit a beat.
	 * 
	 * It's in milliseconds, so divide it by 1000 when using it!
	 */
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds

	/**
	 * Time it takes to hit a step.
	 * 
	 * It's in milliseconds, so divide it by 1000 when using it!
	 */
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

	/**
	 * Current song position (in milliseconds).
	 * 
	 * If not updated, `beatHit` and `stepHit` are not updated.
	 */
	public static var songPosition:Float;

	/**
	 * Pause stuff.
	 */
	public static var lastSongPos:Float;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function recalculateTimings()
	{
		Conductor.safeFrames = Settings.safeFrames;
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}