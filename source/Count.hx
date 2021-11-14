package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Ok so, you know the combo count? Yeah that.
 */
class Count extends FlxSpriteGroup
{
    var yMultiplier:Int = 0;

    var pixelShitPart1 = "";
    var pixelShitPart2 = "";
    var pixelZoom:Float = 1;

    var letters:String = "abcdefghijklmnopqrstuvwxyz ";

    public var currentNumber:Float = 0;

    /**
     * Create a new `Count` object.
     * 
     * @param x You know what this does.
     * @param y This as well.
     * @param text The number/text to be displayed.
     */
    public function new(x:Null<Float> = 0, y:Null<Float> = 0, text:String = "")
    {
        super(x, y);

        if (PlayState.SONG != null)
        {
            if (PlayState.SONG.noteStyle == "pixel")
            {
                pixelShitPart1 = 'pixelUI/';
                pixelShitPart2 = '-pixel';
                pixelZoom = PlayState.daPixelZoom;
            }
        }

        if (Std.parseInt(text) != null)
        {
            switch (text.length)
            {
                case 0:
                    text = '000' + text;
                case 1:
                    text = '00' + text;
                case 2:
                    text = '0' + text;
            }
            currentNumber = Std.parseInt(text);
        }

        for (number in text.split(""))
        {
            if (number == "\n")
            {
                yMultiplier++;
                continue;   
            }
            else
                createCount(number);
        }
        

        // setPosition(assignX, assignY);
    }

    function createCount(theNumber:String = "", huh:Float = 0)
    {
        if (Std.parseInt(theNumber) != null)
            createCharacter(theNumber, huh)
        else
        {
            var special:String = "";
            switch (theNumber)
            {
                case '.':
                    special = "Dot";
                case '%':
                    special = "Percent";
                case '!':
                    special = "ExclamationPoint";
                case ':':
                    special = "Colon";
                case ',':
                    special = "Comma";
            }

            if (special != "")
                createCharacter(special, huh);
            else
            {
                // LETTER SHIT
                if (letters.contains(theNumber.toLowerCase()))
                {
                    var special:String = "";
                    switch (theNumber)
                    {
                        case ' ':
                            special = "SPACE";
                    }
                    createCharacterFromSpriteSheet((special == "" ? theNumber.toUpperCase() : special), huh);
                }
            }
        }
    }

    function createCharacter(name:String = "", huh:Float = 0)
    {
        var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + name + pixelShitPart2));

        numScore.antialiasing = (pixelZoom == 1 ? true : false);
        numScore.setGraphicSize(Std.int(numScore.width * (pixelZoom == 1 ? 0.5 : pixelZoom)));
        numScore.updateHitbox();
        
        add(numScore);
        if (members.length > 1)
            numScore.x = x + width;

        numScore.y = y + (63 * yMultiplier);
    }

    function createCharacterFromSpriteSheet(name:String = "", huh:Float = 0)
    {
        var numScore:FlxSprite = new FlxSprite();
        numScore.frames = Paths.getSparrowAtlas(pixelShitPart1 + "comboAlphabet" + pixelShitPart2);
        numScore.animation.addByPrefix(name, 'letter ${name}0', 24);
        numScore.animation.play(name);

        numScore.antialiasing = (pixelZoom == 1 ? true : false);
        numScore.setGraphicSize(Std.int(numScore.width * (pixelZoom == 1 ? 0.5 : pixelZoom)));
        numScore.updateHitbox();
        
        add(numScore);
        if (members.length > 1)
            numScore.x = x + width;
        
        numScore.y = y + (63 * yMultiplier);
    }

    public function changeNumber(text:String = "")
    {
        clear();

        if (Std.parseInt(text) != null)
        {
            switch (text.length)
            {
                case 0:
                    text = '000' + text;
                case 1:
                    text = '00' + text;
                case 2:
                    text = '0' + text;
            }
            currentNumber = Std.parseInt(text);
        }

        for (number in text.split(""))
        {
            if (number == "\n")
            {
                yMultiplier++;
                continue;   
            }
            else
                createCount(number);
        }
    }

    public function disconnect() 
    {
        for (numScore in members)
        {
            numScore.acceleration.y = FlxG.random.int(200, 300);
            numScore.velocity.y -= FlxG.random.int(140, 160);
            numScore.velocity.x = FlxG.random.float(-5, 5);

            FlxTween.tween(numScore, {alpha: 0}, 0.2, {
                onComplete: function(tween:FlxTween)
                {
                    numScore.destroy();
                },
                startDelay: Conductor.crochet * 0.002
            });
        }
    }
}