package;

import modifiers.Modifiers;

class Ratings
{
	public static var ranks:Array<String> = [
		"PERFECT!",
		"ALMOST THERE!",
		"A TAD BIT THERE!",
		"SS+",
		"SS",
		"SS-",
		"S+",
		"S",
		"S-",
		"A+",
		"A",
		"A-",
		"B",
		"C",
		"D",
		"E",
		"F",
		"N/A"
	];

	public static function GenerateLetterRank(accuracy:Float, isNumberRank:Bool = false)
	{
		var ranking:String = "N/A";
		var numberRank:Int = 17;
		var letterRanking:String = "";

		if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0)
			ranking = "(SFC)";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1)
			ranking = "(GFC)";
		else if (PlayState.misses == 0)
			ranking = "(FC)";
		else if (PlayState.misses < 10)
			ranking = "(SDM)";
		else
			ranking = "(PASS)";

		if (Settings.botplay && !PlayState.instance.devBot)
			ranking = "Botplay";

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935,
			accuracy >= 99.980,
			accuracy >= 99.970,
			accuracy >= 99.955,
			accuracy >= 99.90,
			accuracy >= 99.80,
			accuracy >= 99.70,
			accuracy >= 99,
			accuracy >= 96.50,
			accuracy >= 93,
			accuracy >= 90,
			accuracy >= 85,
			accuracy >= 80,
			accuracy >= 70,
			accuracy >= 60,
			accuracy >= 50,
			accuracy > 0 && accuracy < 50,
			accuracy <= 0
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				letterRanking = ranks[i];
				numberRank = i;
				break;
			}
		}

		letterRanking = " " + letterRanking;

		if (PlayState.sickButNotReally == 0
			&& PlayState.goods == 0
			&& PlayState.bads == 0
			&& PlayState.shits == 0
			&& PlayState.misses == 0)
			letterRanking = " PURE PERFECT!";

		if (PlayState.songScore == 0
			&& PlayState.accuracy == 0)
		{
			ranking = "Nothing";
			letterRanking = "";
		}

		if (Settings.botplay && !PlayState.instance.devBot)
			letterRanking = "";

		ranking += letterRanking;

		return isNumberRank ? numberRank + "" : ranking;
	}

	public static var modifier:Float = 1;

	public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String
	{
		var customTimeScale = Conductor.timeScale;

		if (customSafeZone != null)
			customTimeScale = customSafeZone / 166;

		customTimeScale *= modifier;

		if (noteDiff > 166 * customTimeScale)
			return "miss";
		if (noteDiff > 135 * customTimeScale)
			return "shit";
		else if (noteDiff > 90 * customTimeScale)
			return "bad";
		else if (noteDiff > 45 * customTimeScale)
			return "good";
		else if (noteDiff < -45 * customTimeScale)
			return "good";
		else if (noteDiff < -90 * customTimeScale)
			return "bad";
		else if (noteDiff < -135 * customTimeScale)
			return "shit";
		else if (noteDiff < -166 * customTimeScale)
			return "miss";
		return "sick";
	}

	public static function CalculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		var multiplier:Float = 1;

		for (key => value in Modifiers.modifiers) 
		{
			if (value != Modifiers.modifierDefaults.get(key))
			{
				if (value is Float)
					multiplier += Modifiers.modifierRates.get(key) * value;
				else if (value is Bool)
					multiplier += Modifiers.modifierRates.get(key);
			}
		}

		return 'Score: ${(Conductor.safeFrames != 10 ? Std.int(score * multiplier) + " (" + Std.int(scoreDef * multiplier) + ")" : "" + Std.int(score * multiplier))} |'
			+ ' Misses: ${PlayState.misses} |'
			+ ' Accuracy: ${(Settings.botplay && !PlayState.instance.devBot ? "?" : Helper.completePercent(accuracy, 2) + "%")} |'
			+ ' ${GenerateLetterRank(accuracy)}';
	}
}
