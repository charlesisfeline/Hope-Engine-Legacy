package editors;

import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.Anchor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxAction;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import haxe.Json;
import haxe.zip.Writer;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class ChartingState extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	static var savedPath:String;

	var _file:FileReference;

	public var playBfClaps:Bool = false;
	public var playDadClaps:Bool = false;

	public var snap:Int = 1;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	var camFollow:FlxObject;
	var camFollowXOffset:Float = 5;
	var camFollowYOffset:Float = 200;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var miscTxt:FlxText;
	var noteProperties:FlxText;

	var bg:FlxSprite;
	var strumLine:FlxSprite;
	var eventLine:FlxSprite;
	var curSong:String = 'Dad Battle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 50;

	var dummyArrow:FlxSprite;
	var selectionHighlight:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var eventsGrid:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var curSelectedEvent:Array<Event.SwagEvent>;

	var tempBpm:Float = 0;
	var gridBlackLine:FlxSprite;
	var vocals:FlxSound;

	var player2:Character = new Character(0, 0, "dad");
	var player1:Boyfriend = new Boyfriend(0, 0, "bf");

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	private var lastNote:Note;
	var claps:Array<Note> = [];

	public var snapText:FlxText;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic>;

	var beatLineGroup:FlxTypedGroup<FlxSprite>;
	var beatNumsGroup:FlxTypedGroup<FlxText>;

	var stepLineGroup:FlxTypedGroup<FlxSprite>;
	var stepNumsGroup:FlxTypedGroup<FlxText>;

	var beatLinesShown:Bool = false;
	var stepLinesShown:Bool = false;

	override function create()
	{
		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		FlxG.mouse.visible = true;
		usesMouse = true;

		curSection = lastSection;

		if (PlayState.SONG == null)
		{
			PlayState.SONG = Song.loadFromJson('tutorial', 'tutorial');
			Paths.setCurrentLevel("week" + PlayState.storyWeek);
		}

		_song = PlayState.SONG;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0x2e2e2e;
		bg.scrollFactor.set();
		add(bg);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		eventsGrid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * 16);
		eventsGrid.x = gridBG.x - eventsGrid.width - (GRID_SIZE / 2);
		add(eventsGrid);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		selectionHighlight = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE, 0xFFFFAA00);
		add(selectionHighlight);

		beatLineGroup = new FlxTypedGroup<FlxSprite>();
		add(beatLineGroup);
		beatNumsGroup = new FlxTypedGroup<FlxText>();
		add(beatNumsGroup);

		stepLineGroup = new FlxTypedGroup<FlxSprite>();
		add(stepLineGroup);
		stepNumsGroup = new FlxTypedGroup<FlxText>();
		add(stepNumsGroup);

		snapText = new FlxText(FlxG.width / 2 + 5, 420, 0, "Snap: 1/" + snap + " (Press Control to unsnap the cursor)\nAdd Notes: 1-8 (or click)\n", 16);
		snapText.scrollFactor.set();

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2 - 1).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.save.bind('save', 'hopeEngine');

		tempBpm = _song.bpm;

		addSection();

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		leftIcon = new HealthIcon(_song.player1);
		rightIcon = new HealthIcon(_song.player2);
		leftIcon.setGraphicSize(GRID_SIZE * 2, 0);
		rightIcon.setGraphicSize(GRID_SIZE * 2, 0);
		leftIcon.updateHitbox();
		rightIcon.updateHitbox();
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);
		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(GRID_SIZE, -GRID_SIZE * 2);
		rightIcon.setPosition(gridBG.x + (GRID_SIZE * 5), -GRID_SIZE * 2);

		bpmTxt = new FlxText(FlxG.width / 2 + 5, 500, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		miscTxt = new FlxText(10, 0, 0, "", 16);
		miscTxt.scrollFactor.set();
		add(miscTxt);

		noteProperties = new FlxText(FlxG.width / 2 + 5, 600, 0, "", 16);
		noteProperties.scrollFactor.set();
		add(noteProperties);

		strumLine = new FlxSprite(gridBG.x).makeGraphic(Std.int(gridBG.width), 4);
		add(strumLine);

		eventLine = new FlxSprite(eventsGrid.x).makeGraphic(Std.int(eventsGrid.width), 4);
		add(eventLine);

		add(snapText);

		var tabs = [
			{name: "1", label: 'Assets'},
			{name: "2", label: "Misc"},
			{name: "3", label: "Event Data"},
			{name: "4", label: 'Section Data'},
			{name: "5", label: 'Note Data'},
			{name: "6", label: 'Song Data'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.scrollFactor.set();
		UI_box.resize(GRID_SIZE * 8, 400);
		UI_box.x = FlxG.width / 2 + 5;
		UI_box.y = 20;
		add(UI_box);

		addAssetsUI();
		addMiscUI();
		addEventUI();
		addSectionUI();
		addNoteUI();
		addSongUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		updateHeads();
		updateLines();

		camFollow = new FlxObject(strumLine.x + strumLine.width + camFollowXOffset, strumLine.y + camFollowYOffset);
		FlxG.camera.follow(camFollow);

		vocals.pause();
		vocals.time = 0;
		FlxG.sound.music.pause();
		FlxG.sound.music.time = 0;
		changeSection();

		super.create();
	}

	function addAssetsUI():Void
	{
		var pastMod = Paths.currentMod;
		Paths.setCurrentMod(null);

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfVersions:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		var noteStyles:Array<String> = CoolUtil.coolTextFile(Paths.txt('noteStyleList'));

		// append (cool)
		#if FILESYSTEM
		Paths.setCurrentMod(pastMod);

		if (Paths.currentMod != null)
		{
			if (FileSystem.exists(Paths.txt('characterList')))
				characters = characters.concat(CoolUtil.coolStringFile(File.getContent(Paths.txt('characterList'))));

			if (FileSystem.exists(Paths.txt('gfVersionList')))
				gfVersions = gfVersions.concat(CoolUtil.coolStringFile(File.getContent(Paths.txt('gfVersionList'))));

			if (FileSystem.exists(Paths.txt('stageList')))
				stages = stages.concat(CoolUtil.coolStringFile(File.getContent(Paths.txt('stageList'))));

			if (FileSystem.exists(Paths.txt('noteStyleList')))
				noteStyles = noteStyles.concat(CoolUtil.coolStringFile(File.getContent(Paths.txt('noteStyleList'))));
		}
		#end

		var player1DropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player1Label = new FlxText(player1DropDown.x + player1DropDown.width + 5, 10, player1DropDown.width, 'You (boyfriend)');

		var player2DropDown = new FlxUIDropDownMenu(10, 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;

		var player2Label = new FlxText(player1DropDown.x + player1DropDown.width + 5, 40, player1DropDown.width, 'Opponent (dad)');

		var gfVersionDropDown = new FlxUIDropDownMenu(10, 70, FlxUIDropDownMenu.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
		{
			_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;

		var gfVersionLabel = new FlxText(player1DropDown.x + player1DropDown.width + 5, 70, player1DropDown.width, 'Girlfriend');

		var stageDropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = _song.stage;

		var stageLabel = new FlxText(player1DropDown.x + player1DropDown.width + 5, 100, player1DropDown.width, 'Current Stage');

		var noteStyleDropDown = new FlxUIDropDownMenu(10, 130, FlxUIDropDownMenu.makeStrIdLabelArray(noteStyles, true), function(noteStyle:String)
		{
			_song.noteStyle = noteStyles[Std.parseInt(noteStyle)];
			updateGrid();
		});
		noteStyleDropDown.selectedLabel = _song.noteStyle;

		var noteStyleLabel = new FlxText(player1DropDown.x + player1DropDown.width + 5, 130, player1DropDown.width, 'Note Skin');

		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "1";
		tab_group_assets.add(noteStyleDropDown);
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(gfVersionDropDown);
		tab_group_assets.add(player2DropDown);
		tab_group_assets.add(player1DropDown);

		noteStyleDropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		stageDropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		gfVersionDropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		player2DropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		player1DropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;

		tab_group_assets.add(noteStyleLabel);
		tab_group_assets.add(gfVersionLabel);
		tab_group_assets.add(stageLabel);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);

		UI_box.addGroup(tab_group_assets);
	}

	var tab_group_misc:FlxUI;
	var iconFollow:FlxUICheckBox;

	function addMiscUI():Void
	{
		var bfClaps = new FlxUICheckBox(10, 10, null, null, "Play Boyfriend Hitsounds");
		bfClaps.checked = false;
		bfClaps.callback = function()
		{
			playBfClaps = bfClaps.checked;
		};

		var dadClaps = new FlxUICheckBox(bfClaps.width + 20, 10, null, null, "Play Dad Hitsounds");
		dadClaps.checked = false;
		dadClaps.callback = function()
		{
			playDadClaps = dadClaps.checked;
		};

		iconFollow = new FlxUICheckBox(10, bfClaps.height + 20, null, null, "Icons Follow Strumline");
		iconFollow.checked = false;

		var muteInst = new FlxUICheckBox(iconFollow.width + 20, iconFollow.y, null, null, "Mute Instrumental in editor");
		muteInst.checked = false;
		muteInst.callback = function()
		{
			var vol:Float = 1;

			if (muteInst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var showBeatLines = new FlxUICheckBox(10, iconFollow.y + iconFollow.height + 10, null, null, "Show beat lines");
		showBeatLines.checked = false;
		showBeatLines.callback = function()
		{
			beatLinesShown = showBeatLines.checked;
			updateLines();
		};
		showBeatLines.callback();

		var showStepLines = new FlxUICheckBox(showBeatLines.width + 20, showBeatLines.y, null, null, "Show step lines");
		showStepLines.checked = false;
		showStepLines.callback = function()
		{
			stepLinesShown = showStepLines.checked;
			updateLines();
		};
		showStepLines.callback();

		tab_group_misc = new FlxUI(null, UI_box);
		tab_group_misc.name = '2';
		tab_group_misc.add(bfClaps);
		tab_group_misc.add(dadClaps);
		tab_group_misc.add(iconFollow);
		tab_group_misc.add(muteInst);
		tab_group_misc.add(showBeatLines);
		tab_group_misc.add(showStepLines);

		UI_box.addGroup(tab_group_misc);
	}

	var eventDropdown:FlxUIDropDownMenu;
	var currentEvent:String = "hopeEngine/nothing";

	function addEventUI():Void
	{
		var eventsArray:Array<String> = [
			"hopeEngine/nothing"
		];

		// do a reading if FILESYSTEM epic
		#if FILESYSTEM
		if (FileSystem.exists(Sys.getCwd() + "mods"))
		{
			for (mod in FileSystem.readDirectory(Sys.getCwd() + "mods"))
			{
				if (Paths.currentMod == mod && FileSystem.exists(Sys.getCwd() + 'mods/$mod/assets/_noteTypes'))
				{
					for (noteType in FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/assets/_noteTypes'))
						eventsArray.push('$mod/$noteType');
				}
			}
		}
		#end

		var eventsLabel = new FlxText(10, 10, "Events List");
		eventDropdown = new FlxUIDropDownMenu(10, eventsLabel.y + eventsLabel.height, FlxUIDropDownMenu.makeStrIdLabelArray(eventsArray, true),
			function(a:String)
			{
				currentEvent = eventDropdown.selectedLabel;
			});

		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = '3';
		tab_group_event.add(eventsLabel);
		tab_group_event.add(eventDropdown);

		UI_box.addGroup(tab_group_misc);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		var stepperLengthLabel = new FlxText(74, 10, 'Section Length (in steps)');

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174, 132, 'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var copySectionButton:FlxButton = new FlxButton(10, clearSectionButton.y + clearSectionButton.height * 2, "Copy Section Notes", function()
		{
			notesCopied = [];
			sectionToCopy = curSection;
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSection].sectionNotes[i];
				notesCopied.push(note);
			}
		});

		var pasteSectionButton:FlxButton = new FlxButton(10, copySectionButton.y + copySectionButton.height, "Paste Section Notes", function()
		{
			var addToTime:Float = Conductor.stepCrochet * (_song.notes[curSection].lengthInSteps * (curSection - sectionToCopy));

			for (note in notesCopied)
			{
				var copiedNote:Array<Dynamic> = [];
				if (note[4] != null)
					copiedNote = [note[0] + addToTime, note[1], note[2], note[3], note[4]];
				else
					copiedNote = [note[0] + addToTime, note[1], note[2], note[3]];

				_song.notes[curSection].sectionNotes.push(copiedNote);
			}
			updateGrid();
		});

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				// Man what the fuck
				// I hate strict-types I used 2 hours to fix this
				var note:Array<Dynamic> = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Point camera to Boyfriend?", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 0, null, null, "Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';
		check_altAnim.y = UI_box.height - check_altAnim.height - 30;

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = '4';
		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(copySectionButton);
		tab_group_section.add(pasteSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var tab_group_note:FlxUI;
	var noteTypeDropdown:FlxUIDropDownMenu;
	var currentNoteType:String = "hopeEngine/normal";

	function addNoteUI():Void
	{
		var noteTypeArray:Array<String> = [
			"hopeEngine/normal",
			"hopeEngine/death",
			"hopeEngine/flash",
			"hopeEngine/randomize-position"
		];

		// do a reading if FILESYSTEM epic
		#if FILESYSTEM
		if (FileSystem.exists(Sys.getCwd() + "mods"))
		{
			for (mod in FileSystem.readDirectory(Sys.getCwd() + "mods"))
			{
				if (Paths.currentMod == mod && FileSystem.exists(Sys.getCwd() + 'mods/$mod/assets/_noteTypes'))
				{
					for (noteType in FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/assets/_noteTypes'))
						noteTypeArray.push('$mod/$noteType');
				}
			}
		}
		#end

		var stepperSusLengthLabel = new FlxText(10, 10, 'Note Sustain Length');

		stepperSusLength = new FlxUINumericStepper(10, stepperSusLengthLabel.height + 10, Conductor.stepCrochet / 2, 0, 0, Math.POSITIVE_INFINITY);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var noteTypeLabel = new FlxText(10, stepperSusLength.y + stepperSusLength.height + 20, 'Selected Note Type');
		noteTypeDropdown = new FlxUIDropDownMenu(10, noteTypeLabel.y + noteTypeLabel.height, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypeArray, true),
			function(a:String)
			{
				currentNoteType = noteTypeDropdown.selectedLabel;
			});

		tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = '5';
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(noteTypeLabel);
		tab_group_note.add(noteTypeDropdown);

		UI_box.addGroup(tab_group_note);
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
		};

		var saveButton:FlxButton = new FlxButton(0, 10, "Save", saveLevel);
		saveButton.x = UI_box.width - saveButton.width - 10;

		var reloadSong:FlxButton = new FlxButton(saveButton.x, saveButton.y + saveButton.height + 10, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, reloadSong.y + reloadSong.height + 10, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var restart = new FlxButton(0, 0, "Reset Chart", function()
		{
			for (ii in 0..._song.notes.length)
			{
				for (i in 0..._song.notes[ii].sectionNotes.length)
				{
					_song.notes[ii].sectionNotes = [];
				}
			}
			resetSection(true);
		});
		// hi psych engine
		restart.color = FlxColor.RED;
		restart.label.color = FlxColor.WHITE;
		restart.x = UI_box.width - restart.width - 10;
		restart.y = UI_box.height - restart.height - 30;

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(74, 65, 'BPM');

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, Math.POSITIVE_INFINITY, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(74, 80, 'Scroll Speed');

		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 0.1, 1, 0.1, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(74, 95, 'Vocal Volume');

		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';

		var stepperSongVolLabel = new FlxText(74, 110, 'Instrumental Volume');

		var shiftNoteDialLabel = new FlxText(10, 245, 'Shift Note FWD by (Section)');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 260, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';

		var shiftNoteDialLabel2 = new FlxText(10, 275, 'Shift Note FWD by (Step)');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 290, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';

		var shiftNoteDialLabel3 = new FlxText(10, 305, 'Shift Note FWD by (ms)');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 320, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';

		var shiftNoteButton:FlxButton = new FlxButton(10, 335, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value), Std.int(stepperShiftNoteDialstep.value), Std.int(stepperShiftNoteDialms.value));
		});
		shiftNoteButton.y = UI_box.height - shiftNoteButton.height - 30;

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "6";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(stepperVocalVol);
		tab_group_song.add(stepperVocalVolLabel);
		tab_group_song.add(stepperSongVol);
		tab_group_song.add(stepperSongVolLabel);
		tab_group_song.add(shiftNoteDialLabel);
		tab_group_song.add(stepperShiftNoteDial);
		tab_group_song.add(shiftNoteDialLabel2);
		tab_group_song.add(stepperShiftNoteDialstep);
		tab_group_song.add(shiftNoteDialLabel3);
		tab_group_song.add(stepperShiftNoteDialms);
		tab_group_song.add(shiftNoteButton);

		UI_box.addGroup(tab_group_song);
	}

	function updateLines():Void
	{
		remove(beatLineGroup);
		beatLineGroup = new FlxTypedGroup<FlxSprite>();
		add(beatLineGroup);

		remove(beatNumsGroup);
		beatNumsGroup = new FlxTypedGroup<FlxText>();
		add(beatNumsGroup);

		remove(stepLineGroup);
		stepLineGroup = new FlxTypedGroup<FlxSprite>();
		add(stepLineGroup);

		remove(stepNumsGroup);
		stepNumsGroup = new FlxTypedGroup<FlxText>();
		add(stepNumsGroup);

		beatLineGroup.visible = beatLinesShown;
		beatNumsGroup.visible = beatLinesShown;

		stepLineGroup.visible = stepLinesShown;
		stepNumsGroup.visible = stepLinesShown;

		for (line in beatLineGroup.members)
		{
			line.kill();
			beatLineGroup.remove(line, true);
			line.destroy();
			trace("destroyed line!");
		}

		for (num in beatNumsGroup.members)
		{
			num.kill();
			beatNumsGroup.remove(num, true);
			num.destroy();
		}

		for (line in stepLineGroup.members)
		{
			line.kill();
			stepLineGroup.remove(line, true);
			line.destroy();
		}

		for (num in stepNumsGroup.members)
		{
			num.kill();
			stepNumsGroup.remove(num, true);
			num.destroy();
		}

		for (i in 0..._song.notes[curSection].lengthInSteps)
		{
			var widthThing = Std.int(Math.abs((gridBG.x + gridBG.width) - eventsGrid.x));
			var line = new FlxSprite(eventsGrid.x, i * GRID_SIZE).makeGraphic(widthThing, 2, FlxColor.BLUE);
			line.scrollFactor.set(1, 1);
			line.alpha = 0.5;
			stepLineGroup.add(line);

			var stepNum = (sectionStartTime() / Conductor.stepCrochet) + i;
			var num = new FlxText(0, 0, FlxG.width / 4, stepNum + '');
			num.antialiasing = true;
			num.x = line.x - num.width - 8;
			num.y = line.y + (line.height / 2) - (num.height / 2) - 4;
			num.setFormat('_sans', 16, FlxColor.BLUE, RIGHT);
			stepNumsGroup.add(num);

			if (i % 4 == 0)
			{
				var line = new FlxSprite(eventsGrid.x, i * GRID_SIZE).makeGraphic(widthThing, 2, FlxColor.RED);
				line.scrollFactor.set(1, 1);
				line.alpha = 0.5;
				beatLineGroup.add(line);

				var beatNum = ((sectionStartTime() / Conductor.stepCrochet) + i) / 4;
				var num = new FlxText(0, 0, FlxG.width / 4, beatNum + '');
				num.antialiasing = true;
				num.x = line.x - num.width - 8;
				num.y = line.y + (line.height / 2) - (num.height / 2) - 4;
				if (stepLinesShown)
					num.y += num.height + 8;
				num.setFormat('_sans', 16, FlxColor.RED, RIGHT);
				beatNumsGroup.add(num);
			}
		}
	}

	var pastPitch:Float = 1.0;

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6, false);
		FlxG.sound.music.pause();

		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection(false);
		};
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Point camera to Boyfriend?':
					_song.notes[curSection].mustHitSection = check.checked;
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
				case "Alternate Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;

			switch (wname)
			{
				case 'section_length':
					if (nums.value <= 4)
						nums.value = 4;
					_song.notes[curSection].lengthInSteps = Std.int(nums.value);
					updateGrid();
				case 'song_speed':
					if (nums.value <= 0)
						nums.value = 0;
					_song.speed = nums.value;
				case 'song_bpm':
					if (nums.value <= 0)
						nums.value = 1;
					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));
				case 'note_susLength':
					if (curSelectedNote == null)
						return;

					if (nums.value <= 0)
						nums.value = 0;
					curSelectedNote[2] = nums.value;
					updateGrid();
				case 'section_bpm':
					if (nums.value <= 0.1)
						nums.value = 0.1;
					_song.notes[curSection].bpm = Std.int(nums.value);
					updateGrid();
				case 'song_vocalvol':
					if (nums.value <= 0.1)
						nums.value = 0.1;
					vocals.volume = nums.value;
				case 'song_instvol':
					if (nums.value <= 0.1)
						nums.value = 0.1;
					FlxG.sound.music.volume = nums.value;
			}
		}
	}

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
				daBPM = _song.notes[i].bpm;

			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var writingNotes:Bool = false;
	var doSnapShit:Bool = true;

	var heldTime:Float = 0;
	var timeStopped:Bool = false;

	override function update(elapsed:Float)
	{
		snapText.text = "Snap: 1/"
			+ snap
			+ " ("
			+ (doSnapShit ? "Control to disable" : "Snap Disabled, Control to renable")
			+ ")\nAdd Notes: 1-8 (or click)";

		curStep = recalculateSteps();

		if (selectionHighlight != null)
		{
			if (curSelectedNote != null)
			{
				selectionHighlight.x = FlxMath.lerp(selectionHighlight.x, curSelectedNote[1] * GRID_SIZE, 0.09);
				selectionHighlight.y = FlxMath.lerp(selectionHighlight.y,
					getYfromStrum((curSelectedNote[0] - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)), 0.09);
				// selectionHighlight.setPosition(curSelectedNote[1] * GRID_SIZE, getYfromStrum((curSelectedNote[0] - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
				selectionHighlight.visible = true;
			}
			else
			{
				selectionHighlight.setPosition(0, 0);
				selectionHighlight.visible = false;
			}
		}

		#if cpp
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, currentPitch);

			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, currentPitch);
		}
		#end

		if (FlxG.keys.justPressed.CONTROL)
			doSnapShit = !doSnapShit;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		var pressArray = [
			FlxG.keys.justPressed.ONE, // left		player
			FlxG.keys.justPressed.TWO, // down		player
			FlxG.keys.justPressed.THREE, // up		player
			FlxG.keys.justPressed.FOUR, // right	player
			FlxG.keys.justPressed.FIVE, // left 	opponent
			FlxG.keys.justPressed.SIX, // down 	opponent
			FlxG.keys.justPressed.SEVEN, // up 		opponent
			FlxG.keys.justPressed.EIGHT // right 	opponent
		];

		var delete = false;

		curRenderedNotes.forEach(function(note:Note)
		{
			if (strumLine.overlaps(note) && pressArray[Math.floor(note.x / GRID_SIZE)])
			{
				deleteNote(note, pressArray.indexOf(true));
				delete = true;
			}
		});

		for (p in 0...pressArray.length)
		{
			var i = pressArray[p];
			if (i && !delete)
			{
				addNote(new Note(Conductor.songPosition, p, null, false, currentNoteType));
			}
		}

		strumLine.y = eventLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (iconFollow.checked)
		{
			// can't think of other equations
			var pain = (1 - ((strumLine.y / GRID_SIZE) / 2));

			if (pain > 1)
				pain = 1;

			if (pain < 0.5)
				pain = 0.5;

			leftIcon.scale.set(pain, pain);
			rightIcon.scale.set(pain, pain);
			leftIcon.updateHitbox();
			rightIcon.updateHitbox();

			leftIcon.alpha = pain;
			rightIcon.alpha = pain;

			leftIcon.y = strumLine.y - leftIcon.height;
			rightIcon.y = strumLine.y - rightIcon.height;
		}
		else
		{
			leftIcon.scale.set(1, 1);
			rightIcon.scale.set(1, 1);
			leftIcon.updateHitbox();
			rightIcon.updateHitbox();

			leftIcon.alpha = 1;
			rightIcon.alpha = 1;

			leftIcon.y = -leftIcon.height;
			rightIcon.y = -rightIcon.height;
		}

		leftIcon.x = (GRID_SIZE * 2) - (leftIcon.width / 2);
		rightIcon.x = (GRID_SIZE * 6) - (rightIcon.width / 2);

		camFollow.setPosition(strumLine.x + strumLine.width + camFollowXOffset, strumLine.y + camFollowYOffset);

		curRenderedNotes.forEach(function(note:Note)
		{
			if (note.strumTime <= Conductor.songPosition && !claps.contains(note) && FlxG.sound.music.playing)
			{
				claps.push(note);

				if (playBfClaps && checkMustPress(note))
					FlxG.sound.play(Paths.sound('SNAP'));

				if (playDadClaps && !checkMustPress(note))
					FlxG.sound.play(Paths.sound('SNAP'));
			}

			if (note.y < strumLine.y)
				note.alpha = 0.4;
			else
				note.alpha = 1;
		});

		curRenderedSustains.forEach(function(note:FlxSprite)
		{
			if (note.y + note.height < strumLine.y)
				note.alpha = 0.4;
			else
				note.alpha = 1;
		});

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			if (_song.notes[curSection + 1] == null)
				addSection();

			changeSection(curSection + 1, false);
		}

		if (curStep < 16 * curSection)
		{
			changeSection(curSection - 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
						deleteNote(note);
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.justPressedRight)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
						selectNote(note);
				});
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			dummyArrow.visible = true;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y - (GRID_SIZE / 2);
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}
		else if (FlxG.mouse.x > eventsGrid.x
			&& FlxG.mouse.x < eventsGrid.x + eventsGrid.width
			&& FlxG.mouse.y > eventsGrid.y
			&& FlxG.mouse.y < eventsGrid.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = eventsGrid.x;
			dummyArrow.visible = true;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y - (GRID_SIZE / 2);
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}
		else
			dummyArrow.visible = false;

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.mouse.visible = false;
		}

		if (controls.BACK && !FlxG.keys.justPressed.BACKSPACE)
		{
			if (fromEditors)
			{
				FlxG.switchState(new EditorsState());
				fromEditors = false;
			}
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 4;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab > 4)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.Z && lastNote != null)
				{
					if (curRenderedNotes.members.contains(lastNote))
						deleteNote(lastNote);
					else
						addNote(lastNote);
				}
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (!FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + shiftThing);
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - shiftThing);
			}

			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else if (!FlxG.keys.pressed.CONTROL)
					resetSection();

				if (FlxG.keys.pressed.CONTROL)
					changePitch(-currentPitch + 1.0);
			}

			if (FlxG.sound.music.time < 0 || curStep < 0)
				FlxG.sound.music.time = 0;

			if (FlxG.mouse.wheel != 0)
			{
				if (!FlxG.keys.pressed.CONTROL)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);

					if (doSnapShit)
						FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet);
					else
						FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);

					vocals.time = FlxG.sound.music.time;
				}
				else
				{
					changePitch(FlxG.mouse.wheel * 0.01);
				}
			}

			if (FlxG.keys.justPressed.J)
				changePitch(-0.25);
			else if (FlxG.keys.justPressed.L)
				changePitch(0.25);

			if (FlxG.keys.pressed.SHIFT || timeStopped)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
						heldTime -= daTime;
					else
						heldTime += daTime;

					if (heldTime < 0)
						heldTime = 0;

					if (heldTime > FlxG.sound.music.length)
						heldTime = FlxG.sound.music.length;

					FlxG.sound.music.resume();
					vocals.resume();
					vocals.time = FlxG.sound.music.time;
				}
				else
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}

				FlxG.sound.music.time = heldTime;
				vocals.time = FlxG.sound.music.time;
			}
			else
				heldTime = FlxG.sound.music.time;
		}

		_song.bpm = tempBpm;

		var songPos = (FlxMath.roundDecimal(Conductor.songPosition / 1000, 2));
		var songLen = (FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2));

		bpmTxt.text = '${FlxStringUtil.formatTime(songPos, true)} / ${FlxStringUtil.formatTime(songLen, true)}'
			+ '\nSection: $curSection'
			+ '\nCurrent Step: $curStep'
			+ '\nCurrent Beat: $curBeat';

		miscTxt.text = 'Speed:\n${currentPitch}x\n(J | L)';
		miscTxt.y = FlxG.height - miscTxt.height - 10;

		if (curSelectedNote != null)
		{
			noteProperties.text = 'Note Properties:'
				+ '\nStrumtime: ${curSelectedNote[0]}'
				+ '\nDirection: ${curSelectedNote[1]}'
				+ '\nSustain Length: ${FlxStringUtil.formatTime(curSelectedNote[2] / 1000, true)}'
				+ '\nNote Type: ${curSelectedNote[3]}';
		}
		else
			noteProperties.text = 'Right Click to select/deselect \na note.';

		super.update(elapsed);
	}

	function checkMustPress(note:Note):Bool
	{
		if (note.x < gridBG.width / 2)
		{
			if (_song.notes[curSection].mustHitSection)
				return true;
			else
				return false;
		}

		if (note.x > gridBG.width / 2)
		{
			if (_song.notes[curSection].mustHitSection)
				return false;
			else
				return true;
		}

		return false;
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
				curSelectedNote[2] += value;
		}

		updateNoteUI();
		updateGrid();
	}

	override function stepHit()
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 20
			|| Math.abs(vocals.time - Conductor.songPosition) > 20
			|| Math.abs(FlxG.sound.music.time - vocals.time) > 20)
			resyncVocals();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateHeads():Void
	{
		if (leftIcon != null && rightIcon != null)
		{
			if (_song.notes[curSection].mustHitSection)
			{
				leftIcon.changeIcon(_song.player1);
				rightIcon.changeIcon(_song.player2);
			}
			else
			{
				leftIcon.changeIcon(_song.player2);
				rightIcon.changeIcon(_song.player1);
			}
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		remove(gridBG);
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * _song.notes[curSection].lengthInSteps);
		add(gridBG);

		remove(gridBlackLine);
		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2 - 1).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		remove(eventsGrid);
		eventsGrid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * _song.notes[curSection].lengthInSteps);
		eventsGrid.x = gridBG.x - eventsGrid.width - (GRID_SIZE / 2);
		add(eventsGrid);

		updateHeads();
		updateLines();

		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daType = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, false, daType);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			if (curSelectedNote != null)
				if (curSelectedNote[0] == note.strumTime)
					lastNote = note;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - ((GRID_SIZE * 1 / 6) / 2),
					note.y + GRID_SIZE).makeGraphic(Std.int(GRID_SIZE * 1 / 6),
					Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
				unblandSusNote(sustainVis, note);
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	// may cause some discolors with Black and White
	function unblandSusNote(susSprite:FlxSprite, note:Note)
	{
		var frae = note.animation.curAnim.curFrame;
		var frame = note.frames.frames[frae].frame;

		var xpos = Math.floor((note.graphic.width * FlxMath.roundDecimal(note.frame.uv.x, 2)) + (frame.width / 2));
		var ypos = Math.floor((note.graphic.height * FlxMath.roundDecimal(note.frame.uv.y, 2)) + (frame.height / 2));
		var color = note.graphic.bitmap.getPixel32(xpos, ypos);
		susSprite.color = color;
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	var currentPitch:Float = 1.0;

	function changePitch(change:Float)
	{
		currentPitch += change;
		currentPitch = FlxMath.roundDecimal(currentPitch, 2);
	}

	function selectNote(note:Note, ?multiplier:Float):Void
	{
		var noteData:Float;
		if (multiplier == null)
			noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		else
			noteData = Math.floor(gridBG.x + (GRID_SIZE * multiplier) / GRID_SIZE);

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == noteData)
			{
				// you will hate this
				if (curSelectedNote != null && curSelectedNote.join(" ") == i.join(" "))
					curSelectedNote = null;
				else
					curSelectedNote = i;

				break;
			}
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note, ?multiplier:Float):Void
	{
		var noteData:Float;
		if (multiplier == null)
			noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		else
			noteData = Math.floor(gridBG.x + (GRID_SIZE * multiplier) / GRID_SIZE);

		lastNote = note;
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == noteData)
			{
				_song.notes[curSection].sectionNotes.remove(i);

				// you will hate this
				if (curSelectedNote != null)
				{
					if (curSelectedNote.join(" ") == i.join(" "))
						curSelectedNote = null;
				}

				break;
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function newSection(lengthInSteps:Int = 16, mustHitSection:Bool = false, altAnim:Bool = true):SwagSection
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: mustHitSection,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: altAnim
		};

		return sec;
	}

	function shiftNotes(measure:Int = 0, step:Int = 0, ms:Int = 0):Void
	{
		var newSong = [];

		var millisecadd = (((measure * 4) + step / 4) * (60000 / _song.bpm)) + ms;
		var totaladdsection = Std.int((millisecadd / (60000 / _song.bpm) / 4));

		if (millisecadd > 0)
		{
			for (i in 0...totaladdsection)
				newSong.unshift(newSection());
		}

		for (daSection1 in 0..._song.notes.length)
			newSong.push(newSection(16, _song.notes[daSection1].mustHitSection, _song.notes[daSection1].altAnim));

		for (daSection in 0...(_song.notes.length))
		{
			var aimtosetsection = daSection + Std.int((totaladdsection));
			if (aimtosetsection < 0)
				aimtosetsection = 0;
			newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
			newSong[aimtosetsection].altAnim = _song.notes[daSection].altAnim;
			for (daNote in 0...(_song.notes[daSection].sectionNotes.length))
			{
				var newtiming = _song.notes[daSection].sectionNotes[daNote][0] + millisecadd;
				if (newtiming < 0)
				{
					newtiming = 0;
				}
				var futureSection = Math.floor(newtiming / 4 / (60000 / _song.bpm));
				_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
				newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);
			}
		}

		_song.notes = newSong;
		updateGrid();
		updateSectionUI();
		updateNoteUI();
	}

	private function addNote(?n:Note):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var noteType = currentNoteType;

		if (n != null)
			_song.notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.noteType]);
		else
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		var thingy = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		curSelectedNote = thingy;

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		var songFormatted = song.replace(" ", "-").toLowerCase();
		var songPath = 'assets/data/' + songFormatted + '/' + songFormatted + ".json";

		#if FILESYSTEM
		if (FileSystem.exists(Sys.getCwd() + songPath))
		#else
		if (Assets.exists(songPath))
		#end
		{
			PlayState.SONG = Song.loadFromJson(songFormatted, songFormatted,
				(Paths.currentMod != null && Paths.currentMod.length > 0 ? "mods/" + Paths.currentMod : ""));
			LoadingState.loadAndSwitchState(new editors.ChartingState());
		}
	else
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		LoadingState.loadAndSwitchState(new editors.ChartingState());
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		_file = new FileReference();
		_file.addEventListener(Event.COMPLETE, onSaveComplete);
		_file.addEventListener(Event.CANCEL, onSaveCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file.save(data.trim(), _song.song.toLowerCase() + ".json");
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		trace("Successfully saved LEVEL DATA.");
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
		trace("Problem saving Level data");
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
}
