package;

<<<<<<< HEAD
import achievements.AchievementState;
import achievements.Achievements;
=======
import Controls.KeyboardScheme;
>>>>>>> upstream
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
<<<<<<< HEAD
=======
import flixel.group.FlxGroup.FlxTypedGroup;
>>>>>>> upstream
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
<<<<<<< HEAD
	static var curSelected:Int = 0;
=======
	var curSelected:Int = 0;
>>>>>>> upstream

	var bg:FlxBackdrop;
	var magenta:FlxBackdrop;

	var menuItems:FlxSpriteGroup;

	#if !switch
	var optionShit:Array<String> = [
<<<<<<< HEAD
		'story_mode',
		'freeplay',
		#if (FILESYSTEM && MODS_FEATURE) 'mods', #end // remove this line if you want the Mods Menu to be inaccessible!
		#if ACHIEVEMENTS_FEATURE 'achievements', #end // remove this line if you want the Achievements Menu to be inaccessible!
=======
		'story mode',
		'freeplay',
		#if FILESYSTEM 'mods', #end // remove this line if you want the Mods Menu to be inaccessible!
		'achievements', // remove this line if you want the Achievements Menu to be inaccessible!
>>>>>>> upstream
		'credits',
		'options'
	];
	#else
<<<<<<< HEAD
	var optionShit:Array<String> = ['story_mode', 'freeplay'];
=======
	var optionShit:Array<String> = ['story mode', 'freeplay'];
>>>>>>> upstream
	#end

	public static var hopeEngineVer:String = "";
	public static var kadeEngineVer:String = "1.5.2";
<<<<<<< HEAD
	public static var gameVer:String = "0.2.8 (:troll:)";
=======
	public static var gameVer:String = "0.2.7.1";
>>>>>>> upstream

	var camFollow:FlxObject;
	var camPos:FlxObject;

	override function create()
	{
<<<<<<< HEAD
		if (Paths.priorityMod != "hopeEngine")
		{
			if (Paths.exists(Paths.state("MainMenuState")))
			{
				Paths.setCurrentMod(Paths.priorityMod);
				FlxG.switchState(new CustomState("MainMenuState", MAINMENU));

				DONTFUCKINGTRIGGERYOUPIECEOFSHIT = true;
				return;
			}
		}

		if (Paths.priorityMod == "hopeEngine")
			Paths.setCurrentMod(null);
		else
			Paths.setCurrentMod(Paths.priorityMod);

=======
>>>>>>> upstream
		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

<<<<<<< HEAD
=======
		Paths.setCurrentMod(null); // this menu is unmoddable

>>>>>>> upstream
		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

<<<<<<< HEAD
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
=======
		if (!FlxG.sound.music.playing)
>>>>>>> upstream
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}

		persistentUpdate = persistentDraw = true;

<<<<<<< HEAD
		bg = new FlxBackdrop(Paths.image('menuBG'), Y);
=======
		bg = new FlxBackdrop(Paths.image('menuBG'), 1, 1, false);
>>>>>>> upstream
		bg.screenCenter(X);
		bg.antialiasing = true;
		bg.scrollFactor.set(0, 0.1);
		add(bg);

<<<<<<< HEAD
		magenta = new FlxBackdrop(Paths.image('menuDesat'), Y);
=======
		magenta = new FlxBackdrop(Paths.image('menuDesat'), 1, 1, false);
>>>>>>> upstream
		magenta.scrollFactor.set(0, 0.1);
		magenta.screenCenter(X);
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);

		var whatTheMarkSay:String = "Hope Engine v" + hopeEngineVer + "\nKade Engine v" + kadeEngineVer + "\nFunkin' v" + gameVer;

		if (!Settings.watermarks)
			whatTheMarkSay = "v" + hopeEngineVer;

		var watermark = new FlxText(0, 0, 500, whatTheMarkSay, 72);
		watermark.scrollFactor.set();
		watermark.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		watermark.borderSize = 2;
		watermark.setPosition(10, FlxG.height - watermark.height - 10);
		add(watermark);

		menuItems = new FlxSpriteGroup();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
<<<<<<< HEAD
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/' + optionShit[i] + "_assets");
=======
			switch (optionShit[i])
			{
				case 'credits':
					menuItem.frames = Paths.getSparrowAtlas('credits_assets');
				case 'mods':
					menuItem.frames = Paths.getSparrowAtlas('mods_assets');
				case 'achievements':
					menuItem.frames = Paths.getSparrowAtlas('wins_assets');
				default:
					menuItem.frames = Paths.getSparrowAtlas('FNF_main_menu_assets');
			}
>>>>>>> upstream
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('tweakin', optionShit[i] + " basic", 24);
			menuItem.animation.play('tweakin');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 1);
			menuItem.antialiasing = true;
			menuItem.screenCenter(X);
			menuItem.y = (i * 160);
			fuckingStupid.push(menuItem.height);
		}
<<<<<<< HEAD

=======
		
>>>>>>> upstream
		menuItems.screenCenter(Y);

		var cur = menuItems.members[curSelected];
		camPos.setPosition(cur.getGraphicMidpoint().x, cur.getGraphicMidpoint().y);
		FlxG.camera.follow(camPos, LOCKON, 1);

		changeItem(0);

		super.create();

		// friday night funkin check
		var now = Date.now();
		if (now.getDay() == 5)
		{
			if (now.getHours() >= 15)
				Achievements.give("friday_night");
		}
	}

	var selectedSomethin:Bool = false;
	var fuckingStupid:Array<Float> = [];

	var holdTime:Float = 0;

<<<<<<< HEAD
	var DONTFUCKINGTRIGGERYOUPIECEOFSHIT:Bool = false;

	override function update(elapsed:Float)
	{
		if (DONTFUCKINGTRIGGERYOUPIECEOFSHIT)
			return;
		
=======
	override function update(elapsed:Float)
	{
>>>>>>> upstream
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var lerp:Float = Helper.boundTo(elapsed * 9.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);

		if (!selectedSomethin)
		{
<<<<<<< HEAD
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.UI_BACK)
				CustomTransition.switchTo(new TitleState());

			if (controls.UI_ACCEPT)
				acceptItem();
		}

		#if FILESYSTEM
		if (FlxG.keys.justPressed.EIGHT)
		{
			if (FlxG.keys.pressed.SHIFT)
				CustomTransition.switchTo(new EditorsState());
		}
		#end
=======
			if (controls.UP_P)
				changeItem(-1);

			if (controls.DOWN_P)
				changeItem(1);

			if (controls.BACK)
				FlxG.switchState(new TitleState());

			if (controls.ACCEPT)
				acceptItem();
		}

		if (FlxG.keys.justPressed.EIGHT)
		{
			if (FlxG.keys.pressed.SHIFT)
				FlxG.switchState(new EditorsState());
		}
>>>>>>> upstream

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X); // remove or comment out this line to disable the "x-lock" and be able to move menu items horizontally.

			if (spr.animation.curAnim.name.startsWith('selected'))
				spr.offset.set(0, Math.abs((fuckingStupid[curSelected] / 2) - (spr.height / 2)));
		});

		super.update(elapsed);
	}

	function acceptItem()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		if (Settings.flashing)
			FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0}, 1.3, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				if (Settings.flashing)
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						goToState();
					});
				}
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						goToState();
					});
				}
			}
		});
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
<<<<<<< HEAD
			case 'story_mode':
				CustomTransition.switchTo(new StoryMenuState());
			case 'freeplay':
				CustomTransition.switchTo(new FreeplayState());
			case 'credits':
				CustomTransition.switchTo(new CreditsState());
			#if (FILESYSTEM && MODS_FEATURE)
			case 'mods':
				CustomTransition.switchTo(new mods.ModLoadingState());
			#end
			case 'achievements':
				CustomTransition.switchTo(new AchievementState());
			case 'options':
				CustomTransition.switchTo(new options.OptionsState());
=======
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
			case 'credits':
				FlxG.switchState(new CreditsState());
			case 'mods':
				FlxG.switchState(new ModLoadingState());
			case 'achievements':
				FlxG.switchState(new AchievementState());
			case 'options':
				FlxG.switchState(new options.OptionsState());
>>>>>>> upstream
		}
	}

	function changeItem(huh:Int = 0)
	{
<<<<<<< HEAD
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
		
=======
>>>>>>> upstream
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('tweakin');

			if (spr.ID == curSelected)
			{
<<<<<<< HEAD
				spr.animation.play('selected');

=======
				FlxG.sound.play(Paths.sound('scrollMenu'));
				spr.animation.play('selected');
				
>>>>>>> upstream
				var sprY = FlxMath.remapToRange(spr.y + (spr.height / 2), menuItems.y, menuItems.height, 0, FlxG.height);
				camFollow.setPosition(spr.getGraphicMidpoint().x, sprY);
			}

			spr.updateHitbox();
		});
	}
}
