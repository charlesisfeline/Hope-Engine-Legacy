import flixel.FlxG;

class Ratings
{
    public static var ranks:Array<String> = [
        "PRFT",
        "PAIN",
        "SFRNG",
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
        "NA"
    ];

    public static function GenerateLetterRank(accuracy:Float, isNumberRank:Bool = false) // generate a letter ranking
    {
        var ranking:String = "N/A";
        var numberRank:Int = 17;
        var letterRanking:String = "";

		if(Settings.botplay)
			ranking = "BotPlay";

        if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous Full Combo
            ranking = "(SFC)";
        else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo
            ranking = "(GFC)";
        else if (PlayState.misses == 0) // Regular FC
            ranking = "(FC)";
        else if (PlayState.misses < 10) // Single Digit Miss
            ranking = "(SDM)";
        else
            ranking = "(PASS)";

        // WIFE TIME :)))) (based on Wife3)

        var wifeConditions:Array<Bool> = [
            accuracy >= 99.9935,                    // PRFT (Perfect)
            accuracy >= 99.980,                     // PAIN
            accuracy >= 99.970,                     // SFRNG (Suffering)
            accuracy >= 99.955,                     // SS+
            accuracy >= 99.90,                      // SS
            accuracy >= 99.80,                      // SS-
            accuracy >= 99.70,                      // S+
            accuracy >= 99,                         // S
            accuracy >= 96.50,                      // S-
            accuracy >= 93,                         // A+
            accuracy >= 90,                         // A
            accuracy >= 85,                         // A-
            accuracy >= 80,                         // B
            accuracy >= 70,                         // C
            accuracy >= 60,                         // D
            accuracy >= 50,                         // E
            accuracy > 0 && accuracy < 50,          // F
            accuracy <= 0                           // N/A
        ];

        for(i in 0...wifeConditions.length)
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

    public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
    {
        var customTimeScale = Conductor.timeScale;

        if (customSafeZone != null)
            customTimeScale = customSafeZone / 166;
	    
        if (noteDiff > 166 * customTimeScale) // so god damn early its a miss
            return "miss";
        if (noteDiff > 135 * customTimeScale) // way early
            return "shit";
        else if (noteDiff > 90 * customTimeScale) // early
            return "bad";
        else if (noteDiff > 45 * customTimeScale) // your kinda there
            return "good";
        else if (noteDiff < -45 * customTimeScale) // little late
            return "good";
        else if (noteDiff < -90 * customTimeScale) // late
            return "bad";
        else if (noteDiff < -135 * customTimeScale) // late as fuck
            return "shit";
        else if (noteDiff < -166 * customTimeScale) // so god damn late its a miss
            return "miss";
        return "sick";
    }

    public static function CalculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float):String
    {
        return 'Score: ${(Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score)} |'               // Score
        + ' Misses: ${PlayState.misses} |'                                                                           // Misses
        + ' Accuracy: ${(Settings.botplay ? "N/A" : Helper.truncateFloat(accuracy, 2) + "%")} |'      // Accuracy
        + ' ${GenerateLetterRank(accuracy)}';                                                                        // Letter Rank
    }
}
