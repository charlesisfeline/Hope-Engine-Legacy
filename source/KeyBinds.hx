<<<<<<< HEAD
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
=======
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
>>>>>>> upstream

class KeyBinds
{
	public static function resetBinds():Void
	{
<<<<<<< HEAD
		FlxG.save.data.controls = [
			[W, UP],
			[S, DOWN],
			[A, LEFT],
			[D, RIGHT],
			[ENTER, ESCAPE],
			[R],

			[W, UP],
			[S, DOWN],
			[A, LEFT],
			[D, RIGHT],
			[Z, ENTER],
			[BACKSPACE, ESCAPE],
			[R]
		];

=======
		FlxG.save.data.upBind = "W";
		FlxG.save.data.downBind = "S";
		FlxG.save.data.leftBind = "A";
		FlxG.save.data.rightBind = "D";
		FlxG.save.data.killBind = "R";
>>>>>>> upstream
		PlayerSettings.player1.controls.loadKeyBinds();
	}

	public static function keyCheck():Void
	{
<<<<<<< HEAD
		if (FlxG.save.data.controls == null)
		{
			FlxG.save.data.controls = [
				[W, UP],
				[S, DOWN],
				[A, LEFT],
				[D, RIGHT],
				[ENTER, ESCAPE],
				[R],
	
				[W, UP],
				[S, DOWN],
				[A, LEFT],
				[D, RIGHT],
				[Z, ENTER],
				[BACKSPACE, ESCAPE],
				[R]
			];

			trace("Damn, no controls array AT ALL");
=======
		if (FlxG.save.data.upBind == null)
		{
			FlxG.save.data.upBind = "W";
			trace("No UP");
		}
		if (FlxG.save.data.downBind == null)
		{
			FlxG.save.data.downBind = "S";
			trace("No DOWN");
		}
		if (FlxG.save.data.leftBind == null)
		{
			FlxG.save.data.leftBind = "A";
			trace("No LEFT");
		}
		if (FlxG.save.data.rightBind == null)
		{
			FlxG.save.data.rightBind = "D";
			trace("No RIGHT");
		}
		if (FlxG.save.data.killBind == null)
		{
			FlxG.save.data.killBind = "R";
			trace("No KILL");
>>>>>>> upstream
		}
	}
}
