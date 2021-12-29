package;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<Array<String>> = [
		['EASY'		, '-easy', 		null],
		['NORMAL'	, '', 			null],
		['HARD'		, '-hard', 		null]
	];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty][0];
	}

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty][0];
	}

	public static function difficultySuffixfromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty][1];
	}

	public static function difficultySuffix():String
	{
		return difficultyArray[PlayState.storyDifficulty][1];
	}

	public static function difficultyIntFromString(difficulty:String):Int
	{
		for (item in difficultyArray)
		{
			if (item[0] == difficulty)
				return difficultyArray.indexOf(item);
		}

		return 1;
	}

	#if FILESYSTEM
	public static function loadCustomDifficulties():Void
	{
		if (FileSystem.exists(Paths.txt('customDifficulties')))
		{
			var difficultyFile:Array<String> = coolStringFile(File.getContent(Paths.txt('customDifficulties')));

			for (diff in difficultyFile)
			{
				var a = diff.split(':');

				difficultyArray.push([a[0], a[1], Paths.currentMod]);
				trace("difficulty loaded lmao: " + a[0], a[1], Paths.currentMod);
			}
		}
	}
	#end

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function awesomeDialogueFile(hugeFuckinThing:String):Array<String>
	{
		var daList:Array<String> = hugeFuckinThing.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	
	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}
