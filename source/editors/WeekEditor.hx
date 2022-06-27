package editors;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import ui.*;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
#if desktop
import Discord.DiscordClient;
#end

typedef Week =
{
	var weekName:String;
	var characters:Array<String>;
	var tracks:Array<String>;
	var difficultyLock:Null<String>;
}

#if FILESYSTEM
class WeekEditor extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	var yellowBG:FlxSprite;
	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;

	var UI_box:FlxUITabMenu;

	var _week:Week = {
		weekName: 'Tutorial',
		characters: ['', 'gf', 'bf'],
		tracks: ['Tutorial'],
		difficultyLock: null
	}

	var weekJSONName:String = "tutorial";

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var curDifficulty:Int = 1;

	var saveButton:FlxButton;
	var loadButton:FlxButton;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Week Editor");
		#end

		FlxG.mouse.visible = true;
		usesMouse = true;

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		var scoreText = new FlxText(10, 10, 0, "SCORE: " + FlxG.random.int(0, 999999, [69420, 69, 420, 1337, 42069]), 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		add(scoreText);

		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		add(yellowBG);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		add(grpWeekCharacters);

		grpWeekCharacters.add(new MenuCharacter(0, 0, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(0, 0, 0.5, true));
		grpWeekCharacters.add(new MenuCharacter(0, 0, 0.5, true));

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = "VCR OSD Mono";
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, _week.weekName.toUpperCase(), 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
		add(txtWeekTitle);

		// hi psych engine
		var tracksText:Alphabet = new Alphabet(0, 0, "TRACKS", false);
		tracksText.color = 0xFFe55777;
		tracksText.x = FlxG.width * 0.055;
		tracksText.y = txtTracklist.y;
		add(tracksText);

		////////////////////////

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekJSONName);
		weekThing.y += ((weekThing.height + 20) * 0);
		weekThing.targetY = 0;
		grpWeekText.add(weekThing);

		weekThing.screenCenter(X);
		weekThing.antialiasing = true;

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.antialiasing = true;
		leftArrow.animation.addByPrefix('idle', "arrow menu left0000");
		leftArrow.animation.addByPrefix('press', "arrow menu left0001");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + leftArrow.width, leftArrow.y);
		sprDifficulty.antialiasing = true;

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(0, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.antialiasing = true;
		rightArrow.animation.addByPrefix('idle', 'arrow menu right0000');
		rightArrow.animation.addByPrefix('press', "arrow menu right0001");
		rightArrow.animation.play('idle');
		rightArrow.x = FlxG.width - rightArrow.width - 10;
		difficultySelectors.add(rightArrow);

		///////////////////////////////////

		var tabs = [
			{name: "1", label: 'Week Data'},
			{name: "2", label: 'Songs'},
			{name: "3", label: 'Characters'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(350, 200);
		UI_box.x = 16;
		UI_box.y = 16;
		add(UI_box);

		saveButton = new FlxButton(0, 0, "SAVE FILE", saveJSON);
		saveButton.x = UI_box.x + UI_box.width + 16;
		saveButton.y = UI_box.y;
		add(saveButton);

		loadButton = new FlxButton(0, 0, "LOAD FILE", loadJSON);
		loadButton.x = UI_box.x + UI_box.width + 16;
		loadButton.y = saveButton.y + saveButton.height + 16;
		add(loadButton);

		changeDifficulty();
		createWeekDataUI();
		createSongsUI();
		createCharUI();

		updateChars();

		super.create();

		createToolTips();
	}

	var weekNameInput:InputTextFix;
	var weekJSONNameInput:InputTextFix;
	var diffLockDropdown:DropdownMenuFix;

	function createWeekDataUI():Void
	{
		var weekNameTitle:FlxText = new FlxText(10, 10, "Week Name");

		weekNameInput = new InputTextFix(10, weekNameTitle.y + weekNameTitle.height, 330, _week.weekName);
		weekNameInput.callback = function(s:String, y:String)
		{
			_week.weekName = weekNameInput.text;
			txtWeekTitle.text = _week.weekName.toUpperCase();
			txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		}
		weekNameInput.callback("", "");

		var diffLockTitle = new FlxText(10, weekNameInput.y + weekNameInput.height + 10, "Difficulty Lock");

		var diffList:Array<String> = [""];

		for (i in CoolUtil.difficultyArray)
			diffList.push(i[0]);

		diffLockDropdown = new DropdownMenuFix(10, diffLockTitle.y + diffLockTitle.height, DropdownMenuFix.makeStrIdLabelArray(diffList));
		diffLockDropdown.callback = diffShit;

		var weekJSONTitle:FlxText = new FlxText(diffLockDropdown.x + diffLockDropdown.width + 10, diffLockTitle.y, "Week File Name and Week Image Name");

		weekJSONNameInput = new InputTextFix(weekJSONTitle.x, diffLockDropdown.y, Std.int(Math.abs(weekJSONTitle.x - UI_box.width) - 10), weekJSONName);
		weekJSONNameInput.callback = function(s:String, y:String)
		{
			weekJSONName = weekJSONNameInput.text;

			if (Paths.exists(Paths.image('storymenu/' + weekJSONName)))
			{
				var uhh = grpWeekText.members[0];

				grpWeekText.members[0] = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekJSONName);
				grpWeekText.members[0].screenCenter(X);
				grpWeekText.members[0].antialiasing = true;
				grpWeekText.members[0].color = FlxColor.WHITE;

				uhh.kill();
				uhh.destroy();
			}
		}
		weekJSONNameInput.callback("", "");

		var tab = new FlxUI(null, UI_box);
		tab.name = "1";
		tab.add(weekNameTitle);
		tab.add(weekNameInput);
		tab.add(diffLockTitle);
		tab.add(diffLockDropdown);
		tab.add(weekJSONTitle);
		tab.add(weekJSONNameInput);
		UI_box.addGroup(tab);
	}

	function diffShit(a:String)
	{
		if (diffLockDropdown.selectedLabel == "")
		{
			_week.difficultyLock = null;
			curDifficulty = 1;
		}
		else
		{
			_week.difficultyLock = diffLockDropdown.selectedLabel;
			curDifficulty = CoolUtil.difficultyIntFromString(_week.difficultyLock);
		}

		changeDifficulty();
	}

	var songList:FlxUIList;
	var songNameInput:InputTextFix;

	function createSongsUI():Void
	{
		var songListTitle = new FlxText(10, 10, UI_box.width / 4, "Songs");

		songList = new FlxUIList(10, 10, [], (UI_box.width / 2) - 15, UI_box.height / 2);
		songList.x = UI_box.width - songList.width - 10;
		songList.y = (UI_box.height / 2) - (songList.height / 2);
		songListTitle.x = songList.x;
		updateSongList();

		var songNameTitle = new FlxText(10, 10, 0, "Song Name");

		songNameInput = new InputTextFix(10, songListTitle.height + 10);
		songNameInput.callback = function(a:String, b:String)
		{
			if (b.toLowerCase().trim() == 'enter')
			{
				if (songNameInput.text.trim().length > 0)
				{
					_week.tracks.push(songNameInput.text.trim());
					updateSongList();
				}
			}
		}

		var addSong = new FlxButton(10, songNameInput.y + songNameInput.height, "Add Song", function()
		{
			if (songNameInput.text.trim().length > 0)
			{
				_week.tracks.push(songNameInput.text.trim());
				updateSongList();
			}
		});

		songNameInput.resize((UI_box.width / 2) - 15, songNameInput.height);

		var delSong = new FlxButton(0, addSong.y, "Remove Song", function()
		{
			if (songNameInput.text.trim().length > 0)
			{
				_week.tracks.remove(songNameInput.text.trim());
				updateSongList();
			}
		});
		delSong.color = FlxColor.RED;
		delSong.label.color = FlxColor.WHITE;
		delSong.x = songNameInput.x + songNameInput.width - delSong.width;

		var tab = new FlxUI(null, UI_box);
		tab.name = "2";
		tab.add(songListTitle);
		tab.add(songList);
		tab.add(songNameTitle);
		tab.add(songNameInput);
		tab.add(addSong);
		tab.add(delSong);
		UI_box.addGroup(tab);
	}

	var songsInList:Array<FlxUIText> = [];

	function updateSongList():Void
	{
		for (song in songsInList)
			songsInList.remove(song);

		while (songList.members.length > 0)
		{
			songList.remove(songList.members[0], true);
		}

		for (song in _week.tracks)
		{
			var txt = new FlxUIText(0, 0, 0, song);
			songList.add(txt);
			songsInList.push(txt);
		}

		// man why it aint public :(((
		Reflect.callMethod(songList, Reflect.field(songList, 'refreshList'), []);

		// update tracks text
		txtTracklist.text = "\n\n";
		var stringThing:Array<String> = _week.tracks;

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyArray.length - 1;
		if (curDifficulty > CoolUtil.difficultyArray.length - 1)
			curDifficulty = 0;

		var previousMod = Paths.currentMod;
		Paths.setCurrentMod(CoolUtil.difficultyArray[curDifficulty][2]);

		sprDifficulty.alpha = 0;
		sprDifficulty.loadGraphic(Paths.image("difficulties/" + CoolUtil.difficultyFromInt(curDifficulty)));
		sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.93));
		sprDifficulty.updateHitbox();
		// some long fuckin equation idk mate
		sprDifficulty.x = leftArrow.x + leftArrow.width + ((rightArrow.x - (leftArrow.x + leftArrow.width)) / 2) - (sprDifficulty.width / 2);
		sprDifficulty.y = leftArrow.y + (leftArrow.height / 2) - (sprDifficulty.height / 2) - 15;
		FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 15, alpha: 1}, 0.07);

		Paths.setCurrentMod(previousMod);
	}

	var p2Errors:FlxText;
	var gfErrors:FlxText;
	var p1Errors:FlxText;

	var p2Input:InputTextFix;
	var gfInput:InputTextFix;
	var p1Input:InputTextFix;

	function createCharUI():Void
	{
		p2Errors = new FlxText();
		p1Errors = new FlxText();
		gfErrors = new FlxText();

		var p2InputTitle = new FlxText(10, 10, "Enemy Menu Character (left-hand side)");
		p2Input = new InputTextFix(10, p2InputTitle.y + p2InputTitle.height);
		p2Input.callback = function(a:String, b:String)
		{
			p2Errors.text = getFileErrors(p2Input.text);

			if (p2Errors.text == 'Files are okay!')
				_week.characters[0] = p2Input.text;
		}
		p2Input.text = _week.characters[0];
		p2Input.callback("", "");

		var gfInputTitle = new FlxText(10, p2Input.y + p2Input.height + 10, "Speaker Menu Character (middle)");
		gfInput = new InputTextFix(10, gfInputTitle.y + gfInputTitle.height);
		gfInput.callback = function(a:String, b:String)
		{
			gfErrors.text = getFileErrors(gfInput.text);

			if (gfErrors.text == 'Files are okay!')
				_week.characters[1] = gfInput.text;
		}
		gfInput.text = _week.characters[1];
		gfInput.callback("", "");

		var p1InputTitle = new FlxText(10, gfInput.y + gfInput.height + 10, "Player Menu Character (right-hand side)");
		p1Input = new InputTextFix(10, p1InputTitle.y + p1InputTitle.height);
		p1Input.callback = function(a:String, b:String)
		{
			p1Errors.text = getFileErrors(p1Input.text);

			if (p1Errors.text == 'Files are okay!')
				_week.characters[2] = p1Input.text;
		}
		p1Input.text = _week.characters[2];
		p1Input.callback("", "");

		p1Errors.x = p1Input.x + p1Input.width + 10;
		p1Errors.y = p1Input.y + (p1Input.height / 2) - (p1Errors.height / 2);

		p2Errors.x = p1Errors.x;
		p2Errors.y = p2Input.y + (p2Input.height / 2) - (p2Errors.height / 2);

		gfErrors.x = p1Errors.x;
		gfErrors.y = gfInput.y + (gfInput.height / 2) - (gfErrors.height / 2);

		var reloadChars = new FlxUIButton(10, 0, "Reload Characters", function()
		{
			updateChars();
		});
		reloadChars.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		reloadChars.resize(125, 20);
		reloadChars.y = UI_box.height - (reloadChars.height * 1.5) - 20;

		var bop = new FlxButton(reloadChars.x + reloadChars.width + 10, reloadChars.y, "Make em Bop", function()
		{
			grpWeekCharacters.forEachOfType(MenuCharacter, function(char:MenuCharacter)
			{
				if (char.animation.getByName("danceLeft") != null)
				{
					char.danced = !char.danced;

					if (!char.animation.curAnim.name.startsWith("hey"))
						char.animation.play("dance" + (char.danced ? "Right" : "Left"));
				}
				else if (char.animation.getByName("idle") != null)
				{
					if (!char.animation.curAnim.name.startsWith("hey"))
						char.animation.play('idle', true);
				}
			});
		});

		var tab = new FlxUI(null, UI_box);
		tab.name = "3";
		tab.add(p2InputTitle);
		tab.add(p2Input);
		tab.add(gfInputTitle);
		tab.add(gfInput);
		tab.add(p1InputTitle);
		tab.add(p1Input);
		tab.add(p2Errors);
		tab.add(gfErrors);
		tab.add(p1Errors);
		tab.add(reloadChars);
		tab.add(bop);
		UI_box.addGroup(tab);
	}

	function getFileErrors(fileName:String):String
	{
		var exists = [false, false, false];
		var files = [];

		var s = 'Missing: ';

		exists[0] = FileSystem.exists(Paths.menuCharacterJSON(fileName));
		exists[1] = FileSystem.exists(Paths.menuCharacterPNG(fileName));
		exists[2] = FileSystem.exists(Paths.menuCharacterXML(fileName));

		if (!exists[0])
			files.push('JSON');
		if (!exists[1])
			files.push('PNG');
		if (!exists[1])
			files.push('XML');

		s += files.join(", ");

		if (!exists.contains(false) || fileName == '')
			s = 'Files are okay!';

		return s;
	}

	function updateChars():Void
	{
		grpWeekCharacters.members[0].setCharacter(_week.characters[0]);
		grpWeekCharacters.members[1].setCharacter(_week.characters[1]);
		grpWeekCharacters.members[2].setCharacter(_week.characters[2]);

		grpWeekCharacters.members[0].y = yellowBG.y + yellowBG.height - grpWeekCharacters.members[0].height - 15;
		grpWeekCharacters.members[1].y = yellowBG.y + yellowBG.height - grpWeekCharacters.members[1].height - 30;
		grpWeekCharacters.members[2].y = yellowBG.y + yellowBG.height - grpWeekCharacters.members[2].height - 15;

		grpWeekCharacters.members[1].screenCenter(X);
		grpWeekCharacters.members[0].x = grpWeekCharacters.members[1].x - grpWeekCharacters.members[0].width - 5;
		grpWeekCharacters.members[2].x = grpWeekCharacters.members[1].x + grpWeekCharacters.members[1].width + 5;
	}

	var isTyping:Bool = false;
	var isVisible:Bool = true;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var a = [];

		forEachOfType(InputTextFix, function(inp:InputTextFix)
		{
			a.push(inp.hasFocus);
		}, true);

		isTyping = a.contains(true);

		for (text in songsInList)
		{
			if (FlxG.mouse.overlaps(text))
			{
				if (FlxG.mouse.justPressed)
					songNameInput.text = text.text;
			}
		}

		if (!isTyping)
		{
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];

			if (controls.BACK && !FlxG.keys.justPressed.BACKSPACE)
			{
				#if FILESYSTEM
				if (fromEditors)
				{
					FlxG.switchState(new EditorsState());
					fromEditors = false;
				}
				else
					#end
					FlxG.switchState(new StoryMenuState());
			}

			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.S)
					saveJSON();
				else if (FlxG.keys.justPressed.E)
					loadJSON();
			}

			if (controls.RIGHT_P && _week.difficultyLock == null)
				changeDifficulty(1);
			if (controls.LEFT_P && _week.difficultyLock == null)
				changeDifficulty(-1);

			if (controls.RIGHT)
				rightArrow.animation.play('press');
			else
				rightArrow.animation.play('idle');

			if (controls.LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.ACCEPT || controls.UP_P || controls.DOWN_P)
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.3);

			if (FlxG.keys.justPressed.F1)
			{
				isVisible = !isVisible;

				if (isVisible)
				{
					add(UI_box);
					add(saveButton);
					add(loadButton);
				}
				else
				{
					remove(UI_box, true);
					remove(saveButton, true);
					remove(loadButton, true);
				}
			}
		}
		else
		{
			FlxG.sound.volumeUpKeys = null;
			FlxG.sound.volumeDownKeys = null;
			FlxG.sound.muteKeys = null;
		}

		if (_week.difficultyLock != null)
		{
			leftArrow.visible = false;
			rightArrow.visible = false;
		}
		else
		{
			leftArrow.visible = true;
			rightArrow.visible = true;
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

		_week = cast Json.parse(File.getContent(path).trim());
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

		weekNameInput.text = _week.weekName;
		weekNameInput.callback("", "");

		weekJSONNameInput.text = _file.name.replace(".json", "").trim();
		weekJSONNameInput.callback("", "");

		p2Input.text = _week.characters[0];
		p2Input.callback("", "");

		gfInput.text = _week.characters[1];
		gfInput.callback("", "");

		p1Input.text = _week.characters[2];
		p1Input.callback("", "");

		updateSongList();
		updateChars();

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
		var data:String = Json.stringify(_week, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), weekJSONName + ".json");
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

	function createToolTips():Void
	{
		UI_box.forEachOfType(FlxText, function(spr:FlxText)
		{
			var ass = findHelperDesc(spr.text);
			addToolTipFor(ass, spr, spr.text);
		}, true);

		UI_box.forEachOfType(FlxButton, function(spr:FlxButton)
		{
			var ass = findHelperDesc(spr.label.text);
			addToolTipFor(ass, spr, spr.label.text);
		}, true);

		UI_box.forEachOfType(FlxUICheckBox, function(spr:FlxUICheckBox)
		{
			var ass = findHelperDesc(spr.getLabel().text);
			addToolTipFor(ass, spr, spr.getLabel().text);
		}, true);

		UI_box.forEachOfType(FlxUIButton, function(spr:FlxUIButton)
		{
			var ass = findHelperDesc(spr.getLabel().text);
			addToolTipFor(ass, spr, spr.getLabel().text);
		}, true);

		addToolTipFor(findHelperDesc(saveButton.text), saveButton, saveButton.text);
		addToolTipFor(findHelperDesc(loadButton.text), loadButton, loadButton.text);
	}

	function findHelperDesc(title:String):Null<String>
	{
		var toReturn:Null<String> = null;

		switch (title)
		{
			case 'SAVE FILE':
				toReturn = "Don't forget to save!";
			case 'LOAD FILE':
				toReturn = "Load a Hope Engine week file.";
			case 'Add Song':
				toReturn = "Add a song to the tracks list.\n\nShortcut: Pressing ENTER while having the \"Song Name\" textfield focused.";
			case 'Remove Song':
				toReturn = "Remove the song with the name inputted in the textfield above.";
			case 'Songs':
				toReturn = "The song list!\n\nProtip: clicking on a song name here will input it's name into the \"Song Name\" textfield.";
			case 'Week Name':
				toReturn = "The text at the top right";
			case 'Week File Name and Week Image Name':
				toReturn = "When saving, this will appear as the file name. When adding the \"week image\" asset, the game expects the image to be named like this as well.";
			case 'Difficulty Lock':
				toReturn = "Does exactly what it says.\n\nIf you only have 1 difficulty available, lock it into one!";
			case 'Reload Characters':
				toReturn = "Does exactly what it says. Make sure that all fields say \"Files are okay!\" before reloading!";
			case 'Make em Bop':
				toReturn = "Make the menu characters bop!\n(play their idle/danceLeft/danceRight animations)";
		}

		return toReturn;
	}

	function addToolTipFor(ass:String, spr:FlxObject, title:String)
	{
		if (ass != null)
		{
			tooltips.add(spr, {
				title: title,
				body: ass,
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
		}
	}
}
#end
