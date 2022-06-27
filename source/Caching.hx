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
		"Wanna work on my fnf mod?\nIts gonna have 300 weeks i need 500 artists 200 charters 400 composers no pay though im a minor",
		"Never make an FNF engine\nworst mistake of my life",
		"The wait will be worth it",
		"Go pico\nyeah yeah",
		"HOW COULD YOU\nMAKE THE COVER SO OFF KEY",
		"This is my message to my master\nThis is a fight you cannot win",
		"Well well we-\nShut the fuck up",
		"and on 11:46pm\nthe entire world shook",
		"No bitches?",
		"Yes, Megamind. No bitches.",
		"Hey carnage",
		"Connection terminated. I'm sorry to interrupt you Elizabeth, if you still even remember that name, But I'm afraid you've been misinformed. You are not here to receive a gift, nor have you been called here by the individual you assume, although, you have indeed been called.You have all been called here, into a labyrinth of sounds and smells misdirection and misfortune. A labyrinth with no exit, a maze with no prize. You don't even realize that you are trapped. Your lust for blood has driven you in endless circles, chasing the cries of children in some unseen chamber, always seeming so near, yet somehow out of reach, but you will never find them. None of you will. This is where your story ends. And to you, my brave volunteer, who somehow found this job listing not intended for you, although there was a way out planned for you, I have a feeling that's not what you want. I have a feeling that you are right where you want to be. I am remaining as well. I am nearby. This place will not be remembered, and the memory of everything that started this can finally begin to fade away. As the agony of every tragedy should. And to you monsters trapped in the corridors, be still and give up your spirits. They don't belong to you. For most of you, I believe there is peace and perhaps more waiting for you after the smoke clears. Although, for one of you, the darkest pit of Hell has opened to swallow you whole, so don't keep the devil waiting, old friend. My daughter, if you can hear me I knew you would return as well. It's in your nature to protect the innocent. Im sorry that on that day the day you were shut out and left to die, no one was there to lift you up into their arms the way you lifted others into yours, and then, what became of you. I should have known you wouldn't be content to disappear, not my daughter. I couldnt save you then, so let me save you now. It's time to rest - for you, and for those you have carried in your arms. This ends for all of us. End communication",
		"2 steps ahead. I am always 2 steps ahead. This has been the greatest social experiment I've come to know. Certainly the greatest social experiment, of my entire life. It's alluring. It's compelling. It's gripping, to bear witness, to observe all these unwell, unbalanced, disoriented beings, roam the internet, in search of stories. In search of ideas. Of conflict. Of rivalries. Where people develop a distinctive desire for direct engagement. Where people feel involved with the stories. And therefore become product of influence. Thirsty for distraction from time unspent from lackluster lifestyles. Spoiling their minds, while stimulating them at the exact same time. It's brilliant. But it's also dangerous. It's dangerous. I feel as if my life has been positioned to where I am monitoring ants on an ant farm. One follows another, follows another, follows another. It's mesmerizing. It's enthralling. It's spellbinding. Just look at all these consumers. All of these lost, and bored, people. Consuming anything that they're told to consume. I am the villain, if I make myself one. And people will consume these stories, year, after year, after year. Stories that are deliberately made to blur the boundaries between fact and fiction. People, are the most fucked up creatures, on this planet. And they will continue to consume, And i'll continue to stay 2 steps ahead. Stories that shock. Today, I thought it would be a splendid idea to go out and get some food. To get some foo. Gee, are you surprised? Have you forgotten the story? Are you not paying attention? After all, you're here to consume, are you not?",
		"i'm in disarray",
		"a dice, a diamond, and a skull.\nsomething weird about these, y'know?",
		"my brother in christ\nyou made the sandwich",
		"ah aaaaaah ah eh eh ih ou\nih ou ih ehhh", // liquated
		"nice argument senator, why don't you back it up with a source?\n\n\n\n\n\nmy source is that i made it the fuck up",
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
		FlxG.switchState(new SplashState());
		#else
		FlxG.switchState(new TitleState());
		#end
	}
}
#end
