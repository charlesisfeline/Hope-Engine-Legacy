package editors;

import Discord.DiscordClient;
import Event;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end


class EventEditor extends MusicBeatState
{
	var UI_box:FlxUITabMenu;
	var fakeoutBox:FlxUITabMenu;

	var _event:SwagEvent = {
		eventID: "simple_event",
		params: [
			{
				paramID: "nothing",
				paramName: "Nothing",
				type: "bool",
				value: null,
				defaultValue: false,
				increment: null,
				maxLetters: null
			},
			{
				paramID: "nothing_too",
				paramName: "Nothing... again",
				type: "string",
				value: null,
				defaultValue: "",
				increment: null,
				maxLetters: null
			},
		]
	}

	var _info:EventInfo = {
		eventName: "Simple Event",
		eventDesc: "I am a simple event!"
	}

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Events Editor");
		#end

		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0x2e2e2e;
		bg.scrollFactor.set();
		add(bg);
		
		FlxG.mouse.visible = true;
		usesMouse = true;
		
		var tabs = [
			{name: "1", label: 'Event Info'},
			{name: "2", label: 'Parameters'},
		];
		
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(300, 300);
		UI_box.x = (FlxG.width / 2) + 20;
		UI_box.screenCenter(Y);
		add(UI_box);

		fakeoutBox = new FlxUITabMenu(null, [{name: "1", label: 'Event Preview in Charter'},], true);
		fakeoutBox.scrollFactor.set();
		fakeoutBox.resize(50 * 8, 400);
		fakeoutBox.x = (FlxG.width / 2) - fakeoutBox.width - 20;
		fakeoutBox.screenCenter(Y);
		add(fakeoutBox);

		super.create();

		addInfoUI();
		addParamUI();
		addEventUI();
		updateEventParams();
		updateEventsUI();
	}

	var nameInput:FlxUIInputText;
	var descInput:FlxUIInputText;

	function addInfoUI():Void
	{
		var nameLabel = new FlxText(10, 10, "Event Name");
		nameInput = new FlxUIInputText(10, nameLabel.height + 10, Std.int(UI_box.width - 20), _info.eventName);
		nameInput.callback = function(s1:String, s2:String) {
			_info.eventName = nameInput.text;
			updateEventsUI();
		}

		var descLabel = new FlxText(10, nameInput.y + nameInput.height + 20, "Event Description");
		descInput = new FlxUIInputText(10, descLabel.y + descLabel.height, Std.int(UI_box.width - 20), _info.eventDesc);
		descInput.lines = 3;
		descInput.callback = function(s1:String, s2:String) {
			_info.eventDesc = descInput.text;
			updateEventsUI();
		}

		var saveJSON = new FlxButton(0, 0, "Save Info", saveJSON);
		saveJSON.x = UI_box.width - saveJSON.width - 10;
		saveJSON.y = UI_box.height - (saveJSON.height * 1.5) - 20;

		var loadJSON = new FlxButton(0, 0, "Load Info", function() {
			FlxG.state.openSubState(new ConfirmationPrompt(
				"You sure?", 
				"Be sure to save first!\nYour changes will NOT be saved if you load in a new Info JSON!", 
				"ok", 
				"nah", 
				loadJSON, 
				null));
		});
		loadJSON.x = UI_box.width - loadJSON.width - saveJSON.width - 20;
		loadJSON.y = UI_box.height - (loadJSON.height * 1.5) - 20;

		var tab = new FlxUI(null, UI_box);
		tab.name = '1';
		tab.add(nameLabel);
		tab.add(nameInput);
		tab.add(descLabel);
		tab.add(descInput);
		tab.add(saveJSON);
		tab.add(loadJSON);
		UI_box.addGroup(tab);
	}

	var paramNameInput:FlxUIInputText;
	var paramIDInput:FlxUIInputText;
	var paramTypeDropdown:FlxUIDropDownMenu;
	var paramTypes:Array<String> = [
		"bool",
		"string",
		"number"
	];

	var paramsFieldsInUI:Array<Dynamic> = [];
	
	var defaultValueInput:FlxUIInputText;
	
	var incrementLabel:FlxText;
	var incrementInput:FlxUIInputText;
	var maxLettersLabel:FlxText;
	var maxLettersInput:FlxUIInputText;

	var tab_param:FlxUI;

	function addParamUI():Void
	{
		var eventExists:Bool = false;
		
		var paramNameLabel = new FlxText(10, 10, "Parameter Name");
		paramNameInput = new FlxUIInputText(10, paramNameLabel.y + paramNameLabel.height, Std.int((UI_box.width / 2) - 15));

		var paramIDLabel = new FlxText(paramNameInput.x + paramNameInput.width + 10, 10, "Parameter ID");
		paramIDInput = new FlxUIInputText(paramIDLabel.x, paramIDLabel.y + paramIDLabel.height, Std.int((UI_box.width / 2) - 15));
		paramIDInput.callback = function(s1:String, s2:String)
		{
			for (event in _event.params)
			{
				if (paramIDInput.text == event.paramID)
				{
					paramNameInput.text = event.paramName;
					paramTypeDropdown.selectedLabel = event.type;
					paramTypeDropdown.callback("");
					eventExists = true;
				}
				else
					eventExists = false;
			}
		}

		var paramTypeLabel = new FlxText(10, paramIDInput.y + paramIDInput.height + 10, "Parameter Type");
		paramTypeDropdown = new FlxUIDropDownMenu(10, paramTypeLabel.y + paramTypeLabel.height, FlxUIDropDownMenu.makeStrIdLabelArray(paramTypes, true), new FlxUIDropDownHeader(Std.int((UI_box.width / 2) - 15)));
		paramTypeDropdown.callback = function(s:String)
		{
			for (event in _event.params)
			{
				if (paramIDInput.text == event.paramID)
					event.type = paramTypeDropdown.selectedLabel;
			}

			switch (paramTypeDropdown.selectedLabel)
			{
				case 'bool':
					incrementLabel.active = incrementLabel.visible = false;
					maxLettersLabel.active = maxLettersLabel.visible = false;
					incrementInput.active = incrementInput.visible = false;
					maxLettersInput.active = maxLettersInput.visible = false;
				case 'string':
					incrementLabel.active = incrementLabel.visible = false;
					maxLettersLabel.active = maxLettersLabel.visible = true;
					incrementInput.active = incrementInput.visible = false;
					maxLettersInput.active = maxLettersInput.visible = true;
				case 'number':
					incrementLabel.active = incrementLabel.visible = true;
					maxLettersLabel.active = maxLettersLabel.visible = false;
					incrementInput.active = incrementInput.visible = true;
					maxLettersInput.active = maxLettersInput.visible = false;
			}
		}

		var defaultValueLabel:FlxText = new FlxText(10, paramTypeDropdown.y + paramTypeDropdown.header.height + 10, "Default Value");
		defaultValueInput = new FlxUIInputText(10, defaultValueLabel.y + defaultValueLabel.height, Std.int((UI_box.width / 2) - 15));

		incrementLabel = new FlxText(10, defaultValueInput.y + defaultValueInput.height + 10, "Number Increment");
		incrementInput = new FlxUIInputText(10, incrementLabel.y + incrementLabel.height, Std.int((UI_box.width / 2) - 15));

		maxLettersLabel = new FlxText(10, defaultValueInput.y + defaultValueInput.height + 10, "Max Letters");
		maxLettersInput = new FlxUIInputText(10, maxLettersLabel.y + maxLettersLabel.height, Std.int((UI_box.width / 2) - 15));

		var paramInfo = new FlxText();
		paramInfo.text = "Parameter Types:"
					   + "\nbool: Turns into checkmark"
					   + "\n\nstring: Turns into a textfield"
					   + "\n\nnumber: Turns into a number stepper thing";
		paramInfo.fieldWidth = Std.int((UI_box.width / 2) - 15);
		paramInfo.x = paramIDInput.x;
		paramInfo.y = paramTypeLabel.y;

		var updateButton:FlxButton = new FlxButton(0, 0, "Add/Update", function() {
			var lmao:Int = _event.params.length;
			
			for (i in 0..._event.params.length)
			{
				var event = _event.params[i];
				if (paramIDInput.text == event.paramID)
					lmao = i;
			}
				
			var defaultV:Dynamic = null;
			var increment:Null<Float> = null;
			var maxLetters:Null<Int> = null;

			switch (paramTypeDropdown.selectedLabel)
			{
				case 'bool':
					defaultV = Helper.toBool(defaultValueInput.text);
				case 'string':
					defaultV = defaultValueInput.text;
					maxLetters = Std.parseInt(maxLettersInput.text);
				case 'number':
					defaultV = Std.parseFloat(defaultValueInput.text);
					increment = Std.parseFloat(incrementInput.text);
			}
			_event.params[lmao] = {
				paramID: paramIDInput.text,
				paramName: paramNameInput.text,
				type: paramTypeDropdown.selectedLabel,
				value: null,
				defaultValue: defaultV,
				increment: increment,
				maxLetters: maxLetters
			};

			updateEventParams();

			paramTypeDropdown.callback("");
		});
		updateButton.x = (UI_box.width / 2) - updateButton.width - 5;
		updateButton.y = UI_box.height - (updateButton.height * 1.5) - 20;

		var removeButton:FlxButton = new FlxButton(0, 0, "Remove", function() {
			var lmao:EventParam = null;
			
			for (event in _event.params)
			{
				if (paramIDInput.text == event.paramID)
					lmao = event;
			}

			if (lmao != null) 
			{
				_event.params.remove(lmao);

				updateEventParams();
				paramTypeDropdown.callback("");
			}
		});
		removeButton.x = (UI_box.width / 2) + 5;
		removeButton.y = UI_box.height - (removeButton.height * 1.5) - 20;

		tab_param = new FlxUI(null, UI_box);
		tab_param.name = '2';
		tab_param.add(paramNameLabel);
		tab_param.add(paramNameInput);
		tab_param.add(paramIDLabel);
		tab_param.add(paramIDInput);
		tab_param.add(paramTypeLabel);
		tab_param.add(paramInfo);
		tab_param.add(defaultValueLabel);
		tab_param.add(defaultValueInput);
		tab_param.add(incrementLabel);
		tab_param.add(incrementInput);
		tab_param.add(maxLettersLabel);
		tab_param.add(maxLettersInput);
		tab_param.add(maxLettersInput);
		tab_param.add(updateButton);
		tab_param.add(removeButton);
		tab_param.add(paramTypeDropdown);
		UI_box.addGroup(tab_param);

		paramTypeDropdown.selectedLabel = 'bool';
		paramTypeDropdown.callback("bool");
		incrementLabel.active = incrementLabel.visible = false;
		maxLettersLabel.active = maxLettersLabel.visible = false;
	}

	var eventDropdown:FlxUIDropDownMenu;
	var description:FlxText;
	var tab_group_events:FlxUI;
	var curEventParams:Array<FlxSprite> = [];

	function addEventUI():Void
	{
		var eventsLabel = new FlxText(10, 10, "Events List");
		eventDropdown = new FlxUIDropDownMenu(10, eventsLabel.y + eventsLabel.height, FlxUIDropDownMenu.makeStrIdLabelArray([_info.eventName], true));

		description = new FlxText(10, eventDropdown.y + eventDropdown.header.height + 10, Std.int(fakeoutBox.width - 20), _info.eventDesc);

		tab_group_events = new FlxUI(null, fakeoutBox);
		tab_group_events.name = '1';
		tab_group_events.add(eventsLabel);
		tab_group_events.add(description);
		tab_group_events.add(eventDropdown);
		fakeoutBox.addGroup(tab_group_events);
	}

	function updateEventsUI():Void
	{
		eventDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray([_info.eventName]));
		eventDropdown.selectedLabel = _info.eventName;

		description.text = _info.eventDesc;
		description.y = curEventParams[curEventParams.length - 1].y + curEventParams[curEventParams.length - 1].height + 20;
	}

	function updateEventParams():Void
	{
		removeEventParams();
		createEventParams();
		description.y = curEventParams[curEventParams.length - 1].y + curEventParams[curEventParams.length - 1].height + 20;
	}

	function removeEventParams():Void
	{
		while (curEventParams.length > 0)
		{
			tab_group_events.remove(curEventParams[0], true);
			tooltips.remove(curEventParams[0]);
			curEventParams[0].destroy();
			curEventParams.remove(curEventParams[0]);
		}
	}

	function createEventParams():Void
	{
		var previousItem:FlxSprite = new FlxSprite(10, eventDropdown.y + eventDropdown.header.height + 10).makeGraphic(1, 1, FlxColor.TRANSPARENT);
		curEventParams[0] = previousItem;
		var itemToAdd:FlxSprite = null;

		for (param in _event.params)
		{
			switch (param.type)
			{
				case 'bool':
					itemToAdd = new FlxUICheckBox(10, previousItem.y - tab_group_events.y + previousItem.height + 10, null, null, param.paramName);

					var ass:FlxUICheckBox = cast itemToAdd;
					ass.checked = param.value != null ? param.value : param.defaultValue;
				case 'string':
					var label = new FlxText(10, previousItem.y - tab_group_events.y + previousItem.height + 10, param.paramName);
					previousItem = label;
					itemToAdd = new FlxUIInputText(10, previousItem.y + previousItem.height);

					tab_group_events.add(label);
					curEventParams.push(label);
					
					var ass:FlxUIInputText = cast itemToAdd;
					ass.maxLength = param.maxLetters;
					ass.text = param.value != null ? param.value : param.defaultValue;
				case 'number':
					var label = new FlxText(10, previousItem.y - tab_group_events.y + previousItem.height + 10, param.paramName);
					previousItem = label;
					itemToAdd = new FlxUINumericStepper(10, previousItem.y + previousItem.height, .1);

					tab_group_events.add(label);
					curEventParams.push(label);
					
					var ass:FlxUINumericStepper = cast itemToAdd;
					ass.decimals = 2;
					ass.stepSize = param.increment != null ? param.increment : .1;
					ass.value = param.value != null ? param.value : param.defaultValue;
			}

			tooltips.add(itemToAdd, {
				title: "Parameter ID",
				body: param.paramID,
				style: {
					titleWidth: 120,
					bodyWidth: 120,
					topPadding: 5,
					bottomPadding: 5,
					leftPadding: 5,
					rightPadding: 5,
					bodyOffset: new FlxPoint(0, 5)
				},
				moving: true
			});

			tab_group_events.add(itemToAdd);
			previousItem = itemToAdd;
			curEventParams.push(itemToAdd);
		}
	}

	function updateInfoTab():Void
	{
		nameInput.text = _info.eventName;
		nameInput.callback("", "");

		descInput.text = _info.eventDesc;
		descInput.callback("", "");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.R)
		{
			trace(Json.stringify(_info, null, "\t"));
			trace(Json.stringify(_event, null, "\t"));
		}
	}

	var _file:FileReference;

	private function saveJSON()
	{
		var data:String = Json.stringify(_info, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "info.json");
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

	private function loadJSON()
	{
		var imageFilter:FileFilter = new FileFilter('JSON', 'json');

		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
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

		_info = cast Json.parse(File.getContent(path).trim());
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

		updateEventsUI();
		updateInfoTab();

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
