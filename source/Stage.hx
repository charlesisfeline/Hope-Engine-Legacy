package;

import editors.StageEditor.StageSprite;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.typeLimit.OneOfTwo;
import openfl.display.BlendMode;

typedef StageJSON =
{
	var name:String;
	var bfPosition:Array<Float>;
	var gfPosition:Array<Float>;
	var dadPosition:Array<Float>;
	var defaultCamZoom:Null<Float>;

	var isHalloween:Null<Bool>;
}

//////////////////////
// JSON STAGE STUFF //
//////////////////////

typedef JSONStage =
{
	var stage:Array<JSONStageSprite>;
}

typedef JSONStageSprite =
{
	var varName:String;
	var imagePath:String;

	var layer:Int;

	var antialiasing:Bool;
	var position:Array<Float>;
	var scrollFactor:Array<Float>;
	var scale:Array<Float>;
	var angle:Float;
	var color:String;
	var alpha:Float;
	var blend:String;
	var flipX:Bool;
	var flipY:Bool;
	var initAnim:String;
	var inFront:Bool;
	var animations:Array<JSONStageSpriteAnimation>;
}

typedef JSONStageSpriteAnimation =
{
	var name:String;
	var prefix:String;

	@:optional var frameRate:Null<Int>;
	@:optional var loopedAnim:Null<Bool>;
	@:optional var indices:Null<Array<Int>>;
	@:optional var flipX:Null<Bool>;
	@:optional var flipY:Null<Bool>;
	@:optional var postfix:Null<String>;
}

typedef ParsedJSONStage =
{
	var background:Array<StageSprite>;
	var foreground:Array<StageSprite>;
}

class Stage
{
	public static function parseJSONStage(json:JSONStage):ParsedJSONStage
	{
		var spritesBack:Array<StageSprite> = [];
		var spritesFront:Array<StageSprite> = [];

		for (item in json.stage)
		{
            var s = new StageSprite();

			s.varName = item.varName;
			s.antialiasing = item.antialiasing;
			s.setPosition(item.position[0], item.position[1]);
			s.scrollFactor.set(item.scrollFactor[0], item.scrollFactor[1]);
			s.scale.set(item.scale[0], item.scale[1]);
			s.updateHitbox();
			s.angle = item.angle;
			s.color = FlxColor.fromString("#" + item.color);
			s.alpha = item.alpha;
			s.blend = @:privateAccess BlendMode.fromString(item.blend.toLowerCase());
			s.flipX = item.flipX;
			s.flipY = item.flipY;

			if (item.animations.length > 0)
			{
				s.frames = Paths.getSparrowAtlas(item.imagePath);

				for (anim in item.animations)
				{
					if (anim.indices != null)
						s.animation.addByIndices(anim.name, anim.prefix, anim.indices, anim.postfix, anim.frameRate, anim.loopedAnim, anim.flipX, anim.flipY);
					else
						s.animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loopedAnim, anim.flipX, anim.flipY);
				}

				s.animation.play(item.initAnim);
			}
			else
				s.loadGraphic(Paths.image(item.imagePath));

			if (item.inFront)
				spritesFront.push(s);
			else
				spritesBack.push(s);
		}

		spritesFront.sort(function(a:StageSprite, b:StageSprite) {
			return FlxSort.byValues(FlxSort.ASCENDING, a.layer, b.layer);
		});

		spritesBack.sort(function(a:StageSprite, b:StageSprite) {
			return FlxSort.byValues(FlxSort.ASCENDING, a.layer, b.layer);
		});

		return {background: spritesBack, foreground: spritesFront};
	}
}
