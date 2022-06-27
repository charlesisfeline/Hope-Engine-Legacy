package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Some sort of display that shows the user which key to press to do something.
 */
class KeyDisplay extends FlxSpriteGroup 
{
    public function new(key:String, inst:String)
    {
        super(0, 0);

        var keyImage = new FlxSprite();
        keyImage.frames = Paths.getSparrowAtlas("keyDisplays", "preload");
        keyImage.animation.addByPrefix("idle", key, 24);
        keyImage.animation.play("idle");
        keyImage.updateHitbox();
        keyImage.antialiasing = true;

        var instImage = new FlxText(0, 0, 150, inst);
        instImage.setFormat('Funkerin Regular', 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.NONE);
        instImage.color = FlxColor.WHITE;
        instImage.antialiasing = true;
        instImage.x = keyImage.width + 5;
        instImage.y = (keyImage.height / 2) - (instImage.height / 2);

        add(keyImage);
        add(instImage);
    }
}