package editors;

import Stage.StageJSON;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import hscript.Interp;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.Rectangle;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import scripts.ScriptEssentials;
import ui.*;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
#if desktop
import Discord.DiscordClient;
#end

class StageJSONCreator extends MusicBeatState
{
	public static var fromEditors:Bool = false;

	var UI_box:FlxUITabMenu;

	var _stage:StageJSON = {
		name: "stage",
		bfPosition: [770, 450],
		gfPosition: [400, 130],
		dadPosition: [100, 100],
		defaultCamZoom: 0.9,
		isHalloween: false
	}

	var stageInterp:Interp;

	var dad:Character;
	var gf:Character;
	var bf:Boyfriend;

	var stageGroup:FlxTypedGroup<FlxBasic>;

	var dadInit:String = "dad";
	var bfInit:String = "bf";
	var gfInit:String = "gf";

	var camPos:FlxObject;
	var camFollow:FlxObject;

	var camEdit:FlxCamera;
	var camHUD:FlxCamera;

	public function new(?stageJson:StageJSON, ?dadInit:String = "dad", ?bfInit:String = "bf", ?gfInit:String = "gf")
	{
		super();

		if (stageJson != null)
			this._stage = stageJson;

		this.dadInit = dadInit;
		this.bfInit = bfInit;
		this.gfInit = gfInit;
	}

	override function create()
	{
		#if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end

		#if desktop
		DiscordClient.changePresence("Stage JSON Creator");
		#end

		FlxG.mouse.visible = true;

		camEdit = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camEdit);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camEdit];

		#if FILESYSTEM
		var stageScript = File.getContent(Sys.getCwd() + "/" + Paths.stageScript(_stage.name));
		#else
		var stageScript = Assets.getText(Paths.stageScript(_stage.name));
		#end

		var ast = Main.console.parser.parseString(stageScript);

		stageInterp = new Interp();

		stageGroup = new FlxTypedGroup<FlxBasic>();
		add(stageGroup);

		ScriptEssentials.imports(stageInterp);
		doVars();

		try
		{
			stageInterp.execute(ast);
		}
		catch (e:Dynamic)
		{
			Main.console.add(e, PLAYSTATE);
		}

		if (stageInterp.variables.get("createBackground") != null)
			stageInterp.variables.get("createBackground")();

		gf = new Character(_stage.gfPosition[0], _stage.gfPosition[1], gfInit);
		gf.x += gf.positionOffset[0];
		gf.y += gf.positionOffset[1];
		gf.antialiasing = true;
		gf.scrollFactor.set(0.95, 0.95);
		stageGroup.add(gf);

		dad = new Character(_stage.dadPosition[0], _stage.dadPosition[1], dadInit);
		dad.x += dad.positionOffset[0];
		dad.y += dad.positionOffset[1];
		dad.antialiasing = true;
		stageGroup.add(dad);

		bf = new Boyfriend(_stage.bfPosition[0], _stage.bfPosition[1], bfInit);
		bf.x += bf.positionOffset[0];
		bf.y += bf.positionOffset[1];
		bf.antialiasing = true;
		stageGroup.add(bf);

		ScriptEssentials.imports(stageInterp);
		doVars();
		
		if (stageInterp.variables.get("createForeground") != null)
			stageInterp.variables.get("createForeground")();
		

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camPos, null, 1);

		camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		curZoom = _stage.defaultCamZoom != null ? _stage.defaultCamZoom : 1.05;
		FlxG.camera.zoom = _stage.defaultCamZoom != null ? _stage.defaultCamZoom : 1.05;

		var tabs = [
			{name: "1", label: 'Stage'},
			{name: "2", label: 'Characters'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(350, 200);
		UI_box.x = FlxG.width - UI_box.width - 10;
		UI_box.y = FlxG.height - UI_box.height - 50;
		add(UI_box);
		UI_box.cameras = [camHUD];

		addStageStuff();
		addCharStuff();

		var standardSave:FlxButton = new FlxButton(0, 0, "Save Stage", saveJSON);
		var standardLoad:FlxButton = new FlxButton(0, 0, "Load Stage", function()
			{
				camHUD.visible = false;
				openSubState(new ConfirmationPrompt("You sure?", "Be sure to save your progress. Your progress will be lost if it is left unsaved!", "Sure", "Nah", loadJSON, 
				function()
				{
					FlxG.mouse.visible = camHUD.visible = true;
				}));
			});

		standardLoad.x = FlxG.width - standardLoad.width - 10;
		standardLoad.y = FlxG.height - standardLoad.height - 10;

		standardSave.y = standardLoad.y;
		standardSave.x = standardLoad.x - standardSave.width - 10;

		add(standardSave);
		add(standardLoad);

		standardSave.cameras = [camHUD];
		standardLoad.cameras = [camHUD];

		super.create();
	}

	var dadPosX:NumStepperFix;
	var dadPosY:NumStepperFix;
	var gfPosX:NumStepperFix;
	var gfPosY:NumStepperFix;
	var bfPosX:NumStepperFix;
	var bfPosY:NumStepperFix;

	function addStageStuff():Void
	{
		var dadPosXTitle = new FlxText(10, 10, "Dad's X Position");
		dadPosX = new NumStepperFix(10, dadPosXTitle.y + dadPosXTitle.height, 10, _stage.dadPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		dadPosX.callback = function(_) {
			dad.x = dadPosX.value;
			dad.x += dad.positionOffset[0];
		}

		var dadPosYTitle = new FlxText(UI_box.width / 2 + 5, 10, "Dad's Y Position");
		dadPosY = new NumStepperFix(UI_box.width / 2 + 5, dadPosYTitle.y + dadPosYTitle.height, 10, _stage.dadPosition[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		dadPosY.callback = function(_) {
			dad.y = dadPosY.value;
			dad.y += dad.positionOffset[1];
		}

		var gfPosXTitle = new FlxText(10, 50, "GF's X Position");
		gfPosX = new NumStepperFix(10, gfPosXTitle.y + gfPosXTitle.height, 10, _stage.gfPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		gfPosX.callback = function(_) {
			gf.x = gfPosX.value;
			gf.x += gf.positionOffset[0];
		}

		var gfPosYTitle = new FlxText(UI_box.width / 2 + 5, 50, "GF's Y Position");
		gfPosY = new NumStepperFix(UI_box.width / 2 + 5, gfPosYTitle.y + gfPosYTitle.height, 10, _stage.gfPosition[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		gfPosY.callback = function(_) {
			gf.y = gfPosY.value;
			gf.y += gf.positionOffset[1];
		}

		var bfPosXTitle = new FlxText(10, 90, "BF's X Position");
		bfPosX = new NumStepperFix(10, bfPosXTitle.y + bfPosXTitle.height, 10, _stage.bfPosition[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		bfPosX.callback = function(_) {
			bf.x = bfPosX.value;
			bf.x += bf.positionOffset[0];
		}

		var bfPosYTitle = new FlxText(UI_box.width / 2 + 5, 90, "BF's Y Position");
		bfPosY = new NumStepperFix(UI_box.width / 2 + 5, bfPosYTitle.y + bfPosYTitle.height, 10, _stage.bfPosition[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY,
			2, new InputTextFix(0, 0, Std.int(UI_box.width / 2 - 50)));
		bfPosY.callback = function(_) {
			bf.y = bfPosY.value;
			bf.y += bf.positionOffset[1];
		}

		///

		var focusDad = new FlxButton(0, 0, "Focus Dad", function() {
			curZoom = _stage.defaultCamZoom != null ? _stage.defaultCamZoom : 1.05;

			var offsetX = dad.cameraOffset[0];
			var offsetY = dad.cameraOffset[1];

			camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
		});
		focusDad.x = 10;
		focusDad.y = UI_box.height - focusDad.height - 30;

		var focusGF = new FlxButton(0, 0, "Focus GF", function() {
			curZoom = _stage.defaultCamZoom != null ? _stage.defaultCamZoom : 1.05;
			var offsetX = gf.cameraOffset[0];
			var offsetY = gf.cameraOffset[1];

			camFollow.setPosition(gf.getMidpoint().x + 150 + offsetX, gf.getMidpoint().y - 100 + offsetY);
		});
		focusGF.x = focusDad.x + focusDad.width + 10;
		focusGF.y = focusDad.y;

		var focusBF = new FlxButton(0, 0, "Focus BF", function() {
			curZoom = _stage.defaultCamZoom != null ? _stage.defaultCamZoom : 1.05;
			var offsetX = bf.cameraOffset[0];
			var offsetY = bf.cameraOffset[1];

			camFollow.setPosition(bf.getMidpoint().x - 100 + offsetX, bf.getMidpoint().y - 100 + offsetY);
		});
		focusBF.x = focusGF.x + focusGF.width + 10;
		focusBF.y = focusDad.y;

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

			var index = stageGroup.members.indexOf(dad);
			var item:Character = cast stageGroup.remove(dad, true);
			var pos = [item.x, item.y];
			item.exists = false;
			item.kill();
			item.destroy();

			dad = new Character(pos[0], pos[1], dadCharacter.selectedLabel);
			stageGroup.insert(index, dad);

			openfl.system.System.gc();
		}

		var gfCharacterTitle = new FlxText(dadCharacter.x + daWidth + 10, 10, 0, "GF Character");

		gfCharacter = new DropdownMenuFix(gfCharacterTitle.x, gfCharacterTitle.y + gfCharacterTitle.height,
			DropdownMenuFix.makeStrIdLabelArray(characters, true), new FlxUIDropDownHeader(daWidth));
		gfCharacter.selectedLabel = gf.curCharacter;
		gfCharacter.scrollable = true;
		gfCharacter.callback = function(_) {
			if (gfCharacter.selectedLabel == gf.curCharacter) return;

			var index = stageGroup.members.indexOf(gf);
			var item:Character = cast stageGroup.remove(gf, true);
			var pos = [item.x, item.y];
			item.exists = false;
			item.kill();
			item.destroy();

			gf = new Character(pos[0], pos[1], gfCharacter.selectedLabel);
			stageGroup.insert(index, gf);

			openfl.system.System.gc();
		}

		var bfCharacterTitle = new FlxText(gfCharacter.x + daWidth + 10, 10, 0, "BF Character");

		bfCharacter = new DropdownMenuFix(bfCharacterTitle.x, bfCharacterTitle.y + bfCharacterTitle.height,
			DropdownMenuFix.makeStrIdLabelArray(characters, true), new FlxUIDropDownHeader(daWidth));
		bfCharacter.selectedLabel = bf.curCharacter;
		bfCharacter.scrollable = true;
		bfCharacter.callback = function(_) {
			if (bfCharacter.selectedLabel == bf.curCharacter) return;

			var index = stageGroup.members.indexOf(bf);
			var item:Boyfriend = cast stageGroup.remove(bf, true);
			var pos = [item.x, item.y];
			item.exists = false;
			item.kill();
			item.destroy();

			bf = new Boyfriend(pos[0], pos[1], bfCharacter.selectedLabel);
			stageGroup.insert(index, bf);

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

	function refresh():Void
	{
		while (stageGroup.members.length > 0)
		{
			if (stageGroup.members[0] == dad || stageGroup.members[0] == bf || stageGroup.members[0] == gf) continue;
			
			var s = stageGroup.members.shift();
			s.exists = false;
			s.kill();
			s.destroy();
		}

		#if FILESYSTEM
		var stageScript = File.getContent(Sys.getCwd() + "/" + Paths.stageScript(_stage.name));
		#else
		var stageScript = Assets.getText(Paths.stageScript(_stage.name));
		#end

		var ast = Main.console.parser.parseString(stageScript);

		ScriptEssentials.imports(stageInterp);
		doVars();

		try
		{
			stageInterp.execute(ast);
		}
		catch (e:Dynamic)
		{
			Main.console.add(e, PLAYSTATE);
		}

		stageGroup.remove(dad, true);
		stageGroup.remove(gf, true);
		stageGroup.remove(bf, true);

		if (stageInterp.variables.get("createBackground") != null)
			stageInterp.variables.get("createBackground")();

		stageGroup.add(gf);
		stageGroup.add(dad);
		stageGroup.add(bf);

		ScriptEssentials.imports(stageInterp);
		doVars();

		if (stageInterp.variables.get("createForeground") != null)
			stageInterp.variables.get("createForeground")();

		// force it
		openfl.system.System.gc();
	}

	function doVars():Void
	{
		stageInterp.variables.set("add", stageGroup.add);
		stageInterp.variables.set("remove", stageGroup.remove);
		stageInterp.variables.set("insert", stageGroup.insert);
		stageInterp.variables.set("boyfriend", bf);
		stageInterp.variables.set("gf", gf);
		stageInterp.variables.set("dad", dad);
	}

	var backing:Bool = false;

	var multiplier:Float = 1;
	var speed:Float = 180;

	var curZoom:Float = 1;

	// completely taken from RatingPosSubstate
	var mousePastPos:Array<Float> = [];
	var bfPastPos:Array<Float> = [];
	var gfPastPos:Array<Float> = [];
	var dadPastPos:Array<Float> = [];

	var changingBf:Bool = false;
	var changingDad:Bool = false;
	var changingGf:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerp = Helper.boundTo(elapsed * 2.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, curZoom, Helper.boundTo(elapsed * 3.125, 0, 1));
		multiplier = 1;

		if (!InputTextFix.isTyping)
		{
			if (FlxG.keys.pressed.SHIFT)
				multiplier = 4;
	
			if (FlxG.keys.anyJustPressed([W, A, S, D]))
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
	
			if (FlxG.keys.pressed.Q)
				curZoom -= 0.01 * multiplier;
			if (FlxG.keys.pressed.E)
				curZoom += 0.01 * multiplier;
			if (FlxG.mouse.wheel != 0 && !DropdownMenuFix.isDropdowning)
				curZoom += FlxG.mouse.wheel * 0.1 * multiplier;
	
			if (FlxG.keys.justPressed.F5)
				refresh();
	
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
				LoadingState.loadAndSwitchState(new MainMenuState());
			}

			if (FlxG.mouse.pressed)
			{
				if (!Helper.screenOverlap(UI_box))
				{
					if (FlxG.mouse.justPressed)
					{
						bfPastPos = [bf.x, bf.y];
						dadPastPos = [dad.x, dad.y];
						gfPastPos = [gf.x, gf.y];
						mousePastPos = [FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y];
					}
		
					if ((Helper.screenOverlap(bf) && !changingGf && !changingDad) || changingBf)
					{
						changingBf = true;
		
						bf.x = Math.round(bfPastPos[0] - (mousePastPos[0] - FlxG.mouse.getScreenPosition().x)) + bf.positionOffset[0];
						bf.y = Math.round(bfPastPos[1] - (mousePastPos[1] - FlxG.mouse.getScreenPosition().y)) + bf.positionOffset[1];
		
						_stage.bfPosition[0] = bf.x;
						_stage.bfPosition[1] = bf.y;
	
						updatePosSteppers();
					}
		
					if ((Helper.screenOverlap(dad) && !changingBf && !changingGf) || changingDad)
					{
						changingDad = true;
		
						dad.x = Math.round(dadPastPos[0] - (mousePastPos[0] - FlxG.mouse.getScreenPosition().x)) + dad.positionOffset[0];
						dad.y = Math.round(dadPastPos[1] - (mousePastPos[1] - FlxG.mouse.getScreenPosition().y)) + dad.positionOffset[1];
		
						_stage.dadPosition[0] = dad.x;
						_stage.dadPosition[1] = dad.y;
	
						updatePosSteppers();
					}
		
					if ((Helper.screenOverlap(gf) && !changingBf && !changingDad) || changingGf)
					{
						changingGf = true;
		
						gf.x = Math.round(gfPastPos[0] - (mousePastPos[0] - FlxG.mouse.getScreenPosition().x)) + gf.positionOffset[0];
						gf.y = Math.round(gfPastPos[1] - (mousePastPos[1] - FlxG.mouse.getScreenPosition().y)) + gf.positionOffset[1];
		
						_stage.gfPosition[0] = gf.x;
						_stage.gfPosition[1] = gf.y;
	
						updatePosSteppers();
					}
				}
			}
	
			if (FlxG.mouse.justReleased)
			{
				changingBf = false;
				changingDad = false;
				changingGf = false;
			}

			if (FlxG.keys.justPressed.R)
			{
				_stage.bfPosition = [770, 450];
				_stage.dadPosition = [100, 100];
				_stage.gfPosition = [400, 130];
	
				gf.setPosition(_stage.gfPosition[0] + gf.positionOffset[0], _stage.gfPosition[1] + gf.positionOffset[1]);
				dad.setPosition(_stage.dadPosition[0] + dad.positionOffset[0], _stage.dadPosition[1] + dad.positionOffset[1]);
				bf.setPosition(_stage.bfPosition[0] + bf.positionOffset[0], _stage.bfPosition[1] + bf.positionOffset[1]);

				updatePosSteppers();
			}
		}
	}

	function updatePosSteppers():Void
	{
		bfPosX.value = _stage.bfPosition[0];
		bfPosX.callback(0);
		bfPosY.value = _stage.bfPosition[1];
		bfPosY.callback(0);
		dadPosX.value = _stage.dadPosition[0];
		dadPosX.callback(0);
		dadPosY.value = _stage.dadPosition[1];
		dadPosY.callback(0);
		gfPosX.value = _stage.gfPosition[0];
		gfPosX.callback(0);
		gfPosY.value = _stage.gfPosition[1];
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

		var stage:StageJSON = cast Json.parse(File.getContent(path).trim());
		CustomTransition.switchTo(new StageJSONCreator(stage, dad.curCharacter, bf.curCharacter, gf.curCharacter));

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
		var data:String = Json.stringify(_stage, null, "\t");

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
