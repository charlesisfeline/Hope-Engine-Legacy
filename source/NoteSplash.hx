package;

import Character.Animation;
import PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;

using StringTools;

#if FILESYSTEM
import sys.io.File;
#end

class NoteSplash extends FlxSprite
{
	public var noteData:Int = 0;

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

		animation.addByPrefix("splash", dirs[noteData] + " splash", 24, false);
		animation.play("splash");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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
