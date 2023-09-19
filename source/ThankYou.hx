package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ThankYou extends MusicBeatState
{
    var people:Array<String> = [
        "juney2008",
        "raulandrei27",
        "Stillc",
        "IDKwutimdoinbruh",
        "fewden",
        "Novikond",
        "SpringHat3",
        "ACodedGuy",
        "The Face Games",
        "MythicSpeed",
        "TheKitBoi",
        "watergamer6446",
        "xenriot",
        "obvious_pyro_lol",
        "daisukidaisy",
        "JorgeVini334",
        "hasanverbovoy",
        "A_n0rmal_Hum4n",
        "SuperKoolRaven",
        "bardzo_",
        "Heckat",
        "FizzyBott",
        "Pumpsuki",
        "ElMilanesaXD",
        "Florentin_B",
        "JoelMerinoJ",
        "tom (TOM?!?!)",
        "4kan",
        "Pinkidima",
        "IsaiahDraws"
    ];

	override function create()
	{
        var title = new FlxText(10, 10, "Thank you.");
        title.setFormat("VCR OSD Mono", 64, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        title.borderSize = 3;
        add(title);

        var subtitle = new FlxText(10, title.y + title.height + 10, "Thank you so much for checking out the WIP.");
        subtitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        subtitle.borderSize = 3;
        add(subtitle);

        var people1 = new FlxText(10, subtitle.y + subtitle.height + 20, (FlxG.width / 3) - 15, people.splice(0, 10).join("\n"));
        people1.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        people1.borderSize = 3;
        add(people1);

        var people2 = new FlxText(10, subtitle.y + subtitle.height + 20, (FlxG.width / 3) - 15, people.splice(0, 10).join("\n"));
        people2.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        people2.borderSize = 3;
        people2.screenCenter(X);
        add(people2);

        var people3 = new FlxText(10, subtitle.y + subtitle.height + 20, (FlxG.width / 3) - 15, people.splice(0, 10).join("\n"));
        people3.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        people3.borderSize = 3;
        people3.x = FlxG.width - people2.width - 10;
        add(people3);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (controls.UI_BACK)
            CustomTransition.switchTo(new MainMenuState());
	}
}
