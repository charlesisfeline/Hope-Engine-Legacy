package;

import haxe.Json;
import openfl.Assets;
import sys.FileSystem;

using StringTools;

#if FILESYSTEM
import sys.io.File;
#end

typedef EventData =
{
	var events:Array<Array<EventNote>>; // WELL?!?!?!
	
	/*
	See "events json model.jsonc"
	*/
}

typedef EventNote = 
{
	var strumTime:Float;
	var events:Array<SwagEvent>;
}

// used in JSON file
typedef EventInfo = 
{
	var eventName:String;
	var eventDesc:String;
}

typedef SwagEvent =
{
	var eventID:String; // the event ID for the game and folder name
	var params:Array<EventParam>; // array of params to be parsed in the charter
}

typedef EventParam =
{
	var paramName:String;
	var paramID:String;
	var type:String; // "bool", "float", "int", "string"
	var value:Null<Dynamic>; // you know what it is
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
		if (!FileSystem.exists(Sys.getCwd() + mod + "/assets/data/" + folderLowercase + '/events.json')) return null;
		var rawJson = File.getContent(Sys.getCwd() + mod + "/assets/data/" + folderLowercase + '/events.json').trim();
		#else
		if (!Assets.exists(Paths.json(folderLowercase + '/events'))) return null;
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
