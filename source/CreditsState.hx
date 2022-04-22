package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
#if desktop
import Discord.DiscordClient;
#end

class CreditsState extends MusicBeatState
{
	var alphabets:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var allTheShit:Array<Array<String>> = [];

	var descBackground:FlxSprite;
	var descriptionShit:FlxText;
	var menuBG:FlxBackdrop;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Credits", null);
		#end

		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		menuBG = new FlxBackdrop(Paths.image('credBG'), 1, 1, false);
		menuBG.screenCenter(X);
		menuBG.antialiasing = true;
		menuBG.color = 0xff3e3040;
		add(menuBG);

		alphabets = new FlxTypedGroup<Alphabet>();
		add(alphabets);

		descBackground = new FlxSprite().makeGraphic(Std.int((FlxG.width * 0.85) + 8), 72, 0xFF000000);
		descBackground.alpha = 0.6;
		descBackground.screenCenter(X);
		descBackground.visible = false;
		add(descBackground);

		descriptionShit = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, " ");
		descriptionShit.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionShit.screenCenter(X);
		descriptionShit.borderSize = 3;
		add(descriptionShit);

		descBackground.setPosition(descriptionShit.x - 4, descriptionShit.y - 4);

		var credits:Array<Dynamic> = Json.parse(Assets.getText(Paths.json('credits')));

		for (i in 0...credits.length)
		{
			var curCategory = credits[i];

			var catLabel:Alphabet = new Alphabet(0, 0, curCategory.categoryName, true);
			catLabel.isMenuItem = true;
			catLabel.targetY = alphabets.members.length - 1;
			catLabel.y = catLabel.getTargetY();
			catLabel.screenCenter(X);
			alphabets.add(catLabel);

			allTheShit.push([curCategory.categoryName, "", ""]);

			var catItems:Array<Dynamic> = curCategory.categoryItems;
			for (i2 in 0...catItems.length)
			{
				var curCredit = curCategory.categoryItems[i2];

				var credLabel:Alphabet = new Alphabet(0, 0, curCredit.name, false);
				credLabel.isMenuItem = true;
				credLabel.targetY = alphabets.members.length - 1;
				credLabel.y = credLabel.getTargetY();
				credLabel.screenCenter(X);
				alphabets.add(credLabel);

				allTheShit.push([
					curCredit.name,
					(curCredit.desc == null ? "" : curCredit.desc),
					(curCredit.link == null ? "" : curCredit.link),
					(curCredit.tint == null ? "3e3040" : curCredit.tint)
				]);
			}
		}

		changeSelection();
		if (alphabets.members[curSelected].isBold)
			changeSelection(1);

		super.create();
	}

	var bgTargetY:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		menuBG.y = FlxMath.lerp(menuBG.y, bgTargetY, Helper.boundTo(elapsed * 9.6, 0, 1));

		if (controls.UP_P)
		{
			changeSelection(-1);
			if (alphabets.members[curSelected].isBold)
				changeSelection(-1);
		}

		if (controls.DOWN_P)
		{
			changeSelection(1);
			if (alphabets.members[curSelected].isBold)
				changeSelection(1);
		}

		if (controls.ACCEPT)
		{
			if (allTheShit[curSelected][2] != "")
				fancyOpenURL(allTheShit[curSelected][2]);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = alphabets.length - 1;
		if (curSelected >= alphabets.length)
			curSelected = 0;

		bgTargetY = -120 * 0.2 * curSelected;

		if (allTheShit[curSelected][1] != "")
		{
			descriptionShit.text = allTheShit[curSelected][1];
			descriptionShit.y = (FlxG.height * 0.9) - (descriptionShit.height / 2);
			descriptionShit.visible = true;

			descBackground.setGraphicSize(Std.int(descriptionShit.width + 20), Std.int(descriptionShit.height + 20));
			descBackground.screenCenter(X);
			descBackground.y = (FlxG.height * 0.9) - (descBackground.height / 2);
			descBackground.visible = true;
		}
		else
		{
			descBackground.visible = false;
			descriptionShit.visible = false;
			descriptionShit.text = "";
		}

		if (Settings.flashing)
		{
			FlxTween.cancelTweensOf(menuBG, ["color"]);
			FlxTween.color(menuBG, 0.5, menuBG.color, FlxColor.fromString("#" + allTheShit[curSelected][3]));
		}

		var bullShit:Int = 0;

		for (item in alphabets.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!item.isBold)
				item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
