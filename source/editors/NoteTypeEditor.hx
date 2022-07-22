package editors;

import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUIButton;
import ui.NumStepperFix;
import flixel.ui.FlxButton;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import haxe.Json;
import openfl.events.IOErrorEvent;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxTimer;
import Note;
import ui.DropdownMenuFix;
import flixel.addons.ui.FlxUICheckBox;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUI;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import Note.NoteJSON;
import ui.InputTextFix;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUITabMenu;
import openfl.events.Event;


#if FILESYSTEM
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
	As you can see I genuinely hated making this...

	This whole menu's a mess code-wise, btw
	Will probably not be bothered to refactor
**/
class NoteTypeEditor extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	var UI_box:FlxUITabMenu;

	var camEdit:FlxCamera;
	var camHUD:FlxCamera;

	var camFollow:FlxObject;

	var playStrums:FlxTypedSpriteGroup<StaticArrow>;
	var holdStrums:FlxSpriteGroup;
	var holdEndStrums:FlxSpriteGroup;

	var notes:FlxSpriteGroup;
	var holds:FlxSpriteGroup;
	var holdEnds:FlxSpriteGroup;

	// Such a needy piece of shit
	var _note:NoteJSON = {
		name: "Death Note",
		assetName: "DEATH",
		canMiss: true,
		canScore: false,
		upSpriteOnly: true,
		unblandWhat: "direction",
		noHolds: false,
		visibleLock: true,
		scaleLockY: true,
		scaleLockX: true,
		scale: 1,
		positionLockY: true,
		positionLockX: true,
		offsetMultiplier: [1, 1],
		scrollMultiplier: 1,
		noNoteSplash: true,
		angleLock: true,
		alphaLock: true,
		sprites: {
			up: {
				note: {
					prefix: "note",
					offset: null,
					looped: null,
					frameRate: null,
					flipY: null,
					flipX: null
				},
				holdPiece: {
					prefix: "hold piece",
					offset: null,
					looped: null,
					frameRate: null,
					flipY: null,
					flipX: null
				},
				holdEnd: {
					prefix: "hold end",
					offset: null,
					looped: null,
					frameRate: null,
					flipY: null,
					flipX: null
				}
			},
			down: null,
			left: null,
			right: null
		}
	}

	var curNote:Int = 0;
	var curNoteDisplay:FlxText;

	var origOffsets:Array<Array<Float>> = [[0, 0], [0, 0], [0, 0], [0, 0]];
	var animOffsets:Array<Array<Float>> = [[0, 0], [0, 0], [0, 0], [0, 0]];

	var origHoldOffsets:Array<Array<Float>> = [[0, 0], [0, 0], [0, 0], [0, 0]];
	var animHoldOffsets:Array<Array<Float>> = [[0, 0], [0, 0], [0, 0], [0, 0]];

	var origEndsOffsets:Array<Array<Float>> = [[0, 0], [0, 0], [0, 0], [0, 0]];
	var animEndsOffsets:Array<Array<Float>> = [[0, 0], [0, 0], [0, 0], [0, 0]];

	public function new(?json:NoteJSON)
	{
		super();

		if (json != null)
			this._note = json;
	}

	override function create()
	{
		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		#if desktop
		DiscordClient.changePresence("Note Type Editor");
		#end

		FlxG.mouse.visible = true;
		usesMouse = true;

		camEdit = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camEdit);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camEdit];

		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		add(bg);

		curNoteDisplay = new FlxText(0, 20, FlxG.width, "", 15);
		curNoteDisplay.setFormat(null, 24, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		curNoteDisplay.borderSize = 3;
		add(curNoteDisplay);
		curNoteDisplay.cameras = [camHUD];

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow, 1);

		var tabs = [
			{name: "1", label: 'Assets'},
			{name: "2", label: 'Animations'},
			{name: "3", label: 'Locks and Defaults'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(350, 200);
		UI_box.x = FlxG.width - UI_box.width - 20;
		UI_box.y = 20;
		add(UI_box);
		UI_box.cameras = [camHUD];

		var standardSave:FlxButton = new FlxButton(0, 0, "Save JSON", saveJSON);
		var standardLoad:FlxButton = new FlxButton(0, 0, "Load JSON", function()
			{
				camHUD.visible = false;
				openSubState(new ConfirmationPrompt("You sure?", "Be sure to save your progress. Your progress will be lost if it is left unsaved!", "Sure", "Nah", loadJSON, 
				function()
				{
					FlxG.mouse.visible = camHUD.visible = true;
				}));
			});

		standardLoad.x = UI_box.x + UI_box.width - standardLoad.width;
		standardSave.x = standardLoad.x - standardLoad.width - 10;
		standardLoad.y = standardSave.y = UI_box.y + UI_box.height + 10;

		add(standardSave);
		add(standardLoad);

		standardSave.cameras = [camHUD];
		standardLoad.cameras = [camHUD];

		generateNotes();
		updateNotes();

		addAssetsStuff();
		addAnimStuff();
		addLockStuff();

		super.create();

		createToolTips();
		tooltips.cameras = [camHUD];

		addToolTipFor(findHelperDesc(standardSave.label.text), standardSave, standardSave.label.text);
		addToolTipFor(findHelperDesc(standardLoad.label.text), standardLoad, standardLoad.label.text);

		changeNote();
	}

	function generateNotes():Void
	{
		playStrums = new FlxTypedSpriteGroup<StaticArrow>();
		add(playStrums);

		holdStrums = new FlxSpriteGroup();
		add(holdStrums);

		holdEndStrums = new FlxSpriteGroup();
		add(holdEndStrums);

		notes = new FlxSpriteGroup();
		add(notes);

		holds = new FlxSpriteGroup();
		add(holds);

		holdEnds = new FlxSpriteGroup();
		add(holdEnds);

		var theSex:FlxAtlasFrames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
		#if FILESYSTEM
		if (Settings.noteSkin != "default")
			theSex = FlxAtlasFrames.fromSparrow(options.NoteSkinSelection.loadedNoteSkins.get(Settings.noteSkin),
				File.getContent(Sys.getCwd() + "assets/skins/" + Settings.noteSkin + "/normal/NOTE_assets.xml"));
		#end

		var a:Array<String> = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"];

		for (i in 0...4)
		{
			var babyArrow:StaticArrow = new StaticArrow(0, 0);
			babyArrow.frames = theSex;
			babyArrow.x += Note.swagWidth * i;
			babyArrow.animation.addByPrefix('a', a[i]);
			babyArrow.animation.play("a");
			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			playStrums.add(babyArrow);
		}

		playStrums.screenCenter();

		var a:Array<String> = ["purple hold piece", "blue hold piece", "green hold piece", "red hold piece"];

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, 0);
			babyArrow.frames = theSex;
			babyArrow.animation.addByPrefix('a', a[i]);
			babyArrow.animation.play("a");
			babyArrow.antialiasing = true;
			babyArrow.updateHitbox();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.x = playStrums.members[i].x + (playStrums.members[i].width / 2) - (babyArrow.width / 2);
			babyArrow.y = Note.swagWidth * 1.5 + playStrums.y;
			holdStrums.add(babyArrow);
		}

		var a:Array<String> = ["pruple end hold", "blue hold end", "green hold end", "red hold end"];

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, 0);
			babyArrow.frames = theSex;
			babyArrow.animation.addByPrefix('a', a[i]);
			babyArrow.animation.play("a");
			babyArrow.antialiasing = true;
			babyArrow.updateHitbox();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.x = playStrums.members[i].x + (playStrums.members[i].width / 2) - (babyArrow.width / 2);
			babyArrow.y = Note.swagWidth * 2.5 + playStrums.y;
			holdEndStrums.add(babyArrow);
		}

		var a:Array<NoteAnimation> = [];

		if (_note.upSpriteOnly)
			a = [_note.sprites.up, _note.sprites.up, _note.sprites.up, _note.sprites.up];
		else
			a = [_note.sprites.left, _note.sprites.down, _note.sprites.up, _note.sprites.right];

		for (i in 0...4)
		{
			// create dummy ones (just in case)

			var notePiece:NotePiece = {
				prefix: "",
				flipX: false,
				flipY: false,
				frameRate: 24,
				looped: false,
				offset: [0, 0]
			}

			var holdPiece:NotePiece = {
				prefix: "",
				flipX: false,
				flipY: false,
				frameRate: 24,
				looped: false,
				offset: [0, 0]
			}

			var endPiece:NotePiece = {
				prefix: "",
				flipX: false,
				flipY: false,
				frameRate: 24,
				looped: false,
				offset: [0, 0]
			}

			if (a[i] != null)
			{
				var note = a[i].note;
				var hold = a[i].holdPiece;
				var end = a[i].holdEnd;

				if (note != null)
				{
					notePiece.prefix = note.prefix != null ? note.prefix : "";
					notePiece.flipX = note.flipX != null ? note.flipX : false;
					notePiece.flipY = note.flipY != null ? note.flipY : false;
					notePiece.frameRate = note.frameRate != null ? note.frameRate : 24;
					notePiece.looped = note.looped != null ? note.looped : false;
					notePiece.offset = note.offset != null ? note.offset : [0, 0];
				}

				if (hold != null)
				{
					holdPiece.prefix = hold.prefix != null ? hold.prefix : "";
					holdPiece.flipX = hold.flipX != null ? hold.flipX : false;
					holdPiece.flipY = hold.flipY != null ? hold.flipY : false;
					holdPiece.frameRate = hold.frameRate != null ? hold.frameRate : 24;
					holdPiece.looped = hold.looped != null ? hold.looped : false;
					holdPiece.offset = hold.offset != null ? hold.offset : [0, 0];
				}

				if (end != null)
				{
					endPiece.prefix = end.prefix != null ? end.prefix : "";
					endPiece.flipX = end.flipX != null ? end.flipX : false;
					endPiece.flipY = end.flipY != null ? end.flipY : false;
					endPiece.frameRate = end.frameRate != null ? end.frameRate : 24;
					endPiece.looped = end.looped != null ? end.looped : false;
					endPiece.offset = end.offset != null ? end.offset : [0, 0];
				}
			}

			var theFRAMES = Paths.getSparrowAtlas("styles/" + _note.assetName, "shared");

			var babyArrow:FlxSprite = new FlxSprite(0, 0);
			babyArrow.frames = theFRAMES;
			babyArrow.animation.addByPrefix('a', notePiece.prefix, notePiece.frameRate, notePiece.looped, notePiece.flipX, notePiece.flipY);
			babyArrow.animation.play("a");
			babyArrow.antialiasing = true;
			if (_note.upSpriteOnly)
				babyArrow.angle = Note.noteAngles[i];
			babyArrow.updateHitbox();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.setPosition(playStrums.members[i].x, playStrums.members[i].y);
			origOffsets[i] = [babyArrow.offset.x, babyArrow.offset.y];
			if (_note.upSpriteOnly)
				babyArrow.offset.set(babyArrow.offset.x + animOffsets[2][0], babyArrow.offset.y + animOffsets[2][1]);
			else
				babyArrow.offset.set(babyArrow.offset.x + animOffsets[i][0], babyArrow.offset.y + animOffsets[i][1]);
			notes.add(babyArrow);

			var babyArrow:FlxSprite = new FlxSprite(0, 0);
			babyArrow.frames = theFRAMES;
			babyArrow.animation.addByPrefix('a', holdPiece.prefix, holdPiece.frameRate, holdPiece.looped, holdPiece.flipX, holdPiece.flipY);
			babyArrow.animation.play("a");
			babyArrow.antialiasing = true;
			babyArrow.updateHitbox();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.setPosition(holdStrums.members[i].x, holdStrums.members[i].y);
			origHoldOffsets[i] = [babyArrow.offset.x, babyArrow.offset.y];
			if (_note.upSpriteOnly)
				babyArrow.offset.set(babyArrow.offset.x + animHoldOffsets[2][0], babyArrow.offset.y + animHoldOffsets[2][1]);
			else
				babyArrow.offset.set(babyArrow.offset.x + animHoldOffsets[i][0], babyArrow.offset.y + animHoldOffsets[i][1]);
			holds.add(babyArrow);

			var babyArrow:FlxSprite = new FlxSprite(0, 0);
			babyArrow.frames = theFRAMES;
			babyArrow.animation.addByPrefix('a', endPiece.prefix, endPiece.frameRate, endPiece.looped, endPiece.flipX, endPiece.flipY);
			babyArrow.animation.play("a");
			babyArrow.antialiasing = true;
			babyArrow.updateHitbox();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.setPosition(holdEndStrums.members[i].x, holdEndStrums.members[i].y);
			origEndsOffsets[i] = [babyArrow.offset.x, babyArrow.offset.y];
			if (_note.upSpriteOnly)
				babyArrow.offset.set(babyArrow.offset.x + animEndsOffsets[2][0], babyArrow.offset.y + animEndsOffsets[2][1]);
			else
				babyArrow.offset.set(babyArrow.offset.x + animEndsOffsets[i][0], babyArrow.offset.y + animEndsOffsets[i][1]);
			holdEnds.add(babyArrow);
		}
	}

	var ghostSwitch:FlxUICheckBox;
	var aaSwitch:FlxUICheckBox;
	var upSwitch:FlxUICheckBox;
	var ghostTint:InputTextFix;
	var noteTint:InputTextFix;

	function addAssetsStuff():Void
	{
		var nameTitle = new FlxText(10, 10, "Name");
		var nameInput = new InputTextFix(10, nameTitle.height + 10, Std.int(UI_box.width - 20), _note.name);
		nameInput.callback = function(_, _)
		{
			_note.name = nameInput.text.trim();
		}

		var assetPathTitle = new FlxText(10, nameInput.y + nameInput.height + 10, "Asset Path");
		var assetPathInput = new InputTextFix(10, assetPathTitle.y + assetPathTitle.height, Std.int(UI_box.width - 20), _note.assetName);
		assetPathInput.callback = function(_, _)
		{
			_note.assetName = assetPathInput.text.trim();

			var path = Paths.getPath('shared/images/styles/' + _note.assetName + '.png', IMAGE, null);
			if (Paths.exists(path))
			{
				var funnyFrames = Paths.getSparrowAtlas("styles/" + _note.assetName, "shared");

				for (sprite in notes)
					sprite.frames = funnyFrames;

				for (sprite in holds)
					sprite.frames = funnyFrames;

				for (sprite in holdEnds)
					sprite.frames = funnyFrames;

				updateNotes();
			}
		}

		ghostSwitch = new FlxUICheckBox(10, assetPathInput.y + assetPathInput.height + 10, null, null, "Show Ghost?", function()
		{
			if (ghostSwitch.checked)
			{
				playStrums.alpha = 0.5;
				notes.alpha = 0.5;

				holdStrums.alpha = 0.5;
				holds.alpha = 0.5;

				holdEndStrums.alpha = 0.5;
				holdEnds.alpha = 0.5;
			}
			else
			{
				playStrums.alpha = 1;
				notes.alpha = 1;

				holdStrums.alpha = 1;
				holds.alpha = 1;

				holdEndStrums.alpha = 1;
				holdEnds.alpha = 1;
			}

			ghostTint.callback("", "");
			noteTint.callback("", "");
		});

		aaSwitch = new FlxUICheckBox(ghostSwitch.x + ghostSwitch.width, ghostSwitch.y, null, null, "Don't Smoothen (in editor)", function()
		{
			for (arrow in playStrums.members)
				arrow.antialiasing = !aaSwitch.checked;

			for (arrow in notes.members)
				arrow.antialiasing = !aaSwitch.checked;
		});

		var ghostTintLabel = new FlxText(10, ghostSwitch.y + ghostSwitch.height + 5, "Ghost Tint");
		ghostTint = new InputTextFix(10, ghostTintLabel.y + ghostTintLabel.height, Std.int(ghostTintLabel.width), "ff0000");
		ghostTint.callback = function(_, _)
		{
			if (ghostSwitch.checked)
				playStrums.color = FlxColor.fromString("#" + ghostTint.text.trim());
			else
				playStrums.color = 0xffffffff;
		}

		var noteTintLabel = new FlxText(10, ghostTint.y + ghostTint.height + 5, "Note Tint");
		noteTint = new InputTextFix(10, noteTintLabel.y + noteTintLabel.height, Std.int(noteTintLabel.width), "0000ff");
		noteTint.callback = function(_, _)
		{
			if (ghostSwitch.checked)
				notes.color = FlxColor.fromString("#" + noteTint.text.trim());
			else
				notes.color = 0xffffffff;
		}

		ghostSwitch.callback();

		upSwitch = new FlxUICheckBox(aaSwitch.x, aaSwitch.y + aaSwitch.height + 10, null, null, "Note only has an UP sprite?", function()
		{
			_note.upSpriteOnly = upSwitch.checked;

			updateNotes();
			changeNote();
		});
		upSwitch.checked = _note.upSpriteOnly;

		var unblandTitle = new FlxText(upSwitch.x, upSwitch.y + upSwitch.height + 5, "Fix what");
		var unblandDropdown = new DropdownMenuFix(upSwitch.x, unblandTitle.y + unblandTitle.height, DropdownMenuFix.makeStrIdLabelArray(["none", "color", "direction", "both"]));
		unblandDropdown.callback = function(_) {
			if (unblandDropdown.selectedLabel == 'none')
				_note.unblandWhat = null;
			else
				_note.unblandWhat = unblandDropdown.selectedLabel;

			for (note in notes.members)
				unblandNote(note, notes.members.indexOf(note), false);
			for (note in holds.members)
				unblandNote(note, holds.members.indexOf(note), true);
			for (note in holdEnds.members)
				unblandNote(note, holdEnds.members.indexOf(note), true);
		}

		unblandDropdown.selectedLabel = _note.unblandWhat != null ? _note.unblandWhat : 'none';
		unblandDropdown.callback("");

		var tab = new FlxUI(null, UI_box);
		tab.name = "1";
		tab.add(nameTitle);
		tab.add(nameInput);
		tab.add(assetPathTitle);
		tab.add(assetPathInput);
		tab.add(ghostSwitch);
		tab.add(aaSwitch);
		tab.add(ghostTintLabel);
		tab.add(ghostTint);
		tab.add(noteTintLabel);
		tab.add(noteTint);
		tab.add(upSwitch);
		tab.add(unblandTitle);
		tab.add(unblandDropdown);
		UI_box.addGroup(tab);
	}

	function unblandNote(note:FlxSprite, noteData:Int, ?isSustainNote:Bool = false)
	{
		switch (_note.unblandWhat.toLowerCase())
		{
			case 'color':
				note.color = Note.noteColors[noteData];
			case 'direction':
				if (!isSustainNote)
					note.angle = Note.noteAngles[noteData];
			case 'both':
				note.color = Note.noteColors[noteData];
				if (!isSustainNote)
					note.angle = Note.noteAngles[noteData];
			default:
				note.color = FlxColor.WHITE;

				if (_note.upSpriteOnly)
				{
					if (!isSustainNote)
						note.angle = Note.noteAngles[noteData];
					else
						note.angle = 0;
				}
				else
					note.angle = 0;
		}
	} 

	function updateNotes():Void
	{
		var a = [];

		if (_note.upSpriteOnly)
			a = [_note.sprites.up, _note.sprites.up, _note.sprites.up, _note.sprites.up];
		else
			a = [_note.sprites.left, _note.sprites.down, _note.sprites.up, _note.sprites.right];

		for (sprite in notes)
		{
			var i = notes.members.indexOf(sprite);

			// create dummy ones (just in case)

			var notePiece:NotePiece = {
				prefix: "",
				flipX: false,
				flipY: false,
				frameRate: 24,
				looped: false,
				offset: [0, 0]
			}

			var holdPiece:NotePiece = {
				prefix: "",
				flipX: false,
				flipY: false,
				frameRate: 24,
				looped: false,
				offset: [0, 0]
			}

			var endPiece:NotePiece = {
				prefix: "",
				flipX: false,
				flipY: false,
				frameRate: 24,
				looped: false,
				offset: [0, 0]
			}

			if (a[i] != null)
			{
				var note = a[i].note;
				var hold = a[i].holdPiece;
				var end = a[i].holdEnd;

				if (note != null)
				{
					notePiece.prefix = note.prefix != null ? note.prefix : "";
					notePiece.flipX = note.flipX != null ? note.flipX : false;
					notePiece.flipY = note.flipY != null ? note.flipY : false;
					notePiece.frameRate = note.frameRate != null ? note.frameRate : 24;
					notePiece.looped = note.looped != null ? note.looped : false;
					notePiece.offset = note.offset != null ? note.offset : [0, 0];
				}

				if (hold != null)
				{
					holdPiece.prefix = hold.prefix != null ? hold.prefix : "";
					holdPiece.flipX = hold.flipX != null ? hold.flipX : false;
					holdPiece.flipY = hold.flipY != null ? hold.flipY : false;
					holdPiece.frameRate = hold.frameRate != null ? hold.frameRate : 24;
					holdPiece.looped = hold.looped != null ? hold.looped : false;
					holdPiece.offset = hold.offset != null ? hold.offset : [0, 0];
				}

				if (end != null)
				{
					endPiece.prefix = end.prefix != null ? end.prefix : "";
					endPiece.flipX = end.flipX != null ? end.flipX : false;
					endPiece.flipY = end.flipY != null ? end.flipY : false;
					endPiece.frameRate = end.frameRate != null ? end.frameRate : 24;
					endPiece.looped = end.looped != null ? end.looped : false;
					endPiece.offset = end.offset != null ? end.offset : [0, 0];
				}
			}

			if (_note.upSpriteOnly)
				sprite.angle = Note.noteAngles[i];
			else
				sprite.angle = 0;
			sprite.animation.addByPrefix('a', notePiece.prefix, notePiece.frameRate, notePiece.looped, notePiece.flipX, notePiece.flipY);
			sprite.animation.play("a");
			sprite.updateHitbox();

			var hold = holds.members[i];
			hold.animation.addByPrefix('a', holdPiece.prefix, holdPiece.frameRate, holdPiece.looped, holdPiece.flipX, holdPiece.flipY);
			hold.animation.play("a");
			hold.updateHitbox();

			var end = holdEnds.members[i];
			end.animation.addByPrefix('a', endPiece.prefix, endPiece.frameRate, endPiece.looped, endPiece.flipX, endPiece.flipY);
			end.animation.play("a");
			end.updateHitbox();

			animOffsets[i][0] = notePiece.offset[0];
			animOffsets[i][1] = notePiece.offset[1];

			animHoldOffsets[i][0] = holdPiece.offset[0];
			animHoldOffsets[i][1] = holdPiece.offset[1];

			animEndsOffsets[i][0] = endPiece.offset[0];
			animEndsOffsets[i][1] = endPiece.offset[1];
		}
	}

	var fucking:Array<String> = [
		"left",
		"down",
		"up",
		"right",
		"left hold piece",
		"down hold piece",
		"up hold piece",
		"right hold piece",
		"left hold end",
		"down hold end",
		"up hold end",
		"right hold end",
	];

	var animationsDropdown:DropdownMenuFix;
	var frameRateInput:InputTextFix;
	var prefixInput:InputTextFix;
	var isAnimLooped:FlxUICheckBox;
	var isFlipX:FlxUICheckBox;
	var isFlipY:FlxUICheckBox;

	function addAnimStuff():Void
	{
		var animationsLabel = new FlxText(10, 10, "Animations");
		animationsDropdown = new DropdownMenuFix(10, animationsLabel.y + animationsLabel.height, DropdownMenuFix.makeStrIdLabelArray(fucking), selectPiece);

		var prefixTitle = new FlxText(10, 50, 0, ".XML Prefix");
		prefixInput = new InputTextFix(10, prefixTitle.y + prefixTitle.height, 255);

		var fpsTitle = new FlxText(prefixInput.width + 20, prefixTitle.y, 0, "FPS");
		frameRateInput = new InputTextFix(prefixInput.width + 20, prefixInput.y, 65);
		frameRateInput.filterMode = FlxInputText.ONLY_NUMERIC;

		isAnimLooped = new FlxUICheckBox(10, 90, null, null, "Is Animation Looped?", 75);

		isFlipX = new FlxUICheckBox(60, 90, null, null, "Should Animation be X-Flipped?", 75);

		isFlipY = new FlxUICheckBox(110, 90, null, null, "Should Animation be Y-Flipped?", 75);

		isFlipX.x = 10;
		isFlipY.x = (UI_box.width / 2) - (isFlipX.width / 2);
		isAnimLooped.x = UI_box.width - isAnimLooped.width - 10;

		var deleteAnimation = new FlxButton(0, 0, "Delete Anim", function() {
			var a:Array<NotePiece> = longFuckingArray();
			var i = fucking.indexOf(animationsDropdown.selectedLabel);

			a[i].prefix = null;
			a[i].frameRate = null;
			a[i].looped = null;
			a[i].flipX = null;
			a[i].flipY = null;
			a[i].offset = null;

			updateNotes();
		});

		// hi psych
		deleteAnimation.color = FlxColor.RED;
		deleteAnimation.label.color = FlxColor.WHITE;
		deleteAnimation.x = UI_box.width - deleteAnimation.width - 10;
		deleteAnimation.y = 10;

		var addButton = new FlxButton(deleteAnimation.x, 0, "Update", function() {
			var a:Array<NotePiece> = longFuckingArray();
			var i = fucking.indexOf(animationsDropdown.selectedLabel);

			
			a[i].prefix = prefixInput.text.trim();
			a[i].frameRate = Std.parseInt(frameRateInput.text.trim());
			a[i].looped = isAnimLooped.checked;
			a[i].flipX = isFlipX.checked;
			a[i].flipY = isFlipY.checked;
			a[i].offset = a[i].offset != null ? a[i].offset : [0, 0];

			updateNotes();
		});

		addButton.y = UI_box.height - (addButton.height * 1.5) - 20;


		var tab = new FlxUI(null, UI_box);
		tab.name = "2";
		tab.add(animationsLabel);
		tab.add(prefixTitle);
		tab.add(prefixInput);
		tab.add(fpsTitle);
		tab.add(frameRateInput);
		tab.add(isFlipX);
		tab.add(isFlipY);
		tab.add(isAnimLooped);
		tab.add(animationsDropdown);
		tab.add(deleteAnimation);
		tab.add(addButton);
		UI_box.addGroup(tab);
	}

	function selectPiece(_):Void
	{
		var a:Array<NotePiece> = longFuckingArray();
		var i = fucking.indexOf(animationsDropdown.selectedLabel);

		prefixInput.text = a[i].prefix != null ? a[i].prefix : "";
		frameRateInput.text = a[i].frameRate != null ? a[i].frameRate + "" : "24";
		isAnimLooped.checked = a[i].looped != null ? a[i].looped : false;
		isFlipX.checked = a[i].flipX != null ? a[i].flipX : false;
		isFlipY.checked = a[i].flipY != null ? a[i].flipY : false;
	}

	var noNoteSplash:FlxUICheckBox;
	var canScore:FlxUICheckBox;
	var canMiss:FlxUICheckBox;
	var noHolds:FlxUICheckBox;

	var angleLock:FlxUICheckBox;
	var alphaLock:FlxUICheckBox;
	var visibleLock:FlxUICheckBox;
	var scaleLockX:FlxUICheckBox;
	var scaleLockY:FlxUICheckBox;
	var positionLockX:FlxUICheckBox;
	var positionLockY:FlxUICheckBox;

	function addLockStuff():Void
	{
		var width:Int = 85;

		noNoteSplash = new FlxUICheckBox(10, 10, null, null, "No Note Splashes when hit", width);
		noNoteSplash.checked = _note.noNoteSplash != null ? _note.noNoteSplash : false;
		noNoteSplash.callback = function() {
			_note.noNoteSplash = noNoteSplash.checked;
		}

		canScore = new FlxUICheckBox(10, noNoteSplash.y + noNoteSplash.height + 10, null, null, "Can Score by default?", width);
		canScore.checked = _note.canScore != null ? _note.canScore : true;
		canScore.callback = function() {
			_note.canScore = canScore.checked;
		}

		canMiss = new FlxUICheckBox(10, canScore.y + canScore.height + 10, null, null, "Can Miss by default?", width);
		canMiss.checked = _note.canMiss != null ? _note.canMiss : false;
		canMiss.callback = function() {
			_note.canMiss = canMiss.checked;
		}

		noHolds = new FlxUICheckBox(10, canMiss.y + canMiss.height + 10, null, null, "No Holds?", width);
		noHolds.checked = _note.noHolds != null ? _note.noHolds : false;
		noHolds.callback = function() {
			_note.noHolds = noHolds.checked;
			changeNote();
		}

		var newX:Float = noNoteSplash.x + noNoteSplash.width + 10;
		angleLock = new FlxUICheckBox(newX, 10, null, null, "Angle Locked by default?", width);
		angleLock.checked = _note.angleLock != null ? _note.angleLock : true;
		angleLock.callback = function() {
			_note.angleLock = angleLock.checked;
		}

		alphaLock = new FlxUICheckBox(newX, angleLock.y + angleLock.height + 10, null, null, "Alpha Locked by default?", width);
		alphaLock.checked = _note.alphaLock != null ? _note.alphaLock : true;
		alphaLock.callback = function() {
			_note.alphaLock = alphaLock.checked;
		}

		visibleLock = new FlxUICheckBox(newX, alphaLock.y + alphaLock.height + 10, null, null, "Visibility Locked by default?", width);
		visibleLock.checked = _note.visibleLock != null ? _note.visibleLock : true;
		visibleLock.callback = function() {
			_note.visibleLock = visibleLock.checked;
		}

		newX = angleLock.x + angleLock.width + 10;
		scaleLockX = new FlxUICheckBox(newX, 10, null, null, "X-Scale Locked by default?", width);
		scaleLockX.checked = _note.scaleLockX != null ? _note.scaleLockX : true;
		scaleLockX.callback = function() {
			_note.scaleLockX = scaleLockX.checked;
		}

		scaleLockY = new FlxUICheckBox(newX, scaleLockX.y + scaleLockX.height + 20, null, null, "Y-Scale Locked by default?", width);
		scaleLockY.checked = _note.scaleLockY != null ? _note.scaleLockY : true;
		scaleLockY.callback = function() {
			_note.scaleLockY = scaleLockY.checked;
		}

		positionLockX = new FlxUICheckBox(newX, scaleLockY.y + scaleLockY.height + 20, null, null, "X-Position Locked by default?", width);
		positionLockX.checked = _note.positionLockX != null ? _note.positionLockX : true;
		positionLockX.callback = function() {
			_note.positionLockX = positionLockX.checked;
		}

		positionLockY = new FlxUICheckBox(newX, positionLockX.y + positionLockX.height + 20, null, null, "Y-Position Locked by default?", width);
		positionLockY.checked = _note.positionLockY != null ? _note.positionLockY : true;
		positionLockY.callback = function() {
			_note.positionLockY = positionLockY.checked;
		}

		noNoteSplash.callback();
		canScore.callback();
		canMiss.callback();
		noHolds.callback();
		angleLock.callback();
		alphaLock.callback();
		visibleLock.callback();
		scaleLockX.callback();
		scaleLockY.callback();
		positionLockX.callback();
		positionLockY.callback();

		var scrollTitle = new FlxText(noNoteSplash.x + noNoteSplash.width + 10, visibleLock.y + visibleLock.height + 5, "Default Scroll\nMultiplier");
		var scrollStepper = new NumStepperFix(scrollTitle.x, scrollTitle.y + scrollTitle.height, 0.1, 1, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 3);
		scrollStepper.value = _note.scrollMultiplier != null ? _note.scrollMultiplier : 1;
		scrollStepper.callback = function(_) {
			_note.scrollMultiplier = scrollStepper.value;
		}

		if (_note.offsetMultiplier == null)
			_note.offsetMultiplier = [1, 1];

		var sfmTitle = new FlxText(10, noHolds.y + noHolds.height + 25, "Safe Zone Offset Multiplier\n(early and late, respectively)");
		var earlyStepper = new NumStepperFix(10, sfmTitle.y + sfmTitle.height, 0.1, 1, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 3);
		earlyStepper.value = _note.offsetMultiplier[0] != null ? _note.offsetMultiplier[0] : 1;
		earlyStepper.callback = function(_) {
			_note.offsetMultiplier[0] = earlyStepper.value;
		}
		var lateStepper = new NumStepperFix(earlyStepper.x + earlyStepper.width + 20, sfmTitle.y + sfmTitle.height, 0.1, 1, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 3);
		lateStepper.value = _note.offsetMultiplier[1] != null ? _note.offsetMultiplier[1] : 1;
		lateStepper.callback = function(_) {
			_note.offsetMultiplier[1] = lateStepper.value;
		}

		var tab = new FlxUI(null, UI_box);
		tab.name = "3";
		tab.add(noNoteSplash);
		tab.add(canScore);
		tab.add(canMiss);
		tab.add(noHolds);
		tab.add(angleLock);
		tab.add(alphaLock);
		tab.add(visibleLock);
		tab.add(scaleLockX);
		tab.add(scaleLockY);
		tab.add(positionLockX);
		tab.add(positionLockY);
		tab.add(scrollTitle);
		tab.add(scrollStepper);
		tab.add(sfmTitle);
		tab.add(earlyStepper);
		tab.add(lateStepper);
		UI_box.addGroup(tab);
	}

	function longFuckingArray():Array<NotePiece>
	{
		var a:Array<NotePiece> = [];

		if (_note.upSpriteOnly)
		{
			_note.sprites.left = null;
			_note.sprites.down = null;
			if (_note.sprites.up == null)
				_note.sprites.up = {
					note: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdPiece: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdEnd: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					}
				}
			_note.sprites.right = null;

			a = [
				_note.sprites.up.note,
				_note.sprites.up.note,
				_note.sprites.up.note,
				_note.sprites.up.note,
				_note.sprites.up.holdPiece,
				_note.sprites.up.holdPiece,
				_note.sprites.up.holdPiece,
				_note.sprites.up.holdPiece,
				_note.sprites.up.holdEnd,
				_note.sprites.up.holdEnd,
				_note.sprites.up.holdEnd,
				_note.sprites.up.holdEnd,
			];
		}
		else
		{
			if (_note.sprites.left == null)
				_note.sprites.left = {
					note: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdPiece: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdEnd: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					}
				}

			if (_note.sprites.down == null)
				_note.sprites.down = {
					note: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdPiece: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdEnd: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					}
				}

			if (_note.sprites.up == null)
				_note.sprites.up = {
					note: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdPiece: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdEnd: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					}
				}

			if (_note.sprites.right == null)
				_note.sprites.right = {
					note: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdPiece: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					},
					holdEnd: {
						prefix: "",
						flipX: false,
						flipY: false,
						frameRate: 24,
						looped: false,
						offset: [0, 0]
					}
				}

			a = [
				_note.sprites.left.note,
				_note.sprites.down.note,
				_note.sprites.up.note,
				_note.sprites.right.note,
				_note.sprites.left.holdPiece,
				_note.sprites.down.holdPiece,
				_note.sprites.up.holdPiece,
				_note.sprites.right.holdPiece,
				_note.sprites.left.holdEnd,
				_note.sprites.down.holdEnd,
				_note.sprites.up.holdEnd,
				_note.sprites.right.holdEnd,
			];
		}

		return a;
	}

	function changeNote(?huh:Int = 0):Void
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curNote += huh;

		if (!_note.upSpriteOnly)
		{
			if (!_note.noHolds)
			{
				if (curNote < 0)
					curNote = 11;
		
				if (curNote > 11)
					curNote = 0;
			}
			else
			{
				if (curNote < 0)
					curNote = 3;
		
				if (curNote > 3)
					curNote = 0;
			}
		}
		else
		{
			if (!_note.noHolds)
			{
				if (curNote < 2)
					curNote = 10;
	
				if (curNote > 10)
					curNote = 2;
			}
			else
				curNote = 2;
		}
	}

	var speed:Float = 180;
	var multiplier:Float = 1; // makin this global
	var pastCameraPos:Array<Float> = []; // right click movement
	var pastCharacterPos:Array<Float> = []; // left click movement
	var mousePastPos:Array<Float> = [];

	var broken:String = "";
	var backing:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		holds.visible = holdEnds.visible = !_note.noHolds;
		holdStrums.visible = holdEndStrums.visible = !_note.noHolds;

		for (sprite in notes.members)
		{
			var a = longFuckingArray();
			var i = notes.members.indexOf(sprite);

			if (_note.upSpriteOnly)
			{
				sprite.offset.set(origOffsets[i][0] + animOffsets[2][0], origOffsets[i][1] + animOffsets[2][1]);

				if (a[i] != null)
					a[i].offset = animOffsets[2];
			}
			else
			{
				sprite.offset.set(origOffsets[i][0] + animOffsets[i][0], origOffsets[i][1] + animOffsets[i][1]);

				if (a[i] != null)
					a[i].offset = animOffsets[i];
			}
		}

		for (sprite in holds.members)
		{
			var a = longFuckingArray();
			var i = holds.members.indexOf(sprite);

			if (_note.upSpriteOnly)
			{
				sprite.offset.set(origHoldOffsets[i][0] + animHoldOffsets[2][0], origHoldOffsets[i][1] + animHoldOffsets[2][1]);

				if (a[i + 4] != null)
					a[i + 4].offset = animHoldOffsets[2];
			}
			else
			{
				sprite.offset.set(origHoldOffsets[i][0] + animHoldOffsets[i][0], origHoldOffsets[i][1] + animHoldOffsets[i][1]);

				if (a[i + 4] != null)
					a[i + 4].offset = animHoldOffsets[i];
			}
		}

		for (sprite in holdEnds.members)
		{
			var a = longFuckingArray();
			var i = holdEnds.members.indexOf(sprite);

			if (_note.upSpriteOnly)
			{
				sprite.offset.set(origEndsOffsets[i][0] + animEndsOffsets[2][0], origEndsOffsets[i][1] + animEndsOffsets[2][1]);

				if (a[i + 8] != null)
					a[i + 8].offset = animEndsOffsets[2];
			}
			else
			{
				sprite.offset.set(origEndsOffsets[i][0] + animEndsOffsets[i][0], origEndsOffsets[i][1] + animEndsOffsets[i][1]);

				if (a[i + 8] != null)
					a[i + 8].offset = animEndsOffsets[i];
			}
		}

		if (!InputTextFix.isTyping)
		{
			if (FlxG.keys.pressed.SHIFT)
				multiplier = 3;

			if (FlxG.keys.justPressed.E)
				FlxG.camera.zoom += 0.25;

			if (FlxG.keys.justPressed.Q)
				FlxG.camera.zoom -= 0.25;

			if (FlxG.keys.justPressed.J)
				changeNote(_note.upSpriteOnly ? 4 : 1);

			if (FlxG.keys.justPressed.L)
				changeNote(_note.upSpriteOnly ? 4 : 1);

			FlxG.camera.zoom += FlxG.mouse.wheel * 0.05 * multiplier;

			if (FlxG.camera.zoom < 1)
				FlxG.camera.zoom = 1;

			if (FlxG.mouse.pressedRight)
			{
				if (FlxG.mouse.justPressedRight)
				{
					pastCameraPos = [camFollow.x, camFollow.y];
					mousePastPos = [FlxG.mouse.getScreenPosition(camHUD).x, FlxG.mouse.getScreenPosition(camHUD).y];
				}

				camFollow.x = pastCameraPos[0] + ((mousePastPos[0] - FlxG.mouse.getScreenPosition(camHUD).x) / FlxG.camera.zoom);
				camFollow.y = pastCameraPos[1] + ((mousePastPos[1] - FlxG.mouse.getScreenPosition(camHUD).y) / FlxG.camera.zoom);
			}

			if (FlxG.keys.pressed.W)
				camFollow.velocity.y = -speed * multiplier;
			else if (FlxG.keys.pressed.S)
				camFollow.velocity.y = speed * multiplier;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.A)
				camFollow.velocity.x = -speed * multiplier;
			else if (FlxG.keys.pressed.D)
				camFollow.velocity.x = speed * multiplier;
			else
				camFollow.velocity.x = 0;

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
				CustomTransition.switchTo(new MainMenuState());
			}

			var multi = 1;
			if (FlxG.keys.pressed.SHIFT)
				multi = 10;

			curNoteDisplay.text = fucking[curNote] + (_note.upSpriteOnly ? " (note is upSpriteOnly)" : "") + broken;

			if (FlxG.keys.justPressed.UP)
			{
				if (curNote <= 3)
					animOffsets[curNote][1] += 1 * multi;

				if (curNote > 3 && curNote <= 7)
					animHoldOffsets[curNote - 4][1] += 1 * multi;

				if (curNote > 7 && curNote <= 11)
					animEndsOffsets[curNote - 8][1] += 1 * multi;
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				if (curNote <= 3)
					animOffsets[curNote][1] -= 1 * multi;

				if (curNote > 3 && curNote <= 7)
					animHoldOffsets[curNote - 4][1] -= 1 * multi;

				if (curNote > 7 && curNote <= 11)
					animEndsOffsets[curNote - 8][1] -= 1 * multi;
			}

			if (FlxG.keys.justPressed.LEFT)
			{
				if (curNote <= 3)
					animOffsets[curNote][0] += 1 * multi;

				if (curNote > 3 && curNote <= 7)
					animHoldOffsets[curNote - 4][0] += 1 * multi;

				if (curNote > 7 && curNote <= 11)
					animEndsOffsets[curNote - 8][0] += 1 * multi;
			}

			if (FlxG.keys.justPressed.RIGHT)
			{
				if (curNote <= 3)
					animOffsets[curNote][0] -= 1 * multi;

				if (curNote > 3 && curNote <= 7)
					animHoldOffsets[curNote - 4][0] -= 1 * multi;

				if (curNote > 7 && curNote <= 11)
					animEndsOffsets[curNote - 8][0] -= 1 * multi;
			}
		}
		else 
		{
			//
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

		var newNote:NoteJSON = cast Json.parse(File.getContent(path).trim());
		CustomTransition.switchTo(new NoteTypeEditor(newNote));

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
		var data:String = Json.stringify(_note, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "note.json");
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

	function findHelperDesc(title:String):Null<String>
	{
		var toReturn:Null<String> = null;

		switch (title)
		{
			case 'Asset Path':
				toReturn = "The file path of your assets (both XML and PNG)";
			case 'Show Ghost?':
				toReturn = "Show the static arrows and normal hold pieces behind the note assets to fix your offsets better.";
			case 'Ghost Tint':
				toReturn = "The color tint of the gray arrows and hold pieces";
			case 'Note Tint':
				toReturn = "The color tint of the notes that you're currently editing";
			case 'Don\'t Smoothen (in editor)':
				toReturn = "Dont smoothen the asset in editor. It's automatically smoothened in play.";
			case 'Note only has an UP sprite?':
				toReturn = "Does your note only contain an UP sprite?";
			case 'Fix what':
				toReturn = "Specify which aspect to fix in play.";
			case '.XML Prefix':
				toReturn = "The name of your object in Animate. Or the prefix you set it as in the XML generator.";
			case 'Should Animation be X-Flipped?':
				toReturn = "Should the animation be flipped horizontally (left and right)?";
			case 'Should Animation be Y-Flipped?':
				toReturn = "Should the animation be flipped vertically (up and down)?";
			case 'Is Animation Looped?':
				toReturn = "Is this animation looping?";
			case 'Update':
				toReturn = "Update the selected animation.";
			case 'Delete Anim':
				toReturn = "Lose all data in this animation.";
			case 'No Note Splashes when hit':
				toReturn = "If ticked, no notesplashes will be shown when this note is hit with a \"Sick!!\"";
			case 'Can Score by default?':
				toReturn = "Can this note give you a score when hit by default?";
			case 'Can Miss by default?':
				toReturn = "Can this note be missed? If ticked, Botplay will miss this note, and opponent won't hit this note.";
			case 'No Holds?':
				toReturn = "Removes holds. In play, if holds are in place, they won't get generated.";
			case 'Angle Locked by default?':
				toReturn = "If ticked, when in play, this note's angle will stay the same as the gray notes' angle.";
			case 'Alpha Locked by default?':
				toReturn = "If ticked, when in play, this note's transparency will stay the same as the gray notes' transparency.";
			case 'Visibility Locked by default?':
				toReturn = "If ticked, when in play, this note's visibility will stay the same as the gray notes' visibility.";
			case 'X-Scale Locked by default?':
				toReturn = "If ticked, when in play, this note's horizontal scale will stay the same as the gray notes' horizontal scale (wideness).";
			case 'Y-Scale Locked by default?':
				toReturn = "If ticked, when in play, this note's vertical scale will stay the same as the gray notes' vertical scale (wideness).";
			case 'X-Position Locked by default?':
				toReturn = "If ticked, when in play, this note's horizontal position will stay the same as the gray notes' horizontal position.";
			case 'Y-Position Locked by default?':
				toReturn = "If ticked, when in play, this note's vertical position will stay the same as the gray notes' vertical position.";
			case 'Safe Zone Offset Multiplier\n(early and late, respectively)':
				toReturn = "How tight the hit window of your note is. Lower the number, tighter to hit.";
			case 'Default Scroll\nMultiplier':
				toReturn = "How fast your note should go with a chart's scroll speed. Higher the number, faster the speed.";
			case 'Save JSON':
				toReturn = "Don't forget to save!";
			case 'Load JSON':
				toReturn = "Load a Hope Engine Note JSON file.";
		}

		return toReturn;
	}
}
