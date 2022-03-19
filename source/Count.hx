package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;

using StringTools;

class Count extends FlxSpriteGroup
{
    var yMultiplier:Int = 0;

    var pixelShitPart1 = "";
    var pixelShitPart2 = "";
    var pixelZoom:Float = 1;

    var letters:String = "abcdefghijklmnopqrstuvwxyz ";

    public var currentNumber:Float = 0;

    public var uniform:Bool = true;

    public function new(x:Null<Float> = 0, y:Null<Float> = 0, text:String = "", ?uniform:Bool = true)
    {
        super(x, y);

        this.uniform = uniform;

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

        if (!uniform && pixelShitPart2 != '-pixel')
        {
            var a = 0;
            forEachOfType(FlxSprite, function(spr:FlxSprite)
            {
                spr.x += 2.5 * a;
                spr.offset.set(spr.offset.x + FlxG.random.float(-3, 3), spr.offset.y + FlxG.random.float(-3, 3));
                a++;
            });
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