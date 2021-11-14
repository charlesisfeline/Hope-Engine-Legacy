package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import lime.tools.AssetType;
import lime.utils.AssetType;
import openfl.Assets;

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
	static var characterSettingsJSON:Array<Dynamic>;
	public var danced:Bool = false;
	public var curCharacter:String = '';
	
	var flipped:Bool = false;
	var scaleDeezNuts:Float = 1.0;

	public function new(x:Int, y:Int, scale:Float, flipped:Bool)
	{
		super(x, y);
		
		if (characterSettingsJSON == null)
			characterSettingsJSON = Json.parse(Assets.getText('assets/images/menuCharacters/_characterSettings.json'));

		for (fuck in characterSettingsJSON)
			settings.set(fuck.character, new CharacterSetting(fuck.settings.x, fuck.settings.y, fuck.settings.scale, fuck.settings.flipped));

		this.flipped = flipped;
		this.scaleDeezNuts = scale;
		antialiasing = true;

		setGraphicSize(Std.int(width * scale));
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
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
						addAnimation("danceLeft", fuck.animations.danceLeft.prefix, fuck.animations.danceLeft.fps, fuck.animations.danceLeft.indices);

					if (fuck.animations.danceRight != null)
						addAnimation("danceRight", fuck.animations.danceRight.prefix, fuck.animations.danceRight.fps, fuck.animations.danceRight.indices);
					
					if (fuck.animations.hey != null)
						addAnimation("hey", fuck.animations.hey.prefix, fuck.animations.hey.fps, fuck.animations.hey.indices);

					if (fuck.animations.idle != null)
						addAnimation("idle", fuck.animations.idle.prefix, fuck.animations.idle.fps, fuck.animations.idle.indices);
				}
			}
		}

		var setting:CharacterSetting = settings[character];
		offset.set(setting.x, setting.y);
		setGraphicSize(Std.int(width * setting.scale));
		flipX = setting.flipped != flipped;


		setGraphicSize(Std.int(width * scaleDeezNuts));
		updateHitbox();
	}

	function addAnimation(name:String, prefix:String, fps:Int = 24, ?indices:Array<Int>)
	{
		if (indices == null)
			animation.addByPrefix(name, prefix, fps, false);
		else
			animation.addByIndices(name, prefix, indices, "", fps, false);
	}
}
