package;

import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

// remade it into a substate cuz substates are awesome

enum DialogueStyle
{
	NORMAL;
	PIXEL_NORMAL;
	PIXEL_SPIRIT;
}

// ... what the fuck?
typedef DialogueSettings =
{
	var bgMusic:BGMusic;
	var bg:BG;
	var type:String;
}

typedef BGMusic =
{
	var name:String;
	var fadeIn:MusicFadeIn;
}

typedef BG =
{
	var color:String;
	var alpha:Null<Float>;
	var duration:Null<Float>;
}

typedef MusicFadeIn =
{
	var from:Null<Float>;
	var to:Null<Float>;
	var duration:Null<Float>;
}

class DialogueSubstate extends MusicBeatSubstate
{
	public static var instance:DialogueSubstate;

	public var sounds(default, set):Array<FlxSound>;

	public var splitName:Array<String>;
	public var dialogueList:Array<String> = [];
	public var whosSpeaking:String = '';
	public var speakerEmotion:String = '';
	public var speakerPosition:String = 'right';
	public var dialogueType:String = 'normal';
	public var dialogueBox:FlxSprite;
	public var thatFuckerOnTheLeft:FlxSprite;
	public var thatFuckerOnTheRight:FlxSprite;
	public var onComplete:Void->Void;

	public var typedText:FlxTypeText;
	public var useAlphabet:Bool = false;
	public var style:DialogueStyle = NORMAL;

	public var skipText:FlxText;

	public var portraitGroup:FlxTypedGroup<FlxSprite>;

	public var desiredBgAlpha:Null<Float> = 0.5;
	public var desiredBgColor:FlxColor = FlxColor.fromString("#000000");
	public var desiredBgDuration:Null<Float> = 0;

	public var desiredMusic:Null<String> = "breakfast";
	public var desiredFadeTo:Null<Float> = 0.8;
	public var desiredFadeFrom:Null<Float> = 0;
	public var desiredFadeDuration:Null<Float> = 1;

	public var bg:FlxSprite;

	public var customColorRegEx:EReg = new EReg("<#(?:[a-f\\d]{3}){1,2}\\b>", "g");
	public var customColorFormatMarkers:Array<FlxTextFormatMarkerPair> = [];

	public function new(dialogues:Array<String>, style:DialogueStyle = null, ?onComplete:Void->Void, ?dialogueSettings:DialogueSettings = null)
	{
		super();

		persistentUpdate = false;

		var addedtags:Array<String> = [];

		for (color in FlxColor.colorLookup.keys())
		{
			var fuck = "<" + color.toLowerCase() + ">";
			var a = new FlxTextFormat(FlxColor.colorLookup.get(color));
			var b = new FlxTextFormatMarkerPair(a, fuck);

			addedtags.push(fuck);
			customColorFormatMarkers.push(b);
		}

		for (dia in dialogues)
		{
			customColorRegEx.match(dia);
			var matches:Array<String> = Helper.getERegMatches(customColorRegEx, dia, true);

			for (tag in matches)
			{
				if (!addedtags.contains(tag))
				{
					var trimmed:String = tag.replace("<", "").replace(">", "");
					var a = new FlxTextFormat(FlxColor.fromString(trimmed));
					var b = new FlxTextFormatMarkerPair(a, tag);

					addedtags.push(tag);
					customColorFormatMarkers.push(b);
				}
			}
		}

		bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5));
		bg.alpha = 0;
		bg.screenCenter();
		add(bg);

		// set the setting shit
		var settingsJSON:DialogueSettings = dialogueSettings;

		if (settingsJSON == null)
		{
			#if FILESYSTEM
			if (FileSystem.exists(Paths.dialogueSettingsFile(PlayState.SONG.song.replace(" ", "-").toLowerCase())))
				settingsJSON = cast Json.parse(File.getContent(Paths.dialogueSettingsFile(PlayState.SONG.song.replace(" ", "-").toLowerCase())));
			#else
			if (Assets.exists(Paths.dialogueSettingsFile(PlayState.SONG.song.replace(" ", "-").toLowerCase())))
				settingsJSON = cast Json.parse(Assets.getText(Paths.dialogueSettingsFile(PlayState.SONG.song.replace(" ", "-").toLowerCase())));
			#end
		}

		if (settingsJSON != null)
		{
			if (settingsJSON.bgMusic != null)
			{
				desiredMusic = settingsJSON.bgMusic.name != null ? settingsJSON.bgMusic.name : "breakfast";
				desiredFadeTo = settingsJSON.bgMusic.fadeIn.to != null ? settingsJSON.bgMusic.fadeIn.to : 0.8;
				desiredFadeFrom = settingsJSON.bgMusic.fadeIn.from != null ? settingsJSON.bgMusic.fadeIn.from : 0;
				desiredFadeDuration = settingsJSON.bgMusic.fadeIn.duration != null ? settingsJSON.bgMusic.fadeIn.duration : 1;
			}

			if (settingsJSON.bg != null)
			{
				desiredBgAlpha = settingsJSON.bg.alpha != null ? settingsJSON.bg.alpha : 0.5;
				desiredBgDuration = settingsJSON.bg.duration != null ? settingsJSON.bg.duration : 0;
				desiredBgColor = settingsJSON.bg.color != null ? FlxColor.fromString("#" + settingsJSON.bg.color) : FlxColor.fromString("#000000");
			}

			if (settingsJSON.type != null)
			{
				if (style == null)
				{
					switch (settingsJSON.type.toLowerCase())
					{
						default:
							style = NORMAL;
						case 'pixel' | 'pixel-normal':
							style = PIXEL_NORMAL;
						case 'pixel-spirit':
							style = PIXEL_SPIRIT;
					}
				}
			}
		}

		bg.color = desiredBgColor;

		if (desiredBgDuration == 0)
			bg.alpha = desiredBgAlpha;
		else
			FlxTween.tween(bg, {alpha: desiredBgAlpha}, desiredBgDuration, {ease: FlxEase.linear});

		if (desiredMusic != "")
		{
			FlxG.sound.playMusic(Paths.music(desiredMusic), desiredFadeFrom);
			FlxG.sound.music.fadeIn(desiredFadeDuration, desiredFadeFrom, desiredFadeTo);
		}

		dialogueBox = new FlxSprite();

		this.dialogueList = dialogues;
		this.onComplete = onComplete;

		if (style != null)
			this.style = style;

		thatFuckerOnTheLeft = new FlxSprite();
		thatFuckerOnTheRight = new FlxSprite();

		portraitGroup = new FlxTypedGroup<FlxSprite>();
		add(portraitGroup);

		typedText = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		typedText.font = 'Pixel Arial 11 Bold';
		typedText.visible = false;
		typedText.color = 0xFF3F2021;
		typedText.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFFD89494, 2);
		typedText.shadowOffset.set(1, 1);

		if (this.style == NORMAL)
		{
			dialogueBox.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
			dialogueBox.animation.addByPrefix('normal open', 'Speech Bubble Normal Open0', 24, false);
			dialogueBox.animation.addByPrefix('loud open', 'speech bubble loud open0', 24, false);
			dialogueBox.animation.addByPrefix('normal', 'speech bubble normal', 24);
			dialogueBox.animation.addByPrefix('loud', 'AHH speech bubble', 24);

			dialogueBox.antialiasing = true;
			dialogueBox.setGraphicSize(Std.int(dialogueBox.width * 0.9));
			useAlphabet = true;

			typedText.font = 'Funkerin Regular';
			typedText.size = 72;
			typedText.y -= 15;
			typedText.color = 0xFF000000;
			typedText.antialiasing = true;
			typedText.borderColor = FlxColor.TRANSPARENT;
		}
		else if (this.style == PIXEL_NORMAL)
		{
			dialogueBox.frames = Paths.getSparrowAtlas('pixelUI/dialogueBox-pixel', 'shared');
			dialogueBox.animation.addByPrefix('normal open', 'Text Box Appear instance', 24, false);
			dialogueBox.animation.addByPrefix('normal', 'Text Box Appear instance 10004', 24);
			dialogueBox.setGraphicSize(Std.int(dialogueBox.width * PlayState.daPixelZoom * 0.9));
			typedText.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		}
		else if (this.style == PIXEL_SPIRIT)
		{
			dialogueBox.frames = Paths.getSparrowAtlas('pixelUI/dialogueBox-evil', 'shared');
			dialogueBox.animation.addByPrefix('normal open', 'Spirit Textbox spawn instance', 24, false);
			dialogueBox.animation.addByPrefix('normal', 'Spirit Textbox spawn instance 10011', 24);
			dialogueBox.setGraphicSize(Std.int(dialogueBox.width * PlayState.daPixelZoom * 0.9));

			typedText.color = 0xFFFFFFFF;
			typedText.borderColor = 0xFF000000;
			typedText.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		}

		dialogueBox.scrollFactor.set();
		dialogueBox.y = FlxG.height * 0.5;
		dialogueBox.animation.play("normal open");
		dialogueBox.screenCenter(X);
		add(dialogueBox);

		add(typedText);

		skipText = new FlxText(0, 0, 0, "Press BACKSPACE to skip dialogue.");
		skipText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, OUTLINE, 0xFF000000);
		skipText.borderSize = 3;
		skipText.x = 5;
		skipText.y = FlxG.height - skipText.height - 5;
		add(skipText);

		if (PlayState.instance != null)
			FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, 0.5);

		started = true;
		start();

		instance = this;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (dialogueBox != null)
		{
			dialogueBox.y = FlxG.height * 0.5;

			if (!dialogueBox.animation.curAnim.reversed)
			{
				if (dialogueBox.animation.finished && dialogueBox.animation.curAnim.name.endsWith("open"))
				{
					dialogueBox.animation.play(dialogueType);

					typedText.visible = true;
					typedText.resetText(dialogueList[0]);

					if (customColorFormatMarkers.length > 0)
						typedText.applyMarkup(dialogueList[0], customColorFormatMarkers);

					typedText.start(0.05);
				}
			}

			if (useAlphabet)
			{
				if (dialogueBox.animation.curAnim.name.startsWith("normal"))
					dialogueBox.offset.set(-30, 0);
				else if (dialogueBox.animation.curAnim.name.startsWith("loud"))
					dialogueBox.offset.set(0, 50);
			}
		}

		if (FlxG.keys.justPressed.ANY && started)
		{
			if (started)
			{
				if (!useAlphabet)
					FlxG.sound.play(Paths.sound('clickText'), 0.8);

				if (typedText.text.length >= customColorRegEx.replace(dialogueList[0], "").length)
				{
					if (dialogueList[1] == null && dialogueList[0] != null)
					{
						if (!ending)
						{
							ending = true;

							if (PlayState.instance != null)
							{
								FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 0.25);
								PlayState.instance.inCutscene = false;
							}

							forEachOfType(FlxSprite, function(spr:FlxSprite) {
								FlxTween.tween(spr, {alpha: 0}, 1);
							}, true);
			
							new FlxTimer().start(1, function(twn:FlxTimer)
							{
								close();
			
								if (PlayState.instance != null)
									PlayState.seenCutscene = true;
			
								if (onComplete != null)
									onComplete();
							});
						}
					}
					else
					{
						dialogueList.remove(dialogueList[0]);
						start();
					}
				}
				else
				{
					typedText.skip();
				}
			}

			if (!started)
			{
				started = true;
				start();
			}
		}

		if (FlxG.keys.justPressed.BACKSPACE && started)
		{
			if (!ending)
			{
				ending = true;

				if (PlayState.instance != null)
				{
					FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 0.25);
					PlayState.instance.inCutscene = false;
				}

				forEachOfType(FlxSprite, function(spr:FlxSprite) {
					FlxTween.tween(spr, {alpha: 0}, 1);
				}, true);

				new FlxTimer().start( 1, function(twn:FlxTimer)
				{
					close();

					if (PlayState.instance != null)
						PlayState.seenCutscene = true;

					if (onComplete != null)
						onComplete();
				});
			}
		}
	}

	var started:Bool = false;

	// I am making them unnecessarily long
	var pixelSpritesWithoutPixelSuffix:Array<String> = ["senpai", "spirit"];

	function start():Void
	{
		cleanUpDialogue();

		// portrait bullshit

		portraitGroup.remove(thatFuckerOnTheLeft);
		portraitGroup.remove(thatFuckerOnTheRight);
		thatFuckerOnTheLeft.destroy();
		thatFuckerOnTheRight.destroy();

		if (speakerPosition == "left")
		{
			thatFuckerOnTheLeft = new FlxSprite().loadGraphic(Paths.image('portraits/' + whosSpeaking + "-" + speakerEmotion.toUpperCase()));
			thatFuckerOnTheRight = new FlxSprite();

			thatFuckerOnTheLeft.antialiasing = true;
			thatFuckerOnTheRight.antialiasing = true;

			if (whosSpeaking.endsWith("-pixel") || pixelSpritesWithoutPixelSuffix.contains(whosSpeaking))
			{
				thatFuckerOnTheLeft.antialiasing = false;
				thatFuckerOnTheLeft.setGraphicSize(Std.int(thatFuckerOnTheLeft.width * PlayState.daPixelZoom * 0.9));
				thatFuckerOnTheLeft.updateHitbox();
			}

			thatFuckerOnTheLeft.x = dialogueBox.x;
			thatFuckerOnTheLeft.y = dialogueBox.y - thatFuckerOnTheLeft.height + 100;

			if (useAlphabet)
				thatFuckerOnTheLeft.x += (FlxG.width * 0.125);
			else
			{
				thatFuckerOnTheLeft.x = (FlxG.width * 0.15);
				thatFuckerOnTheLeft.y = dialogueBox.y - thatFuckerOnTheLeft.height + 80;
			}

			portraitGroup.add(thatFuckerOnTheLeft);
		}
		else if (speakerPosition == "right")
		{
			thatFuckerOnTheRight = new FlxSprite().loadGraphic(Paths.image('portraits/' + whosSpeaking + "-" + speakerEmotion.toUpperCase()));
			thatFuckerOnTheLeft = new FlxSprite();

			// since all sprites look to the right,
			thatFuckerOnTheRight.flipX = true;

			thatFuckerOnTheLeft.antialiasing = true;
			thatFuckerOnTheRight.antialiasing = true;

			if (whosSpeaking.endsWith("-pixel") || pixelSpritesWithoutPixelSuffix.contains(whosSpeaking))
			{
				thatFuckerOnTheRight.antialiasing = false;
				thatFuckerOnTheRight.setGraphicSize(Std.int(thatFuckerOnTheRight.width * PlayState.daPixelZoom * 0.9));
				thatFuckerOnTheRight.updateHitbox();
			}

			thatFuckerOnTheRight.x = dialogueBox.x + dialogueBox.width - thatFuckerOnTheRight.width;
			thatFuckerOnTheRight.y = dialogueBox.y - thatFuckerOnTheRight.height + 100;

			if (useAlphabet)
				thatFuckerOnTheRight.x -= (FlxG.width * 0.125);
			else
			{
				thatFuckerOnTheRight.x = FlxG.width - thatFuckerOnTheRight.width - (FlxG.width * 0.15);
				thatFuckerOnTheRight.y = dialogueBox.y - thatFuckerOnTheRight.height + 80;
			}

			portraitGroup.add(thatFuckerOnTheRight);
		}

		if (dialogueBox.animation.curAnim.name != dialogueType + " open")
		{
			typedText.visible = true;
			typedText.resetText(dialogueList[0]);
			typedText.start(0.05, true);
		}
		else
			dialogueBox.animation.play(dialogueType + " open");
	}

	var ending = false;

	function cleanUpDialogue():Void
	{
		typedText.visible = false;

		splitName = dialogueList[0].split(":");
		whosSpeaking = splitName[1];
		speakerEmotion = splitName[2];

		if (dialogueBox.animation.getByName(splitName[4]) != null && dialogueBox.animation.getByName(splitName[4] + " open") != null)
			dialogueType = splitName[4];

		if (speakerPosition != splitName[3])
		{
			if (!useAlphabet)
			{
				if (splitName[3] == "left")
					dialogueBox.flipX = false;
				else if (splitName[3] == "right")
					dialogueBox.flipX = true;
			}
			else
			{
				if (splitName[3] == "left")
					dialogueBox.flipX = true;
				else if (splitName[3] == "right")
					dialogueBox.flipX = false;
			}

			dialogueBox.animation.play(dialogueType + " open", true);
		}

		if (!dialogueBox.animation.curAnim.name.startsWith(dialogueType))
			dialogueBox.animation.play(dialogueType + " open", true);

		speakerPosition = splitName[3];
		var thing = splitName[1].length + splitName[2].length + splitName[3].length + splitName[4].length + 5;
		dialogueList[0] = dialogueList[0].substr(thing).replace("\\n", "\n");
	}

	function set_sounds(value:Array<FlxSound>):Array<FlxSound> 
	{
		typedText.sounds = value;
		
		return value;
	}
}
