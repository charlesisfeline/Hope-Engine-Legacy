package;

import flash.media.Sound;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
import yaml.Yaml;
#end

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

	/**
	 * Set current level. Things like "tutorial", "week1", "week2", etc...
	 * @param name Name of the to-be current level.
	 */
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	/**
	 * Set current mod. Kind of like setCurrentLevel but for mods.
	 * @param name Name of the to-be current mod.
	 */
	static public function setCurrentMod(name:String)
	{
		currentMod = (name == null ? null : name);
	}

	/**
	 * Get paths easily.
	 * @param file Name of the file.
	 * @param type Well, what kinda file is it?
	 * @param library "week1", "week2", "preload", etc...
	 */
	public static function getPath(file:String, type:AssetType, library:Null<String>)
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

	/**
	 * Search for a file without having the hassle of shittons of compiler conditionals.
	 * @param path The path to the file. 
	 */
	static public function exists(path:String):Bool
	{
		var doesIt:Bool = false;

		#if FILESYSTEM
		doesIt = FileSystem.exists(path);
		#else
		doesIt = Assets.exists(path);
		#end

		return doesIt;
	}

	/**
	 * Free up memory.
	 */
	static public function destroyCustomImages() 
	{
		#if FILESYSTEM
		for (key in customImages.keys())	
		{
			var piss:FlxGraphic = customImages.get(key);
			if (piss != null)
			{
				piss.bitmap.dispose();
				piss.destroy();
				FlxG.bitmap.removeByKey(key);
			}
		}

		customImages.clear();
		#end
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
		#if FILESYSTEM
		if (currentMod != null && FileSystem.exists(modFile(file, type, library)))
		{
			if (OpenFlAssets.exists(modFile(file, type, library)))
				return modFile(file, type, library);
			
			return File.getContent(modFile(file, type, library));
		}
		#end

		return getPath(file, type, library);
	}

	inline static public function modchart(key:String,?library:String)
	{
		return getPath('data/$key.hemc', TEXT, library);
	}

	inline static public function dialogueStartFile(key:String)
	{
		#if FILESYSTEM
		if (currentMod != null && FileSystem.exists(modDialogueStartFile(key)))
			return modDialogueStartFile(key);
		#end

		return 'assets/data/${key}/dialogueStart.txt';
	}

	inline static public function dialogueEndFile(key:String)
	{
		#if FILESYSTEM
		if (currentMod != null && FileSystem.exists(modDialogueEndFile(key)))
			return modDialogueEndFile(key);
		#end

		return 'assets/data/${key}/dialogueEnd.txt';
	}

	inline static public function dialogueSettingsFile(key:String)
	{
		#if FILESYSTEM
		if (currentMod != null && FileSystem.exists(modDialogueSettingsFile(key)))
			return modDialogueSettingsFile(key);
		#end

		return 'assets/data/${key}/dialogueSettings.json';
	}

	inline static public function txt(key:String, ?library:String)
	{
		#if FILESYSTEM
		if (currentMod != null && FileSystem.exists(modTxt(key, library)))
			return modTxt(key, library);
		#end
		
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		#if FILESYSTEM
		if (currentMod != null && FileSystem.exists(modJson(key, library)))
			return modJson(key, library);
		#end
		
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function characterJson(key:String)
	{
		#if FILESYSTEM
		if (currentMod != null && FileSystem.exists('mods/$currentMod/assets/_characters/$key.json'))
			return 'mods/$currentMod/assets/_characters/$key.json';
		#end
		
		return 'assets/_characters/$key.json';
	}

	inline static public function noteJSON(key:String, mod:String)
	{
		#if FILESYSTEM
		if (mod != "hopeEngine")
			return 'mods/$mod/assets/_noteTypes/$key/note.json';
		#end

		return 'assets/_noteTypes/$key/note.json';
	}

	inline static public function noteHENT(key:String, mod:String) // you know, I had a crisis between "hent" and "heNT" when naming the files
	{
		#if FILESYSTEM
		if (mod != "hopeEngine")
			return 'mods/$mod/assets/_noteTypes/$key/note.hent';
		#end

		return 'assets/_noteTypes/$key/note.hent';
	}

	static public function sound(key:String, ?library:String):Dynamic
	{
		#if FILESYSTEM
		var pissOff = modSound(key, library);
		if (FileSystem.exists(pissOff))
		{
			if (!customSongs.exists(pissOff))
				customSongs.set(pissOff, Sound.fromFile(pissOff));
			return customSongs.get(pissOff);
		}
		#end
		
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{	
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		#if FILESYSTEM
		var pissOff = modMusic(key, library);
		if (FileSystem.exists(pissOff))
		{
			if (!customSongs.exists(pissOff))
				customSongs.set(pissOff, Sound.fromFile(pissOff));
			return customSongs.get(pissOff);
		}
		#end

		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Dynamic
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		#if FILESYSTEM
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
		
		#if FILESYSTEM
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

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if FILESYSTEM
		var pissOff = modImage(key, library);
		if (FileSystem.exists(pissOff))
		{
			if (!customImages.exists(pissOff))
			{
				var a = FlxGraphic.fromBitmapData(BitmapData.fromFile(pissOff));
				a.persist = true;
				
				customImages.set(pissOff, a);
			}

			return customImages.get(pissOff);
		}
		#end
		
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

	#if FILESYSTEM
	inline static public function loadModFile(mod:String) // the "loadMod" file
	{
		return 'mods/$mod/loadMod';
	}

	inline static public function modInfoFile(mod:String) // mod-info.json
	{
		return 'mods/$mod/modInfo';
	}

	inline static public function checkModLoad(mod:String):Bool // mod-info.json
	{
		if (FileSystem.exists(loadModFile(mod)))
		{
			var yaml = Yaml.parse(File.getContent(loadModFile(mod)));
			return yaml.get("load");
		}

		return false;
	}

	inline static public function modInst(song:String)
	{
		return 'mods/$currentMod/assets/songs/${song}/Inst.$SOUND_EXT';
	}

	inline static public function modVoices(song:String)
	{
		return 'mods/$currentMod/assets/songs/${song}/Voices.$SOUND_EXT';
	}

	inline static public function modMusic(key:String, ?library:String)
	{
		return 'mods/$currentMod/' + getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function modSound(key:String, ?library:String)
	{
		return 'mods/$currentMod/' + getPath('sounds/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function modImage(image:String, ?library:String)
	{
		return 'mods/$currentMod/' + getPath('images/$image.png', IMAGE, library);
	}

	inline static public function modModchart(key:String, ?library:String) // I am so fucking terrified
	{
		return 'mods/$currentMod/' + getPath('data/$key.hemc', TEXT, library);
	}

	inline static public function modDialogueStartFile(key:String)
	{
		return 'mods/$currentMod/assets/data/${key}/dialogueStart.txt';
	}

	inline static public function modDialogueEndFile(key:String)
	{
		return 'mods/$currentMod/assets/data/${key}/dialogueEnd.txt';
	}

	inline static public function modDialogueSettingsFile(key:String)
	{
		return 'mods/$currentMod/assets/data/${key}/dialogueSettings.json';
	}

	inline static public function modTxt(key:String, ?library:String)
	{
		return 'mods/$currentMod/' + getPath('data/$key.txt', TEXT, library);
	}

	inline static public function modJson(key:String, ?library:String)
	{
		return 'mods/$currentMod/' + getPath('data/$key.json', TEXT, library);
	}

	inline static public function modFile(file:String, type:AssetType = TEXT, ?library:String)
	{
		return 'mods/$currentMod/' + getPath(file, type, library);
	}
	#end
}
