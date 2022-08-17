package;

import Stage.JSONStageSprite;
import Stage.JSONStageSpriteAnimation;
import flixel.FlxSprite;
import openfl.display.BlendMode;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

// Les do this again

class StageEditor extends MusicBeatState
{
	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

class StageSprite extends FlxSprite
{
	public var varName:String = '';
	public var initAnim:String = '';
	public var imagePath:String = '';
	public var animations:Array<JSONStageSpriteAnimation> = [];

	public var data:JSONStageSprite;

	public function new()
	{
		super();

		varName = 'sprite' + ID;
		blend = NORMAL;

		data = {
			varName: varName,
			scale: [1, 1],
			initAnim: initAnim,
			antialiasing: antialiasing,
			animations: animations,
			imagePath: imagePath,
			flipX: false,
			flipY: false,
			color: "FFFFFF",
			blend: "NORMAL",
			angle: 0,
			alpha: 1
		}
	}

	public function updateAnimations():Void
	{
		
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (data != null)
		{
			@:privateAccess
			data = {
				varName: varName,
				scale: [scale.x, scale.y],
				initAnim: initAnim,
				antialiasing: antialiasing,
				animations: [],
				imagePath: imagePath,
				flipX: flipX,
				flipY: flipY,
				color: color.toHexString(false, false),
				blend: blend.toString().toUpperCase(),
				angle: angle,
				alpha: alpha
			}
		}
	}
}
