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
	var animations:MenuCharAnimations;
	var settings:MenuCharSettings;
}

typedef MenuCharSettings = {
	var x:Null<Int>;
	var y:Null<Int>;
	var flipped:Null<Bool>;
	var scale:Null<Float>;
}

typedef MenuCharAnimations = {
	var idle:MenuCharAnimation;
	var danceLeft:MenuCharAnimation;
	var danceRight:MenuCharAnimation;
	var hey:MenuCharAnimation;
}

typedef MenuCharAnimation = {
	var prefix:Null<String>;
	var offset:Null<Array<Float>>;
	var indices:Null<Array<Int>>;
	var fps:Null<Int>;
	var looped:Null<Bool>;
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
	public var danced:Bool = false;
	public var curCharacter:String = '';
	
	var flipped:Bool = false;
	var scaleDeezNuts:Float = 1.0;

	var pain:MenuCharacterJSON = {character: null, animations: null, settings: null};

	public function new(x:Int, y:Int, scale:Float, flipped:Bool)
	{
		super(x, y);
		
		if (Paths.currentMod == null)
		{
			if (curCharacter != '')
				pain = cast Json.parse(Assets.getText('assets/images/menuCharacters/$curCharacter.json'));
		}
		#if FILESYSTEM
		else
		{
			if (curCharacter != '')
				pain = cast Json.parse(File.getContent('mods/${Paths.currentMod}/assets/images/menuCharacters/$curCharacter.json'));
		}
		#end

		if (pain.settings != null)
			settings.set(pain.character, new CharacterSetting(pain.settings.x, pain.settings.y, pain.settings.scale, pain.settings.flipped));
		
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


		if (Paths.currentMod == null)
		{
			if (curCharacter != '')
				pain = cast Json.parse(Assets.getText('assets/images/menuCharacters/$curCharacter.json'));
		}
		#if FILESYSTEM
		else
		{
			if (curCharacter != '')
				pain = cast Json.parse(File.getContent('mods/${Paths.currentMod}/assets/images/menuCharacters/$curCharacter.json'));
		}
		#end

		if (pain.settings != null)
			settings.set(pain.character, new CharacterSetting(pain.settings.x, pain.settings.y, pain.settings.scale, pain.settings.flipped));

		frames = Paths.getSparrowAtlas('menuCharacters/' + character);

		// so many ifs....
		var fuck = pain;

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

		var setting:CharacterSetting = settings[character];
		
		if (setting != null)
		{
			setGraphicSize(Std.int(width * setting.scale));
			flipX = setting.flipped != flipped;
			offset.set(setting.x, setting.y);
		}

		if (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null)
			animation.play("danceLeft");
		else
			animation.play("idle");

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
