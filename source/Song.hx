package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
<<<<<<< HEAD
	var speed:Null<Float>;
=======
	var speed:Float;
>>>>>>> upstream

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String, ?mod:String = ""):SwagSong
	{
		// pre lowercasing the song name (update)
<<<<<<< HEAD
		var folderLowercase = Paths.toSongPath(folder);
=======
		var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();
>>>>>>> upstream

		trace('loading ' + folderLowercase + '/' + jsonInput.toLowerCase());

		#if FILESYSTEM
		var rawJson = File.getContent(Sys.getCwd() + mod + "/assets/data/" + folderLowercase + '/' + jsonInput.toLowerCase() + ".json").trim();
		#else
		var rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase())).trim();
		#end

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
