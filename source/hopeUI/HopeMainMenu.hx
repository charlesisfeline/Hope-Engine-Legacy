package hopeUI;

import achievements.Achievements;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

using StringTools;

class HopeMainMenu extends MusicBeatState
{
	var optionShit:Array<String> = [
		'story mode',
		'freeplay',
		#if FILESYSTEM 'mods', #end // remove this line if you want the Mods Menu to be inaccessible!
		'achievements', // remove this line if you want the Achievements Menu to be inaccessible!
		'credits',
		'options'
	];

	var fuckingStupid:Array<Float> = [];
	var menuItems:FlxSpriteGroup;
	static var curSelected:Int = 0;
	var camFollow:FlxObject;
	var camPos:FlxObject;

	override function create()
	{
		var bg = new FlxBackdrop(Paths.image('hopeUI/bgInvert'), 1, 1, false);
		bg.screenCenter(X);
		bg.antialiasing = true;
		bg.scrollFactor.set(0, 0.1);
		add(bg);

		var overlay = new FlxBackdrop(Paths.image("hopeUI/genericCheckeredOverlay"));
		overlay.velocity.set(120, -120);
		overlay.scale.set(2, 2);
		overlay.alpha = 0.3;
		add(overlay);

		var gradi = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xffad34ff, FlxColor.TRANSPARENT], 1, 180);
		gradi.scrollFactor.set();
		gradi.screenCenter();
		gradi.alpha = 0.4;
		add(gradi);

		gradi.x = FlxG.width;
		FlxTween.tween(gradi, {x: 0}, 2, {ease: FlxEase.sineInOut});

		var gradi = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.TRANSPARENT, 0xffad34ff], 1, 180);
		gradi.scrollFactor.set();
		gradi.screenCenter();
		gradi.alpha = 0.4;
		add(gradi);

		gradi.x = -FlxG.width;
		FlxTween.tween(gradi, {x: 0}, 2, {ease: FlxEase.sineInOut});

		menuItems = new FlxSpriteGroup();
		add(menuItems);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);

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
			menuItem.scrollFactor.set(1, 1);
			menuItem.antialiasing = true;
			menuItem.x = (i * 60);
			menuItem.y = (i * FlxG.height);
			fuckingStupid.push(menuItem.height);
		}

		var cur = menuItems.members[curSelected];
		camPos.setPosition(cur.x + (FlxG.width * 0.45), cur.getGraphicMidpoint().y);
		FlxG.camera.follow(camPos, LOCKON, 1);

		changeItem();

		super.create();

		Achievements.give("hope_ui");
	}

	function changeItem(huh:Int = 0)
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
		
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
				camFollow.setPosition(spr.x + (FlxG.width * 0.45), spr.getGraphicMidpoint().y);
				spr.animation.play('selected');
			}

			spr.updateHitbox();
		});
	}

	var selected:Bool = false;

	function selectItem():Void
	{
		selected = true;
		FlxG.sound.play(Paths.sound("confirmMenu"));

		FlxTween.tween(FlxG.camera, {zoom: 1.1}, 1, {
			ease: FlxEase.sineInOut,
			onComplete: function(twn:FlxTween)
			{
				goToState();
			}
		});

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			else
				FlxTween.tween(spr, {alpha: 0, x: spr.x - 300}, 1, {ease: FlxEase.expoInOut});
		});
	}

	function goToState():Void
	{
		var lma = optionShit[curSelected];

		switch (lma)
		{
			case "story mode":
				FlxG.switchState(new StoryMenuState());
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var lerp:Float = Helper.boundTo(elapsed * 9.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);

		if (!selected)
		{
			if (controls.UP_P)
				changeItem(-1);

			if (controls.DOWN_P)
				changeItem(1);

			if (controls.BACK)
				FlxG.switchState(new HopeTitle());

			if (controls.ACCEPT)
				selectItem();
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.curAnim.name.startsWith('selected'))
				spr.offset.set(0, Math.abs((fuckingStupid[curSelected] / 2) - (spr.height / 2)));
		});
	}
}
