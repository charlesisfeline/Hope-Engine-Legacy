package;

import motion.easing.Sine;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxTimer;
import motion.Actuate;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import flixel.FlxG;
import flixel.FlxState;

class CustomTransition
{
    static var changing:Bool = false;
    public static var trans:OpenFLTransition;

    public static function init():Void
        trans = new OpenFLTransition();

    static var fade:Float = 0.5;

    public static function switchTo(to:FlxState, ?time:Float = 0.5):Void
    {
        if (changing) return;
        changing = true;
        fade = time;

        if (!FlxTransitionableState.skipNextTransIn)
            trans.fadeIn(time);
        else
            FlxTransitionableState.skipNextTransIn = false;

        new FlxTimer().start(time, function(_) {
            FlxG.switchState(to);

            if (!FlxTransitionableState.skipNextTransOut)
                FlxG.signals.postStateSwitch.add(fadeOut);
            else
            {
                FlxTransitionableState.skipNextTransOut = false;
                changing = false;
            }
        });
    }

    public static function reset():Void
    {
        switchTo(Type.createInstance(Type.getClass(FlxG.state), []));
    }

    static function fadeOut():Void
    {
        new FlxTimer().start(FlxG.elapsed, function(tmr:FlxTimer) {
            trans.fadeOut(fade);
            FlxG.signals.postStateSwitch.remove(fadeOut);

            changing = false;
        });
    }
}

class OpenFLTransition extends Sprite
{
    var fadeInGradient:Bitmap;      // black top transparent bottom
    var fadeOutGradient:Bitmap;     // transparent top black bottom
    var theEternalVoid:Bitmap;

    public function new() 
    {
        super();

        fadeInGradient = new Bitmap(Assets.getBitmapData('assets/embed/images/lazyFade-in.png'), true);
        fadeInGradient.y = -fadeInGradient.height;
        addChild(fadeInGradient);

        theEternalVoid = new Bitmap(Assets.getBitmapData('assets/embed/images/lazyFade-mid.png'), true);
        theEternalVoid.y = -theEternalVoid.height;
        addChild(theEternalVoid);

        fadeOutGradient = new Bitmap(Assets.getBitmapData('assets/embed/images/lazyFade-out.png', true));
        fadeOutGradient.y = -fadeOutGradient.height;
        addChild(fadeOutGradient);

        FlxG.signals.postUpdate.add(function()
        {
            scaleX = FlxG.scaleMode.scale.x;
            scaleY = FlxG.scaleMode.scale.y;

            x = FlxG.scaleMode.offset.x;
            y = FlxG.scaleMode.offset.y;
        });    
    }

    public function fadeIn(?time:Float = 0.5)
    {
        theEternalVoid.y = y - theEternalVoid.height * 2;

        Actuate.tween(theEternalVoid, time, {y: y}).ease(Sine.easeInOut).onUpdate(function() {
            fadeInGradient.y = theEternalVoid.y + theEternalVoid.height;
            fadeOutGradient.y = theEternalVoid.y - fadeOutGradient.height;
        });
    }

    public function fadeOut(?time:Float = 0.5)
    {
        theEternalVoid.y = y;

        Actuate.tween(theEternalVoid, time, {y: y + theEternalVoid.height + theEternalVoid.height}).ease(Sine.easeInOut).onUpdate(function() {
            fadeInGradient.y = theEternalVoid.y + theEternalVoid.height;
            fadeOutGradient.y = theEternalVoid.y - fadeOutGradient.height;
        });
    }
}