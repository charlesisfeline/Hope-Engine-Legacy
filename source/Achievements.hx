package;

import flixel.FlxG;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

typedef Achievement =
{
	var name:String;
	var desc:String;
	var hint:Null<String>;
}

typedef AchInfo =
{
	var timeGained:String;
}

/**
 * All things achievements!
 */
class Achievements
{
	public static var achievements:Array<String> = [];
	public static var achievementsGet:Map<String, AchInfo> = new Map<String, AchInfo>();

	public static function init():Void
	{
		#if FILESYSTEM
		var listPath = Sys.getCwd() + Paths.achievementList();

		if (!FileSystem.exists(listPath))
			Sys.exit(0);
		else
		{
			var list = File.getContent(listPath);
			var items = list.trim().split('\n');

			for (achievement in items)
				achievements.push(achievement.trim());
		}
		#end

		if (FlxG.save.data.achievementsGet == null)
			FlxG.save.data.achievementsGet = achievementsGet;

		load();
		save();

		FlxG.log.add("Achievements initialized!");
	}

	public static function load():Void
	{
		achievementsGet = FlxG.save.data.achievementsGet;
		FlxG.log.add("Achievements loaded!");
	}

	public static function save():Void
	{
		FlxG.save.data.achievementsGet = achievementsGet;

		FlxG.save.flush();

		FlxG.log.add("Achievements saved!");
	}

	public static function give(achievementId:String):Void
	{
		save();
		load();
	}

	public static function take(achievementId:String, ?showNotif:Bool = false):Void
	{
		save();
		load();
	}
}
