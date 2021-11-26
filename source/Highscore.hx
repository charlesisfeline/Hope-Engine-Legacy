package;

import flixel.FlxG;
import haxe.iterators.StringIteratorUnicode;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songRanks:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRanks:Map<String, Int> = new Map<String, Int>();
	#end


	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		
		if (getModifierShit())
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}
		else 
			trace('A modifier is on! Score isn\'t saved :)');
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (getModifierShit())
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
		else 
			trace('A modifier is on! Week Score isn\'t saved :)');
	}

	public static function saveRank(song:String, rank:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (getModifierShit())
		{
			if (songRanks.exists(daSong))
			{
				if (songRanks.get(daSong) > rank)
					setRank(daSong, rank);
			}
			else
				setRank(daSong, rank);
		}
		else 
			trace('A modifier is on! Rank isn\'t saved :)');
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

	static function setRank(song:String, rank:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRanks.set(song, rank);
		FlxG.save.data.songRanks = songRanks;
		FlxG.save.flush();
	}

	/**
	 * Get modifier shit.
	 * `check` returns `true` when all modifiers are off.
	 * `list` returns the array of bools.
	 * `nameList` retuns the array of strings.
	 * 
	 * @param type "check", "list", "nameList"
	 */
	public static function getModifierShit(type:String = 'check'):Dynamic
	{
		var modifierNames:Array<String> = [
			"Botplay",
			"Chaos",
			"Hidden",
			"No Miss",
			"Sicks Only",
			"Goods Only",
			"Both Sides",
			"Enemy's Side",
			"Flash Notes",
			"Death Notes",
			"Lifesteal Notes"
		];

		var modifiers:Array<Bool> = [
			FlxG.save.data.botplay,
			FlxG.save.data.chaosMode, 
			FlxG.save.data.hiddenMode, 
			FlxG.save.data.fcOnly, 
			FlxG.save.data.sicksOnly,  
			FlxG.save.data.goodsOnly,
			FlxG.save.data.bothSides,
			FlxG.save.data.enemySide,
			FlxG.save.data.flashNotes != 0,
			FlxG.save.data.deathNotes != 0,
			FlxG.save.data.lifestealNotes != 0
		];

		switch (type)
		{
			case 'nameList':
				var toReturn = [];
				for (i in 0...modifiers.length) 
				{
					if (modifiers[i])
						toReturn.push(modifierNames[i]);
				}
				return toReturn;
			case 'list':
				return modifiers;
			case 'check':
				return !modifiers.contains(true);
		}

		return null; // just Don't
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getRank(song:String, diff:Int):Int
	{
		if (!songRanks.exists(formatSong(song, diff)))
			setRank(formatSong(song, diff), 17);

		return songRanks.get(formatSong(song, diff));
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

		if (FlxG.save.data.songRanks != null)
			songRanks = FlxG.save.data.songRanks;

		#if !UNLOCK_ALL_WEEKS
		if (FlxG.save.data.weeksUnlocked == null)
			FlxG.save.data.weeksUnlocked = [true];
		#end
	}
}