package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class TrackedSprite extends FlxSprite
{
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	public var object:FlxObject;

	public function new(object:FlxObject)
	{
		super();

		this.object = object;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		x = object.x + xOffset;
		y = object.y + yOffset;
	}

	override function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):TrackedSprite
	{
		return cast super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
	}
}
