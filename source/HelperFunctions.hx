using StringTools;

class HelperFunctions
{
    /**
     * Truncate a float.
     * @param number The number to truncate.
     * @param precision How many decimal places?
     * @return Truncated float.
     */
    public static function truncateFloat(number:Float, precision:Int):Float 
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	/**
	 * String to bool.
	 * @param bool `true` or `false` lmao
	 */
	public static function toBool(bool:String):Null<Bool>
	{
		switch (bool.toLowerCase())
		{
			case 'true': return true;
			case 'false': return false;
		}

		return null;
	}

	public static function getERegMatches(ereg:EReg, input:String, unique:Bool = false, index:Int = 0):Array<String> 
	{
		var matches = [];
		while (ereg.match(input)) 
		{
			if (unique)
			{
				if (!matches.contains(ereg.matched(index)))
					matches.push(ereg.matched(index)); 
			}
			else
				matches.push(ereg.matched(index));
			
			input = ereg.matchedRight();
		}
		return matches;
	}
}