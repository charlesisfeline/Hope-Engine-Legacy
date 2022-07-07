package scripts;

import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import DialogueSubstate;
import openfl.Lib;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.addons.effects.FlxTrail;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;
import flixel.FlxSprite;
import achievements.Achievements;
import flixel.group.FlxGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;
import hscript.Interp;

using StringTools;

class ScriptEssentials
{
	public static function imports(interp:Interp):Void
	{
		interp.variables.set("BackgroundDancer", BackgroundDancer);
		interp.variables.set("DialogueSubstate", DialogueSubstate);
		interp.variables.set("BackgroundGirls", BackgroundGirls);
		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("Achievements", Achievements);
		interp.variables.set("FlxBackdrop", FlxBackdrop);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("Application", Application);
		interp.variables.set("FunkSprite", FunkSprite);
		interp.variables.set("TankmenBG", TankmenBG);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("Character", Character);
		interp.variables.set("FlxRandom", FlxRandom);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxTimer", FlxTimer);
		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("FlxRect", FlxRect);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("Ratings", Ratings);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Count", Count);
		interp.variables.set("Math", Math);
		interp.variables.set("Note", Note);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("Std", Std);
		interp.variables.set("Lib", Lib);

		interp.variables.set("import", function(classPath:String)
		{
			importClass(classPath, interp);
		});
		interp.variables.set("FlxColor", function(huh:String)
		{
			return FlxColor.colorLookup.get(huh);
		});
		interp.variables.set("Settings", Settings);
		interp.variables.set("DialogueStyle", {
			NORMAL: DialogueStyle.NORMAL,
			PIXEL_NORMAL: DialogueStyle.PIXEL_NORMAL,
			PIXEL_SPIRIT: DialogueStyle.PIXEL_SPIRIT
		});
		interp.variables.set("FlxTextBorderStyle", {
			NONE: FlxTextBorderStyle.NONE,
			SHADOW: FlxTextBorderStyle.SHADOW,
			OUTLINE: FlxTextBorderStyle.OUTLINE,
			OUTLINE_FAST: FlxTextBorderStyle.OUTLINE_FAST
		});
		interp.variables.set("FlxTextAlign", {
			CENTER: FlxTextAlign.CENTER,
			LEFT: FlxTextAlign.LEFT,
			RIGHT: FlxTextAlign.RIGHT,
			JUSTIFY: FlxTextAlign.JUSTIFY
		});
		interp.variables.set("FlxAxes", {
			X: X,
			Y: Y,
			XY: XY,
		});
		interp.variables.set("print", function(e:Dynamic) {
			Main.console.add(e, CONSOLE);
		});
	}

	static function importClass(classPath:String, interp:Interp):Void
	{
		if (classPath.toLowerCase().trim().startsWith("sys"))
		{
			Main.console.add("\"sys\" imports are not allowed!", GAME);
			return;
		}

		var classLol = Type.resolveClass(classPath);
		var className = Type.getClassName(classLol).split(".").pop().trim();

        interp.variables.set(className, classLol);
	}
}
