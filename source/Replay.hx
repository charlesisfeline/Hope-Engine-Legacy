// revamped
// also may look odd because i suck at haxe

#if FILESYSTEM
import sys.io.File;
#end
import flixel.FlxG;
import haxe.Json;

typedef ReplayJSON =
{
    public var properties:Map<String, Dynamic>;
    public var notes:Array<Array<Array<Float>>>;
    public var sustains:Array<Array<Array<Float>>>;
    public var presses:Array<Array<Null<Float>>>;
}

class Replay
{
    public static var version:String = "0.1.5";

    public var path:String = "";
    public var replay:ReplayJSON;
    
    public function new(path:String)
    {
        this.path = path;
        replay = {
            properties: [
                "name" => "Tutorial",
                "difficulty" => 1,
                "speed" => 1.5,
                "downscroll" => false,
                "ghost_tapping" => true,
                "timestamp" => Date.now(),
                "version" => version
            ],
            notes: [],
            sustains: [],
            presses: [],
        };
    }

    public static function LoadReplay(path:String):Replay
    {
        var rep:Replay = new Replay(path);
        rep.LoadFromJSON();
        trace('basic replay data:\nSong Name: ' + rep.replay.properties.get("name") + '\nSong Diff: ' + rep.replay.properties.get("difficulty"));

        return rep;
    }

    public function SaveReplay(notes:Array<Array<Array<Float>>>, sustains:Array<Array<Array<Float>>>, presses:Array<Array<Float>>)
    {
        var json = {
            "properties" : {
                "name": PlayState.SONG.song,
                "difficulty": PlayState.storyDifficulty,
                "speed": (FlxG.save.data.scrollSpeed > 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed),
                "downscroll": FlxG.save.data.downscroll,
                "ghost_tapping": FlxG.save.data.ghost,
                "timestamp": Date.now(),
                "version": version
            },
            "notes": notes,
            "sustains": sustains,
            "presses": presses,
        };
        
        var data:String = Json.stringify(json, null, "\t");

        #if FILESYSTEM
        File.saveContent("assets/replays/" + (Paths.currentMod != null ? Paths.currentMod + "#" : "") + PlayState.SONG.song.toLowerCase() + "-" + Std.int(Date.now().getTime() / 1000) + ".funkinReplay", data);
        #end
    }

    public function LoadFromJSON()
    {
        #if FILESYSTEM
        trace('loading ' + Sys.getCwd() + 'assets/replays/' + path + ' replay...');
        try
        {
            var repl = cast Json.parse(File.getContent(Sys.getCwd() + "assets/replays/" + path));

            replay = {
                properties: [
                    "name" => repl.properties.name,
                    "difficulty" => repl.properties.difficulty,
                    "speed" => repl.properties.speed,
                    "downscroll" => repl.properties.downscroll,
                    "ghost_tapping" => repl.properties.ghost_tapping,
                    "timestamp" => repl.properties.timestamp,
                    "version" => repl.properties.version
                ],
                notes: repl.notes,
                sustains: repl.sustains,
                presses: repl.presses
            }
        }
        catch(e)
        {
            trace('failed!\n' + e.message);
        }
        #end
    }

}
