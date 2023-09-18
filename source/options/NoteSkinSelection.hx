package options;

// this shit's just a superior image and file replacer
<<<<<<< HEAD
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import yaml.Yaml;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class NoteSkinSelection extends MusicBeatSubstate
{
	#if FILESYSTEM
	var registeredPreviews:Array<FlxSpriteGroup> = [];
	var registeredPixelPreviews:Array<FlxSpriteGroup> = [];
	var previewTargetYs:Array<Int> = [];
	var pixelPreviewsActive:Array<Null<Bool>> = [];
=======
import flixel.graphics.FlxGraphic;
#if FILESYSTEM
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class NoteSkinSelection extends MusicBeatSubstate
{
	var registeredPreviews:Array<FlxSpriteGroup> = [];
>>>>>>> upstream

	public static var registeredSkins:Array<String> = ["default"];

	var bg:FlxSprite;
<<<<<<< HEAD
=======
	var arrows:FlxSprite;
>>>>>>> upstream

	var previousOptionText:FlxText;
	var nextOptionText:FlxText;
	var infoText:FlxText;
	var skinName:FlxText;
<<<<<<< HEAD
	var skinCreator:FlxText;
=======
>>>>>>> upstream
	var skinDesc:FlxText;

	var splashSparrow:FlxAtlasFrames;

	public static var loadedNoteSkins:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	public static var loadedSplashes:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	public function new()
	{
		super();

<<<<<<< HEAD
		if (registeredSkins.length - 1 != FileSystem.readDirectory(Sys.getCwd() + "/skins").length)
=======
		if (registeredSkins.length - 1 != FileSystem.readDirectory(Sys.getCwd() + "/assets/skins").length)
>>>>>>> upstream
			refreshSkins();

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), 0xFF000000);
		bg.scrollFactor.set();
		bg.alpha = 0.6;
		bg.screenCenter();
		add(bg);

<<<<<<< HEAD
		infoText = new FlxText(FlxG.width * 0.5 + 10, 0, FlxG.width * 0.5 - 20,
			"Skins folder is at the \"skins\" folder.\nSee \"swag\" folder on how one works.\nPress ESCAPE to save choice.\nPress BACKSPACE to leave without saving.",
			72);
		infoText.scrollFactor.set();
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 3;
		infoText.y = FlxG.height - infoText.height - 10;
		add(infoText);

		skinName = new FlxText(FlxG.width * 0.5 + 10, FlxG.height * 0.3, FlxG.width * 0.5 - 20, "", 72);
=======
		infoText = new FlxText(0, FlxG.height * 0.8, FlxG.width,
			"Skins folder is at assets/skins. See \"swag\" folder on how one works.\nPress ESCAPE to save choice, press BACKSPACE to leave without saving.",
			72);
		infoText.scrollFactor.set();
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 3;
		add(infoText);

		skinName = new FlxText(0, FlxG.height * 0.15, FlxG.width, "", 72);
>>>>>>> upstream
		skinName.scrollFactor.set();
		skinName.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skinName.borderSize = 3;
		add(skinName);

<<<<<<< HEAD
		skinCreator = new FlxText(FlxG.width * 0.5 + 10, skinName.y + skinName.height + 5, FlxG.width * 0.5 - 20, "", 72);
		skinCreator.scrollFactor.set();
		skinCreator.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skinCreator.borderSize = 3;
		add(skinCreator);

		skinDesc = new FlxText(FlxG.width * 0.5 + 10, skinName.y + skinName.height + 45, FlxG.width * 0.5 - 20, "", 72);
		skinDesc.scrollFactor.set();
		skinDesc.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skinDesc.borderSize = 3;
		add(skinDesc);

		// now create the previews
		createPreviews();

		var arrowUp = new FlxSprite();
		arrowUp.frames = Paths.getSparrowAtlas("arrow", "preload");
		arrowUp.animation.addByPrefix("a", "", 24);
		arrowUp.animation.play("a");
		arrowUp.x = FlxG.width * 0.25 - arrowUp.width * 0.5;
		arrowUp.flipY = true;
		arrowUp.y = FlxG.height * 0.1 - arrowUp.height;
		arrowUp.antialiasing = true;
		add(arrowUp);

		var arrowDown = new FlxSprite();
		arrowDown.frames = Paths.getSparrowAtlas("arrow", "preload");
		arrowDown.animation.addByPrefix("a", "", 24);
		arrowDown.animation.play("a");
		arrowDown.x = FlxG.width * 0.25 - arrowDown.width * 0.5;
		arrowDown.y = FlxG.height * 0.9;
		arrowDown.antialiasing = true;
		add(arrowDown);

		previousOptionText = new FlxText(0, 0, FlxG.width * 0.5, "", 32);
		previousOptionText.scrollFactor.set();
		previousOptionText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		previousOptionText.borderSize = 3;
		previousOptionText.y = FlxG.height * 0.2 - previousOptionText.height;
		add(previousOptionText);

		nextOptionText = new FlxText(0, 0, FlxG.width * 0.5, "", 32);
		nextOptionText.scrollFactor.set();
		nextOptionText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nextOptionText.borderSize = 3;
		nextOptionText.y = FlxG.height * 0.8;
		add(nextOptionText);

		changeItem((registeredSkins.indexOf(Settings.noteSkin) == -1 ? 0 : registeredSkins.indexOf(Settings.noteSkin)));
		changeItem();

		forEachOfType(FlxSprite, function(spr:FlxSprite)
		{
			var desiredAlpha:Float = 1;
			if (spr.alpha == 1)
				spr.alpha = 0;
			else
				desiredAlpha = spr.alpha;

			FlxTween.tween(spr, {alpha: desiredAlpha}, 0.5);
		}, true);
	}

	function createPreviews():Void
	{
=======
		skinDesc = new FlxText(0, FlxG.height * 0.05 + 50, FlxG.width, "The default one. Seems to be normal.", 72);
		skinDesc.scrollFactor.set();
		skinDesc.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skinDesc.borderSize = 3;
		// add(skinDesc);

		var arrow_tex = Paths.getSparrowAtlas('arrow');
		arrows = new FlxSprite();
		arrows.frames = arrow_tex;
		arrows.animation.addByPrefix('idle', "arrow idle", 24);
		arrows.animation.play('idle');
		arrows.scrollFactor.set();
		arrows.antialiasing = true;
		arrows.setGraphicSize(Std.int(FlxG.width * 1.0625), 0);
		arrows.updateHitbox();
		arrows.screenCenter();
		add(arrows);

		previousOptionText = new FlxText(0, 0, FlxG.width * 0.1875, "", 32);
		previousOptionText.scrollFactor.set();
		previousOptionText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		previousOptionText.borderSize = 3;
		previousOptionText.screenCenter(Y);
		add(previousOptionText);

		nextOptionText = new FlxText(FlxG.width * 0.8125, 0, FlxG.width * 0.1875, "", 32);
		nextOptionText.scrollFactor.set();
		nextOptionText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nextOptionText.borderSize = 3;
		nextOptionText.screenCenter(Y);
		add(nextOptionText);

		// now create the previews
>>>>>>> upstream
		for (skinName in registeredSkins)
		{
			var theSex:FlxAtlasFrames = null;
			if (skinName != "default")
				theSex = FlxAtlasFrames.fromSparrow(loadedNoteSkins.get(skinName),
<<<<<<< HEAD
					File.getContent(Sys.getCwd() + "skins/" + skinName + "/normal/NOTE_assets.xml"));
=======
					File.getContent(Sys.getCwd() + "assets/skins/" + skinName + "/normal/NOTE_assets.xml"));
>>>>>>> upstream

			var skinPreview:FlxSpriteGroup = new FlxSpriteGroup();

			for (noteType in 0...4)
			{
				for (noteDir in 0...4)
				{
<<<<<<< HEAD
					var pissArrow:FlxSprite = null;
					if (noteType == 0)
						pissArrow = new StaticArrow(0, 0);
					else
						pissArrow = new FlxSprite();
=======
					var pissArrow:FlxSprite = new FlxSprite();
>>>>>>> upstream

					if (theSex == null)
						pissArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared'); // use default
					else
						pissArrow.frames = theSex;

					switch (noteType)
					{
						case 0:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.addByPrefix('piss', 'arrowLEFT');
									pissArrow.animation.addByPrefix('piss pressed', 'left press', 24, false);
									pissArrow.animation.addByPrefix('piss confirm', 'left confirm', 24, false);
								case 1:
									pissArrow.animation.addByPrefix('piss', 'arrowDOWN');
									pissArrow.animation.addByPrefix('piss pressed', 'down press', 24, false);
									pissArrow.animation.addByPrefix('piss confirm', 'down confirm', 24, false);
								case 2:
									pissArrow.animation.addByPrefix('piss', 'arrowUP');
									pissArrow.animation.addByPrefix('piss pressed', 'up press', 24, false);
									pissArrow.animation.addByPrefix('piss confirm', 'up confirm', 24, false);
								case 3:
									pissArrow.animation.addByPrefix('piss', 'arrowRIGHT');
									pissArrow.animation.addByPrefix('piss pressed', 'right press', 24, false);
									pissArrow.animation.addByPrefix('piss confirm', 'right confirm', 24, false);
							}
						case 1:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.addByPrefix('piss', 'purple0');
								case 1:
									pissArrow.animation.addByPrefix('piss', 'blue0');
								case 2:
									pissArrow.animation.addByPrefix('piss', 'green0');
								case 3:
									pissArrow.animation.addByPrefix('piss', 'red0');
							}
						case 2:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.addByPrefix('hold piece', 'purple hold piece');
								case 1:
									pissArrow.animation.addByPrefix('hold piece', 'blue hold piece');
								case 2:
									pissArrow.animation.addByPrefix('hold piece', 'green hold piece');
								case 3:
									pissArrow.animation.addByPrefix('hold piece', 'red hold piece');
							}
						case 3:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.addByPrefix('hold end', 'pruple end hold');
								case 1:
									pissArrow.animation.addByPrefix('hold end', 'blue hold end');
								case 2:
									pissArrow.animation.addByPrefix('hold end', 'green hold end');
								case 3:
									pissArrow.animation.addByPrefix('hold end', 'red hold end');
							}
					}

					switch (noteType)
					{
						case 2:
							pissArrow.animation.play('hold piece');
						case 3:
							pissArrow.animation.play('hold end');
						default:
							pissArrow.animation.play('piss');
					}

					pissArrow.updateHitbox();
					pissArrow.antialiasing = true;
					skinPreview.add(pissArrow);

					if (pissArrow.animation.curAnim.name.startsWith('hold'))
					{
						pissArrow.setGraphicSize(Std.int(pissArrow.width * 0.7));
						if ((pissArrow.animation.curAnim.name.contains('piece')))
							pissArrow.setGraphicSize(Std.int(pissArrow.width * 0.7), Std.int(160 * 0.5));

						pissArrow.updateHitbox();
						pissArrow.x = skinPreview.members[skinPreview.members.length - 5].x
							+ (skinPreview.members[skinPreview.members.length - 5].width / 2)
							- (pissArrow.width / 2);

						pissArrow.y = 160 * 0.7 * noteType;
						if ((pissArrow.animation.curAnim.name.contains('end')))
							pissArrow.y = skinPreview.members[skinPreview.members.length - 5].y
								+ skinPreview.members[skinPreview.members.length - 5].height - 4;
					}
					else
					{
						pissArrow.setGraphicSize(Std.int(160 * 0.7));
						pissArrow.updateHitbox();
						pissArrow.x = 160 * 0.7 * noteDir;
						pissArrow.y = 160 * 0.7 * noteType;
<<<<<<< HEAD

						if (pissArrow is StaticArrow)
						{
							var arr:StaticArrow = cast pissArrow;
							arr.staticWidth = arr.width;
							arr.staticHeight = arr.height;
						}
					}
				}
			}
			// skinPreview.screenCenter();
			skinPreview.x = FlxG.width * 0.25 - skinPreview.width * 0.5;
=======
					}
				}
			}
			skinPreview.screenCenter();
			skinPreview.alpha = 0;
>>>>>>> upstream
			registeredPreviews.push(skinPreview);
			add(skinPreview);
		}

<<<<<<< HEAD
		// now let's do it all over again!

		for (skinName in registeredSkins)
		{
			var theSex:FlxGraphic = null;
			var theSex2:FlxGraphic = null;
			if (skinName != "default")
			{
				theSex = loadedNoteSkins.get(skinName + "-pixel");
				theSex2 = loadedNoteSkins.get(skinName + "-pixelEnds");

				if (theSex == null || theSex2 == null)
				{
					registeredPixelPreviews.push(null);
					pixelPreviewsActive.push(null);
					continue;
				}
			}

			var skinPreview:FlxSpriteGroup = new FlxSpriteGroup();

			for (noteType in 0...4)
			{
				for (noteDir in 0...4)
				{
					var pissArrow:FlxSprite = null;
					if (noteType == 0)
						pissArrow = new StaticArrow(0, 0, true);
					else
						pissArrow = new FlxSprite();

					if (theSex == null)
					{
						pissArrow.loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17); // use default

						if (noteType < 2)
							pissArrow.loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);
						else
							pissArrow.loadGraphic(Paths.image('pixelUI/arrowEnds'), true, 7, 6);
					}
					else
					{
						if (noteType < 2)
							pissArrow.loadGraphic(theSex, true, 17, 17);
						else
							pissArrow.loadGraphic(theSex2, true, 7, 6);
					}

					switch (noteType)
					{
						case 0:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.add('piss', [0]);
									pissArrow.animation.add('piss pressed', [4, 8], 12, false);
									pissArrow.animation.add('piss confirm', [12, 16], 24, false);
								case 1:
									pissArrow.animation.add('piss', [1]);
									pissArrow.animation.add('piss pressed', [5, 9], 12, false);
									pissArrow.animation.add('piss confirm', [13, 17], 24, false);
								case 2:
									pissArrow.animation.add('piss', [2]);
									pissArrow.animation.add('piss pressed', [6, 10], 12, false);
									pissArrow.animation.add('piss confirm', [14, 18], 24, false);
								case 3:
									pissArrow.animation.add('piss', [3]);
									pissArrow.animation.add('piss pressed', [7, 11], 12, false);
									pissArrow.animation.add('piss confirm', [15, 19], 24, false);
							}
						case 1:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.add('piss', [4]);
								case 1:
									pissArrow.animation.add('piss', [5]);
								case 2:
									pissArrow.animation.add('piss', [6]);
								case 3:
									pissArrow.animation.add('piss', [7]);
							}
						case 2:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.add('hold piece', [0]);
								case 1:
									pissArrow.animation.add('hold piece', [1]);
								case 2:
									pissArrow.animation.add('hold piece', [2]);
								case 3:
									pissArrow.animation.add('hold piece', [3]);
							}
						case 3:
							switch (noteDir)
							{
								case 0:
									pissArrow.animation.add('hold end', [4]);
								case 1:
									pissArrow.animation.add('hold end', [5]);
								case 2:
									pissArrow.animation.add('hold end', [6]);
								case 3:
									pissArrow.animation.add('hold end', [7]);
							}
					}

					switch (noteType)
					{
						case 2:
							pissArrow.animation.play('hold piece');
						case 3:
							pissArrow.animation.play('hold end');
						default:
							pissArrow.animation.play('piss');
					}

					pissArrow.setGraphicSize(Std.int(pissArrow.width * PlayState.daPixelZoom));
					pissArrow.updateHitbox();
					pissArrow.antialiasing = false;
					skinPreview.add(pissArrow);

					if (pissArrow.animation.curAnim.name.startsWith('hold'))
					{
						// pissArrow.setGraphicSize(Std.int(pissArrow.width * 0.7));
						if ((pissArrow.animation.curAnim.name.contains('piece')))
							pissArrow.setGraphicSize(Std.int(pissArrow.width), Std.int(160 * 0.5));

						pissArrow.updateHitbox();
						pissArrow.x = skinPreview.members[skinPreview.members.length - 5].x
							+ (skinPreview.members[skinPreview.members.length - 5].width / 2)
							- (pissArrow.width / 2);

						pissArrow.y = 160 * 0.7 * noteType;
						if ((pissArrow.animation.curAnim.name.contains('end')))
							pissArrow.y = skinPreview.members[skinPreview.members.length - 5].y
								+ skinPreview.members[skinPreview.members.length - 5].height - 4;
					}
					else
					{
						// pissArrow.setGraphicSize(Std.int(pissArrow.width * 0.7));
						pissArrow.updateHitbox();
						pissArrow.x = 160 * 0.7 * noteDir;
						pissArrow.y = 160 * 0.7 * noteType;

						if (pissArrow is StaticArrow)
						{
							var arr:StaticArrow = cast pissArrow;
							arr.staticWidth = arr.width;
							arr.staticHeight = arr.height;
						}
					}
				}
			}
			// skinPreview.screenCenter();
			skinPreview.x = FlxG.width * 0.25 - skinPreview.width * 0.5;
			registeredPixelPreviews.push(skinPreview);
			pixelPreviewsActive.push(false);
			add(skinPreview);
		}
=======
		forEachOfType(FlxSprite, function(spr:FlxSprite)
		{
			var desiredAlpha:Float = 1;
			if (spr.alpha == 1)
				spr.alpha = 0;
			else
				desiredAlpha = spr.alpha;

			FlxTween.tween(spr, {alpha: desiredAlpha}, 0.5);
		});

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			changeItem((registeredSkins.indexOf(Settings.noteSkin) == -1 ? 0 : registeredSkins.indexOf(Settings.noteSkin)));
		});
>>>>>>> upstream
	}

	public static function refreshSkins()
	{
		registeredSkins = ['default'];

<<<<<<< HEAD
		for (skinName in (FileSystem.readDirectory(Sys.getCwd() + "/skins")))
=======
		for (skinName in (FileSystem.readDirectory(Sys.getCwd() + "/assets/skins")))
>>>>>>> upstream
			registeredSkins.push(skinName);

		for (skinName in registeredSkins)
		{
			if (skinName != 'default')
			{
<<<<<<< HEAD
				loadedNoteSkins.remove(skinName);
				loadedSplashes.remove(skinName);

				loadedNoteSkins.remove(skinName + "-pixel");
				loadedNoteSkins.remove(skinName + "-pixelEnds");
				loadedSplashes.remove(skinName + "-pixel");

				var piss:BitmapData = BitmapData.fromFile(Sys.getCwd() + "skins/" + skinName + "/normal/NOTE_assets.png");
=======
				var piss:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/normal/NOTE_assets.png");
>>>>>>> upstream
				var shitoffmate:FlxGraphic = FlxGraphic.fromBitmapData(piss);
				shitoffmate.persist = true;
				shitoffmate.destroyOnNoUse = false;
				loadedNoteSkins.set(skinName, shitoffmate);

<<<<<<< HEAD
				if (FileSystem.exists(Sys.getCwd() + "skins/" + skinName + "/normal/note_splashes.png")
					&& FileSystem.exists(Sys.getCwd() + "skins/" + skinName + "/normal/note_splashes.xml"))
				{
					var noteSplashNormal:BitmapData = BitmapData.fromFile(Sys.getCwd() + "skins/" + skinName + "/normal/note_splashes.png");
=======
				if (FileSystem.exists(Sys.getCwd() + "assets/skins/" + skinName + "/normal/note_splashes.png")
					&& FileSystem.exists(Sys.getCwd() + "assets/skins/" + skinName + "/normal/note_splashes.xml"))
				{
					var noteSplashNormal:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/normal/note_splashes.png");
>>>>>>> upstream
					var shitoffmateSplash:FlxGraphic = FlxGraphic.fromBitmapData(noteSplashNormal);
					shitoffmateSplash.persist = true;
					shitoffmateSplash.destroyOnNoUse = false;
					loadedSplashes.set(skinName, shitoffmateSplash);
				}

<<<<<<< HEAD
				if (FileSystem.exists(Sys.getCwd() + "skins/" + skinName + "/pixel/"))
				{
					var piss2:BitmapData = BitmapData.fromFile(Sys.getCwd() + "skins/" + skinName + "/pixel/arrows-pixels.png");
=======
				if (FileSystem.exists(Sys.getCwd() + "assets/skins/" + skinName + "/pixel/"))
				{
					var piss2:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/pixel/arrows-pixels.png");
>>>>>>> upstream
					var shitoffmate2:FlxGraphic = FlxGraphic.fromBitmapData(piss2);
					shitoffmate2.persist = true;
					shitoffmate2.destroyOnNoUse = false;
					loadedNoteSkins.set(skinName + "-pixel", shitoffmate2);

<<<<<<< HEAD
					var piss3:BitmapData = BitmapData.fromFile(Sys.getCwd() + "skins/" + skinName + "/pixel/arrowEnds.png");
=======
					var piss3:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/pixel/arrowEnds.png");
>>>>>>> upstream
					var shitoffmate3:FlxGraphic = FlxGraphic.fromBitmapData(piss3);
					shitoffmate3.persist = true;
					shitoffmate3.destroyOnNoUse = false;
					loadedNoteSkins.set(skinName + "-pixelEnds", shitoffmate3);
<<<<<<< HEAD

					if (FileSystem.exists(Sys.getCwd() + "skins/" + skinName + "/pixel/pixel_splashes.png")
						&& FileSystem.exists(Sys.getCwd() + "skins/" + skinName + "/pixel/pixel_splashes.xml"))
					{
						var noteSplashPixel:BitmapData = BitmapData.fromFile(Sys.getCwd() + "skins/" + skinName + "/pixel/pixel_splashes.png");
						var shitoffmateSplash:FlxGraphic = FlxGraphic.fromBitmapData(noteSplashPixel);
						shitoffmateSplash.persist = true;
						shitoffmateSplash.destroyOnNoUse = false;
						loadedSplashes.set(skinName + "-pixel", shitoffmateSplash);
					}
=======
>>>>>>> upstream
				}
			}
		}

		// reset if it doesn't exist
		if (!registeredSkins.contains(Settings.noteSkin))
			Settings.noteSkin = "default";
	}

	var isPressedPlaying:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 4 == 0)
			isPressedPlaying = !isPressedPlaying;

		if (isPressedPlaying)
<<<<<<< HEAD
		{
			var shitPiss:StaticArrow = cast registeredPreviews[curSelected].members[curBeat % 4];

			if (pixelPreviewsActive[curSelected])
				shitPiss = cast registeredPixelPreviews[curSelected].members[curBeat % 4];

			shitPiss.playAnim('piss pressed');
		}
		else
		{
			var shitPiss:StaticArrow = cast registeredPreviews[curSelected].members[curBeat % 4];

			if (pixelPreviewsActive[curSelected])
				shitPiss = cast registeredPixelPreviews[curSelected].members[curBeat % 4];

			shitPiss.playAnim('piss confirm');
=======
			registeredPreviews[curSelected].members[curBeat % 4].animation.play('piss pressed');
		else
		{
			registeredPreviews[curSelected].members[curBeat % 4].animation.play('piss confirm');
>>>>>>> upstream

			if (splashSparrow != null)
			{
				if (Settings.noteSplashes)
				{
<<<<<<< HEAD
					var splash = new NoteSplash(splashSparrow);
					var strumNote:StaticArrow = shitPiss;

					if (pixelPreviewsActive[curSelected])
					{
						// the pixel splash asset is just the normal splash asset but divided by 6
						splash.setGraphicSize(Std.int(splash.width * PlayState.daPixelZoom));
						splash.updateHitbox();
						splash.antialiasing = false;
					}

					splash.strumNote = strumNote;

					splash.x = strumNote.x + (strumNote.staticWidth / 2) - (splash.width / 2);
					splash.y = strumNote.y + (strumNote.staticHeight / 2) - (splash.height / 2);

					add(splash);

					splash.splash(curBeat % 4);
=======
					var splash = new NoteSplash(curBeat % 4, splashSparrow);
					var strumNote = registeredPreviews[curSelected].members[curBeat % 4];

					splash.x = strumNote.x + (strumNote.width / 2) - (splash.width / 2);
					splash.y = strumNote.y + (strumNote.height / 2) - (splash.height / 2);

					add(splash);
>>>>>>> upstream
				}
			}
		}
	}

<<<<<<< HEAD
	var exiting:Bool = false;

=======
>>>>>>> upstream
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		registeredPreviews[curSelected].forEach(function(spr:FlxSprite)
		{
<<<<<<< HEAD
			if (spr.animation.curAnim.name.startsWith('piss') && !(spr is StaticArrow) && spr.animation.curAnim.finished)
				spr.animation.play('piss');

			if (spr is StaticArrow && spr.animation.curAnim.finished)
			{
				var arr:StaticArrow = cast spr;
				arr.playAnim('piss');
				arr.centerOffsets();
			}
		});

		if (registeredPixelPreviews[curSelected] != null)
		{
			registeredPixelPreviews[curSelected].forEach(function(spr:FlxSprite)
			{
				if (spr.animation.curAnim.name.startsWith('piss') && !(spr is StaticArrow) && spr.animation.curAnim.finished)
					spr.animation.play('piss');

				if (spr is StaticArrow && spr.animation.curAnim.finished)
				{
					var arr:StaticArrow = cast spr;
					arr.playAnim('piss');
				}
			});
		}

		if (!options.OptionsState.acceptInput && !exiting)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				exiting = true;

				FlxG.sound.play(Paths.sound('confirmMenu'));
				Settings.noteSkin = registeredSkins[curSelected];
				if (Note.noteSkin != null)
					Note.noteSkin.destroy();
				Note.noteSkin = null;
=======
			if (spr.animation.curAnim.name.startsWith('piss') && spr.animation.curAnim.finished)
				spr.animation.play('piss');

			if (spr.animation.curAnim.name.endsWith('confirm'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});

		if (!options.OptionsState.acceptInput)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				Settings.noteSkin = registeredSkins[curSelected];
>>>>>>> upstream
				FlxG.save.flush();
				options.OptionsState.acceptInput = true;

				forEachOfType(FlxSprite, function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.5, {
						onComplete: function(twn:FlxTween)
						{
<<<<<<< HEAD
							var a = remove(spr, true);
							a.exists = false;
							a.destroy();
							
=======
>>>>>>> upstream
							close();
						}
					});
				});
			}

<<<<<<< HEAD
			if (FlxG.keys.justPressed.P)
			{
				if (pixelPreviewsActive[curSelected] != null)
					pixelPreviewsActive[curSelected] = !pixelPreviewsActive[curSelected];

				changeItem();
			}

			if (FlxG.keys.justPressed.BACKSPACE)
			{
				exiting = true;

=======
			if (FlxG.keys.justPressed.BACKSPACE)
			{
>>>>>>> upstream
				FlxG.sound.play(Paths.sound('cancelMenu'));
				options.OptionsState.acceptInput = true;

				forEachOfType(FlxSprite, function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.5, {
						onComplete: function(twn:FlxTween)
						{
							close();
						}
					});
				});
			}

<<<<<<< HEAD
			if (controls.UI_UP_P)
=======
			if (FlxG.keys.justPressed.LEFT)
>>>>>>> upstream
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

<<<<<<< HEAD
			if (controls.UI_DOWN_P)
=======
			if (FlxG.keys.justPressed.RIGHT)
>>>>>>> upstream
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
<<<<<<< HEAD

			for (i in 0...registeredPreviews.length)
			{
				var newY = (FlxG.height * 0.5) - (registeredPreviews[i].height * 0.5) + (previewTargetYs[i] * (FlxG.height * 0.6));
				registeredPreviews[i].y = FlxMath.lerp(registeredPreviews[i].y, newY, Helper.boundTo(elapsed * 9.6, 0, 1));

				if (registeredPixelPreviews[i] != null)
				{
					var newYPixel = (FlxG.height * 0.5) - (registeredPixelPreviews[i].height * 0.5) + (previewTargetYs[i] * (FlxG.height * 0.6));
					registeredPixelPreviews[i].y = FlxMath.lerp(registeredPixelPreviews[i].y, newYPixel, Helper.boundTo(elapsed * 9.6, 0, 1));

					if (registeredPixelPreviews[i].visible != pixelPreviewsActive[i])
					{
						registeredPixelPreviews[i].visible = pixelPreviewsActive[i];
						registeredPreviews[i].visible = !pixelPreviewsActive[i];
					}
				}
			}
=======
>>>>>>> upstream
		}
	}

	var previousOption:Int = 0;
	var nextOption:Int = 0;
	var curSelected:Int = 0;

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= registeredPreviews.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = registeredPreviews.length - 1;

		previousOption = curSelected == 0 ? registeredPreviews.length - 1 : curSelected - 1;
		nextOption = curSelected == registeredPreviews.length - 1 ? 0 : curSelected + 1;

<<<<<<< HEAD
		// skinName.text = registeredSkins[curSelected].toUpperCase();
=======
		skinName.text = registeredSkins[curSelected].toUpperCase();
>>>>>>> upstream
		previousOptionText.text = registeredSkins[previousOption].toUpperCase();
		nextOptionText.text = registeredSkins[nextOption].toUpperCase();

		if (registeredSkins[curSelected] != "default")
		{
<<<<<<< HEAD
			splashSparrow = null;

			if (pixelPreviewsActive[curSelected])
			{
				if (FileSystem.exists(Sys.getCwd() + "skins/" + registeredSkins[curSelected] + "/pixel/pixel_splashes.xml"))
				{
					splashSparrow = FlxAtlasFrames.fromSparrow(loadedSplashes.get(registeredSkins[curSelected] + "-pixel"),
						File.getContent(Sys.getCwd() + "skins/" + registeredSkins[curSelected] + "/pixel/pixel_splashes.xml"));
				}
			}
			else
			{
				if (FileSystem.exists(Sys.getCwd() + "skins/" + registeredSkins[curSelected] + "/normal/note_splashes.xml"))
				{
					splashSparrow = FlxAtlasFrames.fromSparrow(loadedSplashes.get(registeredSkins[curSelected]),
						File.getContent(Sys.getCwd() + "skins/" + registeredSkins[curSelected] + "/normal/note_splashes.xml"));
				}
			}

			var infos = Yaml.parse('name: ${registeredSkins[curSelected]}\ndescription: Create a "mod.yaml" in your skin\'s folder for this to function!\ncreator: No one');

			if (Paths.exists("skins/" + registeredSkins[curSelected] + "/skin.yml"))
				infos = Yaml.parse(File.getContent("skins/" + registeredSkins[curSelected] + "/skin.yml"));

			skinName.text = infos.get("name") != null ? infos.get("name") : "No name provided!";
			skinCreator.text = infos.get("creator") != null ? infos.get("creator") : "No creator provided!";
			skinDesc.text = infos.get("description") != null ? infos.get("description") : "No description provided!";
		}
		else
		{
			if (pixelPreviewsActive[curSelected])
				splashSparrow = Paths.getSparrowAtlas('pixel_splashes', 'shared');
			else
				splashSparrow = Paths.getSparrowAtlas('note_splashes', 'shared');

			skinName.text = "Default";
			skinCreator.text = "PhantomArcade3k";
			skinDesc.text = "The default skin, but less the visual bugs.";
		}

		for (i in 0...registeredPreviews.length)
		{
			previewTargetYs[i] = i - curSelected;
			if (i - curSelected == 0)
				registeredPreviews[i].alpha = 1;
			else
				registeredPreviews[i].alpha = 0.6;
		}

		if (huh == 0)
		{
			for (i in 0...registeredPreviews.length)
			{
				var newY = (FlxG.height * 0.5) - (registeredPreviews[i].height * 0.5) + (previewTargetYs[i] * (FlxG.height * 0.6));
				registeredPreviews[i].y = newY;

				if (registeredPixelPreviews[i] != null)
				{
					var newYPixel = (FlxG.height * 0.5) - (registeredPixelPreviews[i].height * 0.5) + (previewTargetYs[i] * (FlxG.height * 0.6));
					registeredPixelPreviews[i].y = newYPixel;
					registeredPixelPreviews[i].visible = pixelPreviewsActive[i];
					registeredPreviews[i].visible = !pixelPreviewsActive[i];
				}
			}
		}
	}
	#end
}
=======
			if (FileSystem.exists(Sys.getCwd() + "assets/skins/" + registeredSkins[curSelected] + "/normal/note_splashes.xml"))
				splashSparrow = FlxAtlasFrames.fromSparrow(options.NoteSkinSelection.loadedSplashes.get(registeredSkins[curSelected]),
					File.getContent(Sys.getCwd() + "assets/skins/" + registeredSkins[curSelected] + "/normal/note_splashes.xml"));
			else
				splashSparrow = null;
		}
		else
			splashSparrow = Paths.getSparrowAtlas('note_splashes', 'shared');

		for (preview in registeredPreviews)
		{
			if (registeredPreviews[curSelected] == preview)
				FlxTween.tween(preview, {alpha: 1}, 0.05, {startDelay: 0.05});
			else
				FlxTween.tween(preview, {alpha: 0}, 0.05);
		}
	}
}
#end
>>>>>>> upstream
