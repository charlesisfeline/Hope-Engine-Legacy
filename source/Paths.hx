package;

#if desktop
import sys.FileSystem;
import sys.io.File;
#end
import flash.media.Sound;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;
	public static var currentMod:String;

	#if (haxe >= "4.0.0")
	public static var customImages:Map<String, FlxGraphic> = new Map();
	public static var customSongs:Map<String, Sound> = new Map();
	#else
	public static var customImages:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	public static var customSongs:Map<String, Sound> = new Map<String, Sound>();
	#end

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function setCurrentMod(name:String)
	{
		currentMod = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function modchart(key:String,?library:String)
	{
		return getPath('data/$key.hemc', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		if (OpenFlAssets.exists(getPath('data/$key.txt', TEXT, library), TEXT))
			return getPath('data/$key.txt', TEXT, library);
		else
			return null;
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Dynamic
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		#if desktop
		var pissOff = modVoices(songLowercase);
		if (FileSystem.exists(pissOff))
		{
			if (!customSongs.exists(pissOff))
				customSongs.set(pissOff, Sound.fromFile(pissOff));
			return customSongs.get(pissOff);
		}
		#end

		return 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):Dynamic
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		
		#if desktop
		var pissOff = modInst(songLowercase);
		if (FileSystem.exists(pissOff))
		{
			if (!customSongs.exists(pissOff))
				customSongs.set(pissOff, Sound.fromFile(pissOff));
			return customSongs.get(pissOff);
		}
		#end
		
		return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	#if desktop
	inline static public function modInst(song:String)
	{
		return 'mods/${currentMod}/assets/songs/${song}/Inst.$SOUND_EXT';
	}

	inline static public function modVoices(song:String)
	{
		return 'mods/${currentMod}/assets/songs/${song}/Voices.$SOUND_EXT';
	}

	inline static public function modModchart(song:String) // I am so fucking terrified
	{
		return 'mods/${currentMod}/assets/data/${song}/modchart.hemc';
	}
	#end
}
