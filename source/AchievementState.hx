package;

import Achievements.Achievement;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;
#if desktop
import Discord.DiscordClient;
#end
#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class AchievementState extends MusicBeatState
{
	var grpAchievements:FlxTypedGroup<Alphabet>;

	var aches:Array<Achievement> = [];
	var isUnlocked:Array<Bool> = [];

	var curSelected:Int = 0;

	var descBG:FlxSprite;
	var descTxt:FlxText;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Achievements Menu");
		#end

		var menuBG = new FlxSprite().loadGraphic(Paths.image("menuBGBlue"));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpAchievements = new FlxTypedGroup<Alphabet>();
		add(grpAchievements);

		for (i in 0...Achievements.achievements.length)
		{
			#if FILESYSTEM
			var achFile = File.getContent(Sys.getCwd() + Paths.achievement(Achievements.achievements[i]));
			#else
			var achFile = Assets.getText(Paths.achievement(Achievements.achievements[i]));
			#end

			var actualAch:Achievement = cast Json.parse(achFile);
			aches.push(actualAch);

			var stringToUse = actualAch.name;
			var unlocked = true;
			if (Achievements.achievementsGet.get(Achievements.achievements[i]) != null)
			{
				stringToUse = "???";
				unlocked = false;
			}

			isUnlocked.push(unlocked);

			var ach:Alphabet = new Alphabet(25, (70 * i) + 30, stringToUse, false);
			ach.isMenuItem = true;
			ach.targetY = i;
			grpAchievements.add(ach);

			var box:FlxSprite = new FlxSprite();
			box.frames = Paths.getSparrowAtlas("achievementBox");
			box.animation.addByPrefix("idle", "box", 24);
			box.animation.play('idle');
			box.setGraphicSize(125);
			box.updateHitbox();
			box.antialiasing = true;
			box.x = -ach.width - 75;
			box.y = (ach.height / 2) - (box.height / 2);

			var lock:FlxSprite = null;

			if (!unlocked)
			{
				box.color = 0xff000000;

				lock = new FlxSprite();
				lock.frames = Paths.getSparrowAtlas("achievementLock");
				lock.animation.addByPrefix("idle", "lock", 24);
				lock.animation.play('idle');
				lock.setGraphicSize(0, Std.int(box.height + 10));
				lock.updateHitbox();
				lock.antialiasing = true;
				lock.x = box.x + (box.width / 2) - (lock.width / 2);
				lock.y = box.y + (box.height / 2) - (lock.height / 2);
				// ach.add(lock);
			}

			// coords normalize after adding to an FlxSpriteGroup
			ach.add(box);

			if (lock != null)
				ach.add(lock);
		}

		descBG = new FlxSprite().makeGraphic(Std.int((FlxG.width * 0.85) + 8), 72, 0xFF000000);
		descBG.alpha = 0.6;
		descBG.screenCenter(X);
		descBG.visible = false;
		add(descBG);

		descTxt = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, " ");
		descTxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descTxt.screenCenter(X);
		descTxt.borderSize = 3;
		add(descTxt);

		changeSelection();

		super.create();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpAchievements.length - 1;
		if (curSelected >= grpAchievements.length)
			curSelected = 0;

		if (aches[curSelected].desc != null || aches[curSelected].hint != null)
		{
			if (isUnlocked[curSelected])
				descTxt.text = aches[curSelected].desc;
			else
				descTxt.text = aches[curSelected].hint != null ? aches[curSelected].hint : aches[curSelected].desc;

			descTxt.y = (FlxG.height * 0.9) - (descTxt.height / 2);
			descTxt.screenCenter(X);
			descTxt.visible = true;

			descBG.setGraphicSize(Std.int(descTxt.width + 20), Std.int(descTxt.height + 20));
			descBG.screenCenter(X);
			descBG.y = (FlxG.height * 0.9) - (descBG.height / 2);
			descBG.visible = true;
		}
		else
		{
			descBG.visible = false;
			descTxt.visible = false;
			descTxt.text = "";
		}

		var bullShit:Int = 0;

		for (item in grpAchievements.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UP_P)
			changeSelection(-1);

		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		for (achLabel in grpAchievements.members)
			achLabel.x = FlxMath.lerp(achLabel.x, (achLabel.targetY * 20) + 315, 9 / lime.app.Application.current.window.frameRate);
	}
}
