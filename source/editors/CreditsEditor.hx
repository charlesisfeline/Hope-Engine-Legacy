package editors;

import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.io.File;
import haxe.Json;
import openfl.events.IOErrorEvent;
import flixel.util.FlxColor;
import Discord.DiscordClient;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUI;
import ui.InputTextFix;
import flixel.text.FlxText;
import CreditsState.CreditCategory;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxSprite;
import openfl.events.Event;

using StringTools;

class CreditsEditor extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	var catGroup:FlxTypedGroup<FlxText>;
	var credArray:Array<FlxTypedGroup<FlxText>> = [];
	var deleteButtons:FlxTypedGroup<FlxButton>;
	var icons:FlxTypedGroup<FlxSprite>;

	var UI_box:FlxUITabMenu;

	var _credits:Array<CreditCategory> = [
		{
			categoryName: "Example Category",
			categoryItems: [
				{
					name: "Credit Name",
					desc: "Credit Description"
				}
			]
		},
		{
			categoryName: "Example Category",
			categoryItems: [
				{
					name: "Credit Name",
					desc: "Credit Description"
				},
				{
					name: "Credit Name",
					desc: "Credit Description"
				}
			]
		},
		{
			categoryName: "Example Category",
			categoryItems: [
				{
					name: "Credit Name",
					desc: "Credit Description"
				},
				{
					name: "Credit Name",
					desc: "Credit Description"
				},
				{
					name: "Credit Name",
					desc: "Credit Description"
				}
			]
		},
		{
			categoryName: "Example Category",
			categoryItems: [
				{
					name: "Credit Name",
					desc: "Credit Description"
				}
			]
		},
		{
			categoryName: "Example Category",
			categoryItems: []
		},
		{
			categoryName: "Example Category",
			categoryItems: []
		}
	];

	var curSelected:Int = 0;
	var curCat:Int = 0;
	var allTheShit:Array<FlxText> = [];

	var camPos:FlxObject;
	var camFollow:FlxObject;

	public function new(?creds:Array<CreditCategory>)
	{
		super();

		if (creds != null)
			this._credits = creds;
	}

	override function create()
	{
		usesMouse = true;
		FlxG.mouse.visible = true;

		#if desktop
		DiscordClient.changePresence("Credits Editor", null);
		#end

		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0x2e2e2e;
		bg.scrollFactor.set();
		add(bg);

		var tabs = [{name: "1", label: 'Category'}, {name: "2", label: 'Credit'}];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(400, 300);
		UI_box.x = 32;
		UI_box.scrollFactor.set();
		UI_box.screenCenter(Y);
		add(UI_box);

		catGroup = new FlxTypedGroup<FlxText>();
		add(catGroup);

		deleteButtons = new FlxTypedGroup<FlxButton>();
		add(deleteButtons);

		icons = new FlxTypedGroup<FlxSprite>();
		add(icons);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.screenCenter();
		add(camPos);

		updateDisplay();

		var standardSave:FlxButton = new FlxButton(0, 0, "Save JSON", saveJSON);
		var standardLoad:FlxButton = new FlxButton(0, 0, "Load JSON", function()
		{
			openSubState(new ConfirmationPrompt("MANDATORY!", "Be sure to save your progress! Your progress will be lost if it is left unsaved!", "Ye",
				"Nah", loadJSON, null));
		});

		standardSave.x = UI_box.x;
		standardLoad.x = standardSave.x + standardSave.width + 10;
		standardLoad.y = standardSave.y = UI_box.y + UI_box.height + 10;

		add(standardSave);
		add(standardLoad);

		addCatUI();
		addCreditUI();

		super.create();

		FlxG.camera.follow(camPos, null, 1);
		changeSelection();
		changeCat();
	}

	function updateDisplay():Void
	{
		while (allTheShit.length > 0)
		{
			allTheShit.remove(allTheShit[0]);
		}

		deleteButtons.clear();
		icons.clear();
		catGroup.clear();

		while (credArray.length > 0)
		{
			var item = credArray[0];
			remove(item);
			credArray.remove(item);
			item.kill();
			item.destroy();
		}

		for (i in 0..._credits.length)
		{
			var cat = _credits[i];

			// So shit needs a fieldWidth more than 0 to render new lines properly...
			// What kind of bullshit is this?

			var catText = new FlxText(0, 0, FlxG.width, cat.categoryName);
			catText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			catText.borderSize = 3;
			catGroup.add(catText);

			allTheShit.push(catText);

			catText.x = UI_box.x + UI_box.width + 10;
			if (credArray[i - 1] != null)
			{
				var beforeThis = credArray[i - 1].members[credArray[i - 1].length - 1];
				var beforeCat = catGroup.members[i - 1];
				if (beforeThis != null)
					catText.y = beforeThis.y + beforeThis.height + 5;
				else if (beforeCat != null)
					catText.y = beforeCat.y + beforeCat.height + 5;
				else
					catText.y = UI_box.y;
			}
			else
				catText.y = UI_box.y;

			catGroup.members[i] = catText;

			credArray[i] = new FlxTypedGroup<FlxText>();
			add(credArray[i]);

			for (credit in cat.categoryItems)
			{
				var credIndex = cat.categoryItems.indexOf(credit);
				var text = '${credit.name}'
						 + '\n${credit.desc == null ? "No Desc" : credit.desc}'
						 + '\n${credit.link == null ? "No Link" : credit.link}' 
						 + '\n${credit.tint == null ? "No Tint" : credit.tint}'
						 + '\n${credit.icon == null ? "No Icon" : credit.icon}';

				var credText = new FlxText(0, 0, FlxG.width, text);
				credText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				credText.borderSize = 3;

				credText.x = UI_box.x + UI_box.width + 120;
				var ball = credArray[i].members[credArray[i].members.length - 1];
				credText.y = ball != null ? ball.y + ball.height + 5 : catText.y + catText.height + 5;
				credArray[i].add(credText);

				var butt = new FlxButton(0, 0, "Delete", function() {
					cat.categoryItems.remove(cat.categoryItems[credIndex]);
					updateDisplay();
				});
				butt.x = credText.x - butt.width - 10;
				butt.y = credText.y + credText.height - butt.height;
				butt.scrollFactor.set(1, 1);
				deleteButtons.add(butt);
				
				var icon = new FlxSprite().loadGraphic(Paths.image("creditIcons/" + credit.icon));
				icon.setGraphicSize(0, Std.int(credText.height - 30));
				icon.updateHitbox();
				icon.y = credText.y;
				icon.x = butt.x + (butt.width / 2) - (icon.width / 2);
				icon.antialiasing = credit.iconAntialiasing != null ? credit.iconAntialiasing : true;
				icons.add(icon);

				allTheShit.push(credText);
			}
		}

		changeSelection();
		changeCat();
	}

	function addCatUI():Void
	{
		var catNameTitle = new FlxText(10, 10, "Category Name");
		var catNameInput = new InputTextFix(10, catNameTitle.height + 10, Std.int(UI_box.width - 20));

		var addCat = new FlxButton(10, catNameInput.y + catNameInput.height + 10, "Add Category", function()
		{
			_credits.push({
				categoryName: catNameInput.text.trim(),
				categoryItems: []
			});

			updateDisplay();
		});

		var delCat = new FlxUIButton(addCat.width + 20, catNameInput.y + catNameInput.height + 10, "Delete Selected Category", function()
		{
			_credits.remove(_credits[curCat]);
			updateDisplay();
		});

		delCat.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		delCat.resize(160, delCat.height);

		var text = new FlxText(10, 0, Std.int(UI_box.width - 20), "");
		text.text = "Controls:"
				  + "\nUP or DOWN: Change the selected category to add credits to"
				  + "\nDEL: Delete selected category"
				  + "\n\nMouse Scroll: Scroll around the credits";

		text.y = UI_box.height - text.height - 30;

		var tab = new FlxUI(null, UI_box);
		tab.name = "1";
		tab.add(catNameTitle);
		tab.add(catNameInput);
		tab.add(addCat);
		tab.add(delCat);
		tab.add(text);
		UI_box.addGroup(tab);
	}

	var nameInput:InputTextFix;
	var descInput:InputTextFix;
	var iconInput:InputTextFix;
	var linkInput:InputTextFix;
	var tintInput:InputTextFix;
	var linkOpen:FlxButton;

	function addCreditUI():Void
	{
		var nameTitle = new FlxText(10, 10, "Credit Name");
		nameInput = new InputTextFix(10, nameTitle.y + nameTitle.height, Std.int(UI_box.width - 20));

		var descTitle = new FlxText(10, nameInput.y + nameInput.height + 10, "Credit Description (leave blank if nothing wants to be shown)");
		descInput = new InputTextFix(10, descTitle.y + descTitle.height, Std.int(UI_box.width - 20));

		var linkTitle = new FlxText(10, descInput.y + descInput.height + 10, "Credit Link (leave blank if no link will be opened when ENTER is pressed)");
		linkInput = new InputTextFix(10, linkTitle.y + linkTitle.height, Std.int(UI_box.width - 20));
		linkInput.callback = function(_, _) {
			if (linkInput.text.trim().length > 0)
				linkOpen.exists = true;
			else
				linkOpen.exists = false;
		}

		var iconTitle = new FlxText(10, linkInput.y + linkInput.height + 10, "Credit Icon (leave blank if no icon can be/will be displayed)");
		iconInput = new InputTextFix(10, iconTitle.y + iconTitle.height, Std.int(UI_box.width - 20));

		var tintTitle = new FlxText(10, iconInput.y + iconInput.height + 10, "Credit Tint (leave blank if the background should stay purple)");
		tintInput = new InputTextFix(10, tintTitle.y + tintTitle.height, Std.int(UI_box.width - 20));

		var antialiasingCheckbox = new FlxUICheckBox(0, 0, null, null, "Icon Smoothing");
		antialiasingCheckbox.x = UI_box.width - antialiasingCheckbox.width - 10;

		var addCredit = new FlxButton(10, 0, "Add Credit", function() {
			_credits[curCat].categoryItems.push({
				name: nameInput.text.trim(),
				desc: descInput.text.trim(),
				link: linkInput.text.trim().length > 0 ? linkInput.text.trim() : null,
				icon: iconInput.text.trim().length > 0 ? iconInput.text.trim() : null,
				tint: iconInput.text.trim().length > 0 ? tintInput.text.trim() : null,
				iconAntialiasing: antialiasingCheckbox.checked
			});
			updateDisplay();
		});

		addCredit.y = tintInput.y + tintInput.height + 10;

		linkOpen = new FlxButton(10, 0, "Open Link", function() {
			fancyOpenURL(linkInput.text.trim());
		});

		linkInput.callback("", "");
		linkOpen.y = addCredit.y;
		linkOpen.x = addCredit.x + addCredit.width + 10;
		antialiasingCheckbox.y = linkOpen.y;

		var tab = new FlxUI(null, UI_box);
		tab.name = "2";
		tab.add(nameTitle);
		tab.add(nameInput);
		tab.add(descTitle);
		tab.add(descInput);
		tab.add(linkTitle);
		tab.add(linkInput);
		tab.add(iconTitle);
		tab.add(iconInput);
		tab.add(tintTitle);
		tab.add(tintInput);
		tab.add(addCredit);
		tab.add(linkOpen);
		tab.add(antialiasingCheckbox);
		UI_box.addGroup(tab);
	}

	function changeSelection(?huh:Int = 0):Void
	{
		curSelected += huh;

		if (curSelected > allTheShit.length - 1)
			curSelected = allTheShit.length - 1;
		if (curSelected < 0)
			curSelected = 0;

		if (_credits.length > 0)
			camFollow.y = allTheShit[curSelected].y + (allTheShit[curSelected].height / 2);
		else
			camFollow.y = FlxG.width / 2;
	}

	function changeCat(?huh:Int = 0):Void
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		curCat += huh;

		if (curCat > _credits.length - 1)
			curCat = 0;
		if (curCat < 0)
			curCat = _credits.length - 1;

		if (_credits.length < 1)
		{
			curCat = 0;
			return;
		}

		for (cat in catGroup.members)
			cat.alpha = 0.6;

		catGroup.members[curCat].alpha = 1;

		for (group in credArray)
		{
			for (text in group)
				text.alpha = 0.6;
		}

		for (cred in credArray[curCat].members)
			cred.alpha = 1;
	}

	var backing:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerp:Float = Helper.boundTo(elapsed * 9.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);

		if (!InputTextFix.isTyping)
		{
			if (FlxG.mouse.wheel != 0)
				changeSelection(-FlxG.mouse.wheel);

			if (FlxG.mouse.justPressed)
			{
				for (group in credArray)
				{
					for (text in group)
					{
						var m = FlxG.mouse.getScreenPosition();
						var t = text.getScreenPosition();
						if ((m.x >= t.x && m.x <= t.x + text.width) && 
							(m.y >= t.y && m.y <= t.y + text.height)) 
						{
							var texts = text.text.split("\n");

							nameInput.text = texts[0].trim();
							descInput.text = texts[1].trim();
							linkInput.text = texts[2].trim();
							tintInput.text = texts[3].trim();
							iconInput.text = texts[4].trim();
						}
					}
				}
			}

			if (controls.UI_UP_P)
				changeCat(-1);
	
			if (controls.UI_DOWN_P)
				changeCat(1);
	
			if (FlxG.keys.justPressed.DELETE)
			{
				_credits.remove(_credits[curCat]);
				updateDisplay();
			}
	
			if (controls.UI_BACK && !backing)
			{
				backing = true;
				#if FILESYSTEM
				if (fromEditors)
				{
					CustomTransition.switchTo(new EditorsState());
					fromEditors = false;
				}
				else
				#end
				CustomTransition.switchTo(new CreditsState());
			}
		}
		else
		{
			
		}
	}

	var _file:FileReference;

	private function loadJSON()
	{
		var imageFilter:FileFilter = new FileFilter('JSON', 'json');

		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([imageFilter]);
	}

	var path:String = null;

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
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

		var creds:Array<CreditCategory> = cast Json.parse(File.getContent(path).trim());
		CustomTransition.switchTo(new CreditsEditor(creds));

		path = null;
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

	private function saveJSON()
	{
		var data:String = Json.stringify(_credits, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "credits.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}
}
