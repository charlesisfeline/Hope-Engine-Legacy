package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.filters.GlowFilter;

class OutdatedState extends MusicBeatState
{
	override function create()
	{
		var awesomeText:FlxText = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, "");
		awesomeText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.NONE);
		awesomeText.text = MainMenuState.hopeEngineVer + " < " + TitleState.requestedVersion
						 + "\n\nSeems like you have an outdated version.";
		awesomeText.screenCenter();
		add(awesomeText);

		var entr = new KeyDisplay("enter", "GET LATEST");
		entr.x = FlxG.width / 2 - entr.width - 20;
		entr.y = awesomeText.y + awesomeText.height + 20;
		add(entr);

		var esc = new KeyDisplay("escape", "IGNORE");
		esc.x = FlxG.width / 2 + 20;
		esc.y = awesomeText.y + awesomeText.height + 20;
		add(esc);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
			fancyOpenURL('https://github.com/skuqre/Hope-Engine/releases/latest/');

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MainMenuState());
	}
}
