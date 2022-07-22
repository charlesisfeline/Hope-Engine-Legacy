package modifiers;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import modifiers.Modifiers.ModifierSave;

class ModifierSaveSubstate extends MusicBeatSubstate
{
	var curSelected:Int = 0;

	var savesFound:Array<ModifierSave> = [];
	var items:FlxTypedGroup<Alphabet>;

	var text:FlxText;

	public function new(songName:String)
	{
		super();

		savesFound = Modifiers.modifierScores.get(songName);
		savesFound.sort(sortByShit);

		var bg = new FlxSprite().loadGraphic(Paths.image("menuBGMagenta"));
		add(bg);

		items = new FlxTypedGroup<Alphabet>();
		add(items);

		for (i in 0...savesFound.length)
		{
			var text = i == 0 ? "Top Score" : "Save " + (i + 1);
			var item:Alphabet = new Alphabet(0, 0, text, true);
			item.targetY = i;
			item.isMenuItem = true;
			item.x = 40;
			item.y = item.getTargetY();

			items.add(item);
		}

		var scoreBG:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2 - 160), Std.int(FlxG.height - 80), FlxColor.BLACK);
        scoreBG.x = FlxG.width - scoreBG.width - 40;
        scoreBG.y = 40;
        scoreBG.alpha = 0.6;
        add(scoreBG);

		text = new FlxText(0, 0, scoreBG.width - 40);
        text.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        text.borderSize = 3;
        text.x = scoreBG.x + 20;
        text.y = scoreBG.y + 20;
        add(text);

		changeSelection();

		forEachOfType(FlxSprite, function(spr:FlxSprite) {
            var alpha = spr.alpha;
            spr.alpha = 0;
            FlxTween.tween(spr, {alpha: alpha}, 0.4, { ease: FlxEase.expoInOut });
        }, true);
		
		super.create();
	}

	function changeSelection(huh:Int = 0):Void
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSelected += huh;

        if (curSelected > items.length - 1)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = items.length - 1;

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

		var curItem:ModifierSave = savesFound[curSelected];
		var modifiers:Array<String> = [];
		var score:Int = 0;
		var multiplier:Float = 1;

		for (s in curItem.modifierList.keys()) 
		{
			var str = Modifiers.modifierNames.get(s);

			if (curItem.modifierList.get(s) is Float)
				str += " (" + Helper.truncateFloat(curItem.modifierList.get(s), 2) + "x)";
			
			modifiers.push(str);
		}

		for (key => value in curItem.modifierList) 
		{
			if (value is Float)
				multiplier += Modifiers.modifierRates.get(key) * value;
			else if (value is Bool)
				multiplier += Modifiers.modifierRates.get(key);
		}

		score = Std.int(curItem.score * multiplier);

		text.text = "Stats for this save: "
				  + '\n'
				  + '\nSong: ${curItem.songName}'
				  + '\nDifficulty: ${curItem.difficulty}'
				  + '\nSaved At: ${curItem.timeSaved}'
				  + '\n'
				  + '\nScore: ${score} (${curItem.score} x ${Helper.completePercent(multiplier, 3)})'
				  + '\nAccuracy: ${Helper.completePercent(curItem.accuracy, 2)}%'
				  + '\n'
				  + '\nModifiers:\n${modifiers.join(", ")}';
	}

	function sortByShit(Obj1:ModifierSave, Obj2:ModifierSave):Int
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.score, Obj2.score);

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
	}
}
