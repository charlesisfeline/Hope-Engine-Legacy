package editors;

import Stage.JSONStage;
import Stage.JSONStageSprite;
import Stage.JSONStageSpriteAnimation;
import Stage.StageJSON;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxSort;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.Rectangle;
import openfl.net.FileFilter;
import openfl.net.FileReference;
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

		var tabs = [
			{name: "1", label: 'Sprite'},
			{name: "2", label: 'Animations'},
			{name: "3", label: 'Stage Data'},
			{name: "4", label: 'Characters'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize((FlxG.width * 0.5) - 10, FlxG.height * 0.25);
		UI_box.x = 10;
		UI_box.y = FlxG.height - UI_box.height - 10;
		UI_box.selected_tab = 0;
		add(UI_box);
		UI_box.cameras = [camHUD];

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

		addSpriteStuff();
		addAnimStuff();
		addDataStuff();
		addCharStuff();

		/**
			to do:

			// TEST ALL EDITORS IF THEY CRASH OR NAH LMAOO

			sprite UI
			// make movement buttons for selected sprites
			// make movement controls for stage
			// make mouse mmovement controls
			merge this and stage json editor together
			// make assetPath input actually work with selected object
			animation UI
			misc UI
			// make selecting objects actually possible

			make scrollfactor dependent on selection AND with select square
			test if stage.json files can exist by itself and exist with stage.hes files

			// add object
			remove selected object

			// right click to select objecy
			// middle mouse click to move with mouse
			also zoom buttons to chars because, well merge with stage json editor

			// when selecting object, lerp camera pos and zoom (focus to selected object)

			die
		**/

		updateLayering();

		super.create();
	}

	var assetPath:InputTextFix;

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

	function addSpriteStuff():Void
	{
		var assetPathTitle = new FlxText(10, 10, "Sprite's image asset path");
		assetPath = new InputTextFix(10, assetPathTitle.y + assetPathTitle.height, 198);
		assetPath.callback = function(_, _)
		{
			if (selectedObj != null)
			{
				if (Paths.image(assetPath.text) is FlxGraphic || Paths.exists(cast (Paths.image(assetPath.text), String).replace("shared:", "")))
				{
					if (selectedObj.animations.length > 0)
						selectedObj.frames = Paths.getSparrowAtlas(assetPath.text);
					else
						selectedObj.loadGraphic(Paths.image(assetPath.text));
				}
			}
		}

		var findThroughExplorer = new FlxUIButton(10, assetPath.y + assetPath.height + 10, "Find image through Explorer", findThroughExplorer);
		findThroughExplorer.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		findThroughExplorer.resize(assetPath.width, 20);

		var addSpriteButton = new FlxUIButton(10, findThroughExplorer.y + findThroughExplorer.height + 10, "Add empty sprite", function() {
			addSprite();
		});
		addSpriteButton.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		addSpriteButton.resize(assetPath.width, 20);
		
		var xStepperTitle = new FlxText(assetPath.x + assetPath.width + 10, 10, "X position");
		xStepper = new NumStepperFix(xStepperTitle.x, xStepperTitle.y + xStepperTitle.height, 10, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1, new InputTextFix(0, 0, 60));
		xStepper.callback = function(_) {
			if (selectedObj != null)
				selectedObj.x = xStepper.value;
		}

		var yStepperTitle = new FlxText(xStepper.x + xStepper.width + 10, 10, "Y position");
		yStepper = new NumStepperFix(yStepperTitle.x, yStepperTitle.y + yStepperTitle.height, 10, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1, new InputTextFix(0, 0, 60));
		yStepper.callback = function(_) {
			if (selectedObj != null)
				selectedObj.y = yStepper.value;
		}

		var xScrollTitle = new FlxText(yStepper.x + yStepper.width + 10, 10, "X Parallax Factor");
		scrollXStepper = new NumStepperFix(xScrollTitle.x, xScrollTitle.y + xScrollTitle.height, 0.1, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1, new InputTextFix(0, 0, 60));
		scrollXStepper.callback = function(_) {
			if (selectedObj != null)
				selectedObj.scrollFactor.x = scrollXStepper.value;
		}

		var yScrollTitle = new FlxText(scrollXStepper.x + scrollXStepper.width + 10, 10, "Y Parallax Factor");
		scrollYStepper = new NumStepperFix(yScrollTitle.x, yScrollTitle.y + yScrollTitle.height, 0.1, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 1, new InputTextFix(0, 0, 60));
		scrollYStepper.callback = function(_) {
			if (selectedObj != null)
				selectedObj.scrollFactor.y = scrollYStepper.value;
		}

		var alphaTitle = new FlxText(xStepperTitle.x, 38, "Opacity");
		alphaStepper = new NumStepperFix(alphaTitle.x, alphaTitle.y + alphaTitle.height, 0.1, 0, 0, 1, 1, new InputTextFix(0, 0, 60));
		alphaStepper.callback = function(_) {
			if (selectedObj != null)
				selectedObj.alpha = alphaStepper.value;
		}

		var angleTitle = new FlxText(yStepperTitle.x, 38, "Rotation");
		angleStepper = new NumStepperFix(angleTitle.x, angleTitle.y + angleTitle.height, 1, 0, -360, 360, 1, new InputTextFix(0, 0, 60));
		angleStepper.callback = function(_) {
			if (selectedObj != null)
				selectedObj.angle = angleStepper.value;
		}

		var flipX = new FlxUIButton(angleStepper.x + angleStepper.width + 10, findThroughExplorer.y, "Flip X", function() {
			if (selectedObj != null)
				selectedObj.flipX = !selectedObj.flipX;
		});
		flipX.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		flipX.resize(93, 20);

		var flipY = new FlxUIButton(flipX.x + flipX.width + 10, findThroughExplorer.y, "Flip Y", function() {
			if (selectedObj != null)
				selectedObj.flipY = !selectedObj.flipY;
		});
		flipY.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		flipY.resize(93, 20);

		var tab = new FlxUI(null, UI_box);
		tab.name = "1";
		tab.add(assetPathTitle);
		tab.add(assetPath);
		tab.add(findThroughExplorer);
		tab.add(addSpriteButton);
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
		tab.add(flipX);
		tab.add(flipY);
		UI_box.addGroup(tab);
	}

	function updateSpriteShiz():Void
	{
		if (selectedObj != null)
		{
			xStepper.value = selectedObj.x;
			yStepper.value = selectedObj.y;
			scrollXStepper.value = selectedObj.scrollFactor.x;
			scrollYStepper.value = selectedObj.scrollFactor.y;
			alphaStepper.value = selectedObj.alpha;
			angleStepper.value = selectedObj.angle;
		}
	}

	function addAnimStuff():Void
	{
		//
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
		dadPosX = new NumStepperFix(10, dadPosXTitle.y + dadPosXTitle.height, 10, stageData.dadPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		dadPosX.callback = function(_) {
			dad.x = dadPosX.value;
			dad.x += dad.positionOffset[0];
		}

		var dadPosYTitle = new FlxText(UI_box.width / 2 + 5, 10, "Dad's Y Position");
		dadPosY = new NumStepperFix(UI_box.width / 2 + 5, dadPosYTitle.y + dadPosYTitle.height, 10, stageData.dadPosition[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		dadPosY.callback = function(_) {
			dad.y = dadPosY.value;
			dad.y += dad.positionOffset[1];
		}

		var gfPosXTitle = new FlxText(10, 50, "GF's X Position");
		gfPosX = new NumStepperFix(10, gfPosXTitle.y + gfPosXTitle.height, 10, stageData.gfPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		gfPosX.callback = function(_) {
			gf.x = gfPosX.value;
			gf.x += gf.positionOffset[0];
		}

		var gfPosYTitle = new FlxText(UI_box.width / 2 + 5, 50, "GF's Y Position");
		gfPosY = new NumStepperFix(UI_box.width / 2 + 5, gfPosYTitle.y + gfPosYTitle.height, 10, stageData.gfPosition[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		gfPosY.callback = function(_) {
			gf.y = gfPosY.value;
			gf.y += gf.positionOffset[1];
		}

		var bfPosXTitle = new FlxText(10, 90, "BF's X Position");
		bfPosX = new NumStepperFix(10, bfPosXTitle.y + bfPosXTitle.height, 10, stageData.bfPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		bfPosX.callback = function(_) {
			bf.x = bfPosX.value;
			bf.x += bf.positionOffset[0];
		}

		var bfPosYTitle = new FlxText(UI_box.width / 2 + 5, 90, "BF's Y Position");
		bfPosY = new NumStepperFix(UI_box.width / 2 + 5, bfPosYTitle.y + bfPosYTitle.height, 10, stageData.bfPosition[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		bfPosY.callback = function(_) {
			bf.y = bfPosY.value;
			bf.y += bf.positionOffset[1];
		}

		///

		var focusDad = new FlxButton(0, 0, "Focus Dad", function() {
			curZoom = stageData.defaultCamZoom != null ? stageData.defaultCamZoom : 1.05;

			var offsetX = dad.cameraOffset[0];
			var offsetY = dad.cameraOffset[1];

			camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
		});
		focusDad.x = 10;
		focusDad.y = UI_box.height - focusDad.height - 30;

		var focusGF = new FlxButton(0, 0, "Focus GF", function() {
			curZoom = stageData.defaultCamZoom != null ? stageData.defaultCamZoom : 1.05;
			var offsetX = gf.cameraOffset[0];
			var offsetY = gf.cameraOffset[1];

			camFollow.setPosition(gf.getMidpoint().x + 150 + offsetX, gf.getMidpoint().y - 100 + offsetY);
		});
		focusGF.x = focusDad.x + focusDad.width + 10;
		focusGF.y = focusDad.y;

		var focusBF = new FlxButton(0, 0, "Focus BF", function() {
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
			openSubState(new ConfirmationPrompt("You sure?", "Be sure to save your progress. Your progress will be lost if it is left unsaved!", "Sure", "Nah", 
			function() {
				lookinFor = 'stagedata';
				loadJSON();
			}, 
			function()
			{
				FlxG.mouse.visible = camHUD.visible = true;
			}));
		});

		dataLoad.x = UI_box.width - dataLoad.width - 10;
		dataSave.x = dataLoad.x - dataSave.width - 10;
		dataLoad.y = dataSave.y = focusDad.y;

		var tab = new FlxUI(null, UI_box);
		tab.name = '3';
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

		dadCharacter = new DropdownMenuFix(10, dadCharacterTitle.y + dadCharacterTitle.height,
			DropdownMenuFix.makeStrIdLabelArray(characters, true), new FlxUIDropDownHeader(daWidth));
		dadCharacter.selectedLabel = dad.curCharacter;
		dadCharacter.scrollable = true;
		dadCharacter.callback = function(_) {
			if (dadCharacter.selectedLabel == dad.curCharacter) return;

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
		gfCharacter.callback = function(_) {
			if (gfCharacter.selectedLabel == gf.curCharacter) return;

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
		bfCharacter.callback = function(_) {
			if (bfCharacter.selectedLabel == bf.curCharacter) return;

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
		tab.name = '4';
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
		if (selectedObj != s)
			selectedObj = s;
		else
		{
			if (!FlxG.keys.pressed.SHIFT)
				curZoom = stageData.defaultCamZoom;
		}

		if (!FlxG.keys.pressed.SHIFT)
		{
			camFollow.x = s.x + s.width / 2;
			camFollow.y = s.y + s.height / 2;
		}

		updateSpriteShiz();
	}

	function addSprite(?spritePath:String):Void
	{
		var s = new StageSprite();
		s.setPosition(0, 0);

		if (spritePath != null)
		{
			if (!Paths.exists(Paths.file('images/$spritePath.xml')))
				s.loadGraphic(Paths.image(spritePath));
			else
				s.frames = Paths.getSparrowAtlas(spritePath);
	
			s.updateAnimations();
		}
		else
			s.screenCenter();
		
		stageSprites.push(s);
		add(s);
		selectObject(s);
	}

	function updateLayering():Void
	{
		remove(characterLayer, true);
		
		var spritesBack:Array<StageSprite> = [];
		var spritesFront:Array<StageSprite> = [];

		for (i in members)
		{
			if (i is StageSprite)
			{
				var s:StageSprite = cast remove(i, true);
				if (s.inFront)
					spritesFront.push(s);
				else
					spritesBack.push(s);
			}
		}

		spritesFront.sort(function(a:StageSprite, b:StageSprite) {
			return FlxSort.byValues(FlxSort.ASCENDING, a.layer, b.layer);
		});

		spritesBack.sort(function(a:StageSprite, b:StageSprite) {
			return FlxSort.byValues(FlxSort.ASCENDING, a.layer, b.layer);
		});

		for (i in spritesBack)
			add(i);

		add(characterLayer);

		for (i in spritesFront)
			add(i);

	}

	var backing:Bool = false;

	var pastCameraPos:Array<Float> = [];
	var mouseMiddleClickPastPos:Array<Float> = [];

	var speed:Float = 180;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerp = Helper.boundTo(elapsed * 2.2, 0, 1);
		curCamPos.x = FlxMath.lerp(curCamPos.x, camFollow.x, lerp);
		curCamPos.y = FlxMath.lerp(curCamPos.y, camFollow.y, lerp);
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, curZoom, Helper.boundTo(elapsed * 3.125, 0, 1));

		if (selectedObj != null)
		{
			select9Slice.exists = true;
			select9Slice.angle = selectedObj.angle;
			select9Slice.resize(selectedObj.width + 8, selectedObj.height + 8);
			select9Slice.x = selectedObj.x - 4;
			select9Slice.y = selectedObj.y - 4;
			select9Slice.scrollFactor.set(selectedObj.scrollFactor.x, selectedObj.scrollFactor.y);
		}
		else
			select9Slice.exists = false;

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

			if (FlxG.mouse.pressedMiddle)
			{
				if (FlxG.mouse.justPressedMiddle)
				{
					pastCameraPos = [camFollow.x, camFollow.y];
					mouseMiddleClickPastPos = [FlxG.mouse.getScreenPosition(camHUD).x, FlxG.mouse.getScreenPosition(camHUD).y];
				}
	
				curCamPos.x = camFollow.x = pastCameraPos[0] + ((mouseMiddleClickPastPos[0] - FlxG.mouse.getScreenPosition(camHUD).x) / FlxG.camera.zoom);
				curCamPos.y = camFollow.y = pastCameraPos[1] + ((mouseMiddleClickPastPos[1] - FlxG.mouse.getScreenPosition(camHUD).y) / FlxG.camera.zoom);
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

	public var data:JSONStageSprite;

	public function new()
	{
		super();

		varName = 'sprite' + ID;
		blend = NORMAL;

		data = {
			varName: varName,
			position: [x, y],
			scrollFactor: [scrollFactor.x, scrollFactor.y],
			scale: [scale.x, scale.y],
			initAnim: initAnim,
			antialiasing: antialiasing,
			animations: animations,
			imagePath: imagePath,
			flipX: false,
			flipY: false,
			color: "FFFFFF",
			blend: "NORMAL",
			angle: 0,
			alpha: 1,
			inFront: inFront,
			layer: layer
		}
	}

	public function updateAnimations():Void
	{
		if (frames == null || animations.length == 0) return;
		
		animation.stop();
		animation.curAnim = null;
		
		for (name in animation.getNameList())
			animation.remove(name);

		for (item in animations)
		{
			if (item.indices != null)
				animation.addByIndices(item.name, item.prefix, item.indices, null, item.frameRate, item.loopedAnim, item.flipX, item.flipY);
			else
				animation.addByPrefix(item.name, item.prefix, item.frameRate, item.loopedAnim, item.flipX, item.flipY);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (data != null)
		{
			@:privateAccess
			data = {
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

	function set_animations(value:Array<JSONStageSpriteAnimation>):Array<JSONStageSpriteAnimation>
	{
		if (animations != value)
			updateAnimations();

		return animations = value;
	}
}
