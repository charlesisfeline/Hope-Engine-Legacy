package mods;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import sys.FileSystem;
import sys.io.File;
import ui.InputTextFix;
import yaml.Yaml;

using StringTools;

/**
	Inspired by TModLoader and their that thing
	I've been working with Terrarias stuff and its so fun
**/
class ModSkeletonSubstate extends MusicBeatSubstate
{
	var inputBG:FlxSprite;
	var input:InputTextFix;
	var inst:FlxText;

	var addFolder:FlxUIButton;
	var warnings:FlxText;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), FlxColor.BLACK);
		bg.alpha = 0.8;
		add(bg);

		var create = new FlxText(0, FlxG.height * 0.15, FlxG.width, "Create a Mod Skeleton");
		create.setFormat("VCR OSD Mono", 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		create.borderSize = 3;
		add(create);

		var name = new FlxText(0, FlxG.height * 0.4, FlxG.width, "Mod Folder Name");
		name.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		name.borderSize = 3;
		add(name);

		inputBG = new FlxSprite(0, FlxG.height * 0.5).makeGraphic(10, 10, 0xFF000000);
		inputBG.alpha = 0.5;
		inputBG.setGraphicSize(Std.int(FlxG.width * 0.3), 32);
		inputBG.updateHitbox();
		inputBG.screenCenter();

		addFolder = new FlxUIButton(0, inputBG.y + inputBG.height + 5, "Add Folder", createSkeleton);
		addFolder.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		addFolder.resize(inputBG.width, inputBG.height);
		addFolder.screenCenter(X);
		addFolder.label.size = 16;
		addFolder.offset.y = -4;
		add(addFolder);

		warnings = new FlxText(0, addFolder.y, FlxG.width, "", 24);
		warnings.exists = false;
		warnings.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		warnings.borderSize = 3;
		add(warnings);

		inst = new FlxText(inputBG.x + 5, inputBG.y + 2, Std.int(FlxG.width * 0.3 - 10), "Input name here");
		inst.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, NONE);
		inst.alpha = 0.9;
		inst.offset.y = -2;

		input = new InputTextFix(inputBG.x + 5, inputBG.y + 2, Std.int(FlxG.width * 0.3 - 10), "", 16, FlxColor.WHITE);
		input.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, NONE);
		input.caretColor = FlxColor.WHITE;
		input.fieldBorderColor = FlxColor.TRANSPARENT;
		input.offset.y = -2;
		// input.filterMode = FlxInputText.CUSTOM_FILTER;
		input.customFilterPattern = ~/(\s+.*|.*[\\\/:\\"?*|<>].*|.*\s+|.*\.)$/g;
		@:privateAccess
		input.backgroundSprite.alpha = 0;
		input.callback = nameCheck;

		input.callback("", "");

		add(inputBG);
		add(input);
		add(inst);

		forEachOfType(FlxSprite, function(spr:FlxSprite)
		{
			var sAlpha = spr.alpha;
			spr.alpha = 0;
			spr.scrollFactor.set();
			FlxTween.tween(spr, {alpha: sAlpha}, 0.5);
		}, true);
	}

	function nameCheck(_, _)
	{
		if (CoolUtil.fileNameCheck(input.text))
		{
			if (input.text.length <= 0)
			{
				addFolder.exists = false;
				warnings.text = "Folder name must be\nat least more than 1 character!";
			}
			else
			{
				if (Paths.exists('mods/' + input.text))
				{
					addFolder.exists = false;
					warnings.text = "Mod folder already exists!";
				}
				else if (input.text.toLowerCase() == 'hopeengine')
				{
					addFolder.exists = false;
					warnings.text = "Friday Night Funkin' - Hope Engine\nis an FNF Engine made from Kade Engine 1.5.2\nthat provides more QoL features, bug fixes, and more.";
				}
				else
					addFolder.exists = true;
			}
		}
		else
		{
			addFolder.exists = false;
			warnings.text = "Invalid file name!";
		}

		warnings.exists = !addFolder.exists;
	}

	function createSkeleton()
	{
		var modName = input.text.trim();

		FileSystem.createDirectory(Sys.getCwd() + 'mods/' + modName);
		FileSystem.createDirectory(Sys.getCwd() + 'mods/' + modName + "/assets");
		Yaml.write(Sys.getCwd() + 'mods/' + modName + "/mod.yml", {
			name: "Your Mod Name",
			description: "Description here"
		});
		Yaml.write(Sys.getCwd() + 'mods/' + modName + "/load.yml", {
			load: false
		});

		var folders = ["_characters", "_weeks", "data", "images", "music", "songs", "sounds",];

		for (s in folders)
		{
			var path = Sys.getCwd() + 'mods/' + modName + "/assets/" + s;
			FileSystem.createDirectory(path);

			switch (s)
			{
				case '_characters':
					File.saveContent(path + "/character_data_goes_here.txt",
						"Character JSONs generated from the Character Editor go here!\n\nPsych Engine character JSONs WILL not work.");
				case '_weeks':
					File.saveContent(path + "/week_data_goes_here.txt",
						"Week JSONs generated from the Week Editor go here!\n\nPsych Engine week JSONs WILL not work.");
				case 'data':
					File.saveContent(path + "/data_goes_here.txt", "Your charts for songs go here!");
				case 'images':
					File.saveContent(path + "/images_go_here.txt", "Your images go here!");
				case 'music':
					File.saveContent(path + "/music_goes_here.txt",
						"Music are NOT songs.\n\nYou can put dialogue music, menu music for custom menus and etc. here.");
				case 'songs':
					File.saveContent(path + "/songs_go_here.txt",
						"Music files for your songs go here.\n\nTypically the Inst.ogg and the Voices.ogg go in folders named the same as the song.\n\nFolder names put in here are formatted like \"song-name\", where its all lowercase letters and spaces are replaced with hyphens/dashes.");
				case 'sounds':
					File.saveContent(path + "/sounds_go_here.txt", "Sound effects.");
			}

			trace("created directory " + s);
		}

		input.callback("", "");
		warnings.text = "Mod folder made. Check your \"mods\" folder!";
		madeAMod = true;
	}

	var madeAMod:Bool = false;
	var exiting:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		inst.visible = !input.hasFocus && input.text.length <= 0;

		if (!InputTextFix.isTyping)
		{
			if (controls.UI_BACK && !exiting)
			{
				exiting = true;

				forEachOfType(FlxSprite, function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.5);
				}, true);

				new FlxTimer().start(0.5, function(_)
				{
					close();

					if (madeAMod)
						FlxG.resetState();
				});
			}
		}
	}
}
