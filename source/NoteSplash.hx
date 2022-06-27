package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class NoteSplash extends FlxSprite
{
	public var noteData:Int = 0;
	public var strumNote:StaticArrow;
	public var actualAlpha:Float = 0.6;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	var dirs = ["purple", "blue", "green", "red"];

	public var onFinish:Void->Void;

	public function new(noteData:Int, ?skin:FlxAtlasFrames, ?onFinish:Void->Void)
	{
		super();

		this.onFinish = onFinish;

		this.noteData = noteData;
		frames = skin;

		alpha = 0.6;

		animation.addByPrefix("splash", dirs[noteData] + " splash", 24, false);
		animation.play("splash");
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
