package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class BackgroundDancer extends FlxSprite
{
	var preloadedAtlas:flixel.graphics.frames.FlxFramesCollection;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas("limo/limoDancer", 'week4');
		animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.play('danceLeft');
		antialiasing = true;

		preloadedAtlas = Paths.getSparrowAtlas("limo/death/hench_death", 'week4');
	}

	var isDying:Bool = false;
	var danceDir:Bool = false;

	public function dance():Void
	{
		if (isDying)
			return;

		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}

	public function die():Void
	{
		isDying = true;

		frames = preloadedAtlas;
		animation.addByPrefix("die", "hench death " + FlxG.random.int(1, 2), 24, false);
		animation.play("die");
	}
}
