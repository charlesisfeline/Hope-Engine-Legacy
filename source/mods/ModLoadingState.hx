package mods;

import flixel.util.FlxTimer;
#if (FILESYSTEM && MODS_FEATURE)
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import yaml.Yaml;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class ModLoadingState extends MusicBeatState
{
	public static var instance:ModLoadingState;

	var selector:FlxText;

	static var curSelected:Int = 0;

	var scrollBarBG:FlxSprite;
	var scrollThing:FlxSprite;

	public var modGroup:FlxTypedGroup<FlxSprite>;

	var camFollow:FlxObject;
	var camPos:FlxObject;

	override function create()
	{
		instance = this;

		if (Paths.priorityMod != "hopeEngine")
		{
			if (Paths.exists(Paths.state("ModLoadingState")))
			{
				Paths.setCurrentMod(Paths.priorityMod);
				FlxG.switchState(new CustomState("ModLoadingState", MODSMENU));

				DONTFUCKINGTRIGGERYOUPIECEOFSHIT = true;
				return;
			}
		}

		if (Paths.priorityMod == "hopeEngine")
			Paths.setCurrentMod(null);
		else
			Paths.setCurrentMod(Paths.priorityMod);

		FlxG.mouse.visible = true;

		var menuBG:FlxBackdrop = new FlxBackdrop(Paths.image('menuDesat'), 1, 1, false);
		menuBG.color = 0xFFea71fd;
		menuBG.scrollFactor.set(0, 0.2);
		menuBG.antialiasing = true;
		add(menuBG);

		modGroup = new FlxTypedGroup<FlxSprite>();
		add(modGroup);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		camPos = new FlxObject(0, 0, 1, 1);
		add(camPos);

		for (mod in FileSystem.readDirectory("mods"))
		{
			var modInfo:Dynamic = Yaml.parse("name: No mod info file!\nicon-antialiasing: true");

			if (Paths.exists(Paths.modInfoFile(mod)))
				modInfo = cast Yaml.parse(File.getContent(Paths.modInfoFile(mod)));

			var pain = new ModWidget(0, 0, mod, modInfo.get("name"), modInfo.get("description"), modInfo.get("version"),
				Helper.toBool(modInfo.get("icon-antialiasing")));
			pain.screenCenter();
			pain.scrollFactor.set(1, 1);
			pain.y += modGroup.length * 225;
			pain.ID = modGroup.length;
			modGroup.add(pain);
		}

		if (modGroup.length < 1)
		{
			curSelected = 0;
			var pain = new FlxText(0, 0, "No mods available! Add some mods!", 64);
			pain.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			pain.borderSize = 3;
			pain.screenCenter();
			pain.scrollFactor.set(1, 1);
			pain.y += modGroup.length * 225;
			pain.ID = modGroup.length;
			modGroup.add(pain);
		}
		else
		{
			if (modGroup.members[curSelected] == null)
				curSelected = 0;
		}

		FlxG.camera.follow(camPos, LOCKON, 1);
		camPos.x = FlxG.width / 2;
		camPos.y = modGroup.members[curSelected].y + (modGroup.members[curSelected].height / 2);
		changeItem();

		var modSkeleton = new FlxUIButton(0, 0, 'Create Mod\nSkeleton');
		modSkeleton.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		modSkeleton.resize(80, modSkeleton.height * 2);
		modSkeleton.scrollFactor.set();
		modSkeleton.x = FlxG.width - modSkeleton.width - 10;
		modSkeleton.y = FlxG.height - modSkeleton.height - 10;
		add(modSkeleton);

		modSkeleton.onUp.callback = function()
		{
			persistentUpdate = false;
			persistentDraw = true;

			openSubState(new ModSkeletonSubstate());
		}

		var disableAll = new FlxButton(0, 0, 'Disable All', function() {
			for (sprite in modGroup) 
			{
				if (sprite is ModWidget)
				{
					var wid:ModWidget = cast sprite;
					if (Paths.checkModLoad(wid.modRepping))
						wid.buttonToggle();
				}
			}
		});
		disableAll.x = FlxG.width - disableAll.width - 10;
		disableAll.y = modSkeleton.y - disableAll.height - 10;
		disableAll.color = FlxColor.RED;
		disableAll.label.color = FlxColor.BLACK;
		add(disableAll);

		var enableAll = new FlxButton(0, 0, 'Enable All', function() {
			for (sprite in modGroup) 
			{
				if (sprite is ModWidget)
				{
					var wid:ModWidget = cast sprite;
					if (!Paths.checkModLoad(wid.modRepping))
						wid.buttonToggle();
				}
			}
		});
		enableAll.x = FlxG.width - enableAll.width - 10;
		enableAll.y = disableAll.y - enableAll.height - 10;
		enableAll.color = FlxColor.LIME;
		enableAll.label.color = FlxColor.BLACK;
		add(enableAll);

		var refresh = new FlxButton(0, 0, 'Refresh', refresh);
		refresh.x = FlxG.width - refresh.width - 10;
		refresh.y = enableAll.y - refresh.height - 10;
		add(refresh);

		super.create();
	}

	// not even a refresh it just resets the state :troll:
	function refresh():Void
	{
		modGroup.visible = false;
		
		var pain = new FlxText(0, 0, "Refreshing...", 64);
		pain.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		pain.borderSize = 3;
		pain.screenCenter();
		pain.scrollFactor.set(0, 0);
		add(pain);

		new FlxTimer().start(FlxG.random.float(0.5, 0.7), function(_) {
			FlxG.resetState();
		});
	}

	function changeItem(huh:Int = 0)
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += huh;

		if (curSelected >= modGroup.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = modGroup.length - 1;

		modGroup.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				camFollow.setPosition(spr.x + spr.width / 2, spr.y + spr.height / 2);
			}
		});
	}

	var DONTFUCKINGTRIGGERYOUPIECEOFSHIT:Bool = false;

	override function update(elapsed:Float)
	{
		if (DONTFUCKINGTRIGGERYOUPIECEOFSHIT)
			return;

		super.update(elapsed);
		
		var lerp:Float = Helper.boundTo(elapsed * 9.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);

		if (controls.UI_BACK)
		{
			#if (FILESYSTEM && MODS_FEATURE)
			var prevMod = Paths.currentMod;

			for (mod in FileSystem.readDirectory('mods'))
			{
				Paths.setCurrentMod(mod);
				if (Paths.checkModLoad(mod))
					CoolUtil.loadCustomDifficulties();
			}

			Paths.setCurrentMod(prevMod);
			#end

			CustomTransition.switchTo(new MainMenuState());
			FlxG.mouse.visible = false;
		}

		if (controls.UI_UP_P)
			changeItem(-1);

		if (controls.UI_DOWN_P)
			changeItem(1);

		if (FlxG.mouse.wheel != 0)
			changeItem(-FlxG.mouse.wheel);
	}
}

class ModWidget extends FlxSpriteGroup
{
	public var icon:FlxSprite;
	public var iconBG:FlxSprite;

	public var modName:FlxText;
	public var modNameBG:FlxSprite;

	public var modDesc:FlxText;
	public var modDescBG:FlxSprite;

	public var daSwitch:FlxUIButton;
	public var prioritySwitch:FlxUIButton;

	public var modRepping:String;

	public var versionText:FlxText;

	public function new(x:Float, y:Float, modFolder:String, ?name:String, ?description:String, ?version:String, ?iconAntialiasing:Bool)
	{
		super(x, y);

		modRepping = modFolder;

		name = name != null ? name : "Mod name not found.";
		description = description != null ? description : "Mod description not found.";
		version = version != null ? version : "";
		iconAntialiasing = iconAntialiasing != null ? iconAntialiasing : true;

		// mf aint \n literally wth
		name = name.replace("\\n", "\n");
		description = description.replace("\\n", "\n");
		version = version.replace("\\n", "\n");

		iconBG = new FlxSprite().makeGraphic(200, 200, FlxColor.BLACK);
		iconBG.alpha = 0.4;

		modNameBG = new FlxSprite(205, 0).makeGraphic(600, 50, FlxColor.BLACK);
		modNameBG.alpha = 0.4;

		modDescBG = new FlxSprite(205, 55).makeGraphic(600, 145, FlxColor.BLACK);
		modDescBG.alpha = 0.4;

		var loadedBitmap:BitmapData = null;

		if (FileSystem.exists('mods/$modFolder/icon.png'))
			loadedBitmap = BitmapData.fromFile('mods/$modFolder/icon.png');

		icon = new FlxSprite();

		if (loadedBitmap != null)
		{
			icon.loadGraphic(loadedBitmap, true, 150, 150);

			var totalFrames = Math.floor(loadedBitmap.width / 150) * Math.floor(loadedBitmap.height / 150);
			icon.animation.add("icon", [for (i in 0...totalFrames) i], 10);
			icon.animation.play("icon");
		}
		else
			icon.loadGraphic(Paths.image('no-icon'));

		icon.setGraphicSize(Std.int(iconBG.width - 25), Std.int(iconBG.height - 25));
		icon.updateHitbox();
		icon.setPosition(iconBG.x + 12.5, iconBG.y + 12.5);

		icon.antialiasing = iconAntialiasing;

		modName = new FlxText(0, 5, modNameBG.width - 10);
		modName.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		modName.borderSize = 2;
		modName.text = name;
		modName.x = modNameBG.x + 5;
		modName.y = modNameBG.y + (modNameBG.height / 2) - (modName.height / 2);

		modDesc = new FlxText(0, modDescBG.y + 5, modDescBG.width - 10);
		modDesc.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		modDesc.borderSize = 2;
		modDesc.text = description;
		modDesc.x = modDescBG.x + 5;

		versionText = new FlxText(0, 0, modDescBG.width - 10);
		versionText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.borderSize = 2;
		versionText.text = version;
		versionText.x = modDescBG.x + 5;
		versionText.y = modDescBG.y + modDescBG.height - versionText.height - 5;

		add(iconBG);
		add(modNameBG);
		add(modDescBG);

		add(icon);
		add(modName);
		add(modDesc);
		add(versionText);

		daSwitch = new FlxUIButton(0, 0, '');
		daSwitch.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		daSwitch.resize(50, 30);
		daSwitch.updateHitbox();
		daSwitch.label.resize(50, 24);
		daSwitch.label.offset.y = 5;
		daSwitch.x = modDescBG.x + modDescBG.width - daSwitch.width - 10;
		daSwitch.y = modDescBG.y + modDescBG.height - daSwitch.height - 10;
		daSwitch.label.color = FlxColor.BLACK;
		add(daSwitch);

		prioritySwitch = new FlxUIButton(0, 0, 'Prioritize?');
		prioritySwitch.loadGraphicSlice9([Paths.image('customButton')], 20, 20, [[4, 4, 16, 16]], false, 20, 20);
		prioritySwitch.resize(120, 30);
		prioritySwitch.updateHitbox();
		prioritySwitch.label.resize(120, 24);
		prioritySwitch.x = daSwitch.x - prioritySwitch.width - 10;
		prioritySwitch.y = modDescBG.y + modDescBG.height - prioritySwitch.height - 10;
		prioritySwitch.label.offset.y = 5;
		prioritySwitch.label.color = FlxColor.BLACK;
		add(prioritySwitch);

		buttonToggle(true);
		updatePriority();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (daSwitch.justPressed)
			buttonToggle();

		if (prioritySwitch.justPressed)
			priorityToggle();
	}

	function priorityToggle():Void
	{
		if (Paths.priorityMod == modRepping)
			FlxG.save.data.priority = Paths.priorityMod = "hopeEngine";
		else
			FlxG.save.data.priority = Paths.priorityMod = modRepping;

		FlxG.save.flush();

		for (mod in ModLoadingState.instance.modGroup.members)
		{
			var s:ModWidget = cast mod;
			s.updatePriority();
		}
	}

	public function updatePriority():Void
	{
		if (modRepping == Paths.priorityMod)
		{
			prioritySwitch.color = 0xFF00FF00;
			prioritySwitch.label.text = "Priority!";
		}
		else
		{
			prioritySwitch.color = 0xFFFF0000;
			prioritySwitch.label.text = "Prioritize?";
		}
	}

	public function buttonToggle(init:Bool = false):Void
	{
		var loadModFile:String = Paths.loadModFile(modRepping);

		if (!Paths.exists(loadModFile)) return;

		if (FileSystem.exists(loadModFile))
		{
			if (!init)
			{
				if (Paths.checkModLoad(modRepping))
				{
					Yaml.write(loadModFile, {
						'load': false
					});
				}
				else
				{
					Yaml.write(loadModFile, {
						'load': true
					});
				}
			}
		}
		else
		{
			Yaml.write(loadModFile, {
				'load': false
			});
		}

		if (!Paths.checkModLoad(modRepping))
		{
			if (!init)
				FlxG.sound.play(Paths.sound('modToggleOff'));

			daSwitch.color = 0xFFFF0000;
			daSwitch.label.text = "OFF";
		}
		else
		{
			if (!init)
				FlxG.sound.play(Paths.sound('modToggleOn'));

			daSwitch.color = 0xFF00FF00;
			daSwitch.label.text = "ON";
		}
	}
}
#end
