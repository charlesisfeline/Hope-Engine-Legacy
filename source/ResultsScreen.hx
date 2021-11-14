package;

import Controls.Control;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class ResultsScreen extends MusicBeatSubstate
{
	var winType:String = Ratings.GenerateLetterRank(PlayState.accuracy);
	var daType:String = "";
	var currentRankImage:String = "NA";
	
	var daRankLogo:FlxSprite;

	var judgementImage:FlxSprite;
	var judgementDisplay:FlxText;

	var mainGroup:FlxTypedGroup<FlxSprite>;
	var otherShit:FlxTypedGroup<FlxSprite>;
	var theWaitIsFinished:Bool = false;
	var theWaitHasStarted:Bool = false;
	
	var winTypeDisplay:FlxText;
	var pauseMusic:FlxSound;

	var pissCamera:FlxCamera;

	var pixelShitPart1 = "";
    var pixelShitPart2 = "";
    var pixelZoom:Float = 1;

	var accuracyCount:Count;
	var rankImage:FlxSprite;

	var peakComboCount:Count;
	var maxComboImage:FlxSprite;

	var ratings:Array<String> = [
		"sick",
		"good",
		"bad",
		"shit",
		"miss"
	];

	var ratingValues:Array<Float> = [
		PlayState.isStoryMode ? PlayState.weekSicks : PlayState.sicks,
		PlayState.isStoryMode ? PlayState.weekGoods : PlayState.goods,
		PlayState.isStoryMode ? PlayState.weekBads : PlayState.bads,
		PlayState.isStoryMode ? PlayState.weekShits : PlayState.shits,
		PlayState.isStoryMode ? PlayState.weekMisses : PlayState.misses
	];
	var theScoreForThis:Int = PlayState.isStoryMode ? PlayState.campaignScore : PlayState.songScore;

	var thePeakComboForThis:String = PlayState.isStoryMode ? PlayState.weekPeakCombo.join(", ") : PlayState.peakCombo + "";

	var lerpScore:Float = 0;
	var intendedScore:Float = 0;
	
	var backgroundThing:FlxSprite;

	public function new()
	{
		super();

		persistentUpdate = persistentDraw = true;

		FlxG.sound.playMusic(Paths.music('results'), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.7);

		pissCamera = new FlxCamera();
		pissCamera.bgColor = FlxColor.BLACK;
		pissCamera.bgColor.alphaFloat = 0.6;
		pissCamera.alpha = 0;
		FlxG.cameras.add(pissCamera);

		mainGroup = new FlxTypedGroup<FlxSprite>();
		mainGroup.cameras = [pissCamera];
		add(mainGroup);

		otherShit = new FlxTypedGroup<FlxSprite>();
		otherShit.cameras = [pissCamera];
		add(otherShit);

		getWinType();

		PlayState.instance.camHUD.visible = false;

		var title:Alphabet = new Alphabet(0, 0, (PlayState.isStoryMode ? "WEEK" : "SONG") + " CLEARED!");
		title.y = 35;
		title.color = 0xFFFFFFFF;
		title.screenCenter(X);
		add(title);

		if (PlayState.SONG.noteStyle == "pixel")
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
			pixelZoom = PlayState.daPixelZoom;
		}

		for (i in 0...ratings.length)
		{
			var rating = ratings[i];
			var value = ratingValues[i];

			if (FlxG.save.data.familyFriendly)
			{
				if (rating == "shit")
					rating = "bad";

				if (rating == "bad")
					rating = "okay";
			}

			var image:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + rating + pixelShitPart2));
			image.setGraphicSize(Std.int(image.width * pixelZoom * 0.7));
			image.updateHitbox();

			if (PlayState.SONG.noteStyle != "pixel")
				image.antialiasing = true;
			
			image.x = 25 * (i + 1);
			image.y = 100 * (i + 1);

			image.x += 25;

			var count:Count = new Count(null, null, value + "");
			count.x = image.x + image.width + 50;
			count.y = image.y + (image.height / 2) - (count.height / 2);

			image.x -= FlxG.width / 2;
			count.x -= FlxG.width / 2;

			if (FlxG.save.data.ratingColor)
			{
				switch (rating)
				{
					case 'shit' | 'bad' | 'miss':
						image.color = 0xffff0000;
					case 'good':
						image.color = 0xff66ff33;
					case 'sick':
						image.color = 0xffad34ff;
				}
			}
			
			mainGroup.add(count);
			mainGroup.add(image);
		}

		rankImage = new FlxSprite().loadGraphic(Paths.image('ranks/NA'));
		rankImage.antialiasing = true;
		rankImage.scale.set(0.35, 0.35);
		rankImage.updateHitbox();
		rankImage.screenCenter();
		// rankImage.y = 100;
		add(rankImage);

		accuracyCount = new Count(0, 0, "0.00%");
		accuracyCount.screenCenter();
		// accuracyCount.y -= 25;
		accuracyCount.y += 150;
		add(accuracyCount);

		maxComboImage = new FlxSprite(FlxG.width, FlxG.height / 2 + 5).loadGraphic(Paths.image(pixelShitPart1 + 'maxCombo' + pixelShitPart2));
		maxComboImage.setGraphicSize(Std.int(maxComboImage.width * pixelZoom * 0.7));
		maxComboImage.updateHitbox();
		add(maxComboImage);

		peakComboCount = new Count(FlxG.width, 0, thePeakComboForThis);
		peakComboCount.y = maxComboImage.y + maxComboImage.height + 2;
		add(peakComboCount);

		// TEXT STUFF :))))

		var pressEnter:FlxText = new FlxText(0, 0, 0, "Press [ENTER] to continue.");
		pressEnter.setFormat(null, 32, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		pressEnter.borderSize = 3;
		pressEnter.x = FlxG.width - pressEnter.width - 10;
		pressEnter.y = FlxG.height - 80;
		otherShit.add(pressEnter);

		var pressBackspace:FlxText = new FlxText(0, 0, 0, "Press [R] to restart song.");
		pressBackspace.setFormat(null, 20, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		pressBackspace.borderSize = 3;
		pressBackspace.x = FlxG.width - pressBackspace.width - 10;
		pressBackspace.y = FlxG.height - pressBackspace.height - 10;

		if (!PlayState.loadRep && !PlayState.isStoryMode)
			otherShit.add(pressBackspace);

		var winTypeDisplay:FlxText = new FlxText(10, FlxG.height - 80, 0, daType);
		winTypeDisplay.setFormat(null, 32, FlxColor.WHITE, LEFT, OUTLINE, 0xFF000000);
		winTypeDisplay.borderSize = 3;
		otherShit.add(winTypeDisplay);

		switch (daType)
		{
			case 'All Sicks!':
				winTypeDisplay.color = 0xFFAD34FF; // sick's purple
			case 'All Sicks & Goods!':
				winTypeDisplay.color = 0xFF00FF00; // green
			case 'Normal Full Combo!':
				winTypeDisplay.color = 0xFFC0C0C0; // silver
			case 'Single Digit Combo Breaker!': 
				winTypeDisplay.color = 0xFFCD7F32; // bronze
		}
		
		var songThings:FlxText = new FlxText(0, 0, 0, "");
		songThings.setFormat(null, 20, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		songThings.borderSize = 3;
		songThings.x = 10;
		songThings.y = FlxG.height - songThings.height - 10;
		otherShit.add(songThings);

		songThings.text = '${(FlxG.save.data.botplay ? 'FNF played' : 'Played')} ${PlayState.SONG.song.toUpperCase()} on ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty)}';

		forEachOfType(FlxSprite, function(spr:FlxSprite) 
		{
			spr.cameras = [pissCamera];
		});

		forEachOfType(FlxSprite, function(spr:FlxSprite) 
		{
			var wantedAlpha:Float = 1;
			if (spr.alpha != 1)
				wantedAlpha = spr.alpha;

			spr.alpha = 0;
			if (!mainGroup.members.contains(spr) && !otherShit.members.contains(spr))
			{
				spr.y -= 100;
				FlxTween.tween(spr, {alpha: wantedAlpha, y: spr.y + 100}, 1, {ease: FlxEase.expoInOut});
			}
			else if (!otherShit.members.contains(spr))
				spr.alpha = 1;
			
		}, true);

		new FlxTimer().start(1.5, function(tmr:FlxTimer)
		{
			theWaitHasStarted = true;
			
			if (!PlayState.isStoryMode)
				intendedScore = PlayState.accuracy;
			else
			{
				var average:Float = 0.00;

				for (acc in PlayState.weekAccuracies)
					average += acc;
				
				average /= PlayState.weekAccuracies.length;

				intendedScore = average;
			}
		});

		FlxTween.tween(pissCamera, {alpha: 1}, 0.5);

		#if windows
		var location:String = (PlayState.isStoryMode ? 
			"WEEK \"" + StoryMenuState.weekNames[PlayState.storyWeek].toUpperCase() + "\"" : 
			"SONG \"" + PlayState.SONG.song.toUpperCase() + "\"");
		
		DiscordClient.changePresence("In the Results Screen", "\nWIN! At " + location);
		#end
	}

	var dontSpam = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!theWaitIsFinished && theWaitHasStarted)
		{
			if (Math.abs(lerpScore - intendedScore) <= 5)
			{
				lerpScore = intendedScore;
				theWaitIsFinished = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				// PAIN
				rankImage.alpha = 0;
				currentRankImage = Ratings.ranks[Std.parseInt(Ratings.GenerateLetterRank(lerpScore, true))];
				rankImage.loadGraphic(Paths.image('ranks/' + currentRankImage));
				FlxTween.tween(rankImage, {alpha: 1}, 0.2);
				rankImage.scale.set(0.35, 0.35);
				rankImage.updateHitbox();
				rankImage.screenCenter();
				FlxTween.tween(rankImage, {x: FlxG.width - rankImage.width - 50, y: 100}, 2, {ease: FlxEase.expoInOut});
				
				if (intendedScore != 0)
					accuracyCount.changeNumber(HelperFunctions.truncateFloat(lerpScore, 2) + "%");
				
				FlxTween.tween(accuracyCount, {x: FlxG.width - accuracyCount.width - 50, y: (FlxG.height / 2) - 5 - accuracyCount.height}, 2, {ease: FlxEase.expoInOut});

				FlxTween.tween(maxComboImage, {x: FlxG.width - maxComboImage.width - 50}, 2, {ease: FlxEase.expoInOut});
				FlxTween.tween(peakComboCount, {x: FlxG.width - peakComboCount.width - 50}, 2, {ease: FlxEase.expoInOut});

				for (i in 0...mainGroup.members.length)
				{
					var spr = mainGroup.members[i];
					FlxTween.tween(spr, {x: spr.x + (FlxG.width / 2)}, 2, {startDelay: 0.1 * i, ease: FlxEase.expoInOut});
				}

				for (i in 0...otherShit.members.length)
				{
					var spr = otherShit.members[i];
					FlxTween.tween(spr, {alpha: 1}, 2, {startDelay: 0.3 * i, ease: FlxEase.expoInOut});
				}
			}
			else
			{
				lerpScore = FlxMath.lerp(lerpScore, intendedScore, 1 / Application.current.window.frameRate);
			}

			if (intendedScore != 0)
				accuracyCount.changeNumber(HelperFunctions.truncateFloat(lerpScore, 2) + "%");
			
			accuracyCount.screenCenter(X);
			
			if (Ratings.ranks[Std.parseInt(Ratings.GenerateLetterRank(lerpScore, true))] != currentRankImage)
			{
				rankImage.alpha = 0;
				currentRankImage = Ratings.ranks[Std.parseInt(Ratings.GenerateLetterRank(lerpScore, true))];
				rankImage.loadGraphic(Paths.image('ranks/' + currentRankImage));
				FlxTween.tween(rankImage, {alpha: 1}, 0.2);
				rankImage.scale.set(0.35, 0.35);
				rankImage.updateHitbox();
				rankImage.screenCenter();
			}
		}

		if (FlxG.keys.justPressed.ENTER && !dontSpam && theWaitIsFinished)
		{
			dontSpam = true;
			if(PlayState.loadRep)
			{
				FlxG.save.data.botplay = false;
				FlxG.save.data.scrollSpeed = 1;
				FlxG.save.data.downscroll = false;
			}
			PlayState.loadRep = false;
			#if windows
			if (PlayState.luaModchart != null)
			{
				PlayState.luaModchart.die();
				PlayState.luaModchart = null;
			}
			#end
			if (FlxG.save.data.fpsCap > 290)
				(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
			FlxG.sound.music.fadeOut(0.5, 0);

			pissCamera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
				FlxG.sound.music.fadeIn(0, 0.7, 0.7);
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			});
		}
		else if (FlxG.keys.justPressed.ENTER && !dontSpam && !theWaitIsFinished)
			lerpScore = intendedScore - 3;

		if (FlxG.keys.justPressed.R && !dontSpam && !PlayState.loadRep && !PlayState.isStoryMode && theWaitIsFinished)
		{
			dontSpam = true;
			pissCamera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.resetState();
			});
		}
		
	}

	function getWinType()
	{

		var types = {
			"(SFC)" : "All Sicks!",
			"(GFC)" : "All Sicks & Goods!",
			"(FC)" : "Normal Full Combo!",
			"(SDM)" : "Single Digit Misses!",
			"(PASS)" : "Pass!"
		};

		for (key in Reflect.fields(types))
		{
			if (winType.contains(key))
				daType = Reflect.field(types, key);
		}
	}
}
