package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StaticArrow extends FlxSprite
{
	public var staticWidth:Float = 0;
	public var staticHeight:Float = 0;
	public var isPixel:Bool = false;
	
	public function new(xx:Float, yy:Float, isPixel:Bool = false)
	{
		this.isPixel = isPixel;
		
		x = xx;
		y = yy;

		super(x, y);
		
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function playAnim(AnimName:String, ?force:Bool = false):Void
	{
		animation.play(AnimName, force);

		centerOrigin();
		updateHitbox();

		if (!isPixel)
		{
			offset.set(frameWidth / 2, frameHeight / 2);

			offset.x -= 54;
			offset.y -= 56;
		}
	}
}
