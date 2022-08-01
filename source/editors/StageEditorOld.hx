package editors;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.system.FlxAssets.FlxGraphicAsset;
import PlayState.StageJSON;
import flixel.addons.ui.FlxUI;
import flixel.math.FlxAngle;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import openfl.geom.Rectangle;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import ui.*;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
#if desktop
import Discord.DiscordClient;
#end

class StageEditor extends MusicBeatState
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

	var bgGroup:FlxTypedGroup<FlxSprite>;
	var chGroup:FlxTypedGroup<Character>;
	var fgGroup:FlxTypedGroup<FlxSprite>;

	var dad:Character;
	var gf:Character;
	var bf:Boyfriend;

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
		DiscordClient.changePresence("Somewhere in Nevada");
		#end

		FlxG.mouse.visible = true;

		bgGroup = new FlxTypedGroup<FlxSprite>();
		add(bgGroup);

		chGroup = new FlxTypedGroup<Character>();
		add(chGroup);

		gf = new Character(_stage.gfPosition[0], _stage.gfPosition[1], gfInit);
		gf.x += gf.positionOffset[0];
		gf.y += gf.positionOffset[1];
		gf.antialiasing = true;
		gf.scrollFactor.set(0.95, 0.95);
		chGroup.add(gf);

		dad = new Character(_stage.dadPosition[0], _stage.dadPosition[1], dadInit);
		dad.x += dad.positionOffset[0];
		dad.y += dad.positionOffset[1];
		dad.antialiasing = true;
		chGroup.add(dad);

		bf = new Boyfriend(_stage.bfPosition[0], _stage.bfPosition[1], bfInit);
		bf.x += bf.positionOffset[0];
		bf.y += bf.positionOffset[1];
		bf.antialiasing = true;
		chGroup.add(bf);

		fgGroup = new FlxTypedGroup<FlxSprite>();
		add(fgGroup);

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camPos, null, 1);

		var s = new FlxText(0, 0, FlxG.width, "Mm, maybe not.\n\nI urge you to learn Haxe and how HaxeFlixel works!\nMaking an editor that's essentially like Scratch is not for the sane.\nI think I still have a bit of sanity left... right?");
		s.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		s.scrollFactor.set();
		s.screenCenter();
		add(s);

		super.create();
	}

	var backing:Bool = false;

	var multiplier:Float = 1;
	var speed:Float = 180;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerp = Helper.boundTo(elapsed * 2.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);

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

class StageSprite extends FlxSprite
{
	var imagePathUsed:Null<String> = null;
	var variableName:Null<String> = null;
	var lib:Null<String> = null;

	static var idInt:Int = 0;

	public function new()
	{
		super(0, 0);
	}

	public function loadImage(imagePath:String, ?lib:String)
	{
		loadGraphic(Paths.image(imagePath, lib));
		imagePathUsed = imagePath;
		this.lib = lib;

		return this;
	}

	public function generateSpriteCode():String
	{
		var lines:Array<String> = [];
		var varNameReal:String = variableName != null ? variableName : "sprite" + idInt++;

		var newLine = 'var $varNameReal = new FlxSprite($x, $y);';
		var loadLine = '$varNameReal.loadGraphic(Paths.image("$imagePathUsed"${lib != null ? ', "$lib"' : ''}));';

		var imageExists = Paths.exists(Paths.image(imagePathUsed, lib));
		var xmlExists = Paths.exists(Paths.file('images/$imagePathUsed.xml', lib));

		lines.push(newLine);

		if (imagePathUsed != null && !imageExists && !xmlExists)
			lines.push(loadLine);

		var scaleX:Null<Float> = scale.x;
		var scaleY:Null<Float> = scale.y;

		if (scaleX != 1 || scaleY != 1)
		{
			lines.push('$varNameReal.scale.set($scaleX, $scaleY);');
			lines.push('$varNameReal.updateHitbox();');
		}

		if (angle != 0)
			lines.push('$varNameReal.angle = $angle;');

		var scrollX:Null<Float> = scrollFactor.x;
		var scrollY:Null<Float> = scrollFactor.y;

		if (scrollX != 1 || scrollY != 1)
			lines.push('$varNameReal.scale.set($scrollX, $scrollY);');

		lines.push('add($varNameReal);');

		return lines.join("\n").trim();
	}
}