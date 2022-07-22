package modifiers;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class ModifierSubstate extends MusicBeatSubstate
{
    var modifiersAvailable:Array<String> = [
        "wind_up",
        "speed",
        "p2_side",
        "stairs",
        "no_miss",
        "perfect",
        "goods_only"
    ];

    var modifierName:FlxText;
    var modifierDesc:FlxText;
    var modifierText:FlxText;
    
    var multiplierText:FlxText;
    var curMultiplier:Float = 1.0;

    var items:FlxTypedGroup<Alphabet>;

    static var curSelected:Int = 0;
    
    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuBGBlue"));
        add(bg);

        items = new FlxTypedGroup<Alphabet>();
        add(items);

        for (i in 0...modifiersAvailable.length)
        {
            var name = Modifiers.modifierNames[modifiersAvailable[i]];

            var item = new Alphabet(0, 0, name, true);
            item.isMenuItem = true;
            item.targetY = i - curSelected;

            var box = new FlxSprite();
			box.frames = Paths.getSparrowAtlas("modifierBox");
			box.animation.addByPrefix("idle", "box", 24);
			box.animation.play('idle');
			box.setGraphicSize(125);
			box.updateHitbox();
			box.antialiasing = true;
			box.x = -box.width - 75;
			box.y = (item.height / 2) - (box.height / 2);

            var icon = new FlxSprite().loadGraphic(Paths.image("modifierIcons/" + modifiersAvailable[i]));
            icon.scale.set(box.scale.x, box.scale.y);
            icon.updateHitbox();
            icon.antialiasing = true;
            icon.x = box.x + (box.width / 2) - (icon.width / 2);
            icon.y = box.y + (box.height / 2) - (icon.height / 2);

            item.add(box);
            item.add(icon);

            item.x = 240;
            item.y = item.getTargetY();
            items.add(item);
        }

        var modifierDescBG:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2 - 160), Std.int(FlxG.height - 80), FlxColor.BLACK);
        modifierDescBG.x = FlxG.width - modifierDescBG.width - 40;
        modifierDescBG.y = 40;
        modifierDescBG.alpha = 0.6;
        add(modifierDescBG);

        modifierName = new FlxText(0, 0, modifierDescBG.width - 40);
        modifierName.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        modifierName.borderSize = 3;
        modifierName.x = modifierDescBG.x + 20;
        modifierName.y = modifierDescBG.y + 20;
        add(modifierName);

        modifierDesc = new FlxText(0, 0, modifierDescBG.width - 40);
        modifierDesc.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        modifierDesc.borderSize = 3;
        modifierDesc.x = modifierDescBG.x + 20;
        modifierDesc.y = modifierName.y + modifierName.height + 20;
        add(modifierDesc);

        modifierText = new FlxText(0, 0, modifierDescBG.width - 40);
        modifierText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        modifierText.borderSize = 3;
        modifierText.x = modifierDescBG.x + 20;
        modifierText.y = modifierDesc.y + modifierDesc.height + 40;
        add(modifierText);

        multiplierText = new FlxText(0, 0, modifierDescBG.width - 40);
        multiplierText.setFormat("VCR OSD Mono", 22, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        multiplierText.borderSize = 3;
        multiplierText.x = modifierDescBG.x + 20;
        multiplierText.y = modifierDescBG.y + modifierDescBG.height - multiplierText.height - 20;
        add(multiplierText);

        changeSelection();
        changeModifier();
        updateMultiplier();

        forEachOfType(FlxSprite, function(spr:FlxSprite) {
            var alpha = spr.alpha;
            spr.alpha = 0;
            FlxTween.tween(spr, {alpha: alpha}, 0.4, { ease: FlxEase.expoInOut });
        }, true);
    }

    function changeSelection(huh:Int = 0):Void
    {
        if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        
        curSelected += huh;

        if (curSelected > modifiersAvailable.length - 1)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = modifiersAvailable.length - 1;

        modifierName.text = Modifiers.modifierNames[modifiersAvailable[curSelected]];
        modifierDesc.text = Modifiers.modifierDescs[modifiersAvailable[curSelected]];

        var bullShit:Int = 0;

		for (i in 0...items.length)
		{
            var item = items.members[i];
            
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

            if (item.targetY == 0)
                item.alpha = 1;
		}

        changeModifier();
    }

    function changeModifier(huh:Float = 0):Void
    {
        if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        if (Modifiers.modifiers[modifiersAvailable[curSelected]] is Float)
        {
            if (huh != 0)
                Modifiers.modifiers[modifiersAvailable[curSelected]] += huh;

            modifierText.text = "< " + Std.string(Modifiers.modifiers[modifiersAvailable[curSelected]]) + " >";
        }
        else if (Modifiers.modifiers[modifiersAvailable[curSelected]] is Bool)
        {
            if (huh != 0)
            {
                Modifiers.modifiers[modifiersAvailable[curSelected]] = (huh > 0 ? true : false);
                modifierText.text = "< " + (huh > 0 ? "Active" : "Not Active") + " >";
            }
            else
                modifierText.text = "< " + (Modifiers.modifiers[modifiersAvailable[curSelected]] > 0 ? "Active" : "Not Active") + " >";
        }

        updateMultiplier();
        
        modifierText.y = modifierDesc.y + modifierDesc.height + 40;
    }

    function updateMultiplier():Void
    {
        curMultiplier = 1.0;

        for (name in modifiersAvailable)
        {
            if (Modifiers.modifiers[name] != Modifiers.modifierDefaults[name])
            {
                if (Modifiers.modifiers[name] is Float)
                    curMultiplier += Modifiers.modifiers[name] * Modifiers.modifierRates[name];
                else if (Modifiers.modifiers[name] is Bool)
                    curMultiplier += Modifiers.modifierRates[name];
            }
        }

        multiplierText.text = "Multiplier Value: " + Helper.completePercent(curMultiplier, 3) + "x";
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (controls.UI_BACK)
        {
            forEachOfType(FlxSprite, function(spr:FlxSprite) {
                FlxTween.tween(spr, {alpha: 0}, 0.4, { ease: FlxEase.expoInOut });
            }, true);

            new FlxTimer().start(0.4, function(tmr:FlxTimer) {
                close();
            });
        }

        if (controls.UI_UP_P)
            changeSelection(-1);

        if (controls.UI_DOWN_P)
            changeSelection(1);

        if (Modifiers.modifiers[modifiersAvailable[curSelected]] is Float)
        {
            if (controls.UI_LEFT_P && Modifiers.modifiers[modifiersAvailable[curSelected]] > 1)
                changeModifier(-Modifiers.modifierIncrements[modifiersAvailable[curSelected]]);
    
            if (controls.UI_RIGHT_P)
                changeModifier(Modifiers.modifierIncrements[modifiersAvailable[curSelected]]);
        }
        else if (Modifiers.modifiers[modifiersAvailable[curSelected]] is Bool)
        {
            if (controls.UI_LEFT_P)
                changeModifier(-1);
    
            if (controls.UI_RIGHT_P)
                changeModifier(1);
        }
    }
}