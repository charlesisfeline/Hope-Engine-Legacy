package;

import flixel.FlxSprite;

class FunkSprite extends FlxSprite
{
    public var idle:String;

	public function new(asset:String, ?library:String, x:Float, y:Float, ?scrollFactorX:Float = 1, ?scrollFactorY:Float = 1, ?animArray:Array<String>, ?looped:Bool = false)
    {
        super(x, y);

        if (animArray != null)
        {
            if (animArray.length > 0)
            {
                frames = Paths.getSparrowAtlas(asset, library);

                for (anim in animArray)
                {
                    animation.addByPrefix(anim, anim, 24, looped);

                    if (idle == null)
                    {
                        idle = anim;
                        animation.play(anim);
                    }
                }
            }
            else
                loadGraphic(Paths.image(asset, library));
        }
        else
            loadGraphic(Paths.image(asset, library));

        scrollFactor.set(scrollFactorX, scrollFactorY);        
        antialiasing = true;
    }

    public function dance(?forced:Bool = true)
    {
        if (idle != null)
            animation.play(idle, forced);
    }
}
