package options;

import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using StringTools;

class KeybindsState extends MusicBeatState
{
	var isRecording:Bool = false;
	var recordBG:FlxSprite;
	var recordText:Alphabet;
    var deleteText:FlxText;

	var curRow:Int = 0;
	var curCol:Int = 0;

	var categoryColumn:FlxTypedGroup<Alphabet>;
	var titleColumn:FlxTypedGroup<Alphabet>;
	var mainColumn:FlxTypedGroup<Alphabet>;
	var altColumn:FlxTypedGroup<Alphabet>;

    var selectUnderline:FlxSprite;
    var camPos:FlxObject;
	var camFollow:FlxObject;

    // both of these should have the same length!
    var categoryNames:Array<String> = ["Gameplay", "UI"];
	var keyNames:Array<Array<String>> = [
		["UP", "DOWN", "LEFT", "RIGHT", "PAUSE", "RESET"],
		["UP", "DOWN", "LEFT", "RIGHT", "ACCEPT", "GO BACK", "RESET"]
	];

	override function create()
	{
        if (Paths.priorityMod != "hopeEngine")
        {
            if (Paths.exists(Paths.state("KeybindsState")))
            {
                Paths.setCurrentMod(Paths.priorityMod);
                FlxG.switchState(new CustomState("KeybindsState", BINDS));
                return;
            }
        }

        if (Paths.priorityMod == "hopeEngine")
			Paths.setCurrentMod(null);
		else
			Paths.setCurrentMod(Paths.priorityMod);

		var menuBG = new FlxSprite().loadGraphic(Paths.image("menuBGMagenta"));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
        menuBG.scrollFactor.set();
		menuBG.antialiasing = true;
		add(menuBG);

        camPos = new FlxObject(0, 0, 1, 1);
        camPos.screenCenter();
        add(camPos);

        camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.screenCenter();
        add(camFollow);

        FlxG.camera.follow(camPos, 1);

        selectUnderline = new FlxSprite();
        selectUnderline.frames = Paths.getSparrowAtlas('alphabet');
        selectUnderline.animation.addByPrefix("a", "-", 24);
        selectUnderline.animation.play("a");
        selectUnderline.updateHitbox();
        selectUnderline.color = 0xff000000;
        selectUnderline.antialiasing = true;
        selectUnderline.visible = false;
        add(selectUnderline);

        categoryColumn = new FlxTypedGroup<Alphabet>();
        add(categoryColumn);

        titleColumn = new FlxTypedGroup<Alphabet>();
        add(titleColumn);

        mainColumn = new FlxTypedGroup<Alphabet>();
        add(mainColumn);

        altColumn = new FlxTypedGroup<Alphabet>();
        add(altColumn);

        var lastY:Null<Float> = null;
        for (i in 0...categoryNames.length)
        {
            var alp = new Alphabet(0, 0, categoryNames[i], true);
            alp.y = lastY != null ? lastY : 0;
            alp.screenCenter(X);

            var lastlastY:Null<Float> = null;
            for (i2 in 0...keyNames[i].length)
            {
                var alp2 = new Alphabet(25, 0, keyNames[i][i2], true);
                alp2.y = lastlastY != null ? lastlastY : alp.y + alp.height + 50;
                lastlastY = alp2.y + alp2.height + 25;
                lastY = alp2.y + alp2.height + 75;

                var controls:Array<Array<Null<FlxKey>>> = cast FlxG.save.data.controls;
                var additive = i > 0 ? 6 : 0;

                var main = controls[i2 + additive][0] != null ? controls[i2 + additive][0].toString() : "---";
                var mainKey = new Alphabet(FlxG.width / 3 + 25, 0, main);
                mainKey.y = alp2.y;
                mainColumn.add(mainKey);

                var alt = controls[i2 + additive][1] != null ? controls[i2 + additive][1].toString() : "---";
                var altKey = new Alphabet(((FlxG.width / 3) * 2) + 25, 0, alt);
                altKey.y = alp2.y;
                altColumn.add(altKey);

                titleColumn.add(alp2);
            }

            categoryColumn.add(alp);
        }

        var reset = new Alphabet(0, 0, "Hold Left Mouse Button\nto reset to default keys", true);
        reset.y = titleColumn.members[titleColumn.length - 1].y + titleColumn.members[titleColumn.length - 1].height + 50;
        reset.screenCenter(X);
        add(reset);

		recordBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		recordBG.visible = false;
        recordBG.scrollFactor.set();
        recordBG.alpha = 0.6;
		add(recordBG);

		recordText = new Alphabet(0, 0, "Recording! Press a key...", true);
		recordText.visible = false;
		recordText.screenCenter();
        recordText.scrollFactor.set();
		add(recordText);

        deleteText = new FlxText(0, 0, FlxG.width, "Press the left mouse button to remove binding...\nPress the right mouse button to stop recording...", 16);
		deleteText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		deleteText.screenCenter();
        deleteText.y = recordText.y + recordText.height + 10;
		deleteText.scrollFactor.set();
		deleteText.borderSize = 3;
        deleteText.visible = false;
		add(deleteText);

		super.create();

        changeRow();
        changeCol();
	}

    var selected:Alphabet = null;

	function changeRow(?huh:Int = 0):Void
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curRow += huh;

        var rows = titleColumn.members;

        if (curRow > rows.length - 1)
            curRow = 0;
        if (curRow < 0)
            curRow = rows.length - 1;

        camFollow.y = rows[curRow].y + (rows[curRow].height / 2);
        camFollow.x = FlxG.width * 0.5;

        for (item in titleColumn.members)
            item.alpha = 0.6;

        for (item in mainColumn.members)
            item.alpha = 0.6;

        for (item in altColumn.members)
            item.alpha = 0.6;

        if (curCol == 0)
            selected = mainColumn.members[curRow];
        if (curCol == 1)
            selected = altColumn.members[curRow];

        selected.alpha = 1;

        titleColumn.members[curRow].alpha = 1;
	}

	function changeCol(?huh:Int = 0):Void
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curCol += huh;

        if (curCol < 0)
            curCol = 1;

        if (curCol > 1)
            curCol = 0;

        changeRow();
	}

	function activateRecord():Void
	{
		isRecording = true;
		recordBG.visible = true;
		recordText.visible = true;
        deleteText.visible = true;
	}

    var allKeysUnique:Bool = false;

    function uniqueness():Void
    {
        var keyGroup:Array<FlxKey> = [];
        var keyGroup2:Array<FlxKey> = [];
        var uniqueGroup1:Array<FlxKey> = [];
        var uniqueGroup2:Array<FlxKey> = [];

        
        for (i in 0...6)
        {
            var a:Array<FlxKey> = cast FlxG.save.data.controls[i];
            for (key in a)
                keyGroup.push(key);
        }

        for (i in 6...13)
        {
            var a:Array<FlxKey> = cast FlxG.save.data.controls[i];
            for (key in a)
                keyGroup2.push(key);
        }

        // push every unique key into the unique groups

        for (key in keyGroup)
        {
            if (!uniqueGroup1.contains(key))
                uniqueGroup1.push(key);
        }

        for (key in keyGroup2)
        {
            if (!uniqueGroup2.contains(key))
                uniqueGroup2.push(key);
        }

        allKeysUnique = (keyGroup.length == uniqueGroup1.length) && (keyGroup2.length == uniqueGroup2.length);
    }

	var recordTime:Float = 0.0;
    var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        uniqueness();

        var lerp:Float = Helper.boundTo(elapsed * 9.2, 0, 1);
		camPos.x = FlxMath.lerp(camPos.x, camFollow.x, lerp);
		camPos.y = FlxMath.lerp(camPos.y, camFollow.y, lerp);

        if (selected != null)
        {
            selectUnderline.setGraphicSize(Std.int(selected.width), Std.int(selectUnderline.height));
            selectUnderline.updateHitbox();
            selectUnderline.y = selected.y + selected.height + 5 + (selected.text == "---" ? 20 : 0);
            selectUnderline.x = selected.x;
            selectUnderline.visible = true;
        }
        else
            selectUnderline.visible = false;

		if (!isRecording)
		{
            if (FlxG.mouse.pressed)
            {
                holdTime += elapsed;
    
                if (holdTime > 3)
                {
                    KeyBinds.resetBinds();
                    FlxG.save.flush();
                    CustomTransition.reset();
    
                    return;
                }
            }
            else
                holdTime = 0;

			if (controls.UI_BACK)
            {
                if (allKeysUnique)
                    CustomTransition.switchTo(new OptionsState());
                else
                    FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
            }

            if (controls.UI_UP_P)
                changeRow(-1);

            if (controls.UI_DOWN_P)
                changeRow(1);

            if (controls.UI_LEFT_P)
                changeCol(-1);

            if (controls.UI_RIGHT_P)
                changeCol(1);

            if (controls.UI_ACCEPT)
                activateRecord();
		}
		else
		{
			recordTime += elapsed;

			recordText.alpha = deleteText.alpha = (Math.sin(recordTime * 5) + 1) / 2;

            if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
            {
                if (FlxG.keys.justPressed.ANY)
                {
                    FlxG.save.data.controls[curRow][curCol] = FlxG.keys.getIsDown()[0].ID;
                    selected.text = FlxKey.toStringMap[FlxG.save.data.controls[curRow][curCol]];
                }

                if (FlxG.mouse.justPressed)
                {
                    if (curCol == 0 || FlxG.save.data.controls[curRow].length < 2)
                        FlxG.save.data.controls[curRow].shift();
                    if (curCol == 1 && FlxG.save.data.controls[curRow].length > 1)
                        FlxG.save.data.controls[curRow].pop();

                    var a:Array<Null<FlxKey>> = FlxG.save.data.controls[curRow];

                    mainColumn.members[curRow].text = a[0] != null ? a[0].toString() : "---";
                    altColumn.members[curRow].text = a[1] != null ? a[1].toString() : "---";
                }

                isRecording = false;
                recordBG.visible = false;
                recordText.visible = false;
                deleteText.visible = false;

                FlxG.save.flush();
                PlayerSettings.player1.controls.loadKeyBinds();
            }
		}
	}
}
