package;

import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TrackedText extends FlxText
{
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	public var object:FlxObject;

	public function new(object:FlxObject, ?size:Int = 16, text:String = '')
	{
		super(0, 0);

		setFormat("VCR OSD Mono", size, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

		this.text = text;
		this.size = size;

		this.object = object;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		x = object.x + xOffset;
		y = object.y + yOffset;
	}
}
