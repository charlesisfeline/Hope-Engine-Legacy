package editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class PositionOffsetEditor extends MusicBeatState
{
    public static var fromEditors:Bool = false;
    
    var pos:FlxText;
    var charChange:FlxText;
    var charChange2:FlxText;
	var character:Character;
	var deathCharacter:Character;

	var charName:String = "bf";
    var charName2:String = "bf";
    var isPlayer:Bool = true;

    var characters:Array<String> = [];

    static var curSelected:Int = 0;
    static var curSelected2:Int = 0;

	public function new(char:String = "bf", char2:String = "bf-dead", isPlayer:Bool = true)
    {
        super();
        charName = char;
        charName2 = char2;
        
        this.isPlayer = isPlayer;
    }

	override function create()
	{
        #if FILESYSTEM
		Paths.destroyCustomImages();
		Paths.clearCustomSoundCache();
		#end
        
        var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		add(bg);
        
        pos = new FlxText(10, 10, "", 24);
        pos.borderStyle = OUTLINE;
        add(pos);

        charChange = new FlxText(10, 10, "", 24);
        charChange.alignment = CENTER;
        charChange.borderStyle = OUTLINE;
        add(charChange);

        charChange2 = new FlxText(10, 10, "", 24);
        charChange2.alignment = CENTER;
        charChange2.borderStyle = OUTLINE;
        add(charChange2);

        var ctrls = new FlxText(10, 10, "", 16);
        ctrls.alignment = CENTER;
        ctrls.borderStyle = OUTLINE;
        add(ctrls);

        ctrls.text = "controls: "
                   + '\n[ENTER] - Reload to set Characters'
                   + '(while holding [SHIFT] - Does the same thing, but makes you it look left instead)'
                   + '[J] or [L] - Change selected character (at bottom left)'
                   + '(while holding [SHIFT] - Change the character to offset)';

        ctrls.x = FlxG.width - ctrls.width - 10;
        ctrls.y = FlxG.width - ctrls.height - 10;
        
        if (isPlayer)
            character = new Boyfriend(0, 0, charName, isPlayer);
        else
            character = new Character(0, 0, charName, isPlayer);
        character.debugMode = true;
        character.screenCenter();
        character.x += character.positionOffset[0];
        character.y += character.positionOffset[1];
        character.alpha = 0.5;
        add(character);

        if (isPlayer)
            deathCharacter = new Boyfriend(0, 0, charName2, isPlayer);
        else
            deathCharacter = new Character(0, 0, charName2, isPlayer);
        deathCharacter.alpha = 0.5;
        add(deathCharacter);

        var pastMod:Null<String> = Paths.currentMod;
		Paths.setCurrentMod(null);
		characters = CoolUtil.coolTextFile(Paths.txt('characterList'));

        #if FILESYSTEM
		Paths.setCurrentMod(pastMod);

		if (Paths.currentMod != null)
		{
			if (FileSystem.exists(Paths.modTxt('characterList')))
				characters = characters.concat(CoolUtil.coolStringFile(File.getContent(Paths.txt('characterList'))));
		}
		#end

        changeChar();
        changeChar2();

		super.create();
	}

    function changeChar(huh:Int = 0):Void
    {
        curSelected += huh;

        if (curSelected < 0)
			curSelected = characters.length - 1;
		if (curSelected >= characters.length)
			curSelected = 0;

        charChange.text = "<J " + characters[curSelected] + " L>";
        charChange.x = 10;
        charChange.y = FlxG.height - charChange.height - 10;

        charChange2.text = "<J " + characters[curSelected2] + " L>";
        charChange2.x = charChange.x + charChange.width + 10;
        charChange2.y = FlxG.height - charChange.height - 10;
    }

    function changeChar2(huh:Int = 0):Void
    {
        curSelected2 += huh;

        if (curSelected2 < 0)
            curSelected2 = characters.length - 1;
        if (curSelected2 >= characters.length)
            curSelected2 = 0;

        charChange.text = "<J " + characters[curSelected] + " L>";
        charChange.x = 10;
        charChange.y = FlxG.height - charChange.height - 10;

        charChange2.text = "<J " + characters[curSelected2] + " L>";
        charChange2.x = charChange.x + charChange.width + 10;
        charChange2.y = FlxG.height - charChange.height - 10;
    }

    var backing:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        deathCharacter.setPosition(character.getScreenPosition().x + deathCharacter.positionOffset[0], character.getScreenPosition().y + deathCharacter.positionOffset[1]);
        pos.text = "current position: " + deathCharacter.positionOffset + "\nthis isn't meant to be an advanced editor lol";

        var mult:Float = 1;

        if (FlxG.keys.pressed.SHIFT)
            mult = 10;

        if (controls.UI_LEFT_P)
            deathCharacter.positionOffset[0] -= mult;

        if (controls.UI_RIGHT_P)
            deathCharacter.positionOffset[0] += mult;

        if (controls.UI_UP_P)
            deathCharacter.positionOffset[1] -= mult;

        if (controls.UI_DOWN_P)
            deathCharacter.positionOffset[1] += mult;

        if (controls.UI_BACK && !backing && !FlxG.keys.justPressed.BACKSPACE)
        {
            backing = true;
            #if FILESYSTEM
            if (fromEditors)
            {
                CustomTransition.switchTo(new EditorsState());
                fromEditors = false;
            }
            else
            #end
            CustomTransition.switchTo(new MainMenuState());
        }

        if (FlxG.keys.justPressed.J)
        {
            if (FlxG.keys.pressed.SHIFT)
                changeChar2(-1);
            else
                changeChar(-1);
        }

        if (FlxG.keys.justPressed.L)
        {
            if (FlxG.keys.pressed.SHIFT)
                changeChar2(1);
            else
                changeChar(1);
        }

        if (controls.UI_ACCEPT)
        {
            // no, the other way does not work and confuses me
            // believe me ive tried
            if (FlxG.keys.pressed.SHIFT)
                CustomTransition.switchTo(new PositionOffsetEditor(characters[curSelected], characters[curSelected2], true));
            else
                CustomTransition.switchTo(new PositionOffsetEditor(characters[curSelected], characters[curSelected2], false));
        }
	}
}
