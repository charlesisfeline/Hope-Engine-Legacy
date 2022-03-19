package;

import editors.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

#if desktop
import Discord.DiscordClient;
#end

class EditorsState extends MusicBeatState
{
    var options:Array<String> = ["Chart Editor", "Character Editor", "Week Editor"];
    var grpOptions:FlxTypedGroup<Alphabet>;

    var mods:Array<String> = [];

    var curSelected:Int = 0;

    override function create() 
    {
        #if desktop
        DiscordClient.changePresence("Editors Menu");
        #end
        
        super.create();
        
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat_gradient"));
        bg.screenCenter();
        bg.color = 0xffad34ff;
        add(bg);

        grpOptions = new FlxTypedGroup<Alphabet>();
        add(grpOptions);

        for (i in 0...options.length)
        {
            var option:Alphabet = new Alphabet(25, (70 * i) + 30, options[i], true);
            option.isMenuItem = true;
            option.targetY = i;
            grpOptions.add(option);
        }

        changeSelection();
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if (curSelected < 0)
            curSelected = grpOptions.length - 1;
        if (curSelected >= grpOptions.length)
            curSelected = 0;

        var bullShit:Int = 0;

        for (item in grpOptions.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.x = 25;
            item.alpha = 0.6;

            if (item.targetY == 0)
                item.alpha = 1;
        }
    }

    function select():Void
    {
        var state:MusicBeatState = null;
        switch (options[curSelected])
        {
            case "Chart Editor": 
                ChartingState.fromEditors = true;
                state = new ChartingState();
            case "Character Editor": 
                state = new CharacterEditor();
            case "Week Editor": 
                state = new WeekEditor();
        }

        FlxG.switchState(state);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.BACK)
			FlxG.switchState(new MainMenuState());
        if (controls.ACCEPT)
            select();
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
    }
}