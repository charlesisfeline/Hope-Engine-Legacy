package;

import haxe.Json;
import openfl.Assets;

using StringTools;

#if FILESYSTEM
import sys.io.File;
#end

typedef EventData =
{
	var events:Array<Array<SwagEvent>>; // WELL?!?!?!
}

typedef SwagEvent =
{
	var eventName:String; // the event name for the charter
	var eventDesc:String; // the event description for the charter
	var eventTime:Float; // time where the event happens
	var params:Array<EventParam>; // array of params to be parsed in the charter
}

typedef EventParam =
{
	var type:String; // "bool", "float", "int", "string"
	var value:Dynamic; // you know what it is
	var increment:Null<Float>; // can be null, increment for float/int params
	var maxLetters:Null<Int>; // can be null, max letters for string values
	var defaultValue:Dynamic; // default value for anything really
}

class Event
{
	public static function load(folder:String, ?mod:String = ""):EventData
	{
		var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();

		trace('loading events for ' + folderLowercase);

		#if FILESYSTEM
		var rawJson = File.getContent(Sys.getCwd() + mod + "/assets/data/" + folderLowercase + '/events.json').trim();
		#else
		var rawJson = Assets.getText(Paths.json(folderLowercase + '/events')).trim();
		#end

		return parseJSON(rawJson);
	}

	public static function parseJSON(rawJson:String):EventData
	{
		var swagShit:EventData = cast Json.parse(rawJson);
		return swagShit;
	}
}
