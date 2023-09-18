package;

<<<<<<< HEAD
import editors.WeekEditor.Week;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

#if FILESYSTEM
import editors.WeekEditor.Week;
import sys.FileSystem;
import sys.io.File;
#end

=======
#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;
>>>>>>> upstream

class CoolUtil
{
	public static var difficultyArray:Array<Array<String>> = [['EASY', '-easy', null], ['NORMAL', '', null], ['HARD', '-hard', null]];

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
		difficultyArray = [['EASY', '-easy', null], ['NORMAL', '', null], ['HARD', '-hard', null]];

		if (FileSystem.exists(Paths.txt('customDifficulties')))
		{
			var difficultyFile:Array<String> = coolStringFile(File.getContent(Paths.txt('customDifficulties')));

			for (diff in difficultyFile)
			{
				var a = diff.split(':');

				difficultyArray.push([a[0], a[1], Paths.currentMod]);
			}
		}
	}
	#end

<<<<<<< HEAD
	public static function fileNameCheck(name:String):Bool
	{
		switch (name.toUpperCase())
		{
			// LMAO
			case "CON" | "PRN" | "AUX" | "NUL" | "COM1" | "COM2" | "COM3" | "COM4" | "COM5" | "COM6" | "COM7" | "COM8" | "COM9" | "LPT1" | "LPT2" | "LPT3" | "LPT4" | "LPT5" | "LPT6" | "LPT7" | "LPT8" | "LPT9":
				return false;
			default:
				return true;
		}
	}

=======
>>>>>>> upstream
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
<<<<<<< HEAD

	public static function getWeek(num:Int, ?mod:Null<String> = null):Week
	{
		var list:Array<String> = [];
		
		#if FILESYSTEM
		if (mod != null)
		{
			list = CoolUtil.coolStringFile(File.getContent(Sys.getCwd() + "mods/" + mod + "/assets/_weeks/_weekList.txt"));

			var path = Sys.getCwd() + "mods/" + mod + "/assets/_weeks/" + list[num] + ".json";
			return cast Json.parse(File.getContent(path));
		}
		else
		#end
		{
			list = CoolUtil.coolTextFile("assets/_weeks/_weekList.txt");
			
			var path = "assets/_weeks/" + list[num] + ".json";
			return cast Json.parse(Assets.getText(path));
		}

		return null;
	}
=======
>>>>>>> upstream
}
