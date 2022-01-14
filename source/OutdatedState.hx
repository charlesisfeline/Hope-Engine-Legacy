package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OutdatedState extends MusicBeatState
{
    override function create() 
    {
        var awesomeText:FlxText = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, "");
		awesomeText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        awesomeText.text = "Seems like you have an outdated version.\n\nPress ENTER to get to the latest release\n\nPress ESCAPE to ignore";
		awesomeText.screenCenter();
		awesomeText.borderSize = 3;
		add(awesomeText);

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