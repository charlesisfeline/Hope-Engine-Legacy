#if FILESYSTEM
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
import sys.FileSystem;
import sys.io.File;

using StringTools;
#if desktop
import Discord.DiscordClient;
#end


class EditorsState extends MusicBeatState
{
	var options:Array<String> = [
		"Chart Editor",
		"Character Editor",
		"Week Editor",
		"Dialogue Editor",
		"Menu Character Editor",
		"Note Type Editor",
		"Event Editor",
		"Position Offset Editor",
		"Credits Editor",
		"Stage Editor"
	];

	var grpOptions:FlxTypedGroup<Alphabet>;

	var mods:Array<String> = ["none"];

	static var curSelected:Int = 0;
	static var curMod:Int = 0;

	var modTxt:FlxText;
	var modTxtBG:FlxSprite;

	override function create()
	{
		if (Paths.priorityMod != "hopeEngine")
		{
			if (Paths.exists(Paths.state("EditorsState")))
			{
				Paths.setCurrentMod(Paths.priorityMod);
				FlxG.switchState(new CustomState("EditorsState", EDITORS));

				DONTFUCKINGTRIGGERYOUPIECEOFSHIT = true;
				return;
			}
		}

		if (Paths.priorityMod == "hopeEngine")
			Paths.setCurrentMod(null);
		else
			Paths.setCurrentMod(Paths.priorityMod);

		#if desktop
		DiscordClient.changePresence("Editors Menu");
		#end

		super.create();

		FlxG.mouse.visible = false;

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
				LoadingState.loadAndSwitchState(state);
				return;
			case "Character Editor":
				CharacterEditor.fromEditors = true;
				state = new CharacterEditor();
			case "Dialogue Editor":
				DialogueEditor.fromEditors = true;
				state = new DialogueEditor();
			case "Week Editor":
				WeekEditor.fromEditors = true;
				state = new WeekEditor();
			case "Event Editor":
				EventEditor.fromEditors = true;
				state = new EventEditor();
			case "Menu Character Editor":
				MenuCharacterEditor.fromEditors = true;
				state = new MenuCharacterEditor();
			case "Note Type Editor":
				NoteTypeEditor.fromEditors = true;
				state = new NoteTypeEditor();
			case "Position Offset Editor":
				PositionOffsetEditor.fromEditors = true;
				state = new PositionOffsetEditor();
			case "Credits Editor":
				CreditsEditor.fromEditors = true;
				state = new CreditsEditor();
			case "Stage Editor":
				StageEditor.fromEditors = true;
				state = new StageEditor();
			case "Stage JSON Creator":
				StageJSONCreator.fromEditors = true;
				state = new StageJSONCreator();
		}

		CustomTransition.switchTo(state);
	}

	var DONTFUCKINGTRIGGERYOUPIECEOFSHIT:Bool = false;

	override function update(elapsed:Float)
	{
		if (DONTFUCKINGTRIGGERYOUPIECEOFSHIT)
			return;

		super.update(elapsed);

		if (controls.UI_BACK)
			CustomTransition.switchTo(new MainMenuState());
		if (controls.UI_ACCEPT)
			select();

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			changeMod(-1);
		if (controls.UI_RIGHT_P)
			changeMod(1);

		for (opt in grpOptions)
			opt.x = FlxMath.lerp(opt.x, (opt.targetY * 20) + 90, Helper.boundTo(elapsed * 9.6, 0, 1));

		modTxt.y = modTxtBG.y + (modTxtBG.height / 2) - (modTxt.height / 2);
	}
}
#end