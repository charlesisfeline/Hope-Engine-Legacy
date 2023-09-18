package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var loser:FlxSprite;
	var camFollow:FlxObject;
	var camPos:FlxObject;

	var stageSuffix:String = "";

	var wellRip:FlxText;

	public static var lossSFX:String = 'fnf_loss_sfx';
	public static var endSFX:String = 'gameOverEnd';
	public static var theme:String = 'gameOver';
	public static var themeBPM:Float = 100;

	public function new(x:Float, y:Float, camPos:FlxObject)
	{
		stageSuffix = (PlayState.SONG.noteStyle == "pixel" ? "-pixel" : "");

		var daBf:String = 'mic';

		if (Paths.exists(Paths.characterJson(PlayState.SONG.player1 + "-dead")))
			daBf = PlayState.SONG.player1 + "-dead";

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		bf.x += bf.positionOffset[0];
        bf.y += bf.positionOffset[1];
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		this.camPos = camPos;
		add(camPos);

		FlxG.sound.play(Paths.sound(lossSFX + stageSuffix));
		Conductor.changeBPM(themeBPM);

		FlxG.camera.follow(camPos, LOCKON, 1);

		bf.playAnim('firstDeath');

		loser = new FlxSprite(100, 100);
		loser.frames = Paths.getSparrowAtlas('lose');
		loser.animation.addByPrefix('lose', 'lose', 24, false);
		loser.scrollFactor.set();
		loser.screenCenter(X);
		loser.y -= 200;
		loser.visible = false;
		add(loser);

		if (PlayState.instance != null)
		{
			PlayState.instance.interpVariables(PlayState.instance.stageInterp);

			if (PlayState.instance.stageInterp.variables.get("onDeathPost") != null)
				PlayState.instance.stageInterp.variables.get("onDeathPost")();
	
			if (PlayState.instance.executeModchart)
			{
				PlayState.instance.interpVariables(PlayState.instance.interp);

				if (PlayState.instance.interp.variables.get("onDeathPost") != null)
					PlayState.instance.interp.variables.get("onDeathPost")();
			}
		}
	}

	function reset():Void
	{
		lossSFX = 'fnf_loss_sfx';
		endSFX = 'gameOverEnd';
		theme = 'gameOver';
		themeBPM = 100;
	}

	var stopQuitting = false;
	var stopEnding = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (PlayState.instance != null)
		{
			PlayState.instance.interpVariables(PlayState.instance.stageInterp);

			if (PlayState.instance.stageInterp.variables.get("onUpdate") != null)
				PlayState.instance.stageInterp.variables.get("onUpdate")(elapsed);
	
			if (PlayState.instance.executeModchart)
			{
				PlayState.instance.interpVariables(PlayState.instance.interp);

				if (PlayState.instance.interp.variables.get("onUpdate") != null)
					PlayState.instance.interp.variables.get("onUpdate")(elapsed);
			}
		}

		if (controls.UI_ACCEPT && !stopEnding)
		{
			endBullshit();
			reset();
			stopEnding = true;
		}

		if (controls.UI_BACK && !stopQuitting)
		{
			quitBullshit();
			reset();
			stopQuitting = true;
		}

		var lerp:Float = Helper.boundTo(elapsed * 2.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music((stageSuffix == "-pixel" ? "pixel/" : "") + theme + stageSuffix));
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
			FlxG.sound.play(Paths.music((stageSuffix == "-pixel" ? "pixel/" : "") + endSFX + stageSuffix));

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
		remove(bf);

		PlayState.openedCharting = false;
		PlayState.startAt = 0;
		Settings.botplay = false;
		PlayState.seenCutscene = false;

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				if (PlayState.isStoryMode)
					CustomTransition.switchTo(new StoryMenuState());
				else
					CustomTransition.switchTo(new FreeplayState());

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
				Conductor.changeBPM(102);
			});
		});
	}
}
