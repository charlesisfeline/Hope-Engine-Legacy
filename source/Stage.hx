package;

import flixel.util.FlxColor;

typedef StageJSON =
{
	var name:String;
	var bfPosition:Array<Float>;
	var gfPosition:Array<Float>;
	var dadPosition:Array<Float>;
	var defaultCamZoom:Null<Float>;

	var isHalloween:Null<Bool>;
}

//////////////////////
// JSON STAGE STUFF //
//////////////////////

typedef JSONStage =
{
    var stage:Array<JSONStageSprite>;
}

typedef JSONStageSprite =
{
    var varName:String;
    var imagePath:String;

    var antialiasing:Bool;
    var scale:Array<Float>;
    var angle:Float;
    var color:String;
    var alpha:Float;
    var blend:String;
    var flipX:Bool;
    var flipY:Bool;

    var initAnim:String;

    var animations:Array<JSONStageSpriteAnimation>;
}

typedef JSONStageSpriteAnimation = 
{
    var name:String;
	var prefix:String;

	@:optional var frameRate:Null<Int>;
	@:optional var loopedAnim:Null<Bool>;
	@:optional var indices:Null<Array<Int>>;
	@:optional var flipX:Null<Bool>;
	@:optional var flipY:Null<Bool>;
}