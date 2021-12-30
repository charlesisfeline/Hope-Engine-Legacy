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
	public var noteType:String = "hopeEngine/normal";

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	var dirs = ["purple", "blue", "green", "red"];

	public function new(noteData:Int, ?noteType:String = "hopeEngine/normal", ?skin:FlxAtlasFrames)
	{
		super();

		this.noteData = noteData;
		this.noteType = noteType;
		frames = skin;

		alpha = 0.6;
		
		animation.addByPrefix("splash", dirs[noteData] + " splash", 24, false);
		animation.play("splash");
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
			if (animation.curAnim.finished)
				kill();

		super.update(elapsed);
	}
}