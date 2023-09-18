package editors;

import Character.Animation;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
<<<<<<< HEAD
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
=======
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
>>>>>>> upstream
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.app.Application;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
<<<<<<< HEAD
import ui.*;

using StringTools;

=======

using StringTools;


>>>>>>> upstream
#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
#if desktop
import Discord.DiscordClient;
#end

class CharacterEditor extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	var _file:FileReference;
	var UI_box:FlxUITabMenu;
	var EXTRAS_box:FlxUITabMenu;

	var curAnim:Int = 0;
	var dumbTexts:FlxTypedGroup<FlxText>;

	var character:Character;
	var ghostCharacter:FlxSprite;

	var camEdit:FlxCamera;
	var camHUD:FlxCamera;
	var camFollow:FlxObject;

	var isDad:Bool = false;
	var initChar:String = 'bf';

	var instructions:FlxText;
	var curAnimName:FlxText;

	var camFollowDisplay:FlxSprite;

	var gridBG:FlxSprite;

<<<<<<< HEAD
	var instructionsText:String = "Hotkeys:" 
								+ "\nCTRL + S: Save character file" 
								+ "\n\nCharacter:" 
								+ "\nArrow Keys: Change Animation Offset"
								+ "\nT: Reset Animation Offset to [0, 0]"
								+ "\nI, K: Cycle through animations"
								+ "\n\nCamera:" 
								+ "\nW, A, S, D, Right Click: Move around" 
								+ "\nQ, E, Mouse wheel: Control zoom"
								+ "\nR: Reset position and zoom" 
								+ "\n\nUI:" 
								+ "\nALT: Hide/Unhide instructions" 
								+ "\nF1: Hide/Unhide UI";
=======
	var instructionsText:String = "Hotkeys:" + "\nCTRL + S: Save character file" + "\n\nCharacter:" + "\nArrow Keys: Change offset"
		+ "\nI, K: Cycle through animations" + "\n\nCamera:" + "\nW, A, S, D, Right Click: Move around" + "\nQ, E, Mouse wheel: Control zoom"
		+ "\nR: Reset position and zoom" + "\n\nUI:" + "\nALT: Hide/Unhide instructions" + "\nF1: Hide/Unhide UI";
>>>>>>> upstream

	public function new(isDad:Bool = false, char:String = 'bf')
	{
		super();

		this.isDad = isDad;
		this.initChar = char;
	}

	override function create()
	{
		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		#if desktop
		DiscordClient.changePresence("Character Editor");
		#end

		FlxG.mouse.visible = true;
<<<<<<< HEAD
=======
		usesMouse = true;
>>>>>>> upstream

		camEdit = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camEdit);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camEdit];

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		ghostCharacter = new FlxSprite();
		ghostCharacter.antialiasing = true;
		ghostCharacter.alpha = 0.5;

		FlxG.camera.follow(camFollow);

		gridBG = FlxGridOverlay.create(20, 20, FlxG.width * 5, FlxG.height * 5);
		gridBG.scrollFactor.set();
		gridBG.screenCenter();
		add(gridBG);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		instructions = new FlxText(0, 0, 0, instructionsText, 15);
		instructions.scrollFactor.set();
		instructions.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE, 0xFF000000);
		instructions.borderSize = 2;
		add(instructions);

		curAnimName = new FlxText(0, 20, FlxG.width, "", 15);
		curAnimName.scrollFactor.set();
		curAnimName.setFormat(null, 24, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		curAnimName.borderSize = 3;

		var tabs = [
			{name: "1", label: 'Assets'},
			{name: "2", label: 'Animations'},
			{name: "3", label: 'Miscellaneous'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(350, 200);
		UI_box.x = FlxG.width - UI_box.width - 20;
		UI_box.y = 20;

		EXTRAS_box = new FlxUITabMenu(null, [{name: "charTab", label: "Character"}, {name: "ghostTab", label: "Ghost"}], true);
		EXTRAS_box.resize(350 / 1.5, 200 / 1.5);
		EXTRAS_box.y = UI_box.y + UI_box.height;
		EXTRAS_box.x = FlxG.width - EXTRAS_box.width - 20;

		add(EXTRAS_box);
		add(UI_box);

		instructions.setPosition(UI_box.x, EXTRAS_box.y + EXTRAS_box.height + 20);
		add(curAnimName);

		UI_box.cameras = [camHUD];
		dumbTexts.cameras = [camHUD];
		EXTRAS_box.cameras = [camHUD];
		curAnimName.cameras = [camHUD];
		instructions.cameras = [camHUD];

		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		camFollowDisplay = new FlxSprite().loadGraphic(pointer);
		camFollowDisplay.setGraphicSize(50, 50);
		camFollowDisplay.updateHitbox();
		camFollowDisplay.color = FlxColor.WHITE;

		add(ghostCharacter);
		loadChar(isDad, initChar);
		genBoyOffsets();
		addHealthBarStuff();
		addAssetStuff();
		addAnimStuff();
		addMiscStuff();
		addCharacterStuff();
		addGhostStuff();

		add(camFollowDisplay);

		updateCamFollowDisplay();

		super.create();

		createToolTips();

		tooltips.cameras = [camHUD];
	}

	var healthBarColor:FlxSprite;
	var iconHealthy:HealthIcon;
	var iconDeath:HealthIcon;

	function addHealthBarStuff():Void
	{
		var healthBarBG = new FlxSprite(20, FlxG.height * 0.9).makeGraphic(Std.int(FlxG.width * 0.45), 20, 0xFF000000);
		healthBarBG.alpha = 0.7;

		healthBarColor = new FlxSprite(healthBarBG.x + 4, healthBarBG.y + 4).makeGraphic(Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));

		add(healthBarBG);
		add(healthBarColor);

<<<<<<< HEAD
		iconHealthy = new HealthIcon(character.icon);
		iconHealthy.animation.curAnim.curFrame = 0;

		iconDeath = new HealthIcon(character.icon);
=======
		iconHealthy = new HealthIcon(character.curCharacter);
		iconHealthy.animation.curAnim.curFrame = 0;

		iconDeath = new HealthIcon(character.curCharacter);
>>>>>>> upstream
		iconDeath.animation.curAnim.curFrame = 1;

		iconDeath.x = healthBarBG.x + 10;
		iconHealthy.x = healthBarBG.x + iconDeath.width + 10;

		iconDeath.y = iconHealthy.y = healthBarBG.y + (healthBarBG.height / 2) - (iconDeath.height / 2);

		add(iconDeath);
		add(iconHealthy);

		healthBarBG.cameras = [camHUD];
		healthBarColor.cameras = [camHUD];
		iconDeath.cameras = [camHUD];
		iconHealthy.cameras = [camHUD];
	}

	var characterName:InputTextFix;
	var assetPath:InputTextFix;
	var scaleStepper:FlxUINumericStepper;
	var antialiasingTick:FlxUICheckBox;
	var defaultWidth:Float;

	function addAssetStuff():Void
	{
		var characterNameLabel = new FlxText(10, 10, 0, "Character Name");
		characterName = new InputTextFix(10, characterNameLabel.y + characterNameLabel.height, 150, character.curCharacter);
		characterName.callback = function(a:String, b:String)
		{
			character.curCharacter = a;
<<<<<<< HEAD

			if (character.icon == null)
			{
				iconHealthy.changeIcon(a);
				iconHealthy.animation.curAnim.curFrame = 0;
				iconDeath.changeIcon(a);
				iconDeath.animation.curAnim.curFrame = 1;	
			}
		};

		var iconTitle = new FlxText(characterName.x + characterName.width + 10, 10, 0, "Character Icon (can be blank)");
		var icon = new InputTextFix(iconTitle.x, iconTitle.y + iconTitle.height, 150, character.icon);
		icon.callback = function(_, _) {
			character.icon = icon.text.trim().length <= 0 ? null : icon.text.trim();
			iconHealthy.changeIcon(character.icon != null ? character.icon : character.curCharacter);
			iconHealthy.animation.curAnim.curFrame = 0;
			iconDeath.changeIcon(character.icon != null ? character.icon : character.curCharacter);
			iconDeath.animation.curAnim.curFrame = 1;
		}

=======
			iconHealthy.changeIcon(a);
			iconDeath.changeIcon(a);
		};

>>>>>>> upstream
		var assetPathLabel = new FlxText(10, 50, 0, "Asset Path");
		assetPath = new InputTextFix(10, assetPathLabel.y + assetPathLabel.height, 150, character.image);

		var reloadCharacter = new FlxButton(0, 0, "Reload Image", function()
		{
			character.image = assetPath.text;
			reloadCharacterImage();
		});

		reloadCharacter.x = assetPath.x + assetPath.width + 10;
		reloadCharacter.y = assetPath.y + (assetPath.height / 2) - (reloadCharacter.height / 2);

		var scaleStepperLabel = new FlxText(10, 90, 0, "Scale");
		scaleStepper = new FlxUINumericStepper(10, scaleStepperLabel.y + scaleStepperLabel.height, 0.1, character.setScale, 0, 999, 5);
		scaleStepper.name = 'scaleChanger';

		defaultWidth = character.width / character.setScale;

		antialiasingTick = new FlxUICheckBox(scaleStepper.x + scaleStepper.width + 10, scaleStepperLabel.y + scaleStepperLabel.height, null, null,
			"Smoothen?");
		antialiasingTick.checked = character.antialiasing;
		antialiasingTick.callback = function()
		{
			character.antialiasing = antialiasingTick.checked;
		};

		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "1";
		tab_group_assets.add(characterNameLabel);
		tab_group_assets.add(characterName);
<<<<<<< HEAD
		tab_group_assets.add(iconTitle);
		tab_group_assets.add(icon);
=======
>>>>>>> upstream
		tab_group_assets.add(assetPathLabel);
		tab_group_assets.add(assetPath);
		tab_group_assets.add(scaleStepperLabel);
		tab_group_assets.add(scaleStepper);
		tab_group_assets.add(antialiasingTick);
		tab_group_assets.add(reloadCharacter);

		UI_box.addGroup(tab_group_assets);
		UI_box.scrollFactor.set();
	}

	var animationName:InputTextFix;
<<<<<<< HEAD
	var animationDropdown:DropdownMenuFix;
=======
	var animationDropdown:FlxUIDropDownMenu;
>>>>>>> upstream
	var animationIndices:InputTextFix;
	var frameRate:InputTextFix;
	var prefix:InputTextFix;
	var postfix:InputTextFix;
	var isAnimLooped:FlxUICheckBox;
	var isFlipX:FlxUICheckBox;
	var isFlipY:FlxUICheckBox;

	function addAnimStuff():Void
	{
		var holypiss = [];
		for (anim in character.animationsArray)
			holypiss.push(anim.name);

		if (holypiss.length < 1)
			holypiss.push('NO ANIMATIONS');
		var availableAnimations = new FlxText(10, 10, 0, "Available Animations");
<<<<<<< HEAD
		animationDropdown = new DropdownMenuFix(10, availableAnimations.y + availableAnimations.height,
			DropdownMenuFix.makeStrIdLabelArray(holypiss, true), function(a:String)
=======
		animationDropdown = new FlxUIDropDownMenu(10, availableAnimations.y + availableAnimations.height,
			FlxUIDropDownMenu.makeStrIdLabelArray(holypiss, true), function(a:String)
>>>>>>> upstream
		{
			animationName.text = animationDropdown.selectedLabel;

			for (anim in character.animationsArray)
			{
				if (animationName.text == anim.name)
				{
					if (anim.indices != null)
						animationIndices.text = anim.indices.join(", ");

					if (anim.prefix != null)
						prefix.text = anim.prefix;

					if (anim.frameRate != null)
						frameRate.text = anim.frameRate + '';

					if (anim.loopedAnim != null)
						isAnimLooped.checked = anim.loopedAnim;

					if (anim.flipX != null)
						isFlipX.checked = anim.flipX;
					else
						isFlipX.checked = false;

					if (anim.flipY != null)
						isFlipY.checked = anim.flipY;
					else
						isFlipY.checked = false;

					break;
				}
			}
		});

		var animNameTitle = new FlxText(10, 50, 0, "Animation Name");
		animationName = new InputTextFix(10, animNameTitle.y + animNameTitle.height, Std.int(animationDropdown.width));

		var prefixTitle = new FlxText(animationName.width + 20, 50, 0, ".XML/.TXT Prefix");
		prefix = new InputTextFix(animationName.width + 20, animNameTitle.y + animNameTitle.height, 197);

		var indicesTitle = new FlxText(10, 80, 0, "Animation Indices");
		animationIndices = new InputTextFix(10, indicesTitle.y + indicesTitle.height, 200);

		var fpsTitle = new FlxText(animationIndices.width + 20, 80, 0, "FPS");
		frameRate = new InputTextFix(animationIndices.width + 20, indicesTitle.y + indicesTitle.height, Std.int((animationDropdown.width / 2) - 10));
<<<<<<< HEAD
		frameRate.filterMode = FlxInputText.ONLY_NUMERIC;
=======
>>>>>>> upstream

		var postfixTitle = new FlxText(animationIndices.width + frameRate.width + 30, 80, 0, "Postfix");
		postfix = new InputTextFix(animationIndices.width
			+ frameRate.width
			+ 30, indicesTitle.y
			+ indicesTitle.height,
			Std.int((animationDropdown.width / 2))
			- 3);

		isAnimLooped = new FlxUICheckBox(10, 115, null, null, "Is Animation Looped?", 75);
		isFlipX = new FlxUICheckBox(60, 115, null, null, "Should Animation be X-Flipped?", 75);
		isFlipY = new FlxUICheckBox(110, 115, null, null, "Should Animation be Y-Flipped?", 75);

		isFlipX.x = (UI_box.width / 2) - (isFlipX.width / 2);
		isFlipY.x = UI_box.width - isFlipY.width - 10;

		var reloadAnimations = new FlxButton(0, 10, "Reload Anims", function()
		{
			character.reloadAnimations();

			var piss = [];
			for (anim in character.animationsArray)
				piss.push(anim.name);

			if (piss.length < 1)
				piss.push('NO ANIMATIONS');

			piss.sort(function(a:String, b:String):Int
			{
				a = a.toUpperCase();
				b = b.toUpperCase();

				if (a < b)
					return -1;
				else if (a > b)
					return 1;
				else
					return 0;
			});

<<<<<<< HEAD
			animationDropdown.setData(DropdownMenuFix.makeStrIdLabelArray(piss, true));
=======
			animationDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(piss, true));
>>>>>>> upstream
		});

		reloadAnimations.x = UI_box.width - reloadAnimations.width - 10;

		var addUpdateButton = new FlxButton(0, 0, "Add/Update", function()
		{
<<<<<<< HEAD
			if (animationName.text.trim() == "NO ANIMATIONS")
			{
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
				return;
			}

=======
>>>>>>> upstream
			var indices:Array<Int> = [];
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

<<<<<<< HEAD
			if (character.animation.curAnim != null && character.animationsArray.length > 0)
			{
				if (character.animation.curAnim.numFrames > 0)
=======
			if (character.animation.curAnim != null)
			{
				if (character.animation.curAnim.frames.length > 0)
>>>>>>> upstream
				{
					if (animationName.text == character.animation.curAnim.name)
						character.animation.stop();
				}
			}

			var lastAnim:String = '';
			var isUpdating = false;
			if (character.animationsArray[curAnim] != null)
				lastAnim = character.animationsArray[curAnim].name;

<<<<<<< HEAD
			var lastOffsets:Array<Float> = [0, 0];
=======
			var lastOffsets:Array<Int> = [0, 0];
>>>>>>> upstream
			for (anim in character.animationsArray)
			{
				if (animationName.text == anim.name)
				{
					lastOffsets = anim.offset;

					if (character.animation.getByName(animationName.text) != null)
						character.animation.remove(animationName.text);

					isUpdating = true;
					character.animationsArray.remove(anim);
				}
			}

			var newAnim:Animation = {
				name: animationName.text + '',
				prefix: prefix.text + '',
				frameRate: Std.parseInt(frameRate.text),
				loopedAnim: isAnimLooped.checked,
				offset: lastOffsets,
				indices: indices,
				postfix: postfix.text + '',
				flipX: isFlipX.checked,
				flipY: isFlipY.checked
			};

			if (newAnim.indices != null && newAnim.indices.length > 0)
				character.animation.addByIndices(newAnim.name, newAnim.prefix, newAnim.indices, newAnim.postfix, newAnim.frameRate, newAnim.loopedAnim,
					newAnim.flipX, newAnim.flipY);
			else
				character.animation.addByPrefix(newAnim.name, newAnim.prefix, newAnim.frameRate, newAnim.loopedAnim, newAnim.flipX, newAnim.flipY);

			if (!character.animOffsets.exists(newAnim.name))
				character.addOffset(newAnim.name, 0, 0);

			character.animationsArray.push(newAnim);

			if (isUpdating)
				character.playAnim(animationName.text);

			reloadAnimationDropdown();
			genBoyOffsets();

			ghostCharacter.animation = ghostCharacter.animation.copyFrom(character.animation);
		});

		var removeAnimButton = new FlxButton(0, 0, "Remove", function()
		{
			for (anim in character.animationsArray)
			{
				if (animationName.text == anim.name)
				{
					var resetAnim:Bool = (character.animation.curAnim != null && anim.name == character.animation.curAnim.name);

<<<<<<< HEAD
					character.animation.stop();

=======
>>>>>>> upstream
					if (character.animation.getByName(anim.name) != null)
						character.animation.remove(anim.name);

					if (character.animOffsets.exists(anim.name))
						character.animOffsets.remove(anim.name);

					character.animationsArray.remove(anim);

					if (resetAnim && character.animationsArray.length > 0)
						character.playAnim(character.animationsArray[0].name, true);
<<<<<<< HEAD
						
=======
>>>>>>> upstream

					reloadAnimationDropdown();
					genBoyOffsets();

					ghostCharacter.animation = ghostCharacter.animation.copyFrom(character.animation);
					break;
				}
			}
		});

		addUpdateButton.x = UI_box.width / 2 - addUpdateButton.width - 10;
		addUpdateButton.y = UI_box.height - addUpdateButton.height - 30;

		removeAnimButton.x = UI_box.width / 2 + 10;
		removeAnimButton.y = UI_box.height - removeAnimButton.height - 30;

		var tab_group_anims = new FlxUI(null, UI_box);
		tab_group_anims.name = "2";
		tab_group_anims.add(animNameTitle);
		tab_group_anims.add(animationName);
		tab_group_anims.add(reloadAnimations);
		tab_group_anims.add(addUpdateButton);
		tab_group_anims.add(removeAnimButton);
		tab_group_anims.add(indicesTitle);
		tab_group_anims.add(animationIndices);
		tab_group_anims.add(prefixTitle);
		tab_group_anims.add(prefix);
		tab_group_anims.add(fpsTitle);
		tab_group_anims.add(frameRate);
		tab_group_anims.add(postfixTitle);
		tab_group_anims.add(postfix);
		tab_group_anims.add(isAnimLooped);
		tab_group_anims.add(isFlipX);
		tab_group_anims.add(isFlipY);
		tab_group_anims.add(availableAnimations);
		tab_group_anims.add(animationDropdown);

		UI_box.addGroup(tab_group_anims);
	}

	var isDeathTick:FlxUICheckBox;
	var facesLeftTick:FlxUICheckBox;
	var initialAnimationText:InputTextFix;
	var charFlipX:FlxButton;
	var color:InputTextFix;
	var singDurationStepper:FlxUINumericStepper;
	var camFollowX:FlxUINumericStepper;
	var camFollowY:FlxUINumericStepper;

	function addMiscStuff():Void
	{
		var initialAnimationTitle = new FlxText(10, 10, 0, "Initial Animation");
		initialAnimationText = new InputTextFix(10, initialAnimationTitle.y + initialAnimationTitle.height, Std.int(animationDropdown.width),
			character.initAnim);
		initialAnimationText.callback = function(a:String, b:String)
		{
			character.initAnim = a;
		}

		var isDeathTick = new FlxUICheckBox(10, 50, null, null, "Death screen character?");
		isDeathTick.checked = character.isDeath;
		isDeathTick.callback = function()
		{
			character.isDeath = isDeathTick.checked;
		};

		var facesLeftTick = new FlxUICheckBox(isDeathTick.x + isDeathTick.width + 10, 50, null, null, "Character faces left?");
		facesLeftTick.checked = character.facesLeft;
		facesLeftTick.callback = function()
		{
			character.facesLeft = facesLeftTick.checked;
		};

		charFlipX = new FlxButton(0, 10, "Flip char X", function()
		{
			character.flipX = !character.flipX;
			ghostCharacter.flipX = !ghostCharacter.flipX;
		});

		charFlipX.x = UI_box.width - charFlipX.width - 10;

		var colorLabel = new FlxText(10, 80, 0, "Health Bar Color (in HEX code)");
		color = new InputTextFix(10, colorLabel.y + colorLabel.height, 150, character.getColor().toWebString().replace("#", ""));
		color.callback = function(a:String, b:String)
		{
			character.healthColor = a;
		};

		var eyedroppingButton = new FlxUIButton(10, 110, "Pick color from screen", function()
		{
			isEyedropping = true;
		});
		eyedroppingButton.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		eyedroppingButton.resize(150, 20);

		var singDurationStepperLabel = new FlxText(color.x + color.width + 10, 80, 0, "Sing Duration");
		singDurationStepper = new FlxUINumericStepper(color.x + color.width + 10, singDurationStepperLabel.y + singDurationStepperLabel.height, 0.1,
			character.singDuration, 0, 999, 2);
		singDurationStepper.name = 'singDurStepper';

		var camFollowXTitle = new FlxText(10, 140, 0, "Camera X Pos");
		camFollowX = new FlxUINumericStepper(10, camFollowXTitle.y + camFollowXTitle.height, 10, character.cameraOffset[0], Math.NEGATIVE_INFINITY,
			Math.POSITIVE_INFINITY, 2);
		camFollowX.name = 'camFollowXStepper';

		var camFollowYTitle = new FlxText(camFollowX.x + camFollowX.width + 20, 140, 0, "Camera Y Pos");
		camFollowY = new FlxUINumericStepper(camFollowYTitle.x, camFollowYTitle.y + camFollowYTitle.height, 10, character.cameraOffset[1],
			Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 2);
		camFollowY.name = 'camFollowYStepper';

		updateCamFollowDisplay();

		var saveButton:FlxButton = new FlxButton(0, 0, "SAVE FILE", saveChar);
		saveButton.x = UI_box.width - saveButton.width - 10;
		saveButton.y = UI_box.height - (saveButton.height * 1.5) - 20;

		var tab_group_misc = new FlxUI(null, UI_box);
		tab_group_misc.name = "3";
		tab_group_misc.add(initialAnimationTitle);
		tab_group_misc.add(initialAnimationText);
		tab_group_misc.add(isDeathTick);
		tab_group_misc.add(facesLeftTick);
		tab_group_misc.add(charFlipX);
		tab_group_misc.add(colorLabel);
		tab_group_misc.add(color);
		tab_group_misc.add(eyedroppingButton);
		tab_group_misc.add(singDurationStepperLabel);
		tab_group_misc.add(singDurationStepper);
		tab_group_misc.add(camFollowXTitle);
		tab_group_misc.add(camFollowX);
		tab_group_misc.add(camFollowYTitle);
		tab_group_misc.add(camFollowY);
		tab_group_misc.add(saveButton);

		UI_box.addGroup(tab_group_misc);
	}

<<<<<<< HEAD
	var characterDropdown:DropdownMenuFix;

	function addCharacterStuff():Void
	{
		var pastMod:Null<String> = Paths.currentMod;
		Paths.setCurrentMod(null);
		var characters = CoolUtil.coolTextFile(Paths.txt('characterList'));
		
		var characterDropdownTitle = new FlxText(10, 10, 0, "Available Characters");

		#if FILESYSTEM
		Paths.setCurrentMod(pastMod);

		if (Paths.currentMod != null)
		{
			if (FileSystem.exists(Paths.modTxt('characterList')))
				characters = characters.concat(CoolUtil.coolStringFile(File.getContent(Paths.txt('characterList'))));
		}
		#end

		characterDropdown = new DropdownMenuFix(10, characterDropdownTitle.y + characterDropdownTitle.height,
			DropdownMenuFix.makeStrIdLabelArray(characters, true));
		characterDropdown.selectedLabel = 'bf';
		characterDropdown.scrollable = true;
=======
	var characterDropdown:FlxUIDropDownMenu;

	function addCharacterStuff():Void
	{
		var characterDropdownTitle = new FlxText(10, 10, 0, "Available Characters");
		characterDropdown = new FlxUIDropDownMenu(10, characterDropdownTitle.y + characterDropdownTitle.height,
			FlxUIDropDownMenu.makeStrIdLabelArray(CoolUtil.coolTextFile(Paths.txt('characterList')), true));
		characterDropdown.selectedLabel = 'bf';
>>>>>>> upstream

		var opponentTick = new FlxUICheckBox(10, 50, null, null, "Character is opponent?");

		var loadCharJSON:FlxButton = new FlxButton(characterDropdown.x + characterDropdown.width + 10, characterDropdown.y, "Load Char JSON", function()
		{
			camHUD.visible = false;
			openSubState(new ConfirmationPrompt("Yo, wait a sec!",
				"Remember to save before you load a different character's JSON file! Your current changes will not be saved!", "Sure", "Nah", function()
			{
<<<<<<< HEAD
				CustomTransition.switchTo(new editors.CharacterEditor(opponentTick.checked, characterDropdown.selectedLabel));
=======
				FlxG.switchState(new editors.CharacterEditor(opponentTick.checked, characterDropdown.selectedLabel));
>>>>>>> upstream
			}, function()
			{
				FlxG.mouse.visible = camHUD.visible = true;
			}));
		});

		var tab_group_char = new FlxUI(null, EXTRAS_box);
		tab_group_char.name = "charTab";
		tab_group_char.add(characterDropdownTitle);
		tab_group_char.add(opponentTick);
		tab_group_char.add(characterDropdown);
		tab_group_char.add(loadCharJSON);

		EXTRAS_box.addGroup(tab_group_char);
	}

<<<<<<< HEAD
	var availableGhostAnims:DropdownMenuFix;
	var charTintld:InputTextFix;
=======
	var availableGhostAnims:FlxUIDropDownMenu;
>>>>>>> upstream

	function addGhostStuff():Void
	{
		var holypiss = [];
		for (anim in character.animationsArray)
			holypiss.push(anim.name);

		if (holypiss.length < 1)
			holypiss.push('NO ANIMATIONS');
		var availableGhostAnimsTitle = new FlxText(10, 10, 0, "Ghost's Animations");
<<<<<<< HEAD
		availableGhostAnims = new DropdownMenuFix(10, availableGhostAnimsTitle.y + availableGhostAnimsTitle.height,
			DropdownMenuFix.makeStrIdLabelArray(holypiss, true));
		availableGhostAnims.callback = function(a:String)
		{
			var animOffset = character.animOffsets.get(availableGhostAnims.selectedLabel);

			if (animOffset != null)
			{
				ghostCharacter.animation.play(availableGhostAnims.selectedLabel, true);
				ghostCharacter.offset.set(animOffset[0], animOffset[1]);
			}
=======
		availableGhostAnims = new FlxUIDropDownMenu(10, availableGhostAnimsTitle.y + availableGhostAnimsTitle.height,
			FlxUIDropDownMenu.makeStrIdLabelArray(holypiss, true));
		availableGhostAnims.callback = function(a:String)
		{
			var animOffset = character.animOffsets.get(availableGhostAnims.selectedLabel);
			ghostCharacter.offset.set(animOffset[0], animOffset[1]);
			ghostCharacter.animation.play(availableGhostAnims.selectedLabel, true);
>>>>>>> upstream
		};

		availableGhostAnims.callback('');

		var visibleTick = new FlxUICheckBox(availableGhostAnims.x + availableGhostAnims.width + 10, 10, null, null, "Ghost is\nvisible?");
		visibleTick.callback = function()
		{
			ghostCharacter.visible = visibleTick.checked;
<<<<<<< HEAD
			character.alpha = ghostCharacter.visible ? 0.5 : 1;
			charTintld.callback("", "");
		}

		var tintTitle = new FlxText(visibleTick.x, visibleTick.y + visibleTick.height + 10, "Ghost Tint");
		var tintField = new InputTextFix(tintTitle.x, tintTitle.y + tintTitle.height, Std.int(EXTRAS_box.width - tintTitle.x - 10), "ff0000");
		tintField.callback = function(_, _)
		{
			ghostCharacter.color = FlxColor.fromString("#" + tintField.text);
		}
		tintField.callback("", "");

		var charTintle = new FlxText(visibleTick.x, tintField.y + tintField.height + 10, "Character Tint");
		charTintld = new InputTextFix(tintTitle.x, charTintle.y + charTintle.height, Std.int(EXTRAS_box.width - tintTitle.x - 10), "0000ff");
		charTintld.callback = function(_, _)
		{
			if (visibleTick.checked)
				character.color = FlxColor.fromString("#" + charTintld.text);
			else
				character.color = FlxColor.WHITE;
		}
		visibleTick.callback();
		charTintld.callback("", "");
=======
		}
		visibleTick.callback();
>>>>>>> upstream

		var tab_group_ghost = new FlxUI(null, EXTRAS_box);
		tab_group_ghost.name = "ghostTab";
		tab_group_ghost.add(availableGhostAnimsTitle);
		tab_group_ghost.add(availableGhostAnims);
		tab_group_ghost.add(visibleTick);
<<<<<<< HEAD
		tab_group_ghost.add(tintTitle);
		tab_group_ghost.add(tintField);
		tab_group_ghost.add(charTintle);
		tab_group_ghost.add(charTintld);
=======
>>>>>>> upstream

		EXTRAS_box.addGroup(tab_group_ghost);
	}

	function loadChar(isDad:Bool = false, char:String = 'bf')
	{
		if (character != null)
		{
			remove(character);
			character.destroy();
			character = null;
		}

		character = new Character(0, 0, char, !isDad);
		character.debugMode = true;
<<<<<<< HEAD
		character.updateHitbox();
		character.screenCenter();
		add(character);

		var animOffset = character.animOffsets.get(character.initAnim);

		if (animOffset != null)
			character.offset.set(animOffset[0], animOffset[1]);

		ghostCharacter.flipX = character.flipX;
		ghostCharacter.frames = character.frames;
		ghostCharacter.animation = ghostCharacter.animation.copyFrom(character.animation);
		ghostCharacter.scale.set(character.scale.x, character.scale.y);
=======
		character.screenCenter();
		add(character);

		ghostCharacter.flipX = character.flipX;
		ghostCharacter.frames = character.frames;
		ghostCharacter.animation = ghostCharacter.animation.copyFrom(character.animation);
>>>>>>> upstream
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

		EXTRAS_box.forEachOfType(FlxText, function(spr:FlxText)
		{
			var ass = findHelperDesc(spr.text);
			addToolTipFor(ass, spr, spr.text);
		}, true);

		EXTRAS_box.forEachOfType(FlxButton, function(spr:FlxButton)
		{
			var ass = findHelperDesc(spr.label.text);
			addToolTipFor(ass, spr, spr.label.text);
		}, true);

		EXTRAS_box.forEachOfType(FlxUICheckBox, function(spr:FlxUICheckBox)
		{
			var ass = findHelperDesc(spr.getLabel().text);
			addToolTipFor(ass, spr, spr.getLabel().text);
		}, true);

		EXTRAS_box.forEachOfType(FlxUIButton, function(spr:FlxUIButton)
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
			case 'Character Name':
				toReturn = "What's your character's name?";
			case 'Asset Path':
				toReturn = "Where's your character located?";
			case 'Scale':
				toReturn = "How big should your character be?\n(1 = 100% big, so 6 = 600% bigger)";
			case 'Smoothen?':
				toReturn = "Should it be smooth?\nRecommended unticked for pixel characters.";
			case 'Reload Image':
				toReturn = "Reload the image.";
			case 'Available Animations':
				toReturn = "Currently available and detected animations.";
			case 'Ghost\'s Animations':
				toReturn = "Currently available and detected animations for the ghost.";
			case 'Animation Name':
				toReturn = "What's your animation called?";
			case '.XML/.TXT Prefix':
				toReturn = "What's your animation called in Animate? Or the XML or TXT?";
			case 'Animation Indices':
				toReturn = "(ADVANCED) What frames to play?\nYou can seperate the indices with commas. Spaces are ignored.";
			case 'FPS':
				toReturn = "Framerate. Measured in frames per second.";
			case 'Postfix':
				toReturn = "honestly I don't know why I added this but here it is";
			case 'Is Animation Looped?':
				toReturn = "Should the animation loop indefinitely?";
			case 'Should Animation be X-Flipped?':
				toReturn = "Should the animation be flipped horizontally (left and right)?";
			case 'Should Animation be Y-Flipped?':
				toReturn = "Should the animation be flipped vertically (up and down)?";
			case 'Reload Anims':
				toReturn = "Reload the character's animations and the animations list.";
			case 'Remove':
				toReturn = "Remove the animation from the list";
			case 'Add/Update':
				toReturn = "Add the animation to the list";
			case 'Initial Animation':
				toReturn = "What should the character play first upon existence?";
			case 'Death screen character?':
				toReturn = "Does the character show up exclusively in the death/game-over screen?";
			case 'Character faces left?':
				toReturn = "Does your character face left?";
			case 'Health Bar Color (in HEX code)':
				toReturn = "Y'know, FFFFFF, AD34FF, 2DCBFF? Color picker from google is recommended.";
			case 'Pick color from screen':
				toReturn = "Pick color from screen using your mouse. (buggy)";
			case 'Sing Duration':
				toReturn = "How long should this character's sing animation last?";
			case 'SAVE FILE':
				toReturn = "Don't forget to save!";
		}

		return toReturn;
	}

	function reloadCharacterImage()
	{
		var lastAnim:String = '';
		if (character.animation.curAnim != null)
			lastAnim = character.animation.curAnim.name;

<<<<<<< HEAD
		if (Paths.image(character.image) is String)
		{
			var s:String = cast Paths.image(character.image);
			s = s.split(":")[1].trim();

			if (!Paths.exists(s))
			{
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
				return;
			}
		}

=======
>>>>>>> upstream
		if (Paths.exists(Paths.getPath('shared/images/' + character.image + '.txt', TEXT, null)))
			character.frames = Paths.getPackerAtlas(character.image, 'shared');
		else
		{
			if (FlxG.keys.pressed.ALT) // for debugging other assets... lmao
<<<<<<< HEAD
				character.frames = Paths.getSparrowAtlas(character.image, "preload");
=======
				character.frames = Paths.getSparrowAtlas(character.image);
>>>>>>> upstream
			else
				character.frames = Paths.getSparrowAtlas(character.image);
		}

		if (character.animationsArray != null && character.animationsArray.length > 0)
		{
			for (anim in character.animationsArray)
			{
				if (anim.indices != null && anim.indices.length > 0)
					character.animation.addByIndices(anim.name, anim.prefix, anim.indices, anim.postfix, anim.frameRate, anim.loopedAnim, anim.flipX,
						anim.flipY);
				else
					character.animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loopedAnim, anim.flipX, anim.flipY);

				if (anim.offset != null)
					character.addOffset(anim.name, anim.offset[0], anim.offset[1]);
			}
		}

		character.animation.stop();

<<<<<<< HEAD
		if (character.animationsArray.length > 0)
		{
			if (lastAnim != '')
				character.playAnim(lastAnim, true);
			else
				character.dance();
		}
=======
		if (lastAnim != '')
			character.playAnim(lastAnim, true);
		else
			character.dance();
>>>>>>> upstream

		character.updateHitbox();
		character.screenCenter();
		defaultWidth = character.width;

<<<<<<< HEAD
		ghostCharacter.width = character.width;
		ghostCharacter.height = character.height;
		ghostCharacter.screenCenter();

=======
>>>>>>> upstream
		ghostCharacter.frames = character.frames;
		ghostCharacter.animation = ghostCharacter.animation.copyFrom(character.animation);
	}

	function reloadAnimationDropdown()
	{
		var piss = [];
		for (anim in character.animationsArray)
			piss.push(anim.name);

		if (piss.length < 1)
			piss.push('NO ANIMATIONS');
<<<<<<< HEAD
		animationDropdown.setData(DropdownMenuFix.makeStrIdLabelArray(piss, true));
		availableGhostAnims.setData(DropdownMenuFix.makeStrIdLabelArray(piss, true));

		animationDropdown.callback("");
		availableGhostAnims.callback("");
=======
		animationDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(piss, true));
		availableGhostAnims.setData(FlxUIDropDownMenu.makeStrIdLabelArray(piss, true));
>>>>>>> upstream
	}

	function genBoyOffsets():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.destroy();
		});

		dumbTexts.clear();

		var daLoop:Int = 0;
		var sortThisArray:Array<String> = [];

		for (anim => offsets in character.animOffsets)
			sortThisArray.push(anim);

		sortThisArray.sort(function(a:String, b:String):Int
		{
			a = a.toUpperCase();
			b = b.toUpperCase();

			if (a < b)
				return -1;
			else if (a > b)
				return 1;
			else
				return 0;
		});

		for (anim in sortThisArray)
		{
			var text:FlxText = new FlxText(20, 20 + (20 * daLoop), 0, anim + ": " + character.animOffsets.get(anim), 15);
			text.scrollFactor.set();
			text.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE, 0xFF000000);
			text.borderSize = 2;
			dumbTexts.add(text);

			daLoop++;
		}
	}

	function updateCamFollowDisplay()
	{
		if (this.isDad)
		{
			camFollowDisplay.x = character.getMidpoint().x + 150 + character.cameraOffset[0] - (camFollowDisplay.width / 2);
			camFollowDisplay.y = character.getMidpoint().y - 100 + character.cameraOffset[1] - (camFollowDisplay.height / 2);
		}
		else
		{
			camFollowDisplay.x = character.getMidpoint().x - 100 + character.cameraOffset[0] - (camFollowDisplay.width / 2);
			camFollowDisplay.y = character.getMidpoint().y - 100 + character.cameraOffset[1] - (camFollowDisplay.height / 2);
		}
	}

	var speed:Float = 180;
	var instructionsEnabled:Bool = true;
	var pastCameraPos:Array<Float> = []; // right click movement
	var pastCharacterPos:Array<Float> = []; // left click movement
	var mousePastPos:Array<Float> = [];
	var isTyping:Bool = false;
	var isEyedropping:Bool = false;
	var multiplier:Float = 1; // makin this global
<<<<<<< HEAD
	var backing:Bool = false;
=======
>>>>>>> upstream

	override function update(elapsed:Float)
	{
		if (character.animationsArray[curAnim] != null)
		{
			var curAnimNameLiteral = character.animationsArray[curAnim].name;

			var daAnim = character.animation.getByName(character.animationsArray[curAnim].name);
			if (daAnim == null || daAnim.frames.length < 1)
				curAnimNameLiteral += ' (!BROKEN!)';

			curAnimName.text = curAnimNameLiteral;
		}

		character.animationsArray.sort(function(a:Animation, b:Animation):Int
		{
			var ass = a.name.toUpperCase();
			var balls = b.name.toUpperCase();

			if (ass < balls)
				return -1;
			else if (ass > balls)
				return 1;
			else
				return 0;
		});

		// the Eyedropper is so inconsistent, like fr
		#if desktop
		if (FlxG.mouse.justPressed && isEyedropping)
		{
			var window = Application.current.window;
			var posX = FlxG.mouse.getScreenPosition(camHUD).x * (window.width / FlxG.width);
			var posY = FlxG.mouse.getScreenPosition(camHUD).y * (window.height / FlxG.height);

			var color:Int = FlxScreenGrab.grab(new flash.geom.Rectangle(0, 0, window.width, window.height), false, true)
				.bitmapData.getPixel(Std.int(posX), Std.int(posY));
			this.color.text = color.hex(6).toLowerCase();
			character.healthColor = this.color.text;

			isEyedropping = false;
		}
		#end

<<<<<<< HEAD
		character.screenCenter();
		character.x += character.positionOffset[0];
		character.y += character.positionOffset[1];

		ghostCharacter.width = character.width;
		ghostCharacter.height = character.height;
		ghostCharacter.screenCenter();
		ghostCharacter.x += character.positionOffset[0];
		ghostCharacter.y += character.positionOffset[1];
		var animOffset = character.animOffsets.get(availableGhostAnims.selectedLabel);

		if (animOffset != null)
			ghostCharacter.offset.set(animOffset[0], animOffset[1]);
		
=======
		ghostCharacter.screenCenter();
>>>>>>> upstream
		if (ghostCharacter.antialiasing != character.antialiasing)
			ghostCharacter.antialiasing = character.antialiasing;
		healthBarColor.color = character.getColor();

<<<<<<< HEAD
		if (controls.UI_BACK && !backing && !FlxG.keys.justPressed.BACKSPACE)
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
=======
		if (controls.BACK && !FlxG.keys.justPressed.BACKSPACE)
		{
			if (fromEditors)
			{
				FlxG.switchState(new EditorsState());
				fromEditors = false;
			}
			else
>>>>>>> upstream
				LoadingState.loadAndSwitchState(new PlayState());

			FlxG.mouse.visible = false;
		}

		var a = [];

		forEachOfType(InputTextFix, function(inp:InputTextFix)
		{
			a.push(inp.hasFocus);
		}, true);

		isTyping = a.contains(true);

		// non-keyboard movement
		if (FlxG.keys.pressed.SHIFT)
			multiplier = 3;

<<<<<<< HEAD
		if (!DropdownMenuFix.isDropdowning)
			FlxG.camera.zoom += FlxG.mouse.wheel * 0.05 * multiplier;
=======
		FlxG.camera.zoom += FlxG.mouse.wheel * 0.05 * multiplier;
>>>>>>> upstream

		if (FlxG.mouse.pressedRight)
		{
			if (FlxG.mouse.justPressedRight)
			{
				pastCameraPos = [camFollow.x, camFollow.y];
				mousePastPos = [FlxG.mouse.getScreenPosition(camHUD).x, FlxG.mouse.getScreenPosition(camHUD).y];
			}

<<<<<<< HEAD
			camFollow.x = pastCameraPos[0] + ((mousePastPos[0] - FlxG.mouse.getScreenPosition(camHUD).x) / FlxG.camera.zoom);
			camFollow.y = pastCameraPos[1] + ((mousePastPos[1] - FlxG.mouse.getScreenPosition(camHUD).y) / FlxG.camera.zoom);
=======
			camFollow.x = pastCameraPos[0] + (mousePastPos[0] - FlxG.mouse.getScreenPosition(camHUD).x);
			camFollow.y = pastCameraPos[1] + (mousePastPos[1] - FlxG.mouse.getScreenPosition(camHUD).y);
>>>>>>> upstream
		}

		if (FlxG.camera.zoom <= 0.2)
			FlxG.camera.zoom = 0.2;

		// keyboard movement
		if (!isTyping)
		{
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];

			if (FlxG.keys.justPressed.ALT)
			{
				instructionsEnabled = !instructionsEnabled;

				if (instructionsEnabled)
					instructions.text = instructionsText;
				else
					instructions.text = "Press ALT to show hotkey info.";
			}

			if (FlxG.keys.justPressed.F1)
			{
				camHUD.visible = !camHUD.visible;
				camFollowDisplay.visible = camHUD.visible;
			}

			if (FlxG.keys.justPressed.E)
				FlxG.camera.zoom += 0.25;

			if (FlxG.keys.justPressed.Q)
				FlxG.camera.zoom -= 0.25;

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.A || FlxG.keys.pressed.S || FlxG.keys.pressed.D)
			{
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
			}
			else
				camFollow.velocity.set();

			if (FlxG.keys.pressed.R)
			{
				camFollow.screenCenter();
				FlxG.camera.zoom = 0;
			}

<<<<<<< HEAD
			if (FlxG.keys.justPressed.T)
			{
				character.animOffsets.set(character.animationsArray[curAnim].name, [0, 0]);

				character.animationsArray[curAnim].offset = [
					character.animOffsets.get(character.animationsArray[curAnim].name)[0],
					character.animOffsets.get(character.animationsArray[curAnim].name)[1]
				];

				genBoyOffsets();

				character.playAnim(character.animationsArray[curAnim].name);
			}

=======
>>>>>>> upstream
			if (FlxG.keys.justPressed.K || FlxG.keys.justPressed.I || FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.keys.justPressed.I)
					curAnim -= 1;

				if (FlxG.keys.justPressed.K)
					curAnim += 1;

				if (curAnim < 0)
					curAnim = character.animationsArray.length - 1;

				if (curAnim >= character.animationsArray.length)
					curAnim = 0;

				if (character.animation.getByName(character.animationsArray[curAnim].name) != null)
					character.playAnim(character.animationsArray[curAnim].name);

				genBoyOffsets();
			}

			if ((FlxG.keys.pressed.K || FlxG.keys.pressed.I) && FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.I)
					curAnim -= 1;
				else if (FlxG.keys.pressed.K)
					curAnim += 1;

				if (curAnim < 0)
					curAnim = character.animationsArray.length - 1;

				if (curAnim >= character.animationsArray.length)
					curAnim = 0;

				if (character.animation.getByName(character.animationsArray[curAnim].name) != null)
					character.playAnim(character.animationsArray[curAnim].name);
			}

			if (FlxG.keys.justPressed.S)
			{
				if (FlxG.keys.pressed.CONTROL)
					saveChar();
			}

			var upP = FlxG.keys.anyJustPressed([UP]);
			var rightP = FlxG.keys.anyJustPressed([RIGHT]);
			var downP = FlxG.keys.anyJustPressed([DOWN]);
			var leftP = FlxG.keys.anyJustPressed([LEFT]);

			var holdShift = FlxG.keys.pressed.SHIFT;
			var multiplier = 1;
			if (holdShift)
				multiplier = 10;

			if (upP || rightP || downP || leftP)
			{
				if (upP)
					character.animOffsets.get(character.animationsArray[curAnim].name)[1] += 1 * multiplier;
				if (downP)
					character.animOffsets.get(character.animationsArray[curAnim].name)[1] -= 1 * multiplier;
				if (leftP)
					character.animOffsets.get(character.animationsArray[curAnim].name)[0] += 1 * multiplier;
				if (rightP)
					character.animOffsets.get(character.animationsArray[curAnim].name)[0] -= 1 * multiplier;

				character.animationsArray[curAnim].offset = [
					character.animOffsets.get(character.animationsArray[curAnim].name)[0],
					character.animOffsets.get(character.animationsArray[curAnim].name)[1]
				];

				genBoyOffsets();
				character.playAnim(character.animationsArray[curAnim].name);
			}
		}
		else
		{
			FlxG.sound.volumeUpKeys = null;
			FlxG.sound.volumeDownKeys = null;
			FlxG.sound.muteKeys = null;
		}

		super.update(elapsed);
	}

	function getColorFromIcon():FlxColor
	{
		return FlxColor.WHITE;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			switch (wname)
			{
				case 'scaleChanger':
					character.setGraphicSize(Std.int(defaultWidth * nums.value));
					character.updateHitbox();
					character.screenCenter();

					ghostCharacter.setGraphicSize(Std.int(defaultWidth * nums.value));
					ghostCharacter.updateHitbox();
					ghostCharacter.screenCenter();

					character.setScale = nums.value;
				case 'singDurStepper':
					character.singDuration = nums.value;
				case 'camFollowXStepper':
					character.cameraOffset[0] = nums.value;
					updateCamFollowDisplay();
				case 'camFollowYStepper':
					character.cameraOffset[1] = nums.value;
					updateCamFollowDisplay();
			}
		}
	}

	private function saveChar()
	{
		var json = {
			name: character.curCharacter,
			image: character.image,
<<<<<<< HEAD
			icon: character.icon,
=======
>>>>>>> upstream
			antialiasing: character.antialiasing,
			scale: character.setScale,
			facesLeft: character.facesLeft,
			isDeath: character.isDeath,
			initialAnimation: character.initAnim,
			animations: character.animationsArray,
			healthColor: character.getColor().toWebString().replace("#", ""),
			singDuration: character.singDuration,
			cameraOffset: [character.cameraOffset[0], character.cameraOffset[1]]
		};

		var data:String = Json.stringify(json, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), character.curCharacter.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
<<<<<<< HEAD

		FlxG.mouse.visible = camHUD.visible = true;
=======
>>>>>>> upstream
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
<<<<<<< HEAD

		FlxG.mouse.visible = camHUD.visible = true;
=======
>>>>>>> upstream
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
<<<<<<< HEAD

		FlxG.mouse.visible = camHUD.visible = true;
	}
}
=======
	}
}
>>>>>>> upstream
