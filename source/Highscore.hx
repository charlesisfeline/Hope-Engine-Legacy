package;

import flixel.FlxG;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map();
	public static var songAccuracies:Map<String, Float> = new Map();

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (!Settings.botplay && !PlayState.openedCharting)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (!Settings.botplay && !PlayState.openedCharting)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}
	}

	public static function saveAccuracy(song:String, acc:Float = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (!Settings.botplay && !PlayState.openedCharting)
		{
			if (songAccuracies.exists(daSong))
			{
				if (songAccuracies.get(daSong) < acc)
					setAccuracy(daSong, acc);
			}
			else
				setAccuracy(daSong, acc);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setAccuracy(song:String, acc:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songAccuracies.set(song, acc);
		FlxG.save.data.songAccuracies = songAccuracies;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		daSong += CoolUtil.difficultySuffixfromInt(diff);

		// mod songs have their mod's name as their prefix
		// just so that nothing gets overwritten
		if (Paths.currentMod != null)
			daSong = Paths.currentMod + ':' + daSong;

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getAccuracy(song:String, diff:Int):Float
	{
		if (!songAccuracies.exists(formatSong(song, diff)))
			setAccuracy(formatSong(song, diff), 0);

		return songAccuracies.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songAccuracies != null)
			songAccuracies = FlxG.save.data.songAccuracies;

		#if !UNLOCK_ALL_WEEKS
		if (FlxG.save.data.weeksUnlocked == null)
			FlxG.save.data.weeksUnlocked = [true];
		#end
	}
}
