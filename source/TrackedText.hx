package;

import flixel.text.FlxText;
import flixel.util.FlxColor;

class TrackedText extends FlxText 
{
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	public var trackX:Float = 0;
	public var trackY:Float = 0;
	
	public function new(trackX:Float, trackY:Float, ?size:Int = 16, text:String = '') 
	{
		super(0, 0);

		setFormat("VCR OSD Mono", size, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

		this.text = text;
		this.size = size;

		this.trackX = trackX;
		this.trackY = trackY;
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		x = trackX + xOffset;
		y = trackY + yOffset;
	}
}