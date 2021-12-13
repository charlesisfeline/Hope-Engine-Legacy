package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;

#if windows
import Discord.DiscordClient;
#end

class CreditsState extends MusicBeatState
{
    var alphabets:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var allTheShit:Array<Array<String>> = [];

    var descBackground:FlxSprite;
    var descriptionShit:FlxText;

    override function create()
    {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits", null);
		#end
        
        var bg = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);

        alphabets = new FlxTypedGroup<Alphabet>();
        add(alphabets);

        descBackground = new FlxSprite().makeGraphic(Std.int((FlxG.width * 0.85) + 8), 72, 0xFF000000);
		descBackground.alpha = 0.6;
		descBackground.screenCenter(X);
		descBackground.visible = false;
		add(descBackground);

        descriptionShit = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, " ");
		descriptionShit.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionShit.screenCenter(X);
		descriptionShit.borderSize = 3;
		add(descriptionShit);

        descBackground.setPosition(descriptionShit.x - 4, descriptionShit.y - 4);

        var credits:Array<Dynamic> = Json.parse(Assets.getText(Paths.json('credits')));

        for (i in 0...credits.length)
        {
            var curCategory = credits[i];

            var catLabel:Alphabet = new Alphabet(0, 0, curCategory.categoryName, true);
			catLabel.isMenuItem = true;
			catLabel.targetY = alphabets.members.length - 1;
            catLabel.y = -catLabel.height;
            catLabel.screenCenter(X);
			alphabets.add(catLabel);

            allTheShit.push([curCategory.categoryName,"",""]);

            var catItems:Array<Dynamic> = curCategory.categoryItems;
            for (i2 in 0...catItems.length)
            {
                var curCredit = curCategory.categoryItems[i2];

                var credLabel:Alphabet = new Alphabet(0, 0, curCredit.name, false);
                credLabel.isMenuItem = true;
                credLabel.targetY = alphabets.members.length - 1;
                credLabel.y = -credLabel.height;
                credLabel.screenCenter(X);
                alphabets.add(credLabel);

                allTheShit.push([curCredit.name, (curCredit.desc == null ? "" : curCredit.desc), (curCredit.link == null ? "" : curCredit.link)]);
            }
        }

        changeSelection();
        if (alphabets.members[curSelected].isBold)
            changeSelection(1);
        
        super.create();
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
        
        if (controls.UP_P)
        {
            changeSelection(-1);
            if (alphabets.members[curSelected].isBold)
                changeSelection(-1);
        }

        if (controls.DOWN_P)
        {
            changeSelection(1);
            if (alphabets.members[curSelected].isBold)
                changeSelection(1);
        }

        if (controls.ACCEPT)
        {
            if (allTheShit[curSelected][2] != "")
                fancyOpenURL(allTheShit[curSelected][2]);
        }

        if (controls.BACK)
			FlxG.switchState(new MainMenuState());
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

        curSelected += change;

        if (curSelected < 0)
            curSelected = alphabets.length - 1;
        if (curSelected >= alphabets.length)
            curSelected = 0;

        if (allTheShit[curSelected][1] != "")
        {
            descBackground.visible = true;
            descriptionShit.visible = true;
            descriptionShit.text = allTheShit[curSelected][1];
        }
        else
        {
            descBackground.visible = false;
            descriptionShit.visible = false;
            descriptionShit.text = "";
        }

        var bullShit:Int = 0;

        for (item in alphabets.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            if (!item.isBold)
                item.alpha = 0.6;

            if (item.targetY == 0)
                item.alpha = 1;
        }
    }
}