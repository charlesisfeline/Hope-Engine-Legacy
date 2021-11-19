package;

import flixel.FlxG;
import flixel.FlxSprite;

class ModchartFunctions {

    public static var curSprites:Map<String, FlxSprite> = new Map<String, FlxSprite>();

    public static function addCustomSprite(tag:String, behindCharacters:Bool = false) 
    {
        
    }

    public static function changeDad(newDad:String, positionProperly:Bool = false) 
    {
        var oldDad = PlayState.dad;
        PlayState.instance.removeObject(PlayState.dad);
        PlayState.dad = new Character(oldDad.x, oldDad.y, newDad);
        PlayState.instance.addObject(PlayState.dad);

        if (positionProperly)
        {
            PlayState.dad.x = oldDad.x + (oldDad.width / 2) - (PlayState.dad.width / 2);
            PlayState.dad.y = oldDad.y + oldDad.height - PlayState.dad.height;
        }
    }

    public static function changeBoyfriend(newBf:String, positionProperly:Bool = false) 
    {
        var oldBf = PlayState.boyfriend;
        PlayState.instance.removeObject(PlayState.boyfriend);
        PlayState.boyfriend = new Boyfriend(oldBf.x, oldBf.y, newBf);
        PlayState.instance.addObject(PlayState.boyfriend);

        if (positionProperly)
        {
            PlayState.boyfriend.x = oldBf.x + (oldBf.width / 2) - (PlayState.boyfriend.width / 2);
            PlayState.boyfriend.y = oldBf.y + oldBf.height - PlayState.boyfriend.height;
        }
    }

    public static function changeGirlfriend(newGf:String, positionProperly:Bool = false) 
    {
        var oldGf = PlayState.gf;
        PlayState.instance.removeObject(PlayState.gf);
        PlayState.dad = new Character(oldGf.x, oldGf.y, newGf);
        PlayState.instance.addObject(PlayState.gf);

        if (positionProperly)
        {
            PlayState.dad.x = oldGf.x + (oldGf.width / 2) - (PlayState.gf.width / 2);
            PlayState.dad.y = oldGf.y + oldGf.height - PlayState.gf.height;
        }
    }

}