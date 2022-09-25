package editors;

import Stage.JSONStage;
import Stage.JSONStageSprite;
import Stage.JSONStageSpriteAnimation;
import Stage.StageJSON;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.Rectangle;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.system.System;
import ui.*;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end
#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

// Les do this again

class StageEditor extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	var UI_box:FlxUITabMenu;
	var SPRITE_box:FlxUITabMenu;

	var camEdit:FlxCamera;
	var camHUD:FlxCamera;
	var curCamPos:FlxObject;
	var camFollow:FlxObject;

	var selectedObj:StageSprite;
	var select9Slice:FlxUI9SliceSprite;

	var addingASprite:Bool = false;

	var stageSprites:Array<StageSprite> = [];

	var characterLayer:FlxTypedGroup<Character>;
	var dad:Character;
	var gf:Character;
	var bf:Boyfriend;

	var copy:FlxUIButton;
	var cut:FlxUIButton;
	var paste:FlxUIButton;
	var duplicate:FlxUIButton;
	var deselect:FlxUIButton;
	var delete:FlxUIButton;

	var objectCount:FlxText;

	var copyClipboard:StageSprite;
	var cutClipboard:StageSprite;

	var stageData:StageJSON = {
		name: "stage",
		bfPosition: [770, 450],
		gfPosition: [400, 130],
		dadPosition: [100, 100],
		defaultCamZoom: 0.9,
		isHalloween: false
	};

	var curZoom:Float = 0.9;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Stage Editor");
		#end

		FlxG.mouse.visible = true;

		camEdit = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camEdit);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camEdit];

		camFollow = new FlxObject(0, 0, 1, 1);
		curCamPos = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(curCamPos.x, curCamPos.y);
		curCamPos.setPosition(curCamPos.x, curCamPos.y);

		add(camFollow);
		add(curCamPos);

		FlxG.camera.follow(curCamPos, LOCKON, 1);

		select9Slice = new FlxUI9SliceSprite(0, 0, Paths.image("select9Slice", "shared"), new Rectangle(0, 0, 32, 32), [4, 4, 28, 28]);
		select9Slice.exists = false;
		add(select9Slice);

		var tabs = [{name: "1", label: 'Stage Data'}, {name: "2", label: 'Characters'}];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(460, 200);
		UI_box.x = 10;
		UI_box.y = FlxG.height - UI_box.height - 10;
		UI_box.selected_tab = 0;
		add(UI_box);
		UI_box.cameras = [camHUD];

		var tabs = [{name: "1", label: 'Sprite'}, {name: "2", label: 'Animations'}];

		SPRITE_box = new FlxUITabMenu(null, tabs, true);
		SPRITE_box.resize((FlxG.width * 0.5) - 10, 200);
		SPRITE_box.x = FlxG.width - SPRITE_box.width - 10;
		SPRITE_box.y = FlxG.height - SPRITE_box.height - 10;
		SPRITE_box.selected_tab = 0;
		add(SPRITE_box);
		SPRITE_box.exists = false;
		SPRITE_box.cameras = [camHUD];

		characterLayer = new FlxTypedGroup<Character>();

		gf = new Character(stageData.gfPosition[0], stageData.gfPosition[1], "gf");
		gf.x += gf.positionOffset[0];
		gf.y += gf.positionOffset[1];
		gf.antialiasing = true;
		gf.scrollFactor.set(0.95, 0.95);
		characterLayer.add(gf);

		dad = new Character(stageData.dadPosition[0], stageData.dadPosition[1], "dad");
		dad.x += dad.positionOffset[0];
		dad.y += dad.positionOffset[1];
		dad.antialiasing = true;
		characterLayer.add(dad);

		bf = new Boyfriend(stageData.bfPosition[0], stageData.bfPosition[1], "bf");
		bf.x += bf.positionOffset[0];
		bf.y += bf.positionOffset[1];
		bf.antialiasing = true;
		characterLayer.add(bf);

		objectCount = new FlxText(10, 10, FlxG.width - 20, "Objects: 0");
		objectCount.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		objectCount.borderSize = 3;
		add(objectCount);
		objectCount.cameras = [camHUD];

		var delAll = new FlxButton(10, objectCount.height + 20, "Delete All", function() {
			selectedObj = null;
			copyClipboard = null;

			if (cutClipboard != null)
			{
				add(cutClipboard);
				updateLayering();
			}

			cutClipboard = null;
			
			while (stageSprites.length > 0)
			{
				var spr = remove(stageSprites[0], true);
				stageSprites.remove(cast spr);
				spr.exists = false;
				spr.kill();
				spr.destroy();
			}
		});
		delAll.color = FlxColor.RED;
		delAll.label.color = FlxColor.WHITE;
		add(delAll);
		delAll.cameras = [camHUD];

		var emptySprite = new FlxUIButton(UI_box.x + UI_box.width + 10, FlxG.height - 30, "Add empty sprite", function()
		{
			addSprite();
		});
		emptySprite.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		emptySprite.resize(150, 20);
		add(emptySprite);
		emptySprite.cameras = [camHUD];

		var loadedSprite = new FlxUIButton(UI_box.x + UI_box.width + 10, emptySprite.y - 30, "Add sprite w/ graphic", function()
		{
			addingASprite = true;
			findThroughExplorer();
		});
		loadedSprite.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		loadedSprite.resize(150, 20);
		add(loadedSprite);
		loadedSprite.cameras = [camHUD];

		deselect = new FlxUIButton(UI_box.x + UI_box.width + 10, loadedSprite.y - 30, "Deselect Sprite", function()
		{
			selectedObj = null;
		});
		deselect.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		deselect.resize(150, 20);
		deselect.exists = false;
		add(deselect);
		deselect.cameras = [camHUD];

		delete = new FlxUIButton(UI_box.x + UI_box.width + 10, deselect.y - 30, "Delete Sprite", function()
		{
			delSprite();
		});
		delete.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		delete.resize(150, 20);
		delete.color = FlxColor.RED;
		delete.label.color = FlxColor.WHITE;
		delete.exists = false;
		add(delete);
		delete.cameras = [camHUD];

		duplicate = new FlxUIButton(UI_box.x + UI_box.width + 10, delete.y - 30, "Duplicate Sprite", function()
		{
			var newObj = selectedObj.clone();
			newObj.x = selectedObj.x;
			newObj.y = selectedObj.y;
			newObj.layer = getMaxLayer() + 1;
			stageSprites.push(newObj);
			add(newObj);
			updateLayering();
			selectObject(newObj);
		});
		duplicate.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		duplicate.resize(150, 20);
		duplicate.exists = false;
		add(duplicate);
		duplicate.cameras = [camHUD];

		paste = new FlxUIButton(UI_box.x + UI_box.width + 10, duplicate.y - 30, "Paste Sprite", function()
		{
			if (cutClipboard != null)
			{
				var added:StageSprite = cast add(cutClipboard);

				added.x = camFollow.x - (added.width / 2);
				added.y = camFollow.y - (added.height / 2);

				cutClipboard = null;
				updateLayering();
				updateSpriteShiz();
				return;
			}

			if (copyClipboard != null)
			{
				var newObj = copyClipboard.clone();
				newObj.x = camFollow.x - (newObj.width / 2);
				newObj.y = camFollow.y - (newObj.height / 2);
				newObj.layer = getMaxLayer() + 1;
				stageSprites.push(newObj);
				add(newObj);
				updateLayering();
				selectObject(newObj);
			}
		});
		paste.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		paste.resize(150, 20);
		paste.exists = false;
		add(paste);
		paste.cameras = [camHUD];

		copy = new FlxUIButton(UI_box.x + UI_box.width + 10, paste.y - 30, "Copy Sprite", function()
		{
			if (cutClipboard != null)
			{
				add(cutClipboard);
				updateLayering();
			}

			cutClipboard = null;
			copyClipboard = selectedObj;
		});
		copy.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		copy.resize((150 / 2) - 5, 20);
		copy.exists = false;
		add(copy);
		copy.cameras = [camHUD];

		cut = new FlxUIButton(copy.x + copy.width + 10, copy.y, "Cut Sprite", function()
		{
			copyClipboard = null;

			if (cutClipboard != null)
			{
				add(cutClipboard);
				updateLayering();
				cutClipboard = null;
			}

			var cutObj:StageSprite = cast remove(selectedObj, true);
			cutClipboard = cutObj;
		});
		cut.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		cut.resize((150 / 2) - 5, 20);
		cut.exists = false;
		add(cut);
		cut.cameras = [camHUD];

		addSpriteStuff();
		addAnimStuff();
		addDataStuff();
		addCharStuff();

		/**
			to do:

			sprite UI
			width + height stuff

			animation UI
			reset position when selecting new sprite in prefix list
		**/

		updateLayering();

		super.create();

		FlxG.stage.window.onDropFile.add(onDropDown);
	}

	var assetPath:InputTextFix;
	var varName:InputTextFix;

	var xStepper:NumStepperFix;
	var yStepper:NumStepperFix;

	var scrollXStepper:NumStepperFix;
	var scrollYStepper:NumStepperFix;

	var widthStepper:NumStepperFix;
	var heightStepper:NumStepperFix;

	var scaleXStepper:NumStepperFix;
	var scaleYStepper:NumStepperFix;

	var angleStepper:NumStepperFix;
	var alphaStepper:NumStepperFix;

	var antiAliasing:FlxUICheckBox;
	var inFront:FlxUICheckBox;

	var colorInput:InputTextFix;

	var layerStepper:NumStepperFix;

	var blendDrop:DropdownMenuFix;

	// MOST OF THESE DONT WORK OPENFL-FLIXEL WHYYYYYYYYYYYYYYYY
	var blends:Array<String> = [
		"ADD", "ALPHA", "DARKEN", "DIFFERENCE", "ERASE", "HARDLIGHT", "INVERT", "LAYER", "LIGHTEN", "MULTIPLY", "NORMAL", "OVERLAY", "SCREEN", "SUBTRACT"
	];

	function addSpriteStuff():Void
	{
		var varNameTitle = new FlxText(10, 10, "Sprite Unique Variable Name");
		varName = new InputTextFix(10, varNameTitle.y + varNameTitle.height, 198);
		varName.callback = function(_, _)
		{
			if (selectedObj != null)
				selectedObj.varName = varName.text.trim();
		}

		var assetPathTitle = new FlxText(10, 38, "Sprite's image asset path");
		assetPath = new InputTextFix(10, assetPathTitle.y + assetPathTitle.height, 198);
		assetPath.callback = function(_, _)
		{
			if (selectedObj != null)
			{
				if (Paths.image(assetPath.text) is FlxGraphic
					|| Paths.exists(cast(Paths.image(assetPath.text), String).replace("shared:", "")))
				{
					if (selectedObj.animations.length > 0)
						selectedObj.frames = Paths.getSparrowAtlas(assetPath.text);
					else
						selectedObj.loadGraphic(Paths.image(assetPath.text));

					selectedObj.imagePath = assetPath.text;
				}
			}
		}

		var findThroughExplorer = new FlxUIButton(10, assetPath.y + assetPath.height + 10, "Find image through Explorer", function()
		{
			addingASprite = false;
			findThroughExplorer();
		});
		findThroughExplorer.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		findThroughExplorer.resize(assetPath.width, 20);

		antiAliasing = new FlxUICheckBox(10, findThroughExplorer.y + findThroughExplorer.height + 10, null, null, "Smoothen?", 75);
		antiAliasing.callback = function()
		{
			if (selectedObj != null)
				selectedObj.antialiasing = antiAliasing.checked;
		}

		inFront = new FlxUICheckBox(10, findThroughExplorer.y + findThroughExplorer.height + 10, null, null, "Foreground object?", 75);
		inFront.callback = function()
		{
			if (selectedObj != null)
			{
				selectedObj.inFront = inFront.checked;
				updateLayering();
			}
		}
		inFront.x = findThroughExplorer.x + findThroughExplorer.width - inFront.width;

		var layerTitle = new FlxText(10, antiAliasing.y + antiAliasing.height + 10, "Layer");
		layerStepper = new NumStepperFix(layerTitle.x, layerTitle.y + layerTitle.height, 1, 0, 0, 256, 1, new InputTextFix(0, 0, 60));
		layerStepper.callback = function(_)
		{
			if (selectedObj != null)
			{
				selectedObj.layer = Std.int(layerStepper.value);
				updateLayering();
			}
		}

		layerStepper.button_minus.label.loadGraphic(FlxUIAssets.IMG_DROPDOWN);
		layerStepper.button_plus.label.loadGraphic(FlxUIAssets.IMG_DROPDOWN);
		layerStepper.button_plus.label.offset.x += 2;
		layerStepper.button_minus.label.offset.x += 2;
		layerStepper.button_plus.label.flipY = true;

		var xStepperTitle = new FlxText(assetPath.x + assetPath.width + 10, 10, "X position");
		xStepper = new NumStepperFix(xStepperTitle.x, xStepperTitle.y + xStepperTitle.height, 10, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1,
			new InputTextFix(0, 0, 60));
		xStepper.callback = function(_)
		{
			if (selectedObj != null)
				selectedObj.x = xStepper.value;
		}

		var yStepperTitle = new FlxText(xStepper.x + xStepper.width + 10, 10, "Y position");
		yStepper = new NumStepperFix(yStepperTitle.x, yStepperTitle.y + yStepperTitle.height, 10, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1,
			new InputTextFix(0, 0, 60));
		yStepper.callback = function(_)
		{
			if (selectedObj != null)
				selectedObj.y = yStepper.value;
		}

		var xScrollTitle = new FlxText(yStepper.x + yStepper.width + 10, 10, "X Parallax Factor");
		scrollXStepper = new NumStepperFix(xScrollTitle.x, xScrollTitle.y + xScrollTitle.height, 0.1, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1,
			new InputTextFix(0, 0, 60));
		scrollXStepper.callback = function(_)
		{
			if (selectedObj != null)
				selectedObj.scrollFactor.x = scrollXStepper.value;
		}

		var yScrollTitle = new FlxText(scrollXStepper.x + scrollXStepper.width + 10, 10, "Y Parallax Factor");
		scrollYStepper = new NumStepperFix(yScrollTitle.x, yScrollTitle.y + yScrollTitle.height, 0.1, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1,
			new InputTextFix(0, 0, 60));
		scrollYStepper.callback = function(_)
		{
			if (selectedObj != null)
				selectedObj.scrollFactor.y = scrollYStepper.value;
		}

		var alphaTitle = new FlxText(xStepperTitle.x, 38, "Opacity");
		alphaStepper = new NumStepperFix(alphaTitle.x, alphaTitle.y + alphaTitle.height, 0.1, 0, 0, 1, 1, new InputTextFix(0, 0, 60));
		alphaStepper.callback = function(_)
		{
			if (selectedObj != null)
				selectedObj.alpha = alphaStepper.value;
		}

		var angleTitle = new FlxText(yStepperTitle.x, 38, "Rotation");
		angleStepper = new NumStepperFix(angleTitle.x, angleTitle.y + angleTitle.height, 1, 0, -360, 360, 1, new InputTextFix(0, 0, 60));
		angleStepper.callback = function(_)
		{
			if (selectedObj != null)
				selectedObj.angle = angleStepper.value;
		}

		var flipX = new FlxUIButton(angleStepper.x + angleStepper.width + 10, alphaStepper.y - 4, "Flip X", function()
		{
			if (selectedObj != null)
				selectedObj.flipX = !selectedObj.flipX;
		});
		flipX.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		flipX.resize(93, 20);

		var flipY = new FlxUIButton(flipX.x + flipX.width + 10, flipX.y, "Flip Y", function()
		{
			if (selectedObj != null)
				selectedObj.flipY = !selectedObj.flipY;
		});
		flipY.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		flipY.resize(93, 20);

		var colorTitle = new FlxText(alphaTitle.x, alphaStepper.y + alphaStepper.height + 10, "Color Tint");
		colorInput = new InputTextFix(colorTitle.x, colorTitle.y + colorTitle.height, 60);
		colorInput.callback = function(_, _)
		{
			if (selectedObj != null)
				selectedObj.color = FlxColor.fromString("#" + colorInput.text.trim());
		}

		var blendTitle = new FlxText(colorInput.x + colorInput.width + 10, colorTitle.y, "Blend Mode");
		blendDrop = new DropdownMenuFix(blendTitle.x, blendTitle.y + blendTitle.height, DropdownMenuFix.makeStrIdLabelArray(blends));
		blendDrop.scrollable = true;
		blendDrop.callback = function(_)
		{
			if (selectedObj != null)
				selectedObj.blend = @:privateAccess BlendMode.fromString(blendDrop.selectedLabel.toLowerCase());
		}

		var tab = new FlxUI(null, SPRITE_box);
		tab.name = "1";
		tab.add(varNameTitle);
		tab.add(varName);
		tab.add(assetPathTitle);
		tab.add(assetPath);
		tab.add(findThroughExplorer);
		tab.add(antiAliasing);
		tab.add(inFront);
		tab.add(layerTitle);
		tab.add(layerStepper);
		tab.add(xStepperTitle);
		tab.add(xStepper);
		tab.add(yStepperTitle);
		tab.add(yStepper);
		tab.add(xScrollTitle);
		tab.add(scrollXStepper);
		tab.add(yScrollTitle);
		tab.add(scrollYStepper);
		tab.add(alphaTitle);
		tab.add(alphaStepper);
		tab.add(angleTitle);
		tab.add(angleStepper);
		tab.add(colorTitle);
		tab.add(colorInput);
		tab.add(blendTitle);
		tab.add(blendDrop);
		tab.add(flipX);
		tab.add(flipY);
		SPRITE_box.addGroup(tab);
	}

	function updateSpriteShiz():Void
	{
		if (selectedObj != null)
		{
			varName.text = selectedObj.varName;
			assetPath.text = selectedObj.imagePath;
			xStepper.value = selectedObj.x;
			yStepper.value = selectedObj.y;
			scrollXStepper.value = selectedObj.scrollFactor.x;
			scrollYStepper.value = selectedObj.scrollFactor.y;
			alphaStepper.value = selectedObj.alpha;
			angleStepper.value = selectedObj.angle;
			antiAliasing.checked = selectedObj.antialiasing;
			inFront.checked = selectedObj.inFront;
			layerStepper.value = selectedObj.layer;
			colorInput.text = selectedObj.color.toHexString(false, false);
			blendDrop.selectedLabel = @:privateAccess selectedObj.blend.toString().toUpperCase();
		}
	}

	var animationDropdown:DropdownMenuFix;
	var animationName:InputTextFix;
	var prefix:InputTextFix;
	var animationIndices:InputTextFix;
	var frameRate:InputTextFix;
	var postfix:InputTextFix;
	var isAnimLooped:FlxUICheckBox;
	var isFlipX:FlxUICheckBox;
	var isFlipY:FlxUICheckBox;

	var prefixList:FlxUIList;

	function addAnimStuff():Void
	{
		var animsTitle = new FlxText(10, 10, "Animations");
		animationDropdown = new DropdownMenuFix(10, animsTitle.y + animsTitle.height, DropdownMenuFix.makeStrIdLabelArray([""]));
		animationDropdown.callback = onAnimDropdown;

		var animNameTitle = new FlxText(10, 50, 0, "Animation Name");
		animationName = new InputTextFix(10, animNameTitle.y + animNameTitle.height, Std.int(animationDropdown.width));

		var prefixTitle = new FlxText(animationName.width + 20, 50, 0, ".XML/.TXT Prefix");
		prefix = new InputTextFix(animationName.width + 20, animNameTitle.y + animNameTitle.height, 197);

		var indicesTitle = new FlxText(10, 80, 0, "Animation Indices");
		animationIndices = new InputTextFix(10, indicesTitle.y + indicesTitle.height, 200);

		var fpsTitle = new FlxText(animationIndices.width + 20, 80, 0, "FPS");
		frameRate = new InputTextFix(animationIndices.width + 20, indicesTitle.y + indicesTitle.height, Std.int((animationDropdown.width / 2) - 10));
		frameRate.filterMode = FlxInputText.ONLY_NUMERIC;

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

		isFlipX.x = (350 / 2) - (isFlipX.width / 2);
		isFlipY.x = 350 - isFlipY.width - 10;

		var avaPrefixesTitle = new FlxText(340, 10, 70, "XML Prefixes\nAvailable:");
		prefixList = new FlxUIList(avaPrefixesTitle.x + avaPrefixesTitle.width + 10, 10, [], 300, (UI_box.height / 2) + 20);
		prefixList.y = (UI_box.height / 2) - (prefixList.height / 2) - 10;

		var addOrUpdate = new FlxButton(10, 0, "Add/Update", addUpdateAnim);
		addOrUpdate.y = UI_box.height - (addOrUpdate.height * 1.5) - 20;

		var delete = new FlxButton(addOrUpdate.x + addOrUpdate.width + 10, addOrUpdate.y, "Delete", deleteAnim);

		var tab = new FlxUI(null, SPRITE_box);
		tab.name = "2";
		tab.add(animsTitle);
		tab.add(animNameTitle);	
		tab.add(animationName);
		tab.add(prefixTitle);
		tab.add(prefix);
		tab.add(indicesTitle);
		tab.add(animationIndices);
		tab.add(fpsTitle);
		tab.add(frameRate);
		tab.add(postfixTitle);
		tab.add(postfix);
		tab.add(isAnimLooped);
		tab.add(isFlipX);
		tab.add(isFlipY);
		tab.add(avaPrefixesTitle);
		tab.add(prefixList);
		tab.add(addOrUpdate);
		tab.add(delete);
		tab.add(animationDropdown);
		SPRITE_box.addGroup(tab);
	}

	var prefixInList:Array<FlxUIText> = [];

	function updatePrefixList():Void
	{
		if (selectedObj.frames == null)
			return;

		while (prefixInList.length > 0)
		{
			var obj = prefixList.remove(prefixInList[0], true);
			prefixInList.remove(cast obj);
			obj.exists = false;
			obj.kill();
			obj.destroy();
		}

		var collected = [];

		for (frame in selectedObj.frames.frames)
			collected.push(frame.name);

		if (collected.length < 1)
			collected.push("No frames!!");

		for (frame in collected)
		{
			var txt = new FlxUIText(0, 0, 0, frame);
			prefixList.add(txt);
			prefixInList.push(txt);
		}

		Reflect.callMethod(prefixList, Reflect.field(prefixList, 'refreshList'), []);
	}

	function onAnimDropdown(_):Void
	{
		if (selectedObj != null)
		{
			var anim = selectedObj.animation.getByName(animationDropdown.selectedLabel);
			var animRaw:JSONStageSpriteAnimation = null;

			for (rawAnim in selectedObj.animations)
			{
				if (rawAnim.name == animationDropdown.selectedLabel)
				{
					animRaw = rawAnim;
					break;
				}
			}

			if (animRaw != null && anim != null && anim.frames.length > 0)
			{
				selectedObj.animation.play(animationDropdown.selectedLabel, true);

				if (animRaw.name != null)
					animationName.text = animRaw.name;
				if (animRaw.prefix != null)
					prefix.text = animRaw.prefix;
				if (animRaw.indices != null)
					animationIndices.text = animRaw.indices.join(', ');
				if (animRaw.frameRate != null)
					frameRate.text = animRaw.frameRate + "";
				if (animRaw.postfix != null)
					postfix.text = animRaw.postfix;
				if (animRaw.loopedAnim != null)
					isAnimLooped.checked = animRaw.loopedAnim;
				if (animRaw.flipX != null)
					isFlipX.checked = animRaw.flipX;
				if (animRaw.flipY != null)
					isFlipY.checked = animRaw.flipY;
			}
		}
	}

	function addUpdateAnim():Void
	{
		if (selectedObj != null)
		{
			var animRaw:JSONStageSpriteAnimation = null;

			for (rawAnim in selectedObj.animations)
			{
				if (rawAnim.name == animationName.text)
				{
					animRaw = rawAnim;
					break;
				}
			}

			if (animRaw != null)
				selectedObj.animations.remove(animRaw);

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

			animRaw = {
				name: animationName.text,
				prefix: prefix.text,
				indices: indices.length > 0 ? indices : null,
				frameRate: frameRate.text.trim().length > 0 ? Std.parseInt(frameRate.text.trim()) : 24,
				postfix: postfix.text,
				loopedAnim: isAnimLooped.checked,
				flipX: isFlipX.checked,
				flipY: isFlipY.checked
			}

			selectedObj.animations.push(animRaw);
			selectedObj.updateAnimations();
			selectedObj.animation.play(animRaw.name, true);
			updateAnimDropdown();
		}
	}

	function deleteAnim():Void
	{
		if (selectedObj != null)
		{
			var animRaw:JSONStageSpriteAnimation = null;

			for (rawAnim in selectedObj.animations)
			{
				if (rawAnim.name == animationName.text)
				{
					animRaw = rawAnim;
					break;
				}
			}

			if (animRaw != null)
				selectedObj.animations.remove(animRaw);

			selectedObj.updateAnimations();
			updateAnimDropdown();
		}
	}

	function updateAnimDropdown():Void
	{
		var arr = [for (i in selectedObj.animations) i.name];

		if (arr.length < 1)
			arr.push('');

		animationDropdown.setData(DropdownMenuFix.makeStrIdLabelArray(arr));
	}

	var dadPosX:NumStepperFix;
	var dadPosY:NumStepperFix;
	var gfPosX:NumStepperFix;
	var gfPosY:NumStepperFix;
	var bfPosX:NumStepperFix;
	var bfPosY:NumStepperFix;

	function addDataStuff():Void
	{
		var dadPosXTitle = new FlxText(10, 10, "Dad's X Position");
		dadPosX = new NumStepperFix(10, dadPosXTitle.y + dadPosXTitle.height, 10, stageData.dadPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 2,
			new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		dadPosX.callback = function(_)
		{
			dad.x = dadPosX.value;
			dad.x += dad.positionOffset[0];
		}

		var dadPosYTitle = new FlxText(UI_box.width / 2 + 5, 10, "Dad's Y Position");
		dadPosY = new NumStepperFix(UI_box.width / 2 + 5, dadPosYTitle.y + dadPosYTitle.height, 10, stageData.dadPosition[1], Math.NEGATIVE_INFINITY,
			Math.POSITIVE_INFINITY, 2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		dadPosY.callback = function(_)
		{
			dad.y = dadPosY.value;
			dad.y += dad.positionOffset[1];
		}

		var gfPosXTitle = new FlxText(10, 50, "GF's X Position");
		gfPosX = new NumStepperFix(10, gfPosXTitle.y + gfPosXTitle.height, 10, stageData.gfPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 2,
			new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		gfPosX.callback = function(_)
		{
			gf.x = gfPosX.value;
			gf.x += gf.positionOffset[0];
		}

		var gfPosYTitle = new FlxText(UI_box.width / 2 + 5, 50, "GF's Y Position");
		gfPosY = new NumStepperFix(UI_box.width / 2 + 5, gfPosYTitle.y + gfPosYTitle.height, 10, stageData.gfPosition[1], Math.NEGATIVE_INFINITY,
			Math.POSITIVE_INFINITY, 2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		gfPosY.callback = function(_)
		{
			gf.y = gfPosY.value;
			gf.y += gf.positionOffset[1];
		}

		var bfPosXTitle = new FlxText(10, 90, "BF's X Position");
		bfPosX = new NumStepperFix(10, bfPosXTitle.y + bfPosXTitle.height, 10, stageData.bfPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 2,
			new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		bfPosX.callback = function(_)
		{
			bf.x = bfPosX.value;
			bf.x += bf.positionOffset[0];
		}

		var bfPosYTitle = new FlxText(UI_box.width / 2 + 5, 90, "BF's Y Position");
		bfPosY = new NumStepperFix(UI_box.width / 2 + 5, bfPosYTitle.y + bfPosYTitle.height, 10, stageData.bfPosition[1], Math.NEGATIVE_INFINITY,
			Math.POSITIVE_INFINITY, 2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		bfPosY.callback = function(_)
		{
			bf.y = bfPosY.value;
			bf.y += bf.positionOffset[1];
		}

		///

		var focusDad = new FlxButton(0, 0, "Focus Dad", function()
		{
			curZoom = stageData.defaultCamZoom != null ? stageData.defaultCamZoom : 1.05;

			var offsetX = dad.cameraOffset[0];
			var offsetY = dad.cameraOffset[1];

			camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
		});
		focusDad.x = 10;
		focusDad.y = UI_box.height - focusDad.height - 30;

		var focusGF = new FlxButton(0, 0, "Focus GF", function()
		{
			curZoom = stageData.defaultCamZoom != null ? stageData.defaultCamZoom : 1.05;
			var offsetX = gf.cameraOffset[0];
			var offsetY = gf.cameraOffset[1];

			camFollow.setPosition(gf.getMidpoint().x + 150 + offsetX, gf.getMidpoint().y - 100 + offsetY);
		});
		focusGF.x = focusDad.x + focusDad.width + 10;
		focusGF.y = focusDad.y;

		var focusBF = new FlxButton(0, 0, "Focus BF", function()
		{
			curZoom = stageData.defaultCamZoom != null ? stageData.defaultCamZoom : 1.05;
			var offsetX = bf.cameraOffset[0];
			var offsetY = bf.cameraOffset[1];

			camFollow.setPosition(bf.getMidpoint().x - 100 + offsetX, bf.getMidpoint().y - 100 + offsetY);
		});
		focusBF.x = focusGF.x + focusGF.width + 10;
		focusBF.y = focusDad.y;

		var dataSave:FlxButton = new FlxButton(0, 0, "Save Data", saveData);
		var dataLoad:FlxButton = new FlxButton(0, 0, "Load Data", function()
		{
			camHUD.visible = false;
			openSubState(new ConfirmationPrompt("You sure?", "Be sure to save your progress. Your progress will be lost if it is left unsaved!", "Sure",
				"Nah", function()
			{
				lookinFor = 'stagedata';
				loadJSON();
			}, function()
			{
				FlxG.mouse.visible = camHUD.visible = true;
			}));
		});

		dataLoad.x = UI_box.width - dataLoad.width - 10;
		dataSave.x = dataLoad.x - dataSave.width - 10;
		dataLoad.y = dataSave.y = focusDad.y;

		var tab = new FlxUI(null, UI_box);
		tab.name = '1';
		tab.add(dadPosXTitle);
		tab.add(dadPosX);
		tab.add(dadPosYTitle);
		tab.add(dadPosY);
		tab.add(gfPosXTitle);
		tab.add(gfPosX);
		tab.add(gfPosYTitle);
		tab.add(gfPosY);
		tab.add(bfPosXTitle);
		tab.add(bfPosX);
		tab.add(bfPosYTitle);
		tab.add(bfPosY);
		tab.add(focusDad);
		tab.add(focusGF);
		tab.add(focusBF);
		tab.add(dataSave);
		tab.add(dataLoad);
		UI_box.addGroup(tab);
	}

	var dadCharacter:DropdownMenuFix;
	var bfCharacter:DropdownMenuFix;
	var gfCharacter:DropdownMenuFix;

	function addCharStuff():Void
	{
		var pastMod:Null<String> = Paths.currentMod;
		Paths.setCurrentMod(null);
		var characters = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#if FILESYSTEM
		Paths.setCurrentMod(pastMod);

		if (Paths.currentMod != null)
		{
			if (FileSystem.exists(Paths.modTxt('characterList')))
				characters = characters.concat(CoolUtil.coolStringFile(File.getContent(Paths.txt('characterList'))));
		}
		#end

		var daWidth:Int = Std.int((UI_box.width / 3) - 15);

		var dadCharacterTitle = new FlxText(10, 10, 0, "Dad Character");

		dadCharacter = new DropdownMenuFix(10, dadCharacterTitle.y + dadCharacterTitle.height, DropdownMenuFix.makeStrIdLabelArray(characters, true),
			new FlxUIDropDownHeader(daWidth));
		dadCharacter.selectedLabel = dad.curCharacter;
		dadCharacter.scrollable = true;
		dadCharacter.callback = function(_)
		{
			if (dadCharacter.selectedLabel == dad.curCharacter)
				return;

			var index = characterLayer.members.indexOf(dad);
			var item:Character = cast characterLayer.remove(dad, true);
			var pos = [item.x, item.y];
			item.exists = false;
			item.kill();
			item.destroy();

			dad = new Character(pos[0], pos[1], dadCharacter.selectedLabel);
			characterLayer.insert(index, dad);

			openfl.system.System.gc();
		}

		var gfCharacterTitle = new FlxText(dadCharacter.x + daWidth + 10, 10, 0, "GF Character");

		gfCharacter = new DropdownMenuFix(gfCharacterTitle.x, gfCharacterTitle.y + gfCharacterTitle.height,
			DropdownMenuFix.makeStrIdLabelArray(characters, true), new FlxUIDropDownHeader(daWidth));
		gfCharacter.selectedLabel = gf.curCharacter;
		gfCharacter.scrollable = true;
		gfCharacter.callback = function(_)
		{
			if (gfCharacter.selectedLabel == gf.curCharacter)
				return;

			var index = characterLayer.members.indexOf(gf);
			var item:Character = cast characterLayer.remove(gf, true);
			var pos = [item.x, item.y];
			item.exists = false;
			item.kill();
			item.destroy();

			gf = new Character(pos[0], pos[1], gfCharacter.selectedLabel);
			characterLayer.insert(index, gf);

			openfl.system.System.gc();
		}

		var bfCharacterTitle = new FlxText(gfCharacter.x + daWidth + 10, 10, 0, "BF Character");

		bfCharacter = new DropdownMenuFix(bfCharacterTitle.x, bfCharacterTitle.y + bfCharacterTitle.height,
			DropdownMenuFix.makeStrIdLabelArray(characters, true), new FlxUIDropDownHeader(daWidth));
		bfCharacter.selectedLabel = bf.curCharacter;
		bfCharacter.scrollable = true;
		bfCharacter.callback = function(_)
		{
			if (bfCharacter.selectedLabel == bf.curCharacter)
				return;

			var index = characterLayer.members.indexOf(bf);
			var item:Boyfriend = cast characterLayer.remove(bf, true);
			var pos = [item.x, item.y];
			item.exists = false;
			item.kill();
			item.destroy();

			bf = new Boyfriend(pos[0], pos[1], bfCharacter.selectedLabel);
			characterLayer.insert(index, bf);

			openfl.system.System.gc();
		}

		var tab = new FlxUI(null, UI_box);
		tab.name = '2';
		tab.add(dadCharacterTitle);
		tab.add(dadCharacter);
		tab.add(gfCharacterTitle);
		tab.add(gfCharacter);
		tab.add(bfCharacterTitle);
		tab.add(bfCharacter);
		UI_box.addGroup(tab);
	}

	function selectObject(s:StageSprite)
	{
		remove(select9Slice, true);

		if (selectedObj != s)
			selectedObj = s;
		else
		{
			if (!FlxG.keys.pressed.SHIFT)
				curZoom = stageData.defaultCamZoom != null ? stageData.defaultCamZoom : 1.05;
		}

		if (!FlxG.keys.pressed.SHIFT)
		{
			camFollow.x = s.x + s.width / 2;
			camFollow.y = s.y + s.height / 2;
		}

		add(select9Slice);

		updatePrefixList();
		updateSpriteShiz();
	}

	function addSprite(?spritePath:String, ?isDropdown:Bool = false):Void
	{
		var s = new StageSprite();
		s.setPosition(0, 0);

		if (spritePath != null)
		{
			s.imagePath = spritePath;

			if (!Paths.exists(Paths.file('images/$spritePath.xml', TEXT, 'shared').replace("shared:", ""))
				&& !Paths.exists(Paths.modFile('images/$spritePath.xml')))
				s.loadGraphic(Paths.image(spritePath));
			else
				s.frames = Paths.getSparrowAtlas(spritePath);

			s.updateAnimations();
		}
		else
			s.screenCenter();

		if (isDropdown)
		{
			s.x = camFollow.x - (s.width / 2);
			s.y = camFollow.y - (s.height / 2);
		}

		s.layer = getMaxLayer() + 1;
		stageSprites.push(s);
		add(s);
		updateLayering();
		selectObject(s);
	}

	function delSprite():Void
	{
		remove(selectedObj, true);
		stageSprites.remove(selectedObj);
		selectedObj.exists = false;
		selectedObj.kill();
		selectedObj.destroy();

		System.gc();

		selectedObj = null;
	}

	function onDropDown(imagePath:String):Void
	{
		var prefix = Sys.getCwd().replace("\\", "/").trim() + "assets/shared/images/";

		if (Paths.currentMod != null)
			prefix = Sys.getCwd().replace("\\", "/").trim() + "mods/" + Paths.currentMod + "/assets/images/";

		var repl = imagePath.replace("\\", "/").trim();

		if (repl.startsWith(prefix))
			addSprite(repl.substr(prefix.length).replace(".png", ""), true);
		else
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), 0.6);
	}

	function getMaxLayer(?inFront:Bool = false):Int
	{
		var sprites:Array<StageSprite> = [];

		for (i in stageSprites)
		{
			if (i.inFront == inFront)
				sprites.push(i);
		}

		return sprites.length - 1;
	}

	function updateLayering():Void
	{
		remove(characterLayer, true);
		remove(select9Slice, true);

		var spritesBack:Array<StageSprite> = [];
		var spritesFront:Array<StageSprite> = [];

		for (i in stageSprites)
		{
			var s:StageSprite = cast remove(i, true);
			if (s.inFront)
				spritesFront.push(s);
			else
				spritesBack.push(s);
		}

		spritesFront.sort(function(a:StageSprite, b:StageSprite)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.layer, b.layer);
		});

		spritesBack.sort(function(a:StageSprite, b:StageSprite)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.layer, b.layer);
		});

		for (i in spritesBack)
			add(i);

		add(characterLayer);

		for (i in spritesFront)
			add(i);

		add(select9Slice);
	}

	var backing:Bool = false;

	var pastCameraPos:Array<Float> = [];
	var mouseMiddleClickPastPos:Array<Float> = [];

	var speed:Float = 180;

	var prevCount:Int = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (prevCount != stageSprites.length)
		{
			objectCount.text = "Objects: " + stageSprites.length;
			prevCount = stageSprites.length;
		}

		var lerp = Helper.boundTo(elapsed * 2.2, 0, 1);
		curCamPos.x = FlxMath.lerp(curCamPos.x, camFollow.x, lerp);
		curCamPos.y = FlxMath.lerp(curCamPos.y, camFollow.y, lerp);
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, curZoom, Helper.boundTo(elapsed * 3.125, 0, 1));

		if (selectedObj != null)
		{
			select9Slice.exists = true;
			SPRITE_box.exists = true;
			delete.exists = true;
			deselect.exists = true;
			duplicate.exists = true;
			paste.exists = true;
			copy.exists = true;
			cut.exists = true;

			select9Slice.angle = selectedObj.angle;
			select9Slice.resize(selectedObj.width + 8, selectedObj.height + 8);
			select9Slice.x = selectedObj.x - 4;
			select9Slice.y = selectedObj.y - 4;
			select9Slice.scrollFactor.set(selectedObj.scrollFactor.x, selectedObj.scrollFactor.y);
		}
		else
		{
			select9Slice.exists = false;
			SPRITE_box.exists = false;
			delete.exists = false;
			deselect.exists = false;
			duplicate.exists = false;
			paste.exists = false;
			copy.exists = false;
			cut.exists = false;
		}

		// I don't wanna modify world bounds
		@:privateAccess camFollow.updateMotion(elapsed);

		if (!InputTextFix.isTyping)
		{
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

			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.S)
					saveJSON();

				if (FlxG.keys.justPressed.C)
					copy.onUp.callback();

				if (FlxG.keys.justPressed.V)
					paste.onUp.callback();

				if (FlxG.keys.justPressed.X)
					cut.onUp.callback();

				if (FlxG.keys.justPressed.D)
					duplicate.onUp.callback();
			}

			if (FlxG.keys.justPressed.F)
			{
				if (selectedObj != null)
				{
					curZoom = stageData.defaultCamZoom != null ? stageData.defaultCamZoom : 1.05;
					camFollow.x = selectedObj.x + selectedObj.width / 2;
					camFollow.y = selectedObj.y + selectedObj.height / 2;
				}
			}

			if (FlxG.mouse.pressedMiddle)
			{
				if (!FlxG.stage.window.cursor.equals(MOVE))
					FlxG.stage.window.cursor = MOVE;

				if (FlxG.mouse.justPressedMiddle)
				{
					pastCameraPos = [camFollow.x, camFollow.y];
					mouseMiddleClickPastPos = [FlxG.mouse.getScreenPosition(camHUD).x, FlxG.mouse.getScreenPosition(camHUD).y];
				}

				curCamPos.x = camFollow.x = pastCameraPos[0] + ((mouseMiddleClickPastPos[0] - FlxG.mouse.getScreenPosition(camHUD).x) / FlxG.camera.zoom);
				curCamPos.y = camFollow.y = pastCameraPos[1] + ((mouseMiddleClickPastPos[1] - FlxG.mouse.getScreenPosition(camHUD).y) / FlxG.camera.zoom);
			}
			else
			{
				if (!FlxG.stage.window.cursor.equals(ARROW))
					FlxG.stage.window.cursor = ARROW;
			}

			if (FlxG.mouse.justPressedRight)
			{
				for (sprite in stageSprites)
				{
					if (Helper.screenOverlap(sprite))
					{
						selectObject(sprite);
						break;
					}
				}
			}

			if (FlxG.mouse.wheel != 0 && !DropdownMenuFix.isDropdowning)
				FlxG.camera.zoom = curZoom += FlxG.mouse.wheel * 0.1;

			if (FlxG.keys.anyPressed([W, A, S, D]))
			{
				var multiplier = 1;

				if (FlxG.keys.pressed.SHIFT)
					multiplier = 10;

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

			if (selectedObj != null)
			{
				if (FlxG.keys.anyJustPressed([Q, E]))
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.Q)
							selectedObj.angle -= 15;
						if (FlxG.keys.justPressed.E)
							selectedObj.angle += 15;
					}
					else if (FlxG.keys.pressed.ALT)
					{
						if (FlxG.keys.justPressed.Q)
							selectedObj.angle -= 90;
						if (FlxG.keys.justPressed.E)
							selectedObj.angle += 90;
					}
					else
					{
						if (FlxG.keys.justPressed.Q)
							selectedObj.angle -= 45;
						if (FlxG.keys.justPressed.E)
							selectedObj.angle += 45;
					}

					if (selectedObj.angle < -360)
						selectedObj.angle += 360;
					if (selectedObj.angle > 360)
						selectedObj.angle -= 360;

					updateSpriteShiz();
				}

				if (FlxG.keys.anyJustPressed([LEFT, DOWN, UP, RIGHT]))
				{
					var modX:Float = 0;
					var modY:Float = 0;

					if (FlxG.keys.justPressed.LEFT)
						modX = -1;
					if (FlxG.keys.justPressed.RIGHT)
						modX = 1;
					if (FlxG.keys.justPressed.DOWN)
						modY = 1;
					if (FlxG.keys.justPressed.UP)
						modY = -1;

					if (!FlxG.keys.pressed.SHIFT)
					{
						modX *= 10;
						modY *= 10;
					}

					if (FlxG.keys.pressed.ALT)
					{
						modX *= 100;
						modY *= 100;
					}

					selectedObj.x += modX;
					selectedObj.y += modY;

					updateSpriteShiz();
				}
			}
		}
	}

	override function destroy()
	{
		FlxG.stage.window.onDropFile.remove(onDropDown);

		super.destroy();
	}

	function updatePosSteppers():Void
	{
		bfPosX.value = stageData.bfPosition[0];
		bfPosX.callback(0);
		bfPosY.value = stageData.bfPosition[1];
		bfPosY.callback(0);
		dadPosX.value = stageData.dadPosition[0];
		dadPosX.callback(0);
		dadPosY.value = stageData.dadPosition[1];
		dadPosY.callback(0);
		gfPosX.value = stageData.gfPosition[0];
		gfPosX.callback(0);
		gfPosY.value = stageData.gfPosition[1];
		gfPosY.callback(0);
	}

	var _file:FileReference;

	private function loadJSON()
	{
		var funnyFilter:FileFilter = new FileFilter('JSON', 'json');

		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([funnyFilter]);
	}

	var path:String = null;

	var lookinFor:String = "jsonstage";

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

		// var newNote:NoteJSON = cast Json.parse(File.getContent(path).trim());

		switch (lookinFor)
		{
			case 'stagedata':
				stageData = cast Json.parse(File.getContent(path).trim());
				updatePosSteppers();
			case 'jsonstage':
		}

		FlxG.mouse.visible = camHUD.visible = true;

		path = null;
		_file = null;
	}

	private function findThroughExplorer()
	{
		var funnyFilter:FileFilter = new FileFilter('PNG', 'png');

		_file = new FileReference();
		_file.addEventListener(Event.SELECT, findComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([funnyFilter]);
	}

	var imagePath:String = null;

	function findComplete(_)
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		@:privateAccess
		{
			if (_file.__path != null)
				imagePath = _file.__path;
		}
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

		var prefix = Sys.getCwd().replace("\\", "/").trim() + "assets/shared/images/";

		if (Paths.currentMod != null)
			prefix = Sys.getCwd().replace("\\", "/").trim() + "mods/" + Paths.currentMod + "/assets/images/";

		var repl = imagePath.replace("\\", "/").trim();

		if (!addingASprite)
		{
			if (repl.startsWith(prefix) && selectedObj != null)
			{
				assetPath.text = repl.substr(prefix.length).replace(".png", "");
				assetPath.callback("", "");
			}
		}
		else
		{
			if (repl.startsWith(prefix))
				addSprite(repl.substr(prefix.length).replace(".png", ""));

			addingASprite = false;
		}

		FlxG.mouse.visible = camHUD.visible = true;

		imagePath = null;
		_file = null;
	}

	function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;

		FlxG.mouse.visible = camHUD.visible = true;
	}

	function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;

		FlxG.mouse.visible = camHUD.visible = true;
	}

	private function saveJSON()
	{
		var stage:JSONStage = {
			stage: []
		}

		for (i in stageSprites)
			stage.stage.push(i.data);

		var data:String = Json.stringify(stage, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "stage.json");
		}
	}

	private function saveData()
	{
		var data:String = Json.stringify(stageData, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "data.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;

		FlxG.mouse.visible = camHUD.visible = true;
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;

		FlxG.mouse.visible = camHUD.visible = true;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;

		FlxG.mouse.visible = camHUD.visible = true;
	}
}

class StageSprite extends FlxSprite
{
	public var varName:String = '';
	public var initAnim:String = '';
	public var imagePath:String = '';
	public var animations(default, set):Array<JSONStageSpriteAnimation> = [];
	public var inFront:Bool = false;
	public var layer:Int = 0;

	public var data(get, null):JSONStageSprite;

	public function new()
	{
		super();

		varName = 'sprite' + ID;
		blend = NORMAL;
	}

	public function updateAnimations():Void
	{
		if (frames == null || animations.length == 0)
			return;

		animation.stop();
		animation.curAnim = null;

		for (name in animation.getNameList())
			animation.remove(name);

		for (item in animations)
		{
			trace("adding anim..." + item);
			
			if (item.indices != null)
				animation.addByIndices(item.name, item.prefix, item.indices, item.postfix, item.frameRate, item.loopedAnim, item.flipX, item.flipY);
			else
				animation.addByPrefix(item.name, item.prefix, item.frameRate, item.loopedAnim, item.flipX, item.flipY);
		}
	}

	override function clone():StageSprite 
	{
		var obj:StageSprite = cast new StageSprite().loadGraphicFromSprite(this);

		obj.varName = "sprite" + obj.ID;
		obj.initAnim = initAnim;
		obj.imagePath = imagePath;
		obj.animations = animations.copy();
		obj.inFront = inFront;
		obj.layer = layer;

		obj.setPosition(x, y);
		obj.scrollFactor.set(scrollFactor.x, scrollFactor.y);
		obj.scale.set(scale.x, scale.y);
		obj.imagePath = imagePath;
		obj.flipX = flipX;
		obj.flipY = flipY;
		obj.color = color;
		obj.blend = blend;
		obj.angle = angle;
		obj.alpha = alpha;

		obj.updateAnimations();

		return obj;
	}

	function set_animations(value:Array<JSONStageSpriteAnimation>):Array<JSONStageSpriteAnimation>
	{
		if (animations != value)
		{
			animations = value;
			updateAnimations();
		}

		return value;
	}

	function get_data():JSONStageSprite
	{
		@:privateAccess
		return {
			varName: varName,
			position: [x, y],
			scrollFactor: [scrollFactor.x, scrollFactor.y],
			scale: [scale.x, scale.y],
			initAnim: initAnim,
			antialiasing: antialiasing,
			animations: animations,
			imagePath: imagePath,
			flipX: flipX,
			flipY: flipY,
			color: color.toHexString(false, false),
			blend: blend.toString().toUpperCase(),
			angle: angle,
			alpha: alpha,
			inFront: inFront,
			layer: layer
		}
	}
}
