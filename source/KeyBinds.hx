import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

class KeyBinds
{
	public static function resetBinds():Void
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

		PlayerSettings.player1.controls.loadKeyBinds();
	}

	public static function keyCheck():Void
	{
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
		}
	}
}
