package;

import flash.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

// remade it into a substate cuz substates are awesome

enum DialogueStyle {
    NORMAL;
    PIXEL_NORMAL;
    PIXEL_SPIRIT;
}
class DialogueSubstate extends MusicBeatSubstate
{
    var pissCamera:FlxCamera;

    var splitName:Array<String>;
    var dialogueList:Array<String> = [];
    var whosSpeaking:String = '';
    var speakerEmotion:String = '';
    var speakerPosition:String = 'right';
    var dialogueType:String = 'normal';
    var dialogueBox:FlxSprite;
    var thatFuckerOnTheLeft:FlxSprite;
    var thatFuckerOnTheRight:FlxSprite;
    var onComplete:Void->Void;
    
    var typedText:FlxTypeText;
    var useAlphabet:Bool = false;
    var style:DialogueStyle = NORMAL;

    var skipText:FlxText;

    var portraitGroup:FlxTypedGroup<FlxSprite>;

    public function new(dialogues:Array<String>, style:DialogueStyle = NORMAL, ?onComplete:Void->Void)
    {
        super();

        persistentUpdate = false;

        pissCamera = new FlxCamera();
        pissCamera.bgColor.alphaFloat = 0.5;
        FlxG.cameras.add(pissCamera);

        dialogueBox = new FlxSprite();

        this.dialogueList = dialogues;
        this.onComplete = onComplete;
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

        if (style == NORMAL)
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
        else if (style == PIXEL_NORMAL)
        {
            dialogueBox.frames = Paths.getSparrowAtlas('pixelUI/dialogueBox-pixel', 'shared');
            dialogueBox.animation.addByPrefix('normal open', 'Text Box Appear instance', 24, false);
            dialogueBox.animation.addByPrefix('normal', 'Text Box Appear instance 10004', 24);
            dialogueBox.setGraphicSize(Std.int(dialogueBox.width * PlayState.daPixelZoom * 0.9));
            typedText.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
        }
        else if (style == PIXEL_SPIRIT)
        {
            dialogueBox.frames = Paths.getSparrowAtlas('pixelUI/dialogueBox-evil', 'shared');
            dialogueBox.animation.addByPrefix('normal open', 'Spirit Textbox spawn instance', 24, false);
            dialogueBox.animation.addByPrefix('normal', 'Spirit Textbox spawn instance 10011', 24);
            dialogueBox.setGraphicSize(Std.int(dialogueBox.width * PlayState.daPixelZoom * 0.9));

            typedText.color = 0xFFFFFFFF;
            typedText.borderColor = 0xFF000000;
            typedText.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
        }

        typedText.cameras = [pissCamera];

        dialogueBox.scrollFactor.set();
        dialogueBox.y = FlxG.height * 0.5;
        dialogueBox.animation.play("normal open");
        dialogueBox.screenCenter(X);
        add(dialogueBox);
        dialogueBox.cameras = [pissCamera];
        
        add(typedText);

        skipText = new FlxText(0, 0, 0, "Press BACKSPACE to skip dialogue.");
        skipText.setFormat(null, 24, FlxColor.WHITE, LEFT, OUTLINE, 0xFF000000);
        skipText.borderSize = 3;
        skipText.x = 5;
        skipText.y = FlxG.height - skipText.height - 5;
        add(skipText);

        skipText.cameras = [pissCamera];

        if (PlayState.instance != null)
            FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, 0.5);

        started = true;
        start();
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
                
                if (typedText.text.length >= dialogueList[0].length)
                {
                    if (dialogueList[1] == null && dialogueList[0] != null)
                    {
                        if (!ending)
                        {
                            ending = true;
                            if (onComplete != null)
                                onComplete();
                            
                            if (PlayState.instance != null)
                                FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 0.25);

                            FlxTween.tween(pissCamera, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
                                FlxG.cameras.remove(pissCamera, true);
                                close();
                            }});
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
                if (onComplete != null)
                    onComplete();
                
                if (PlayState.instance != null)
                    FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 0.25);

                FlxTween.tween(pissCamera, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
                    FlxG.cameras.remove(pissCamera, true);
                    close();
                }});
            }
        }
    }

    var started:Bool = false;

    var spritesFacingLeft:Array<String> = [
        "bf",
        "bf-pixel",
        "bf-christmas"
    ];

    // I am making them unnecessarily long
    var pixelSpritesWithoutPixelSuffix:Array<String> = [
        "senpai",
        "spirit"
    ];

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
            thatFuckerOnTheLeft = new FlxSprite().loadGraphic(Paths.image('portraits/' + whosSpeaking + "-" + speakerEmotion.toUpperCase(), 'shared'));
            if (spritesFacingLeft.contains(whosSpeaking))
                thatFuckerOnTheLeft.flipX = true;

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

            thatFuckerOnTheLeft.cameras = [pissCamera];
            portraitGroup.add(thatFuckerOnTheLeft);
        }
        else if (speakerPosition == "right")
        {
            thatFuckerOnTheRight = new FlxSprite().loadGraphic(Paths.image('portraits/' + whosSpeaking + "-" + speakerEmotion.toUpperCase(), 'shared'));
            if (!spritesFacingLeft.contains(whosSpeaking))
                thatFuckerOnTheRight.flipX = true;

            thatFuckerOnTheLeft = new FlxSprite();

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

            thatFuckerOnTheRight.cameras = [pissCamera];
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

            typedText.visible = false;
            dialogueBox.animation.play(dialogueType + " open", true);
        }
        speakerPosition = splitName[3];
		dialogueList[0] = splitName[5].replace("\\n", "\n");
    }
}