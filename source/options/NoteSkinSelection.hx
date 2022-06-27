#if FILESYSTEM
package options;

// this shit's just a superior image and file replacer
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
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

	public static var registeredSkins:Array<String> = ["default"];

	var bg:FlxSprite;
	var arrows:FlxSprite;

	var previousOptionText:FlxText;
	var nextOptionText:FlxText;
	var infoText:FlxText;
	var skinName:FlxText;
	var skinDesc:FlxText;

	var splashSparrow:FlxAtlasFrames;

	public static var loadedNoteSkins:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	public static var loadedSplashes:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	public function new()
	{
		super();

		if (registeredSkins.length - 1 != FileSystem.readDirectory(Sys.getCwd() + "/assets/skins").length)
			refreshSkins();

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), 0xFF000000);
		bg.scrollFactor.set();
		bg.alpha = 0.6;
		bg.screenCenter();
		add(bg);

		infoText = new FlxText(0, FlxG.height * 0.8, FlxG.width,
			"Skins folder is at assets/skins. See \"swag\" folder on how one works.\nPress ESCAPE to save choice, press BACKSPACE to leave without saving.",
			72);
		infoText.scrollFactor.set();
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 3;
		add(infoText);

		skinName = new FlxText(0, FlxG.height * 0.15, FlxG.width, "", 72);
		skinName.scrollFactor.set();
		skinName.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skinName.borderSize = 3;
		add(skinName);

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
		for (skinName in registeredSkins)
		{
			var theSex:FlxAtlasFrames = null;
			if (skinName != "default")
				theSex = FlxAtlasFrames.fromSparrow(loadedNoteSkins.get(skinName),
					File.getContent(Sys.getCwd() + "assets/skins/" + skinName + "/normal/NOTE_assets.xml"));

			var skinPreview:FlxSpriteGroup = new FlxSpriteGroup();

			for (noteType in 0...4)
			{
				for (noteDir in 0...4)
				{
					var pissArrow:FlxSprite = new FlxSprite();

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
					}
				}
			}
			skinPreview.screenCenter();
			skinPreview.alpha = 0;
			registeredPreviews.push(skinPreview);
			add(skinPreview);
		}

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
	}

	public static function refreshSkins()
	{
		registeredSkins = ['default'];

		for (skinName in (FileSystem.readDirectory(Sys.getCwd() + "/assets/skins")))
			registeredSkins.push(skinName);

		for (skinName in registeredSkins)
		{
			if (skinName != 'default')
			{
				var piss:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/normal/NOTE_assets.png");
				var shitoffmate:FlxGraphic = FlxGraphic.fromBitmapData(piss);
				shitoffmate.persist = true;
				shitoffmate.destroyOnNoUse = false;
				loadedNoteSkins.set(skinName, shitoffmate);

				if (FileSystem.exists(Sys.getCwd() + "assets/skins/" + skinName + "/normal/note_splashes.png")
					&& FileSystem.exists(Sys.getCwd() + "assets/skins/" + skinName + "/normal/note_splashes.xml"))
				{
					var noteSplashNormal:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/normal/note_splashes.png");
					var shitoffmateSplash:FlxGraphic = FlxGraphic.fromBitmapData(noteSplashNormal);
					shitoffmateSplash.persist = true;
					shitoffmateSplash.destroyOnNoUse = false;
					loadedSplashes.set(skinName, shitoffmateSplash);
				}

				if (FileSystem.exists(Sys.getCwd() + "assets/skins/" + skinName + "/pixel/"))
				{
					var piss2:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/pixel/arrows-pixels.png");
					var shitoffmate2:FlxGraphic = FlxGraphic.fromBitmapData(piss2);
					shitoffmate2.persist = true;
					shitoffmate2.destroyOnNoUse = false;
					loadedNoteSkins.set(skinName + "-pixel", shitoffmate2);

					var piss3:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/skins/" + skinName + "/pixel/arrowEnds.png");
					var shitoffmate3:FlxGraphic = FlxGraphic.fromBitmapData(piss3);
					shitoffmate3.persist = true;
					shitoffmate3.destroyOnNoUse = false;
					loadedNoteSkins.set(skinName + "-pixelEnds", shitoffmate3);
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
			registeredPreviews[curSelected].members[curBeat % 4].animation.play('piss pressed');
		else
		{
			registeredPreviews[curSelected].members[curBeat % 4].animation.play('piss confirm');

			if (splashSparrow != null)
			{
				if (Settings.noteSplashes)
				{
					var splash = new NoteSplash(curBeat % 4, splashSparrow);
					var strumNote = registeredPreviews[curSelected].members[curBeat % 4];

					splash.x = strumNote.x + (strumNote.width / 2) - (splash.width / 2);
					splash.y = strumNote.y + (strumNote.height / 2) - (splash.height / 2);

					add(splash);
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		registeredPreviews[curSelected].forEach(function(spr:FlxSprite)
		{
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
				if (Note.noteSkin != null)
					Note.noteSkin.destroy();
				Note.noteSkin = null;
				FlxG.save.flush();
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

			if (FlxG.keys.justPressed.BACKSPACE)
			{
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

			if (FlxG.keys.justPressed.LEFT)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.RIGHT)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
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

		skinName.text = registeredSkins[curSelected].toUpperCase();
		previousOptionText.text = registeredSkins[previousOption].toUpperCase();
		nextOptionText.text = registeredSkins[nextOption].toUpperCase();

		if (registeredSkins[curSelected] != "default")
		{
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
