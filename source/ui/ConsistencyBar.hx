package ui;

import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

// How consistent are you?
class ConsistencyBar extends FlxSpriteGroup
{
	public var lerpFactor:Float = 3.2;
	public var lines:FlxTypedGroup<FlxSprite>;

	var _width:Int = 0;
	var _height:Int = 0;

	var diffDisplay:FlxText;
	var arrow:FlxSprite;
	var arrowX:Float;

	var shitBar:FlxSprite;
	var badBar:FlxSprite;
	var goodBar:FlxSprite;
	var sickBar:FlxSprite;

	public function new(?x:Float = 0, ?y:Float = 0, width:Int = 300, height:Int = 10)
	{
		super(x, y);

		this._width = width;
		this._height = height;

		make();
	}

	private function make():Void
	{
		var background = new FlxSprite(-4, -4).makeGraphic(_width + 8, _height + 8, FlxColor.BLACK);
		background.alpha = 0.7;
		add(background);

		diffDisplay = new FlxText("cock");
		diffDisplay.setFormat("VCR OSD Mono", 24, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		diffDisplay.fieldWidth = Std.int(background.width);
		diffDisplay.alpha = 0;
		diffDisplay.borderSize = 3;
		add(diffDisplay);
		diffDisplay.y = background.y - diffDisplay.height - 24;

		arrow = new FlxSprite().loadGraphic(Paths.image("arrow", "shared"));
		arrow.antialiasing = true;
		arrow.setGraphicSize(8, 10);
		arrow.updateHitbox();
		arrowX = _width / 2;
		arrow.x = (_width / 2) - (arrow.width / 2);
		add(arrow);
		arrow.y = background.y - arrow.height - 2;

		var darkerBG = new FlxSprite(-2, -2).makeGraphic(_width + 4, _height + 4, FlxColor.BLACK);
		add(darkerBG);

		var missBar = new FlxSprite().makeGraphic(_width, _height, 0xff290000);
		add(missBar);

		shitBar = new FlxSprite().makeGraphic(_width, _height, 0xff962e2e);
		add(shitBar);

		badBar = new FlxSprite().makeGraphic(_width, _height, 0xfff84747);
		add(badBar);

		goodBar = new FlxSprite().makeGraphic(_width, _height, 0xff43ff53);
		add(goodBar);

		sickBar = new FlxSprite().makeGraphic(_width, _height, 0xff00f7ff);
		add(sickBar);

		lines = new FlxTypedGroup<FlxSprite>();

		background.y = arrow.y - 4;
		background.setGraphicSize(Std.int(background.width), Std.int(background.height + 16));
		background.updateHitbox();
	}

	var hits:Int = 0;
	var hitTotal:Float = 0;

	public function noteHit():Void
	{

	}

	public function move(diff:Float)
	{
		hits++;
		hitTotal += diff;

		FlxTween.cancelTweensOf(diffDisplay);

		switch (Ratings.CalculateRating(diff))
		{
			case "sick":
				diffDisplay.color = 0xff00f7ff;
			case "good":
				diffDisplay.color = 0xff43ff53;
			case "bad":
				diffDisplay.color = 0xfff84747;
			case "shit":
				diffDisplay.color = 0xff962e2e;
			case "miss":
				diffDisplay.color = 0xff290000;
		}
		
		diffDisplay.text = Helper.truncateFloat(diff, 2) + " ms";
		diffDisplay.scale.set(1.1, 1.1);
		diffDisplay.alpha = 1;
		FlxTween.tween(diffDisplay, {"scale.x": 1, "scale.y": 1}, 0.4);

		var customTimeScale = Conductor.timeScale;
		customTimeScale *= Ratings.modifier;

		var curX = (_width / 2) + ((diff / 166 * customTimeScale) * (_width / 2));

		var newLine = new FlxSprite();
		newLine.makeGraphic(2, _height + 8, FlxColor.WHITE);
		newLine.alpha = 0.6;
		lines.add(newLine);
		add(newLine);
		newLine.x = shitBar.x + curX - 1;
		newLine.y = shitBar.y + (shitBar.height / 2) - (newLine.height / 2);
		FlxTween.tween(newLine, {alpha: 0}, 0.2, {
			onComplete: function(_) {
				remove(newLine);
				newLine.kill();
				newLine.destroy();
			},
			startDelay: Conductor.crochet * 0.001 * 2
		});

		var average = hitTotal / hits;

		arrowX = (_width / 2) + ((average / 166 * customTimeScale) * (_width / 2));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var customTimeScale = Conductor.timeScale;
		customTimeScale *= Ratings.modifier;

		shitBar.scale.x = (166 * 2 * customTimeScale) / (166 * 2);
		badBar.scale.x = (135 * 2 * customTimeScale) / (166 * 2);
		goodBar.scale.x = (90 * 2 * customTimeScale) / (166 * 2);
		sickBar.scale.x = (45 * 2 * customTimeScale) / (166 * 2);

		arrow.x = FlxMath.lerp(arrow.x, shitBar.x + arrowX - (arrow.width / 2), Helper.boundTo(elapsed * lerpFactor, 0, 1));
	}
}
