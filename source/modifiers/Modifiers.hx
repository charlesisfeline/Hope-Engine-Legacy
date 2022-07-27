package modifiers;

import Section.SwagSection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;

typedef ModifierSave = 
{
    var timeSaved:String;
    var songName:String;
    var modifierList:Map<String, Dynamic>;
    var score:Int;
    var accuracy:Float;
    var difficulty:String;
}

class Modifiers 
{
    public static var modifiers:Map<String, Dynamic> = [
        "wind_up" => 1,
        "speed" => 1,
        "p2_side" => false,
        "stairs" => false,
        "no_miss" => false,
        "perfect" => false,
        "goods_only" => false,
        "pure_perfect" => false,
        "loud_speakers" => 1,
        "fast_forward" => 1
    ];

    public static var modifierRates:Map<String, Float> = [
        "wind_up" => 0.005,
        "speed" => 0.0015,
        "p2_side" => 0,
        "stairs" => -0.03,
        "no_miss" => 0.05,
        "perfect" => 0.1,
        "goods_only" => 0.11,
        "pure_perfect" => 0.13,
        "loud_speakers" => 0.003,
        "fast_forward" => 0.005
    ];

    public static var modifierNames:Map<String, String> = [
        "wind_up" => "Wind Up",
        "speed" => "Speed",
        "p2_side" => "P2's Side",
        "stairs" => "Stairs",
        "no_miss" => "No Miss",
        "perfect" => "Perfect!",
        "goods_only" => "Goods Only",
        "pure_perfect" => "Pure Perfect!",
        "loud_speakers" => "Loud Speakers",
        "fast_forward" => "Fast Forward"
    ];

    /**
     * ONLY APPLIES TO FLOAT-VALUE MODIFIERS
     */
    public static var modifierIncrements:Map<String, Float> = [
        "wind_up" => 0.1,
        "speed" => 0.1,
        "loud_speakers" => 0.05,
        "fast_forward" => 0.1
    ];

    public static var modifierDescs:Map<String, String> = [
        "wind_up" => "\"Can you keep up?\""
                   + "\n\nThe song gradually speeds up over time. It's pitch will also go higher."
                   + "\n\nCan be twice as fast, thrice as fast, anything, really."
                   + "\n\nAdds 0.005 to the multiplier per level."
                   + "\n\n- Hit Timings will become more lenient as it goes on.",
        "speed" => "Multiplies the scroll speed. Does not alter anything song-related."
                 + "\n\nAdds 0.0015 to the multiplier per level.",
        "p2_side" => "Lets you play as the enemy instead."
                   + "\n\nDoes not add anything to the multiplier.",
        "stairs" => "Hi Mic'd Up!"
                  + "\n\nEverything becomes a staircase."
                  + "\n\nDecreases 0.03 to the multiplier. Stairs are easy.",
        "no_miss" => "You can't miss."
                   + "\n\nAdds 0.05 to the multiplier.",
        "perfect" => "You can't hit anything but a Sick!!"
                   + "\n\nAdds 0.1 to the multiplier.",
        "goods_only" => "You can't hit anything but a Good! Even hitting a Sick!! *will* kill you."
                      + "\n\nAdds 0.11 to the multiplier."
                      + "\nYou can't just delay yourself, right?",
        "pure_perfect" => "You have to do it more perfectly."
                        + "\n\nIf anything but a Sick!! (with 2 exclamation marks) appears, you're dead."
                        + "\n\nAdds 0.13 to the multiplier.",
        "loud_speakers" => "The speakers are too loud."
                        + "\nThe screen shakes when GF bops."
                        + "\n\nThat's about it really."
                        + "\n\nAlso no the sound does not get bass boosted, this is just visual impairment"
                        + "\n\n- higher value = higher intensity = more visual impairment"
                        + "\n\nAdds 0.003 to the multiplier per level.",
        "fast_forward" => "Go faster! Just go faster!"
                        + "\nThink it's like Wind Up, but with a stable speed."
                        + "\n\nAdds 0.005 to the multiplier per level."

    ];

    public static var modifierScores:Map<String, Array<ModifierSave>> = [];

    public static var modifierDefaults:Map<String, Dynamic> = [];

    public static function init():Void
    {
        modifierDefaults = modifiers.copy();
        load();
    }

    public static function stateCreation():Void
    {
        Ratings.modifier = 1;
        musicOnComplete = null;
        peakPitch = 1;

        pitchedElapsed = 0;

        if (modifiers["speed"] > 1)
            PlayState.instance.globalScrollSpeed *= modifiers["speed"];
    }

    static var stair:Int = 0;
    static var stair2:Int = 0;

    public static function preNoteMade(note:Array<Dynamic>, section:SwagSection):Array<Dynamic>
    {
        var mustPress = section.mustHitSection;
        if (note[1] > 3)
            mustPress = !section.mustHitSection;

        var s = note.copy();

        if (modifiers["stairs"])
        {
            var a = note[1] > 3 ? 4 : 0;

            if (!mustPress)
            {
                s[1] = (stair2 % 4) + a;
                stair2++;
            }
            else 
            {
                s[1] = (stair % 4) + a;
                stair++;
            }
        }

        return s;
    }

    // fired when a note has been instantiated
    public static function noteMade(note:Note)
    {
        if (modifiers["p2_side"])
            note.mustPress = !note.mustPress;
    }

    public static function staticArrowGeneration():Void
    {
        if (modifiers["p2_side"])
        {
            var oppoX = PlayState.cpuStrums.x;
            var playX = PlayState.playerStrums.x;

            PlayState.cpuStrums.x = playX;
            PlayState.playerStrums.x = oppoX;

            
            if (PlayState.instance.healthBar.fillDirection == RIGHT_TO_LEFT)
            {
                PlayState.instance.healthBar.fillDirection = LEFT_TO_RIGHT;
                PlayState.instance.healthBar.createFilledBar(PlayState.boyfriend.getColor(), PlayState.dad.getColor());
            }
            else if (PlayState.instance.healthBar.fillDirection == LEFT_TO_RIGHT)
            {
                PlayState.instance.healthBar.fillDirection = RIGHT_TO_LEFT;
                PlayState.instance.healthBar.createFilledBar(PlayState.dad.getColor(), PlayState.boyfriend.getColor());
            }
            PlayState.instance.healthBar.updateFilledBar();
            PlayState.instance.healthBar.updateBar();
        }
    }

    public static function songStarted():Void
    {
        if (musicOnComplete == null)
            musicOnComplete = FlxG.sound.music.onComplete;
    }

    // fired when a note has been hit
    public static function noteHit(note:Note)
    {

    }

    public static function beatHit(beat:Int):Void
    {
        if (modifiers["loud_speakers"] > 1)
            FlxG.cameras.shake(0.02 * modifiers["loud_speakers"], (Conductor.crochet / 1000) * 0.8);
    }

    public static function stepHit(step:Int):Void
    {

    }

    static var musicOnComplete:Void->Void;
    static var peakPitch:Float = 1;

    static var pitchedElapsed:Float = 0;

    // idk playstate update???
    public static function playStateUpdate(elapsed:Float)
    {
        if (PlayState.misses != 0 && (modifiers["perfect"] || modifiers["goods_only"] || modifiers["no_miss"] || modifiers["pure_perfect"]))
            PlayState.instance.health = 0;

        if (modifiers["perfect"] && (PlayState.goods != 0 || PlayState.bads != 0 || PlayState.shits != 0))
            PlayState.instance.health = 0;

        if (modifiers["goods_only"] && (PlayState.sicks != 0 || PlayState.bads != 0 || PlayState.shits != 0))
            PlayState.instance.health = 0;

        if (modifiers["pure_perfect"] && (PlayState.sickButNotReally != 0 || PlayState.goods != 0 || PlayState.bads != 0 || PlayState.shits != 0))
            PlayState.instance.health = 0;

        if ((modifiers["wind_up"] > 1 || modifiers["fast_forward"] > 1) && PlayState.instance.songStarted)
        {
            var songPercent = FlxG.sound.music.time / FlxG.sound.music.length;
            var vocals = PlayState.instance.vocals;
            var currentPitch = (modifiers["wind_up"] * songPercent) + (1 * (1 - songPercent));
            Ratings.modifier = currentPitch;

            if (modifiers["fast_forward"] > 1)
            {
                currentPitch = modifiers["fast_forward"];
                Ratings.modifier = 1;
            }

            FlxG.watch.addQuick("pitch" #if !cpp + " (false hope)" #end, currentPitch);

            if (currentPitch > peakPitch)
                peakPitch = currentPitch;

            if (FlxG.sound.music.time > pitchedElapsed)
                pitchedElapsed = FlxG.sound.music.time;

            #if cpp
            @:privateAccess
            {
                if (!PlayState.instance.ending)
                {
                    if (FlxG.sound.music.playing)
                        lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, currentPitch);
    
                    if (vocals.playing)
                        lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, currentPitch);

                    // when the time is done on a pitched sound, it turns time to 0
                    // onComplete does not trigger after that and will trigger after the song's unpitched time has passed
                    if (FlxG.sound.music.time < pitchedElapsed)
                    {
                        if (musicOnComplete != null)
                            musicOnComplete();
                    }
                }
            }
            #end
        }
    }

    public static function postUpdate(elapsed:Float)
    {
        if (modifiers["p2_side"])
        {
            if (PlayState.instance.healthBar.percent < 20)
                PlayState.instance.iconP2.animation.curAnim.curFrame = 1;
            else
                PlayState.instance.iconP2.animation.curAnim.curFrame = 0;
    
            if (PlayState.instance.healthBar.percent > 80)
                PlayState.instance.iconP1.animation.curAnim.curFrame = 1;
            else
                PlayState.instance.iconP1.animation.curAnim.curFrame = 0;
        }
    }

    public static function save(songName:String, difficulty:String, score:Int, accuracy:Float):Void
    {
        var list:Map<String, Dynamic> = [];
        for (key => value in Modifiers.modifiers) 
        {
            if (value != Modifiers.modifierDefaults.get(key))
                list.set(key, value);
        }

        var save:ModifierSave = {
            timeSaved: Date.now().toString(),
            difficulty: difficulty,
            score: score,
            accuracy: accuracy,
            modifierList: list,
            songName: songName
        }

        if (!modifierScores.exists(songName))
            modifierScores.set(Paths.currentMod + ":" + songName, []);

        var copy:Null<Array<ModifierSave>> = modifierScores.get(Paths.currentMod + ":" + songName).copy();
        copy.push(save);

        modifierScores.set(Paths.currentMod + ":" + songName, copy);
        FlxG.save.data.modifierScores = modifierScores;
        FlxG.save.flush();
    }

    public static function load():Void
    {
        if (FlxG.save.data.modifierScores != null)
            modifierScores = FlxG.save.data.modifierScores
        else
            FlxG.save.data.modifierScores = modifierScores;
    }
}