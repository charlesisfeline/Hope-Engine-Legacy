#if sys
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.utils.Assets;

using StringTools;
#if desktop
import Discord.DiscordClient;
#end
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

// literally copied from 1.7 LMAO
class Caching extends MusicBeatState
{
    var toBeDone:Int = 0;
    var done:Int = 0;

    var loaded:Bool = false;

    var logo:FlxSprite;
    var tip:FlxText;

    var loadingBar:FlxBar;
    var loadingBarBG:FlxSprite;
    var loadingText:FlxText;

    var loadingNumber:Float;

    var images = [];
    var music = [];
    var charts = [];

    public static var bitmapData:Map<String,FlxGraphic>;

    var tips:Array<String> = [
        "Turn on Family Friendly in the\noptions if you have to!",
        "Going to the options 6 times does something!", // mod exclusive
        "Note Skins are available!\nGo follow how the \"Swag\" skin does it!",
        "Hate the results screen?\nTurn it off in the options!",
        "Modifiers exist.",
        "Wanna see how you did in a song?\nGo to Options > Misc > Replays!"
    ];

    override function create() 
    {
        FlxG.save.bind('save', 'hopeEngine');

        PlayerSettings.init();
		Data.initSave();

        FlxG.mouse.visible = false;
        FlxG.worldBounds.set(0,0);

        bitmapData = new Map<String,FlxGraphic>();

        loadingBarBG = new FlxSprite();
        add(loadingBarBG);

        loadingBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 16, this, 'loadingNumber', 0, 1);
        loadingBar.numDivisions = 1000;
        loadingBar.scrollFactor.set();
        loadingBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
        loadingBar.screenCenter();
        add(loadingBar);

        loadingBarBG.makeGraphic(Std.int(loadingBar.width + 8), Std.int(loadingBar.height + 8), 0xFF000000);
        loadingBarBG.setPosition(loadingBar.x - 4, loadingBar.y - 4);

        loadingText = new FlxText(0, 0, FlxG.width, "", 16);
        loadingText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        loadingText.screenCenter();
        loadingText.scrollFactor.set();
        loadingText.borderSize = 4;
        add(loadingText);

        tip = new FlxText(0, 0, FlxG.width, "", 16);
        tip.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        tip.y = loadingBar.y + loadingBar.height + 20;
        tip.scrollFactor.set();
        tip.borderSize = 4;
        add(tip);

        tip.text = tips[FlxG.random.int(0, tips.length - 1)];

        FlxGraphic.defaultPersist = FlxG.save.data.cacheImage;

        #if cpp
        if (FlxG.save.data.cacheImages)
        {
            trace("Getting character images...");

            for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
            {
                if (!i.endsWith(".png"))
                    continue;
                images.push(i);
            }
        }

        trace("Getting songs...");

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
        #end

        toBeDone = Lambda.count(images) + Lambda.count(music);

        #if cpp
		sys.thread.Thread.create(() -> {
			cache();
		});
		#end

        super.create();
    }

	override function update(elapsed) 
	{
		super.update(elapsed);
        loadingNumber = FlxMath.lerp(loadingNumber, (done / toBeDone) + (1 / toBeDone), 0.09);
	}

    function cache()
    {
        #if !linux
        trace("LOADING: " + toBeDone + " OBJECTS.");

        for (i in images)
        {
            var replaced = i.replace(".png","");
            var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
            trace('id ' + replaced + ' file - assets/shared/images/characters/' + i + ' ${data.width}');
            loadingText.text = "LOADING CHARACTERS";
            var graph = FlxGraphic.fromBitmapData(data);
            graph.persist = true;
            graph.destroyOnNoUse = false;
            bitmapData.set(replaced, graph);
            done++;
        }
        
        for (i in music)
        {
            FlxG.sound.cache(Paths.inst(i));
            FlxG.sound.cache(Paths.voices(i));
            
            trace("Cached " + i);
            loadingText.text = "LOADING MUSIC";
            done++;
        }

        trace("Finished caching...");

        loaded = true;
        #end
        FlxG.switchState(new TitleState());
    }
}
#end