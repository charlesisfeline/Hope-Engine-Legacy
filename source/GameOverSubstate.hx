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
	var camFollow:FlxObject;
	var camFollow2:FlxObject;

	var deathReason:FlxText;
	var deathReasonClone:FlxText;

	var stageSuffix:String = "";
	var daCause:String = "";

	var wellRip:FlxText;

	public function new(x:Float, y:Float, ?cause:String)
	{
		var daBf:String = '';
		switch ((FlxG.save.data.enemySide ? PlayState.SONG.player2 : PlayState.SONG.player1))
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bf':
				daBf = 'bf';
			default:
				daBf = 'mic';
		}

		daCause = cause;

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf, !FlxG.save.data.enemySide);
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

		FlxTween.tween(restartImage, {"scale.x": piss}, 0.5, {ease: FlxEase.backOut});

		deathReason = new FlxText(0, FlxG.height * 0.8, FlxG.width, "You died to a ", 64);
		deathReason.color = FlxColor.WHITE;
		deathReason.alignment = CENTER;
		deathReason.y = bf.y + 250;
		deathReason.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 5);

		deathReasonClone = new FlxText(0, FlxG.height * 0.8, FlxG.width, "", 64);
		deathReasonClone.color = 0xFF3333cc;
		deathReasonClone.alignment = CENTER;
		deathReasonClone.y = bf.y + 250;
		deathReasonClone.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF3333cc, 10);

		// Fuck me, LMAO

		if (FlxG.save.data.fcOnly && PlayState.misses != 0)
			deathReason.text += "miss!";

		if (FlxG.save.data.sicksOnly)
		{
			if (PlayState.goods != 0)
				deathReason.text += "\"Good\"!";
			else if (PlayState.bads != 0)
				deathReason.text += "\"Bad\"!";
			else if (PlayState.shits != 0)
				deathReason.text += "\"Shit\"!";
		}

		if (FlxG.save.data.goodsOnly)
		{
			if (PlayState.sicks != 0)
				deathReason.text += "\"Sick!!\"!";
			else if (PlayState.bads != 0)
				deathReason.text += "\"Bad\"!";
			else if (PlayState.shits != 0)
				deathReason.text += "\"Shit\"!";
		}

		if (FlxG.save.data.fcOnly && PlayState.misses != 0 && FlxG.save.data.botplay)
			deathReason.text += "\n(The \"bot\" can miss!)";

		deathReasonClone.y = deathReason.y;
		deathReasonClone.text += deathReason.text;
		
		if (FlxG.save.data.fcOnly || FlxG.save.data.sicksOnly || FlxG.save.data.goodsOnly)
		{
			deathReason.x = bf.getGraphicMidpoint().x - deathReason.width / 2;
			deathReasonClone.x = bf.getGraphicMidpoint().x - deathReasonClone.width / 2;
			remove(bf);
			add(deathReasonClone);
			add(bf);
			add(deathReason);
		}

		if (cause != null) 
		{
			switch (cause)
			{
				case 'deathNote':
					bf.visible = false;
					deathReason.visible = false;
					deathReasonClone.visible = false;
					restartImage.visible = false;
					wellRip = new FlxText(bf.getGraphicMidpoint().x - deathReasonClone.width / 2, FlxG.height * 0.8, FlxG.width, "you died to a death note.");
					wellRip.scrollFactor.set();
					wellRip.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					add(wellRip);
			}
		}
	}

	var stopQuitting = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

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
			switch (daCause)
			{
				// case 'deathNote':
					// FlxG.sound.playMusic(Paths.music('gameOverDeathNote'), 0);
					// FlxG.sound.music.fadeIn(1, 0, 0.7);
				default:
					FlxG.sound.playMusic(Paths.music((stageSuffix == "-pixel" ? "pixel/" : "") + 'gameOver' + stageSuffix));
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();
		
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			switch (daCause)
			{
				// case 'deathNote':
				// 	FlxG.sound.playMusic(Paths.music('gameOverDeathNoteEnd'), 0);
				// 	FlxG.sound.music.fadeIn(1, 0, 0.7);
				default:
					FlxG.sound.play(Paths.music((stageSuffix == "-pixel" ? "pixel/" : "") + 'gameOverEnd' + stageSuffix));
			}

			#if windows
			if (PlayState.luaModchart != null)
			{
				PlayState.luaModchart.die();
				PlayState.luaModchart = null;
			}
			#end
			
			FlxTween.tween(restartImage, {"scale.x": 0}, 0.5, {ease: FlxEase.backIn, onComplete: function(twn:FlxTween) 
			{
				restartImage.visible = false;
			}});
			
			deathReason.visible = false;
			deathReasonClone.visible = false;
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

		#if windows
		if (PlayState.luaModchart != null)
		{
			PlayState.luaModchart.die();
			PlayState.luaModchart = null;
		}
		#end

		var loser:FlxSprite = new FlxSprite(100, 100);
		var loseTex = Paths.getSparrowAtlas('lose');
		loser.frames = loseTex;
		loser.animation.addByPrefix('lose', 'lose', 24, false);
		loser.animation.play('lose');
		loser.x = bf.x + (bf.width / 2) - (loser.width / 2);
		loser.y = bf.y + (bf.height / 2) - (loser.height);
		add(loser);

		remove(bf);
		remove(restartImage);
		remove(deathReason);
		remove(deathReasonClone);
		remove(wellRip);

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
		PlayState.loadRep = false;
	}
}
