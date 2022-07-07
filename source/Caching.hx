#if FILESYSTEM
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

using StringTools;

#if FILESYSTEM
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
	var sounds = [];
	var sharedSounds = [];

	public static var bitmapData:Map<String, FlxGraphic>;

	var tips:Array<String> = [
		"Note Skins are available!\nGo follow how the \"Swag\" skin does it!",
		"If you can't see where the rating and the combo counter?\nTick \"Stationary Ratings\" in the Options Menu!\n(you can also change its' positions as well!)\n\n(if you don't see it, it's right below that option i just said)\n(it's called \"Change Rating and Combo positions\")",
		"Never make an FNF engine\nworst mistake of my life",
		"The wait will be worth it",
		"Go pico\nyeah yeah",
		"i'm in disarray",
		"a dice, a diamond, and a skull.\nsomething weird about these, y'know?",
		"my brother in christ\nyou made the sandwich",
		"ah aaaaaah ah eh eh ih ou\nih ou ih ehhh", // liquated
		"nice argument senator, why don't you back it up with a source?\n\n\n\n\n\nmy source is that i made it the fuck up",
		"back in my day big 'ol bunny was the shit\n\n\nokay grandpa let's get you to bed",
		"\"x and y or z\"\nwhat the fuck is this LUA\nshit aint even a native ternary operator\nit is but an imitation" + (FlxG.random.bool() ? ", an impostor, perhaps" : "") + "\nlua please",
		"while (true) {}",
		"\"x ? y : z\"\nNOW THAT'S A TERNARY OPERATOR",
		"imma be real this shit does nothing",
		"wah",
		"i wish i could add back \"Space to Hey!\" but i can't :(((((",
		"documentation... sigh",
		"Todokete",
		"child.kill()",
		"you know i've come to realize something\n\ni love putting something like this\nin my projects"
	];

	override function create()
	{
		FlxG.worldBounds.set(0, 0);

		bitmapData = new Map<String, FlxGraphic>();

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

		loadingText = new FlxText(0, 0, FlxG.width, "GETTING FILES", 16);
		loadingText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingText.screenCenter();
		loadingText.scrollFactor.set();
		loadingText.borderSize = 4;
		add(loadingText);

		tip = new FlxText(0, 0, FlxG.width, "", 16);
		tip.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tip.y = loadingBar.y + loadingBar.height + 20;
		tip.scrollFactor.set();
		tip.borderSize = 4;
		add(tip);

		tip.text = tips[FlxG.random.int(0, tips.length - 1)];

		FlxGraphic.defaultPersist = Settings.cacheImages;

		#if FILESYSTEM
		if (Settings.cacheImages)
		{
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}
		}

		if (Settings.cacheMusic)
		{
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
				music.push(i);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/sounds")))
			if (i.endsWith("." + Paths.SOUND_EXT))
				sounds.push(i.replace("." + Paths.SOUND_EXT, ""));

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/sounds")))
			if (i.endsWith("." + Paths.SOUND_EXT))
				sharedSounds.push(i.replace("." + Paths.SOUND_EXT, ""));
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music) + Lambda.count(sounds) + Lambda.count(sharedSounds);

		#if FILESYSTEM
		sys.thread.Thread.create(() ->
		{
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
		for (i in images)
		{
			var replaced = i.replace(".png", "");
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

			loadingText.text = "LOADING MUSIC";
			done++;
		}

		for (i in sounds)
		{
			FlxG.sound.cache(Paths.sound(i));

			loadingText.text = "LOADING SOUNDS IN ASSETS";
			done++;
		}

		for (i in sharedSounds)
		{
			FlxG.sound.cache(Paths.sound(i, 'shared'));

			loadingText.text = "LOADING SOUNDS IN SHARED";
			done++;
		}

		if (!Settings.cacheImages && !Settings.cacheMusic)
			loadingText.text = "SKIPPING CACHING PHASE";

		loaded = true;
		#end

		#if CUSTOM_SPLASH_SCREEN
		CustomTransition.switchTo(new SplashState());
		#else
		CustomTransition.switchTo(new TitleState());
		#end
	}
}
#end
