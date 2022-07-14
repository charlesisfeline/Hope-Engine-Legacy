#if FILESYSTEM
package editors;

import MenuCharacter.CharacterSetting;
import MenuCharacter.MenuCharacterJSON;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.io.File;
import ui.*;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end


class MenuCharacterEditor extends MusicBeatState
{
	public static var fromEditors:Bool = false;
	var UI_box:FlxUITabMenu;
	var yellowBox:FlxSprite;

	var currentPosition:String = 'dad';
	var fakeCharacter:FlxSprite; // hehe it's not actually a menucharacter
	var animationText:FlxText;

	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var fakeDad:MenuCharacter;
	var fakeGF:MenuCharacter;
	var fakeBF:MenuCharacter;
	
	var _char:MenuCharacterJSON = {
		character: "bf",
		animations: {
			idle: {
				prefix: "idle0",
				indices: null,
				fps: 24,
				looped: false
			},
			hey: {
				prefix: "hey0",
				indices: null,
				fps: 24,
				looped: false
			},
			danceLeft: null,
			danceRight: null
		},
		settings: {
			flipped: true,
			scale: 1
		}
	}
	
	var yellowBG:FlxSprite;

	public function new(?char:MenuCharacterJSON)
	{
		super();

		if (char != null)
			this._char = char;
	}

	var originalWidth:Float = 1.0;

	override function create() 
	{
		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end
		
		#if desktop
		DiscordClient.changePresence("Menu Character Editor");
		#end

		FlxG.mouse.visible = true;
		usesMouse = true;

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		animationText = new FlxText(0, 10, FlxG.width, "");
		animationText.setFormat("VCR OSD Mono", 32, CENTER);
		add(animationText);

		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		add(yellowBG);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		add(grpWeekCharacters);

		fakeDad = new MenuCharacter(0, 0, 0.5, false);
		fakeDad.alpha = 0.5;
		grpWeekCharacters.add(fakeDad);

		fakeBF = new MenuCharacter(0, 0, 0.5, true);
		fakeBF.alpha = 0.5;
		grpWeekCharacters.add(fakeBF);

		fakeGF = new MenuCharacter(0, 0, 0.5, true);
		fakeGF.alpha = 0.5;
		grpWeekCharacters.add(fakeGF);

		fakeCharacter = new FlxSprite();
		fakeCharacter.frames = Paths.getSparrowAtlas('menuCharacters/' + _char.character, "preload");
		fakeCharacter.antialiasing = true;
		originalWidth = fakeCharacter.width;
		fakeCharacter.setGraphicSize(Std.int(fakeCharacter.width * 0.5));
		fakeCharacter.updateHitbox();
		add(fakeCharacter);

		var tabs = [
			{name: "1", label: 'Character & Settings'}, 
			{name: "2", label: 'Animations'},
			{name: "3", label: 'Menu'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(400, 200);
		UI_box.y = FlxG.height - UI_box.height - 20;
		UI_box.screenCenter(X);
		add(UI_box);

		addCharStuff();
		addAnimStuff();
		addMenuStuff();

		var tryAsDad = new FlxButton(0, 0, "Try as Dad", function() {
			currentPosition = 'dad';
			refreshShit();
		});
		add(tryAsDad);

		var tryAsBF = new FlxButton(0, 0, "Try as BF", function() {
			currentPosition = 'bf';
			refreshShit();
		});
		add(tryAsBF);

		var tryAsGF = new FlxButton(0, 0, "Try as GF", function() {
			currentPosition = 'gf';
			refreshShit();
		});
		add(tryAsGF);

		tryAsGF.screenCenter(X);
		tryAsBF.x = tryAsGF.x + tryAsGF.width + 10;
		tryAsDad.x = tryAsGF.x - tryAsDad.width - 10;

		var fuck = yellowBG.y + yellowBG.height;
		tryAsDad.y = tryAsGF.y = tryAsBF.y = fuck + ((UI_box.y - fuck) / 2) - 10;

		refreshAnimation();
		
		if (fakeCharacter.animation.getByName("idle") != null)
			playAnimForCharacter("idle");
		else if (fakeCharacter.animation.getByName("danceLeft") != null)
			playAnimForCharacter("danceLeft");

		super.create();
	}

	function addAnimation(name:String, prefix:String, fps:Int = 24, ?indices:Array<Int>, ?looped:Bool = false)
	{
		if (indices == null)
			fakeCharacter.animation.addByPrefix(name, prefix, fps, looped);
		else
			fakeCharacter.animation.addByIndices(name, prefix, indices, "", fps, looped);
	}

	var characterName:InputTextFix;
	var flipped:FlxUICheckBox;

	function addCharStuff():Void
	{
		var characterNameLabel = new FlxText(10, 10, "Character Name");
		characterName = new InputTextFix(10, characterNameLabel.y + characterNameLabel.height, 380, _char.character);
		characterName.callback = function(a:String, b:String) {
			_char.character = characterName.text;
			
			if (Paths.exists(Paths.image("menuCharacters/" + _char.character)) || Paths.image("menuCharacters/" + _char.character) is FlxGraphic)
			{
				fakeCharacter.frames = Paths.getSparrowAtlas('menuCharacters/' + _char.character , "preload");
				fakeCharacter.setGraphicSize(Std.int(fakeCharacter.width * 0.5));
				fakeCharacter.updateHitbox();
				refreshAnimation();
				refreshShit();

				if (fakeCharacter.animation.getByName("idle") != null)
					playAnimForCharacter("idle");
				else if (fakeCharacter.animation.getByName("danceLeft") != null)
					playAnimForCharacter("danceLeft");
			}
		}

		flipped = new FlxUICheckBox(10, characterName.y + characterName.height + 10, null, null, "Flipped?");
		flipped.callback = function() {
			_char.settings.flipped = flipped.checked;
			refreshShit();
		}
		flipped.checked = _char.settings.flipped;

		var scale = new NumStepperFix(0, 0, 0.1, 1, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 2);
		scale.x = flipped.x + flipped.width + 10;
		scale.y = flipped.y;
		scale.callback = function(a:Float) {
			_char.settings.scale = scale.value;
			
			// do it like how MenuCharacter exactly does it -- by repeating it
			fakeCharacter.setGraphicSize(Std.int(originalWidth * 0.5));
			fakeCharacter.updateHitbox();

			fakeCharacter.setGraphicSize(Std.int(fakeCharacter.width * scale.value));
			fakeCharacter.updateHitbox();

			refreshShit();
		}
		scale.value = _char.settings.scale;
		scale.callback(1);

		var scaleLabel = new FlxText(scale.x + scale.width, scale.y, "Scale");

		var save = new FlxButton(0, 0, "Save Character", saveJSON);
		save.x = UI_box.width - save.width - 10;
		save.y = UI_box.height - save.height - 30;

		var load = new FlxButton(0, 0, "Load Character", loadJSON);
		load.x = save.x - load.width - 10;
		load.y = save.y;
		
		flipped.callback();

		var tab = new FlxUI(null, UI_box);
		tab.name = "1";
		tab.add(characterNameLabel);
		tab.add(characterName);
		tab.add(flipped);
		tab.add(scale);
		tab.add(scaleLabel);
		tab.add(save);
		tab.add(load);
		UI_box.addGroup(tab);
	}

	var prefix:InputTextFix;
	var animationIndices:InputTextFix;
	var frameRate:InputTextFix;
	var looped:FlxUICheckBox;

	function addAnimStuff():Void
	{
		/**
		 * It's just me repeating myself over and over again...
		 * 
		 * But fuck it, we ball
		 */
		 
		var animationsLabel = new FlxText(10, 10, "Animations");
		var animationsDropdown = new DropdownMenuFix(10, animationsLabel.y + animationsLabel.height, DropdownMenuFix.makeStrIdLabelArray(["hey", "idle", "danceLeft", "danceRight"]));
		animationsDropdown.callback = function(a:String) {
			prefix.text = "";
			animationIndices.text = "";
			frameRate.text = "";
			looped.checked = false;

			switch (animationsDropdown.selectedLabel)
			{
				case "hey":
					if (_char.animations.hey == null) return;
					
					prefix.text = _char.animations.hey.prefix;
					if (_char.animations.hey.indices != null)
						animationIndices.text = _char.animations.hey.indices.join(", ");
					frameRate.text = _char.animations.hey.fps + "";
					looped.checked = _char.animations.hey.looped;
				case "idle":
					if (_char.animations.idle == null) return;

					prefix.text = _char.animations.idle.prefix;
					if (_char.animations.idle.indices != null)
						animationIndices.text = _char.animations.idle.indices.join(", ");
					frameRate.text = _char.animations.idle.fps + "";
					looped.checked = _char.animations.idle.looped;
				case "danceLeft":
					if (_char.animations.danceLeft == null) return;

					prefix.text = _char.animations.danceLeft.prefix;
					if (_char.animations.danceLeft.indices != null)
						animationIndices.text = _char.animations.danceLeft.indices.join(", ");
					frameRate.text = _char.animations.danceLeft.fps + "";
					looped.checked = _char.animations.danceLeft.looped;
				case "danceRight":
					if (_char.animations.danceRight == null) return;

					prefix.text = _char.animations.danceRight.prefix;
					if (_char.animations.danceRight.indices != null)
						animationIndices.text = _char.animations.danceRight.indices.join(", ");
					frameRate.text = _char.animations.danceRight.fps + "";
					looped.checked = _char.animations.danceRight.looped;
			}
		}

		var deleteAnimation = new FlxButton(0, 0, "Delete Anim", function() {
			switch (animationsDropdown.selectedLabel)
			{
				case "hey":
					fakeCharacter.animation.remove("hey");
					_char.animations.hey = null;
				case "idle":
					fakeCharacter.animation.remove("idle");
					_char.animations.idle = null;
				case "danceLeft":
					fakeCharacter.animation.remove("danceLeft");
					_char.animations.danceLeft = null;
				case "danceRight":
					fakeCharacter.animation.remove("danceRight");
					_char.animations.danceRight = null;
			}

			refreshAnimation();
			animationsDropdown.callback("");
		});

		// hi psych
		deleteAnimation.color = FlxColor.RED;
		deleteAnimation.label.color = FlxColor.WHITE;
		deleteAnimation.x = UI_box.width - deleteAnimation.width - 10;
		deleteAnimation.y = 10;

		var prefixTitle = new FlxText(10, 50, 0, ".XML/.TXT Prefix");
		prefix = new InputTextFix(10, prefixTitle.y + prefixTitle.height, 200);
		prefix.callback = function(a:String, b:String) {
			switch (animationsDropdown.selectedLabel)
			{
				case "hey":
					if (_char.animations.hey == null)
						createNewAnimationFor("hey");

					_char.animations.hey.prefix = prefix.text;
				case "idle":
					if (_char.animations.idle == null)
						createNewAnimationFor("idle");
					
					_char.animations.idle.prefix = prefix.text;
				case "danceLeft":
					if (_char.animations.danceLeft == null)
						createNewAnimationFor("danceLeft");

					_char.animations.danceLeft.prefix = prefix.text;
				case "danceRight":
					if (_char.animations.danceRight == null)
						createNewAnimationFor("danceRight");
					
					_char.animations.danceRight.prefix = prefix.text;
			}
			
			refreshAnimation();
		}

		var fpsTitle = new FlxText(prefix.x + prefix.width + 10, prefixTitle.y, 0, "FPS");
		frameRate = new InputTextFix(fpsTitle.x, fpsTitle.y + fpsTitle.height, 40);
		frameRate.callback = function(a:String, b:String) {
			if (frameRate.text.length < 1) return;
			
			switch (animationsDropdown.selectedLabel)
			{
				case "hey":
					if (_char.animations.hey == null)
						createNewAnimationFor("hey");
					
					_char.animations.hey.fps = Std.parseInt(frameRate.text);
				case "idle":
					if (_char.animations.idle == null)
						createNewAnimationFor("idle");

					_char.animations.idle.fps = Std.parseInt(frameRate.text);
				case "danceLeft":
					if (_char.animations.danceLeft == null)
						createNewAnimationFor("danceLeft");

					_char.animations.danceLeft.fps = Std.parseInt(frameRate.text);
				case "danceRight":
					if (_char.animations.danceRight == null)
						createNewAnimationFor("danceRight");
					
					_char.animations.danceRight.fps = Std.parseInt(frameRate.text);
			}

			refreshAnimation();
		}

		looped = new FlxUICheckBox(frameRate.x + frameRate.width + 10, frameRate.y, null, null, "Looped Animation?");
		looped.callback = function() {
			switch (animationsDropdown.selectedLabel)
			{
				case "hey":
					if (_char.animations.hey == null)
						createNewAnimationFor("hey");
					
					_char.animations.hey.looped = looped.checked;
				case "idle":
					if (_char.animations.idle == null)
						createNewAnimationFor("idle");

					_char.animations.idle.looped = looped.checked;
				case "danceLeft":
					if (_char.animations.danceLeft == null)
						createNewAnimationFor("danceLeft");

					_char.animations.danceLeft.looped = looped.checked;
				case "danceRight":
					if (_char.animations.danceRight == null)
						createNewAnimationFor("danceRight");

					_char.animations.danceRight.looped = looped.checked;
			}

			refreshAnimation();
		}

		var indicesTitle = new FlxText(10, 80, 0, "Animation Indices (separated by commas)");
		animationIndices = new InputTextFix(10, indicesTitle.y + indicesTitle.height, Std.int(UI_box.width - 20));
		animationIndices.callback = function(a:String, b:String) {
			var indices:Null<Array<Int>> = [];
			var indicesStr:Array<String> = animationIndices.text.trim().replace(" ", "").split(",");

			if (indicesStr.length > 1)
			{
				for (i in 0...indicesStr.length)
				{
					var index:Int = Std.parseInt(indicesStr[i]);
					if (indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1)
						indices.push(index);
				}
			}
			else
				indices = null;

			switch (animationsDropdown.selectedLabel)
			{
				case "hey":
					if (_char.animations.hey == null)
						createNewAnimationFor("hey");

					_char.animations.hey.indices = indices;
				case "idle":
					if (_char.animations.idle == null)
						createNewAnimationFor("idle");

					_char.animations.idle.indices = indices;
				case "danceLeft":
					if (_char.animations.danceLeft == null)
						createNewAnimationFor("danceLeft");

					_char.animations.danceLeft.indices = indices;
				case "danceRight":
					if (_char.animations.danceRight == null)
						createNewAnimationFor("danceRight");

					_char.animations.danceRight.indices = indices;
			}

			refreshAnimation();
		}

		var playHey = new FlxButton("Play Hey", function() {
			playAnimForCharacter("hey");
		});
		
		var playIdle = new FlxButton("Play Idle", function() {
			playAnimForCharacter("idle");
		});

		var playDanceLeft = new FlxButton("Play Left Bop", function() {
			playAnimForCharacter("danceLeft");
		});

		var playDanceRight = new FlxButton("Play Right Bop", function() {
			playAnimForCharacter("danceRight");
		});

		playHey.x = playDanceLeft.x = UI_box.width / 2 - playDanceLeft.width - 5;
		playDanceLeft.y = UI_box.height - playDanceLeft.height - 30;

		playIdle.x = playDanceRight.x = UI_box.width / 2 + 5;
		playDanceRight.y = UI_box.height - playDanceRight.height - 30;
		
		playHey.y = playDanceLeft.y - playHey.height - 10;
		playIdle.y = playDanceRight.y - playIdle.height - 10;

		animationsDropdown.callback("");

		var tab = new FlxUI(null, UI_box);
		tab.name = "2";
		tab.add(animationsLabel);
		tab.add(deleteAnimation);
		tab.add(prefixTitle);
		tab.add(prefix);
		tab.add(indicesTitle);
		tab.add(animationIndices);
		tab.add(fpsTitle);
		tab.add(frameRate);
		tab.add(looped);
		tab.add(animationsDropdown);
		tab.add(playIdle);
		tab.add(playHey);
		tab.add(playDanceLeft);
		tab.add(playDanceRight);
		UI_box.addGroup(tab);
	}

	function createNewAnimationFor(anim:String):Void
	{
		switch (anim)
		{
			case 'hey':
				_char.animations.hey = {
					prefix: '',
					looped: false,
					fps: 24,
					indices: null
				}
			case 'idle':
				_char.animations.idle = {
					prefix: '',
					looped: false,
					fps: 24,
					indices: null
				}
			case 'danceLeft':
				_char.animations.danceLeft = {
					prefix: '',
					looped: false,
					fps: 24,
					indices: null
				}
			case 'danceRight':
				_char.animations.danceRight = {
					prefix: '',
					looped: false,
					fps: 24,
					indices: null
				}
		}
	}

	function addMenuStuff():Void
	{
		var dadTitle = new FlxText(10, 10, "Opponent");
		var dadInput = new InputTextFix(10, dadTitle.y + dadTitle.height, Std.int((UI_box.width / 3) - 15));
		dadInput.callback = function(a:String, b:String) {
			fakeDad.setCharacter(dadInput.text);
			refreshShit();
		}
		dadInput.text = 'dad';
		dadInput.callback("", "");

		var gfTitle =  new FlxText(10, 10, "Girlfriend");
		var gfInput = new InputTextFix(10, dadInput.y, Std.int((UI_box.width / 3) - 15));
		gfInput.x = gfTitle.x = (UI_box.width / 2) - (gfInput.width / 2);
		gfInput.callback = function(a:String, b:String) {
			fakeGF.setCharacter(gfInput.text);
			refreshShit();
		}
		gfInput.text = 'gf';
		gfInput.callback("", "");

		var bfTitle = new FlxText(10, 10, "Boyfriend");
		var bfInput = new InputTextFix(10, dadInput.y, Std.int((UI_box.width / 3) - 15));
		bfInput.x = bfTitle.x = UI_box.width - bfInput.width - 10;
		bfInput.callback = function(a:String, b:String) {
			fakeBF.setCharacter(bfInput.text);
			refreshShit();
		}
		bfInput.text = 'bf';
		bfInput.callback("", "");

		var tab = new FlxUI(null, UI_box);
		tab.name = "3";
		tab.add(dadTitle);
		tab.add(dadInput);
		tab.add(gfTitle);
		tab.add(gfInput);
		tab.add(bfTitle);
		tab.add(bfInput);
		UI_box.addGroup(tab);
	}

	function refreshShit():Void
	{
		fakeCharacter.flipX = flipped.checked != !(currentPosition == 'dad');
		fakeCharacter.updateHitbox();

		fakeDad.y = yellowBG.y + yellowBG.height - fakeDad.height - 15;
		fakeGF.y = yellowBG.y + yellowBG.height - fakeGF.height - 30;
		fakeBF.y = yellowBG.y + yellowBG.height - fakeBF.height - 15;

		fakeGF.screenCenter(X);
		fakeDad.x = fakeGF.x - fakeDad.width - 5;
		fakeBF.x = fakeGF.x + fakeGF.width + 5;

		fakeBF.visible = fakeGF.visible = fakeDad.visible = true;

		switch (currentPosition)
		{
			case 'dad':
				fakeDad.visible = false;
				fakeCharacter.x = fakeGF.x - fakeCharacter.width - 5;
				fakeCharacter.y = yellowBG.y + yellowBG.height - fakeCharacter.height - 15;
			case 'bf':
				fakeBF.visible = false;
				fakeCharacter.x = fakeGF.x + fakeGF.width + 5;
				fakeCharacter.y = yellowBG.y + yellowBG.height - fakeCharacter.height - 15;
			case 'gf':
				fakeGF.visible = false;
				fakeCharacter.screenCenter(X);
				fakeDad.x = fakeCharacter.x - fakeDad.width - 5;
				fakeBF.x = fakeCharacter.x + fakeCharacter.width + 5;
				fakeCharacter.y = yellowBG.y + yellowBG.height - fakeCharacter.height - 30;
		}
	}

	function refreshAnimation():Void
	{
		if (_char.animations.danceLeft != null)
			addAnimation("danceLeft", _char.animations.danceLeft.prefix, _char.animations.danceLeft.fps, _char.animations.danceLeft.indices,
				_char.animations.danceLeft.looped);

		if (_char.animations.danceRight != null)
			addAnimation("danceRight", _char.animations.danceRight.prefix, _char.animations.danceRight.fps, _char.animations.danceRight.indices,
				_char.animations.danceRight.looped);

		if (_char.animations.hey != null)
			addAnimation("hey", _char.animations.hey.prefix, _char.animations.hey.fps, _char.animations.hey.indices, _char.animations.hey.looped);

		if (_char.animations.idle != null)
			addAnimation("idle", _char.animations.idle.prefix, _char.animations.idle.fps, _char.animations.idle.indices, _char.animations.idle.looped);
	}

	function playAnimForCharacter(anim:String):Void
	{
		animationText.text = "Current Animation: ";
		var daAnim = fakeCharacter.animation.getByName(anim);
		if (daAnim == null || daAnim.frames.length < 1)
		{
			animationText.text += anim + " (!BROKEN!)";
			return;
		}

		animationText.text += anim;
		fakeCharacter.animation.play(anim, true);
	}

	var danced:Bool = true;
	var backing:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_BACK && !backing && !FlxG.keys.justPressed.BACKSPACE)
		{
			backing = true;
			#if FILESYSTEM
			if (fromEditors)
			{
				fromEditors = false;
				CustomTransition.switchTo(new EditorsState());
			}
			else
			#end
				CustomTransition.switchTo(new StoryMenuState());
		}

		if (FlxG.keys.pressed.CONTROL)
		{
			if (FlxG.keys.justPressed.S)
				saveJSON();
			else if (FlxG.keys.justPressed.E)
				loadJSON();
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			if (fakeCharacter.animation.getByName("idle") != null)
				playAnimForCharacter("idle");
			else if (fakeCharacter.animation.getByName("danceLeft") != null)
			{
				danced = !danced;
				playAnimForCharacter(!danced ? "danceLeft" : "danceRight");
			}

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

		CustomTransition.switchTo(new MenuCharacterEditor(cast Json.parse(File.getContent(path).trim())));
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

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
		var data:String = Json.stringify(_char, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), characterName.text + ".json");
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
#end