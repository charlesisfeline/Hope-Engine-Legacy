package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

typedef CharacterJSON =
{
	var name:String;
	var image:String;
	@:optional var icon:String;
	var healthColor:String;

	var antialiasing:Null<Bool>;
	var scale:Null<Float>;
	var facesLeft:Null<Bool>;
	var isDeath:Null<Bool>;
	var initialAnimation:String;
	var cameraOffset:Array<Float>;
	var singDuration:Null<Float>;
	var animations:Array<Animation>;

	var positionOffset:Null<Array<Float>>;
}

typedef Animation =
{
	var name:String;
	var prefix:String;

	var frameRate:Null<Int>;
	var loopedAnim:Null<Bool>;
	var offset:Array<Float>;
	var indices:Array<Int>;
	var postfix:String;
	var flipX:Null<Bool>;
	var flipY:Null<Bool>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Float>>;

	public var isPlayer:Bool = false; // if they are a player
	public var isDeath:Bool = false; // if they are a character that shows up on the gameover screen

	public var curCharacter:String = 'bf';
	public var image:String = '';
	public var icon:String = 'face';
	public var setAntialiasing:Bool = true;
	public var setScale:Float = 1;
	public var facesLeft:Bool = true;
	public var initAnim:String = 'idle';
	public var cameraOffset:Array<Float> = [0, 0];
	public var positionOffset:Array<Float> = [0, 0];
	public var singDuration:Float = 4;
	public var healthColor:String;

	public var animationsArray:Array<Animation> = [];

	public var holdTimer:Float = 0;
	public var debugMode:Bool = false;

	public var specialAnim:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Float>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		switch (curCharacter)
		{
			default:
				var rawJSON:String = "";

				if (Paths.exists(Paths.characterJson(curCharacter)))
				{
					#if FILESYSTEM
					rawJSON = File.getContent(Paths.characterJson(curCharacter));
					#else
					rawJSON = Assets.getText(Paths.characterJson(curCharacter));
					#end
				}

				var charFile:CharacterJSON = cast Json.parse(rawJSON);

				image = charFile.image != null ? charFile.image : '';
				icon = charFile.icon != null ? charFile.icon : curCharacter;
				setAntialiasing = charFile.antialiasing != null ? charFile.antialiasing : true;
				setScale = charFile.scale != null ? charFile.scale : 1;
				facesLeft = charFile.facesLeft != null ? charFile.facesLeft : false;
				isDeath = charFile.isDeath != null ? charFile.isDeath : false;
				initAnim = charFile.initialAnimation != null ? charFile.initialAnimation : 'idle';
				cameraOffset = charFile.cameraOffset != null ? charFile.cameraOffset : [0, 0];
				positionOffset = charFile.positionOffset != null ? charFile.positionOffset : [0, 0];
				singDuration = charFile.singDuration != null ? charFile.singDuration : 4;
				animationsArray = charFile.animations != null ? charFile.animations : [];
				healthColor = charFile.healthColor != null ? charFile.healthColor : "a1a1a1";


				#if html5
				if (Paths.exists(Paths.getPath('images/' + charFile.image + '.txt', TEXT, null)))
				#else
				if (Paths.exists('assets/shared/images/' + charFile.image + '.txt'))
				#end
				frames = Paths.getPackerAtlas(charFile.image);
				else
					frames = Paths.getSparrowAtlas(charFile.image);

				if (setScale != 1)
				{
					setGraphicSize(Std.int(width * setScale));
					updateHitbox();
				}

				antialiasing = setAntialiasing;
				flipX = !!facesLeft;

				if (animationsArray != null && animationsArray.length > 0)
				{
					for (anim in animationsArray)
					{
						if (anim.indices != null && anim.indices.length > 0)
							animation.addByIndices(anim.name, anim.prefix, anim.indices, anim.postfix, anim.frameRate, anim.loopedAnim, anim.flipX,
								anim.flipY);
						else
							animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loopedAnim, anim.flipX, anim.flipY);

						if (anim.offset != null)
							addOffset(anim.name, anim.offset[0], anim.offset[1]);
						else
							addOffset(anim.name, 0, 0);
					}
				}

				if (animation.getByName(initAnim) == null)
				{
					if (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null)
						initAnim = "danceLeft";

					if (animation.getByName("idle") != null)
						initAnim = "idle";
				}

				playAnim(initAnim);
		}

		dance();

		if (!isDeath)
		{
			if (isPlayer)
				flipX = !flipX;
		}
	}

	public final function getColor():FlxColor
	{
		return FlxColor.fromString("#" + healthColor);
	}

	public function reloadAnimations():Void
	{
		if (animationsArray != null && animationsArray.length > 0)
		{
			for (anim in animationsArray)
			{
				if (anim.indices != null && anim.indices.length > 0)
					animation.addByIndices(anim.name, anim.prefix, anim.indices, anim.postfix, anim.frameRate, anim.loopedAnim, anim.flipX, anim.flipY);
				else
					animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loopedAnim, anim.flipX, anim.flipY);

				if (anim.offset != null)
					addOffset(anim.name, anim.offset[0], anim.offset[1]);
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null && !debugMode)
		{
			if (!curCharacter.startsWith('bf'))
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
				else
					holdTimer = 0;

				// var dadVar:Float = 4;

				// if (curCharacter == 'dad')
				// 	dadVar = 6.1;

				if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001)
				{
					dance();
					holdTimer = 0;
				}
			}

			switch (curCharacter)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight');
			}

			if (animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
				playAnim(animation.curAnim.name + '-loop');

			if (specialAnim && animation.finished)
				specialAnim = false;
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			if (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null)
			{
				danced = !danced;
				playAnim("dance" + (danced ? "Right" : "Left"));
			}
			else
				playAnim('idle');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			animation.play(AnimName, Force, Reversed, Frame);
		else
			return;

		var daOffset = animOffsets.get(AnimName);

		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null)
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];
}
