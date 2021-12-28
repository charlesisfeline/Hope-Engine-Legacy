package;

#if FILESYSTEM
import sys.io.File;
#end
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import lime.tools.AssetType;
import lime.utils.AssetType;
import openfl.Assets;

typedef MenuCharacterJSON = {
	var character:String;
	var animations:Array<Dynamic>;
	var settings:Array<Dynamic>;
}

class CharacterSetting
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var scale(default, null):Float;
	public var flipped(default, null):Bool;

	public function new(x:Int = 0, y:Int = 0, scale:Float = 1.0, flipped:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.scale = scale;
		this.flipped = flipped;
	}
}

class MenuCharacter extends FlxSprite
{
	static var settings:Map<String, CharacterSetting> = new Map<String, CharacterSetting>();
	static var characterSettingsJSON:Array<Dynamic> = [];
	public var danced:Bool = false;
	public var curCharacter:String = '';
	
	var flipped:Bool = false;
	var scaleDeezNuts:Float = 1.0;

	public function new(x:Int, y:Int, scale:Float, flipped:Bool)
	{
		super(x, y);
		
		if (Paths.currentMod == null)
		{
			var pain:Array<MenuCharacterJSON> = Json.parse(Assets.getText('assets/images/menuCharacters/_characterSettings.json'));
			
			for (a in pain)
			{
				if (!characterSettingsJSON.contains(a))
					characterSettingsJSON.push(a);
			}
		}
		else
		{
			var pain:Array<MenuCharacterJSON> = Json.parse(File.getContent('mods/${Paths.currentMod}/assets/images/menuCharacters/_characterSettings.json'));

			for (a in pain)
			{
				if (!characterSettingsJSON.contains(a))
					characterSettingsJSON.push(a);
			}
		}

		for (fuck in characterSettingsJSON)
		{
			if (fuck.settings != null)
				settings.set(fuck.character, new CharacterSetting(fuck.settings.x, fuck.settings.y, fuck.settings.scale, fuck.settings.flipped));
		}
		
		this.flipped = flipped;
		this.scaleDeezNuts = scale;
		antialiasing = true;

		setGraphicSize(Std.int(width * scale));
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
		if (Paths.currentMod != null)
		{
			var pain:Array<MenuCharacterJSON> = Json.parse(File.getContent('mods/${Paths.currentMod}/assets/images/menuCharacters/_characterSettings.json'));

			for (a in pain)
			{
				if (!characterSettingsJSON.contains(a))
					characterSettingsJSON.push(a);
			}
		}
		if (character == '')
		{
			visible = false;
			return;
		}
		else
			visible = true;

		if (curCharacter != character)
			curCharacter = character;
		else
			return;

		frames = Paths.getSparrowAtlas('menuCharacters/' + character);

		// so many ifs....
		for (fuck in characterSettingsJSON)
		{
			if (fuck.character == character)
			{
				if (fuck.animations != null)
				{
					if (fuck.animations.danceLeft != null)
						addAnimation("danceLeft", fuck.animations.danceLeft.prefix, fuck.animations.danceLeft.fps, fuck.animations.danceLeft.indices, fuck.animations.danceLeft.looped);

					if (fuck.animations.danceRight != null)
						addAnimation("danceRight", fuck.animations.danceRight.prefix, fuck.animations.danceRight.fps, fuck.animations.danceRight.indices, fuck.animations.danceRight.looped);
					
					if (fuck.animations.hey != null)
						addAnimation("hey", fuck.animations.hey.prefix, fuck.animations.hey.fps, fuck.animations.hey.indices, fuck.animations.hey.looped);

					if (fuck.animations.idle != null)
						addAnimation("idle", fuck.animations.idle.prefix, fuck.animations.idle.fps, fuck.animations.idle.indices, fuck.animations.idle.looped);
				}
			}
		}

		var setting:CharacterSetting = settings[character];
		
		if (setting != null)
		{
			setGraphicSize(Std.int(width * setting.scale));
			flipX = setting.flipped != flipped;
			offset.set(setting.x, setting.y);
		}


		setGraphicSize(Std.int(width * scaleDeezNuts));
		updateHitbox();
	}

	function addAnimation(name:String, prefix:String, fps:Int = 24, ?indices:Array<Int>, ?looped:Bool = false)
	{
		if (indices == null)
			animation.addByPrefix(name, prefix, fps, looped);
		else
			animation.addByIndices(name, prefix, indices, "", fps, looped);
	}
}
