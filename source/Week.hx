package;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef WeekJSON = {

    public var weekName:String;
    public var weekCharacters:Array<String>;
    public var characterFlipX:Array<Bool>;
    public var tracks:Array<String>;

}

class Week
{
    public static var weeksLoaded:Map<String, WeekJSON> = new Map<String, WeekJSON>();
}