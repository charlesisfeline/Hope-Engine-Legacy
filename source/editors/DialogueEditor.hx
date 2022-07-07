package editors;

import DialogueSubstate.DialogueSettings;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.FileSystem;
import sys.io.File;
import ui.DropdownMenuFix;
import ui.InputTextFix;
import ui.NumStepperFix;

using StringTools;

class DialogueEditor extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	var UI_box:FlxUITabMenu;
	var deleteButtons:FlxTypedSpriteGroup<FlxButton>;
	var dialogs:FlxTypedSpriteGroup<FlxText>;

	var dialogue:String = ":bf:normal:right:normal:I am sane.";

	var _settings:DialogueSettings = {
		bg: {
			alpha: 0.5,
			duration: 0,
			color: "000000"
		},
		bgMusic: {
			name: "breakfast",
			fadeIn: {
				to: 0.8,
				from: 0,
				duration: 1
			}
		},
		type: "normal"
	}

	override function create()
	{
		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end
		
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0x2e2e2e;
		bg.scrollFactor.set();
		add(bg);

		FlxG.mouse.visible = true;
		usesMouse = true;

		var tabs = [
			{name: "1", label: 'Background & Style'},
			{name: "2", label: 'Music'},
			{name: "3", label: 'Dialogue'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(400, 300);
		UI_box.x = FlxG.width / 2 - 405;
		UI_box.screenCenter(Y);
		add(UI_box);

		deleteButtons = new FlxTypedSpriteGroup<FlxButton>();
		add(deleteButtons);

		dialogs = new FlxTypedSpriteGroup<FlxText>();
		add(dialogs);

		var test:FlxUIButton = new FlxUIButton("Test The Dialogue", function()
		{
			openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(dialogue), null, function()
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}, _settings));
		});
		test.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		test.resize(UI_box.width, test.height);
		test.x = UI_box.x;
		test.y = UI_box.y + UI_box.height + 10;
		add(test);

		var saveDialogButton = new FlxButton(test.x, test.y + test.height + 10, "Save Dialogue", saveDialogue);
		add(saveDialogButton);

		var loadDialogButton = new FlxButton(test.x, saveDialogButton.y + saveDialogButton.height + 10, "Load Dialogue", loadDialog);
		add(loadDialogButton);

		var saveSettingsButton = new FlxButton(saveDialogButton.x + saveDialogButton.width + 10, test.y + test.height + 10, "Save Settings", saveSettings);
		add(saveSettingsButton);

		var loadSettingsButton = new FlxButton(saveSettingsButton.x, saveDialogButton.y + saveDialogButton.height + 10, "Load Settings", loadSettings);
		add(loadSettingsButton);

		addBGStuff();
		addBGMStuff();
		addDialogueStuff();

		refreshDialogue();

		forEachOfType(FlxObject, function(obj:FlxObject)
		{
			obj.scrollFactor.set();
		}, true);

		super.create();
	}

	var colorInput:InputTextFix;
	var colorPreview:FlxSprite;
	var alphaInput:NumStepperFix;
	var durInput:NumStepperFix;
	var dtypeDrop:DropdownMenuFix;

	function addBGStuff():Void
	{
		var colorLabel = new FlxText(10, 10, "Color (in HEX color code)");
		colorInput = new InputTextFix(10, colorLabel.y + colorLabel.height, Std.int(UI_box.width - 70), _settings.bg.color);
		colorInput.callback = function(_, _)
		{
			_settings.bg.color = colorInput.text.trim();
			colorPreview.color = FlxColor.fromString("#" + _settings.bg.color);
		}

		var colorPreviewBorder = new FlxSprite(colorInput.x + colorInput.width + 9,
			colorInput.y - 1).makeGraphic(42, Std.int(colorInput.height + 2), FlxColor.BLACK);
		colorPreview = new FlxSprite(colorPreviewBorder.x + 1,
			colorPreviewBorder.y + 1).makeGraphic(Std.int(colorPreviewBorder.width - 2), Std.int(colorPreviewBorder.height - 2));

		colorInput.callback("", "");

		var inputWidth:Int = Std.int((UI_box.width / 3) - 15);

		var alphaLabel = new FlxText(10, colorInput.y + colorInput.height + 10, "Fade In to alpha");
		alphaInput = new NumStepperFix(10, alphaLabel.y + alphaLabel.height, 0.1, _settings.bg.alpha, 0, 1, 2, new InputTextFix(0, 0, inputWidth - 31));
		alphaInput.callback = function(_)
		{
			_settings.bg.alpha = alphaInput.value;
		}

		var durLabel = new FlxText(alphaInput.width + 20, colorInput.y + colorInput.height + 10, "Fade In Duration");
		durInput = new NumStepperFix(durLabel.x, durLabel.y + durLabel.height, 0.1, _settings.bg.duration, 0, Math.POSITIVE_INFINITY, 2,
			new InputTextFix(0, 0, inputWidth - 31));
		durInput.callback = function(_)
		{
			_settings.bg.duration = durInput.value;
		}

		var dtypeLabel = new FlxText(durInput.x + durInput.width + 10, colorInput.y + colorInput.height + 10, "Dialogue Style");
		dtypeDrop = new DropdownMenuFix(dtypeLabel.x, dtypeLabel.y + dtypeLabel.height,
			DropdownMenuFix.makeStrIdLabelArray(["normal", "pixel", "pixel-spirit"]), new FlxUIDropDownHeader(inputWidth));
		dtypeDrop.callback = function(_)
		{
			_settings.type = dtypeDrop.selectedLabel.trim();

			typeLabel.exists = true;
			typeDrop.exists = true;

			if (_settings.type != 'normal')
			{
				typeLabel.exists = false;
				typeDrop.exists = false;
			}
		}

		var tab = new FlxUI(null, UI_box);
		tab.name = '1';
		tab.add(colorLabel);
		tab.add(colorInput);
		tab.add(colorPreviewBorder);
		tab.add(colorPreview);
		tab.add(alphaLabel);
		tab.add(alphaInput);
		tab.add(durLabel);
		tab.add(durInput);
		tab.add(dtypeLabel);
		tab.add(dtypeDrop);
		UI_box.addGroup(tab);
	}

	var songInput:InputTextFix;
	var fromInput:NumStepperFix;
	var toInput:NumStepperFix;
	var durMInput:NumStepperFix;

	function addBGMStuff():Void
	{
		var songLabel = new FlxText(10, 10, "Music to play (file should be found at the music folder)");
		songInput = new InputTextFix(10, songLabel.y + songLabel.height, Std.int(UI_box.width - 20), _settings.bgMusic.name);
		songInput.callback = function(_, _)
		{
			_settings.bgMusic.name = songInput.text.trim();
		}

		var inputWidth:Int = Std.int((UI_box.width / 3) - 46);

		var durLabel = new FlxText(10, songInput.y + songInput.height + 10, "Fade In Duration");
		durMInput = new NumStepperFix(durLabel.x, durLabel.y + durLabel.height, 0.1, _settings.bgMusic.fadeIn.duration, 0, Math.POSITIVE_INFINITY, 2,
			new InputTextFix(0, 0, inputWidth));
		durMInput.callback = function(_)
		{
			_settings.bgMusic.fadeIn.duration = durMInput.value;
		}

		var fromLabel = new FlxText(durMInput.width + 20, songInput.y + songInput.height + 10, "Fade In song from");
		fromInput = new NumStepperFix(fromLabel.x, fromLabel.y + fromLabel.height, 0.1, _settings.bgMusic.fadeIn.from, 0, _settings.bgMusic.fadeIn.to, 2,
			new InputTextFix(0, 0, inputWidth));
		fromInput.callback = function(_)
		{
			_settings.bgMusic.fadeIn.from = fromInput.value;
		}

		var toLabel = new FlxText(fromInput.x + fromInput.width + 10, songInput.y + songInput.height + 10, "Fade In song to");
		toInput = new NumStepperFix(toLabel.x, toLabel.y + toLabel.height, 0.1, _settings.bgMusic.fadeIn.to, 0, 1, 2, new InputTextFix(0, 0, inputWidth));
		toInput.callback = function(_)
		{
			_settings.bgMusic.fadeIn.to = toInput.value;

			fromInput.max = _settings.bgMusic.fadeIn.to;
			if (fromInput.value > _settings.bgMusic.fadeIn.to)
				fromInput.value = _settings.bgMusic.fadeIn.to;
			fromInput.callback(0);
		}

		var tab = new FlxUI(null, UI_box);
		tab.name = '2';
		tab.add(songLabel);
		tab.add(songInput);
		tab.add(durLabel);
		tab.add(durMInput);
		tab.add(fromLabel);
		tab.add(fromInput);
		tab.add(toLabel);
		tab.add(toInput);
		UI_box.addGroup(tab);
	}

	var characterInput:InputTextFix;
	var emotionDrop:DropdownMenuFix;
	var positionDrop:DropdownMenuFix;
	var typeLabel:FlxText;
	var typeDrop:DropdownMenuFix;
	var dialogInput:InputTextFix;

	function addDialogueStuff():Void
	{
		var characterLabel = new FlxText(10, 10, "Who will say");
		characterInput = new InputTextFix(10, characterLabel.y + characterLabel.height, Std.int(UI_box.width - 20), "");
		characterInput.callback = function(_, _)
		{
			var newEmotions = [];
			var path = "assets/shared/images/portraits/";
			var modPath = 'mods/${Paths.currentMod}/assets/images/portraits/';

			var possiblePortraits = [];
			var char = characterInput.text + "-";

			if (Paths.currentMod != null)
			{
				if (Paths.exists(modPath))
				{
					for (portrait in FileSystem.readDirectory(Sys.getCwd() + modPath))
					{
						if (portrait.startsWith(char) && portrait.substr(char.length).split("-").length == 1)
							possiblePortraits.push(portrait.trim().replace(".png", ""));
					}
				}
			}

			for (portrait in FileSystem.readDirectory(Sys.getCwd() + path))
			{
				if (portrait.startsWith(char) && portrait.substr(char.length).split("-").length == 1)
					possiblePortraits.push(portrait.trim().replace(".png", ""));
			}

			for (portrait in possiblePortraits)
			{
				var split = portrait.split("-");
				newEmotions.push(split[split.length - 1].trim());
			}

			if (newEmotions.length < 1)
				newEmotions = [""];

			emotionDrop.setData(DropdownMenuFix.makeStrIdLabelArray(newEmotions));
		}

		var dialogLabel = new FlxText(10, characterInput.y + characterInput.height + 10, "What to say");
		dialogInput = new InputTextFix(10, dialogLabel.y + dialogLabel.height, Std.int(UI_box.width - 20), "");

		var positions = [
			"left",
			// "center",
			"right"
		];

		var textBoxTypes = ["normal", "loud"];

		var inputWidth:Int = Std.int((UI_box.width / 3) - 15);

		var emotionLabel = new FlxText(10, dialogInput.y + dialogInput.height + 10, "What to feel");
		emotionDrop = new DropdownMenuFix(10, emotionLabel.y + emotionLabel.height, DropdownMenuFix.makeStrIdLabelArray([""]),
			new FlxUIDropDownHeader(inputWidth));

		var positionLabel = new FlxText(emotionDrop.width + 20, dialogInput.y + dialogInput.height + 10, "Where to be");
		positionDrop = new DropdownMenuFix(positionLabel.x, emotionLabel.y + emotionLabel.height, DropdownMenuFix.makeStrIdLabelArray(positions),
			new FlxUIDropDownHeader(inputWidth));

		typeLabel = new FlxText(positionDrop.x + positionDrop.width + 10, dialogInput.y + dialogInput.height + 10, "How to say");
		typeDrop = new DropdownMenuFix(typeLabel.x, emotionLabel.y + emotionLabel.height, DropdownMenuFix.makeStrIdLabelArray(textBoxTypes),
			new FlxUIDropDownHeader(inputWidth));

		characterInput.callback("", "");

		var add = new FlxButton(0, 0, "Add", function()
		{
			// trim()
			// sorry i've just been traumatized

			var character = characterInput.text.trim();
			var emotion = emotionDrop.selectedLabel.trim();
			var position = positionDrop.selectedLabel.trim();
			var type = typeDrop.selectedLabel.trim();
			var text = dialogInput.text.trim();

			dialogue += '\n:$character:$emotion:$position:$type:$text';

			refreshDialogue();
		});

		add.y = positionDrop.y + positionDrop.height + 10;
		add.x = (UI_box.width / 2) - (add.width / 2);

		var note = new FlxText(10);
		note.text = "I *strongly* recommend you edit the text file you get instead."
			+ "\nA line goes as follows:"
			+ "\n:[character]:[emotion]:[position]:[dialogue box type]:[dialog text]";

		note.y = UI_box.height - note.height - 30;

		var tab = new FlxUI(null, UI_box);
		tab.name = '3';
		tab.add(note);
		tab.add(characterLabel);
		tab.add(characterInput);
		tab.add(emotionLabel);
		tab.add(emotionDrop);
		tab.add(positionLabel);
		tab.add(positionDrop);
		tab.add(typeLabel);
		tab.add(typeDrop);
		tab.add(dialogLabel);
		tab.add(dialogInput);
		tab.add(add);
		UI_box.addGroup(tab);
	}

	function refreshDialogue():Void
	{
		dialogs.clear();
		deleteButtons.clear();

		if (dialogue.trim().length < 1)
			return;

		var i = 0;
		for (dialog in dialogue.trim().split('\n'))
		{
			var text = new FlxText(UI_box.x + UI_box.width + 10, 0, 400, dialog.trim());
			text.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			text.borderSize = 3;

			if (dialogs.length > 0)
				text.y = dialogs.height + 10;

			var s = i;
			var del = new FlxButton(text.x + text.width + 10, text.y + (text.height * 0.5) - 10, "Delete", function()
			{
				dialogue = dialogue.trim();

				var split = dialogue.split("\n");
				split.remove(split[s]);

				dialogue = split.join('\n');

				refreshDialogue();
			});

			dialogs.add(text);
			deleteButtons.add(del);

			i++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// deceleration? what's that LMAO
		if (FlxG.mouse.wheel != 0 && dialogs.height > UI_box.height)
			dialogs.velocity.y = 720 * FlxG.mouse.wheel;
		else
		{
			if (dialogs.velocity.y != 0)
			{
				if (dialogs.velocity.y > 0)
					dialogs.velocity.y -= 20;
				else
					dialogs.velocity.y += 20;
			}
			else
				dialogs.velocity.y = 0;
		}

		if (dialogs.height > UI_box.height)
		{
			if (dialogs.y >= UI_box.y)
				dialogs.y = UI_box.y;
			if (dialogs.y + dialogs.height <= UI_box.y + UI_box.height)
				dialogs.y = UI_box.y + UI_box.height - dialogs.height;
		}
		else
			dialogs.y = UI_box.y;

		deleteButtons.y = dialogs.y;

		if (controls.BACK && !FlxG.keys.justPressed.BACKSPACE)
		{
			#if FILESYSTEM
			if (fromEditors)
			{
				CustomTransition.switchTo(new EditorsState());
				fromEditors = false;
			}
			else
			#end
			CustomTransition.switchTo(new MainMenuState());
		}

		dialogs.forEachAlive(function(text:FlxText)
		{
			if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(text))
				{
					var split = text.text.split(':');

					characterInput.text = split[1].trim();
					characterInput.callback("", "");

					emotionDrop.selectedLabel = split[2].trim().toUpperCase();
					positionDrop.selectedLabel = split[3].trim();
					typeDrop.selectedLabel = split[4].trim();

					var len = split[1].length + split[2].length + split[3].length + split[4].length + 5;
					dialogInput.text = text.text.trim().substr(len).replace("\\n", "\n");
				}
			}
		});
	}

	var _file:FileReference;

	private function saveSettings()
	{
		var data:String = Json.stringify(_settings, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "dialogueSettings.json");
		}
	}

	private function saveDialogue()
	{
		var data:String = dialogue;

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "dialogueStart.txt");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	////////////////////////

	private function loadSettings()
	{
		var imageFilter:FileFilter = new FileFilter('JSON', 'json');

		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([imageFilter]);
	}

	private function loadDialog()
	{
		var imageFilter:FileFilter = new FileFilter('TXT', 'txt');

		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onDialogLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([imageFilter]);
	}

	var path:String;

	function onLoadComplete(_)
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		@:privateAccess
		{
			if (_file.__path != null)
				path = _file.__path;
		}

		_settings = cast Json.parse(File.getContent(path).trim());
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

		colorInput.text = _settings.bg.color;
		colorInput.callback("", "");

		alphaInput.value = _settings.bg.alpha;
		alphaInput.callback(_settings.bg.alpha);

		durInput.value = _settings.bg.duration;
		durInput.callback(_settings.bg.duration);

		dtypeDrop.selectedLabel = _settings.type;
		dtypeDrop.callback(_settings.type);

		songInput.text = _settings.bgMusic.name.trim();
		songInput.callback("", "");

		durMInput.value = _settings.bgMusic.fadeIn.duration;
		durMInput.callback(_settings.bgMusic.fadeIn.duration);

		fromInput.value = _settings.bgMusic.fadeIn.from;
		fromInput.callback(_settings.bgMusic.fadeIn.from);

		toInput.value = _settings.bgMusic.fadeIn.to;
		toInput.callback(_settings.bgMusic.fadeIn.to);

		_file = null;
	}

	function onDialogLoadComplete(_)
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		@:privateAccess
		{
			if (_file.__path != null)
				path = _file.__path;
		}

		dialogue = File.getContent(path).trim();
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

		refreshDialogue();

		_file = null;
	}

	function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
	}

	function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
	}
}
