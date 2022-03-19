package;

import flixel.FlxSprite;

 class CheckBox extends FlxSprite 
 {
     public function new(x:Float, y:Float, ?toggle:Bool = false)
     {
         super(x, y);
 
         frames = Paths.getSparrowAtlas('checkboxAwesome');
         antialiasing = true;
 
         animation.addByPrefix("ticked", "checkbox checked", 24, false);
         setGraphicSize(150);
         updateHitbox();
         change(toggle);
     }
 
     public function change(huh:Bool)
     {
         if (huh)
             animation.play('ticked', true);
         else
             animation.play('ticked', true, true);
     }
 }