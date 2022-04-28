package;

import editors.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end
#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class EditorsState extends MusicBeatState
{
	var options:Array<String> = ["Chart Editor", "Character Editor", "Week Editor", "Event Editor"];

	var grpOptions:FlxTypedGroup<Alphabet>;
	
	var mods:Array<String> = ["none"];

	var curSelected:Int = 0;
	var curMod:Int = 0;

	var modTxt:FlxText;
	var modTxtBG:FlxSprite;

	override function create()
	{
		Paths.setCurrentMod(null);

		#if desktop
		DiscordClient.changePresence("Editors Menu");
		#end

		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat_gradient"));
		bg.screenCenter();
		bg.color = 0xffad34ff;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var option:Alphabet = new Alphabet(25, (70 * i) + 30, options[i], true);
			option.isMenuItem = true;
			option.targetY = i;
			grpOptions.add(option);
		}

		modTxtBG = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 64, FlxColor.BLACK);
		modTxtBG.alpha = 0.6;
		add(modTxtBG);

		modTxt = new FlxText(0, modTxtBG.y, FlxG.width, "");
		modTxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		modTxt.borderSize = 3;
		add(modTxt);

		FlxTween.tween(modTxtBG, {y: FlxG.height - modTxtBG.height}, 1, {ease: FlxEase.sineInOut, startDelay: 0.5});

		for (mod in FileSystem.readDirectory(Sys.getCwd() + "/mods"))
			mods.push(mod.trim());

		changeMod();
		changeSelection();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpOptions.length - 1;
		if (curSelected >= grpOptions.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			
			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	function changeMod(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curMod += huh;

		if (curMod < 0)
			curMod = mods.length - 1;
		if (curMod >= mods.length)
			curMod = 0;

		var mod = mods[curMod];

		modTxt.text = 'CURRENT MOD: < $mod >';

		if (mod == 'none')
		{
			Paths.setCurrentMod(null);
			modTxt.text = '< NO MOD SELECTED >';
		}
		else
			Paths.setCurrentMod(mod);
	}

	function select():Void
	{
		var state:MusicBeatState = null;
		switch (options[curSelected])
		{
			case "Chart Editor":
				ChartingState.fromEditors = true;
				state = new ChartingState();
			case "Character Editor":
				CharacterEditor.fromEditors = true;
				state = new CharacterEditor();
			case "Week Editor":
				WeekEditor.fromEditors = true;
				state = new WeekEditor();
			case "Event Editor":
				EventEditor.fromEditors = true;
				state = new EventEditor();
		}

		FlxG.switchState(state);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());
		if (controls.ACCEPT)
			select();

		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.LEFT_P)
			changeMod(-1);
		if (controls.RIGHT_P)
			changeMod(1);

		for (opt in grpOptions)
			opt.x = FlxMath.lerp(opt.x, (opt.targetY * 20) + 90, Helper.boundTo(elapsed * 9.6, 0, 1));

		modTxt.y = modTxtBG.y + (modTxtBG.height / 2) - (modTxt.height / 2);
	}
}
