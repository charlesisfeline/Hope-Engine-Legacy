package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class NoteSplash extends FlxSprite
{
	public var strumNote:StaticArrow;
	public var actualAlpha:Float = 0.6;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	var dirs = ["purple", "blue", "green", "red"];

	public var onFinish:Void->Void;

	public var skin:FlxAtlasFrames;

	public function new(?skin:FlxAtlasFrames)
	{
		super();

		this.skin = skin;
		frames = skin;

		alpha = 0.6;
	}

	public function splash(noteData:Int, ?onFinish:Void->Void):Void
	{
		this.onFinish = onFinish;

		frames = skin;

		for (i in 0...4)
		{
			animation.addByPrefix("splash 1 " + i, dirs[i] + " splash 1", 24, false);
			animation.addByPrefix("splash 2 " + i, dirs[i] + " splash 2", 24, false);
		}

		var randy = FlxG.random.int(1, 2);

		if (animation.getByName("splash " + randy + " " + noteData) == null)
			animation.addByPrefix("splash " + randy + " " + noteData, dirs[noteData] + " splash", 24, false);

		animation.play("splash " + randy + " " + noteData);
		centerOffsets();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (strumNote != null)
		{
			angle = strumNote.angle;
			alpha = strumNote.alpha * actualAlpha;

			x = strumNote.x + (strumNote.staticWidth / 2) - (width / 2);
			y = strumNote.y + (strumNote.staticHeight / 2) - (height / 2);
		}

		if (animation.curAnim != null)
		{
			if (animation.curAnim.finished)
			{
				kill();
				if (onFinish != null)
					onFinish();
			}
		}
	}
}
