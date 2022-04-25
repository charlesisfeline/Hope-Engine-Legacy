package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
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
	var curSelected:Int = 0;

	var bg:FlxBackdrop;
	var magenta:FlxBackdrop;

	var menuItems:FlxSpriteGroup;

	#if !switch
	var optionShit:Array<String> = [
		'story mode',
		'freeplay',
		#if FILESYSTEM 'mods', #end // remove this line if you want the Mods Menu to be inaccessible!
		'achievements', // remove this line if you want the Achievements Menu to be inaccessible!
		'credits',
		'options'
	];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	public static var hopeEngineVer:String = "";
	public static var kadeEngineVer:String = "1.5.2";
	public static var gameVer:String = "0.2.7.1";

	var camFollow:FlxObject;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		Paths.setCurrentMod(null); // this menu is unmoddable

		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}

		persistentUpdate = persistentDraw = true;

		bg = new FlxBackdrop(Paths.image('menuBG'), 1, 1, false);
		bg.screenCenter(X);
		bg.antialiasing = true;
		bg.scrollFactor.set(0, 0.1);
		add(bg);

		magenta = new FlxBackdrop(Paths.image('menuDesat'), 1, 1, false);
		magenta.scrollFactor.set(0, 0.1);
		magenta.screenCenter(X);
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

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
		
		menuItems.screenCenter(Y);

		FlxG.camera.follow(camFollow, LOCKON, Helper.boundTo(FlxG.elapsed * 9.6, 0, 1));

		changeItem(0);

		super.create();
	}

	var selectedSomethin:Bool = false;
	var fuckingStupid:Array<Float> = [];

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.camera.followLerp = Helper.boundTo(FlxG.elapsed * 9.6, 0, 1);

		if (!selectedSomethin)
		{
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
		}
	}

	function changeItem(huh:Int = 0)
	{
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
				FlxG.sound.play(Paths.sound('scrollMenu'));
				spr.animation.play('selected');
				
				var sprY = FlxMath.remapToRange(spr.y + (spr.height / 2), menuItems.y, menuItems.height, 0, FlxG.height);
				camFollow.setPosition(spr.getGraphicMidpoint().x, sprY);
			}

			spr.updateHitbox();
		});
	}
}
