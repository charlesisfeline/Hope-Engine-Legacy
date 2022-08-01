package editors;

import hscript.Interp;
import scripts.ScriptEssentials;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxObject;
import PlayState.StageJSON;
import flixel.addons.ui.FlxUI;
import flixel.math.FlxAngle;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import openfl.geom.Rectangle;
import flixel.FlxSprite;
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

	var UI_box:FlxUI;

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

	var bgGroup:FlxTypedGroup<FlxSprite>;
	var fgGroup:FlxTypedGroup<FlxSprite>;

	var dadInit:String = "dad";
	var bfInit:String = "bf";
	var gfInit:String = "gf";

	var camPos:FlxObject;
	var camFollow:FlxObject;

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

		#if FILESYSTEM
		var stageScript = File.getContent(Sys.getCwd() + "/" + Paths.stageScript(_stage.name));
		#else
		var stageScript = Assets.getText(Paths.stageScript(_stage.name));
		#end

		var ast = Main.console.parser.parseString(stageScript);

		stageInterp = new Interp();

		bgGroup = new FlxTypedGroup<FlxSprite>();
		add(bgGroup);

		ScriptEssentials.imports(stageInterp);
		stageInterp.variables.set("add", bgGroup.add);
		stageInterp.variables.set("remove", bgGroup.remove);
		stageInterp.variables.set("insert", bgGroup.insert);

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
		add(gf);

		dad = new Character(_stage.dadPosition[0], _stage.dadPosition[1], dadInit);
		dad.x += dad.positionOffset[0];
		dad.y += dad.positionOffset[1];
		dad.antialiasing = true;
		add(dad);

		bf = new Boyfriend(_stage.bfPosition[0], _stage.bfPosition[1], bfInit);
		bf.x += bf.positionOffset[0];
		bf.y += bf.positionOffset[1];
		bf.antialiasing = true;
		add(bf);

		fgGroup = new FlxTypedGroup<FlxSprite>();
		add(fgGroup);

		ScriptEssentials.imports(stageInterp);
		stageInterp.variables.set("add", fgGroup.add);
		stageInterp.variables.set("remove", fgGroup.remove);
		stageInterp.variables.set("insert", fgGroup.insert);
		
		if (stageInterp.variables.get("createForeground") != null)
			stageInterp.variables.get("createForeground")();
		

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camPos, null, 1);

		camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		curZoom = _stage.defaultCamZoom;
		FlxG.camera.zoom = _stage.defaultCamZoom;

		super.create();
	}

	var backing:Bool = false;

	var multiplier:Float = 1;
	var speed:Float = 180;

	var curZoom:Float = 1;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerp = Helper.boundTo(elapsed * 2.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, curZoom, Helper.boundTo(elapsed * 3.125, 0, 1));

		if (FlxG.keys.pressed.SHIFT)
			multiplier = 4;

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

		if (FlxG.keys.pressed.Q)
			curZoom -= 0.01 * multiplier;
		if (FlxG.keys.pressed.E)
			curZoom += 0.01 * multiplier;
		if (FlxG.mouse.wheel != 0)
			curZoom += FlxG.mouse.wheel * 0.1 * multiplier;

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
	}
}
