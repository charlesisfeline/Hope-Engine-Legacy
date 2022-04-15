package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var restartImage:FlxSprite;
	var loser:FlxSprite;
	var camFollow:FlxObject;
	var camFollow2:FlxObject;

	var stageSuffix:String = "";
	
	var wellRip:FlxText;

	public function new(x:Float, y:Float)
	{
		stageSuffix = (PlayState.SONG.noteStyle == "pixel" ? "-pixel" : "");

		var daBf:String = 'mic';

		if (Paths.exists(Paths.characterJson(PlayState.SONG.player1 + "-dead")))
			daBf = PlayState.SONG.player1 + "-dead";

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y - 100, 1, 1);
		add(camFollow);

		camFollow2 = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow2);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		restartImage = new FlxSprite().loadGraphic(Paths.image('restart'));
		restartImage.antialiasing = true;
		restartImage.setGraphicSize(Std.int(restartImage.width * 0.55));
		restartImage.x = bf.getGraphicMidpoint().x - restartImage.getGraphicMidpoint().x;
		restartImage.y = bf.y - bf.height / 2 - 50;
		var piss = restartImage.scale.x;
		restartImage.scale.x = 0;
		add(restartImage);

		loser = new FlxSprite(100, 100);
		loser.frames = Paths.getSparrowAtlas('lose');
		loser.animation.addByPrefix('lose', 'lose', 24, false);
		loser.scrollFactor.set();
		loser.screenCenter(X);
		loser.y = bf.y + (bf.height / 2) - (loser.height);
		loser.visible = false;
		add(loser);

		FlxTween.tween(restartImage, {"scale.x": piss}, 0.5, {ease: FlxEase.backOut});
	}

	var stopQuitting = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK && !stopQuitting)
		{
			quitBullshit();
			stopQuitting = true;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music((stageSuffix == "-pixel" ? "pixel/" : "") + 'gameOver' + stageSuffix));
			bf.playAnim('deathLoop', true);
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.sound.music.playing)
			bf.playAnim('deathLoop', true);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;

			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music((stageSuffix == "-pixel" ? "pixel/" : "") + 'gameOverEnd' + stageSuffix));

			FlxTween.tween(restartImage, {"scale.x": 0}, 0.5, {
				ease: FlxEase.backIn,
				onComplete: function(twn:FlxTween)
				{
					restartImage.visible = false;
				}
			});

			FlxG.camera.follow(camFollow2, LOCKON, 0.01);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}

	function quitBullshit():Void
	{
		FlxG.sound.music.stop();

		loser.visible = true;
		loser.animation.play('lose');
		remove(restartImage);
		remove(bf);

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				if (PlayState.isStoryMode)
					FlxG.switchState(new StoryMenuState());
				else
					FlxG.switchState(new FreeplayState());

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			});
		});
	}
}
