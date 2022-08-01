package;

import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxSprite;

class TankmenBG extends FlxSprite
{
    // Hi psych
	private var tankSpeed:Float;
	private var endingOffset:Float;
	private var fromLeft:Bool;

	public var strumTime:Float;

	public function new(?x:Float = 20, ?y:Float = 500, ?strumTime:Float = 0, ?fromLeft:Bool = false)
	{
		super();

		tankSpeed = 0.7;
		this.strumTime = strumTime;
		endingOffset = FlxG.random.float(50, 200);
		this.fromLeft = fromLeft;
		super(x, y);

        flipX = fromLeft;

		frames = Paths.getSparrowAtlas('tankmanRunning', 'week7');
		animation.addByPrefix('run', 'tankman running', 24, true);
		animation.addByPrefix('shot', 'John Shot ' + FlxG.random.int(1, 2), 24, false);
		animation.play('run');
		animation.curAnim.curFrame = FlxG.random.int(0, animation.curAnim.frames.length - 1);
		antialiasing = true;

		updateHitbox();
		setGraphicSize(Std.int(0.8 * width));
		updateHitbox();
	}

	public var dying:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!dying)
			visible = (x > -0.5 * FlxG.width && x < 1.2 * FlxG.width);

		if (animation.curAnim.name == "run")
		{
			var speed:Float = (Conductor.songPosition - strumTime) * tankSpeed;
			if (fromLeft)
				x = (0.02 * FlxG.width - endingOffset) + speed;
			else
				x = (0.74 * FlxG.width + endingOffset) - speed;
		}
		else if (animation.curAnim.finished)
		{
			kill();
		}

		// fuck it, hardcoded flicker
		if (animation.curAnim.curFrame >= 14 && animation.curAnim.curFrame % 2 == 0 && dying)
			visible = !visible;

		if (Conductor.songPosition > strumTime && !dying)
		{
			dying = true;

			animation.play('shot');

			if (fromLeft)
			{
				offset.x = 300;
				offset.y = 200;
			}
		}
	}
}
