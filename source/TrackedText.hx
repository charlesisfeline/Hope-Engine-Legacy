package;

<<<<<<< HEAD
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TrackedText extends FlxText
=======
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TrackedText extends FlxText 
>>>>>>> upstream
{
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

<<<<<<< HEAD
	public var object:FlxObject;

	public function new(object:FlxObject, ?size:Int = 16, text:String = '')
=======
	public var trackX:Float = 0;
	public var trackY:Float = 0;
	
	public function new(trackX:Float, trackY:Float, ?size:Int = 16, text:String = '') 
>>>>>>> upstream
	{
		super(0, 0);

		setFormat("VCR OSD Mono", size, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

		this.text = text;
		this.size = size;

<<<<<<< HEAD
		this.object = object;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		x = object.x + xOffset;
		y = object.y + yOffset;
	}
}
=======
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
>>>>>>> upstream
