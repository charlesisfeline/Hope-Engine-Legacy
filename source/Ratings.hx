package;

import modifiers.Modifiers;

class Ratings
{
	public static var ranks:Array<String> = [
		"PERFECT!", "ALMOST THERE!", "A TAD BIT THERE!", "SS+", "SS", "SS-", "S+", "S", "S-", "A+", "A", "A-", "B", "C", "D", "E", "F", "N/A"
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

		if (PlayState.sickButNotReally == 0 && PlayState.goods == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.misses == 0)
			letterRanking = " PURE PERFECT!";

		if (PlayState.songScore == 0 && PlayState.accuracy == 0)
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
	public static var windows:Array<Array<Float>> = [[-166, 166], [-135, 135], [-90, 90], [-45, 45]];

	public static var ratings:Array<String> = ["shit", "bad", "good", "sick"];

	public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String
	{
		var customTimeScale = Conductor.timeScale;

		if (customSafeZone != null)
			customTimeScale = customSafeZone / 166;

		customTimeScale *= modifier;

		/*
			135 > x > 166 = miss
			90 > x > 135 = shit
			45 > x > 90 = good
			0 > x > 45 = sick
		 */

		var indexLol:Null<Int> = null;

		for (i in 0...windows.length)
		{
			var time = windows[i];
			var nextTime = windows[i + 1] != null ? windows[i + 1] : [0.0, 0.0];

			if (noteDiff < 0)
			{
				if (noteDiff >= time[0] * customTimeScale && noteDiff <= nextTime[0] * customTimeScale)
					indexLol = i;
			}
			else
			{
				if (noteDiff <= time[1] * customTimeScale && noteDiff >= nextTime[1] * customTimeScale)
					indexLol = i;
			}
		}

		if (indexLol != null)
			return ratings[indexLol];

		// flat out give up
		return 'miss';
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

		return
			'Score: ${(Conductor.safeFrames != 10 ? Std.int(score * multiplier) + " (" + Std.int(scoreDef * multiplier) + ")" : "" + Std.int(score * multiplier))} ${PlayState.scoreSeparator}'
			+ ' Misses: ${PlayState.misses} ${PlayState.scoreSeparator}'
			+ ' Accuracy: ${(Settings.botplay && !PlayState.instance.devBot ? "?" : Helper.completePercent(accuracy, 2) + "%")} ${PlayState.scoreSeparator}'
			+ ' ${GenerateLetterRank(accuracy)}';
	}
}
