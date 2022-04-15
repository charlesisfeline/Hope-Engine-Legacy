import flixel.FlxG;

class Ratings
{
	public static var ranks:Array<String> = [
		"PRFT", "PAIN", "SFRNG", "SS+", "SS", "SS-", "S+", "S", "S-", "A+", "A", "A-", "B", "C", "D", "E", "F", "NA"
	];

	public static function GenerateLetterRank(accuracy:Float, isNumberRank:Bool = false)
	{
		var ranking:String = "N/A";
		var numberRank:Int = 17;
		var letterRanking:String = "";

		if (Settings.botplay)
			ranking = "BotPlay";

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

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // PRFT (Perfect)
			accuracy >= 99.980, // PAIN
			accuracy >= 99.970, // SFRNG (Suffering)
			accuracy >= 99.955, // SS+
			accuracy >= 99.90, // SS
			accuracy >= 99.80, // SS-
			accuracy >= 99.70, // S+
			accuracy >= 99, // S
			accuracy >= 96.50, // S-
			accuracy >= 93, // A+
			accuracy >= 90, // A
			accuracy >= 85, // A-
			accuracy >= 80, // B
			accuracy >= 70, // C
			accuracy >= 60, // D
			accuracy >= 50, // E
			accuracy > 0 && accuracy < 50, // F
			accuracy <= 0 // N/A
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

		ranking += " " + letterRanking;

		return isNumberRank ? numberRank + "" : ranking;
	}

	public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String
	{
		var customTimeScale = Conductor.timeScale;

		if (customSafeZone != null)
			customTimeScale = customSafeZone / 166;

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
		return 'Score: ${(Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score)} |'
			+ ' Misses: ${PlayState.misses} |'
			+ ' Accuracy: ${(Settings.botplay ? "N/A" : Helper.truncateFloat(accuracy, 2) + "%")} |'
			+ ' ${GenerateLetterRank(accuracy)}';
	}
}
