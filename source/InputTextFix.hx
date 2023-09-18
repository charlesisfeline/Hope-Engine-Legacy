package;

import flixel.addons.ui.interfaces.IResizable;
import flixel.util.FlxColor;
import texter.flixel.FlxInputTextRTL;

/**
 * Uses Texter haxelib
 * 
 * Cool shit tbh
 */
class InputTextFix extends FlxInputTextRTL implements IResizable
{
	public function resize(w:Float, h:Float)
    {
        width = w;
        height = h;
        calcFrame();
    }
}