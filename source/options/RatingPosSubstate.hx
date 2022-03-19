package options;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

#if FILESYSTEM
import sys.io.File;
#end

class RatingPosSubstate extends MusicBeatSubstate 
{
    var bg:FlxSprite;
    var info:FlxText;
    
    var rPos:FlxText;
    var cPos:FlxText;

    var rate:FlxSprite;
    var comb:FlxSprite;

    var playStrums:FlxTypedSpriteGroup<StaticArrow>;
    var oppoStrums:FlxTypedSpriteGroup<StaticArrow>;
    
    public function new()
    {
        super();

        FlxG.mouse.visible = true;

        bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.1), Std.int(FlxG.height * 1.1), FlxColor.BLACK);
        bg.screenCenter();
        bg.alpha = 0.7;
        add(bg);

        info = new FlxText("Press and click over the items to move them.\nPress ESC to leave. Press R to reset.\n");
        info.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		info.screenCenter(X);
        info.y = FlxG.height * 0.9;
		info.borderSize = 3;
        add(info);

        cPos = new FlxText();
        cPos.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(cPos);

        rPos = new FlxText();
        rPos.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(rPos);

        createArrows();

        rate = new FlxSprite().loadGraphic(Paths.image("sick", "shared"));
        rate.setPosition(Settings.ratingPos[0], Settings.ratingPos[1]);
        rate.setGraphicSize(Std.int(rate.width * 0.7));
        rate.updateHitbox();
        rate.antialiasing = true;
        add(rate);

        comb = new Count(0, 0, FlxG.random.int(0, 999, [69, 420, 690]) + "");
        comb.setPosition(Settings.comboPos[0], Settings.comboPos[1]);
        add(comb);

        forEachOfType(FlxSprite, function(spr:FlxSprite)
        {
            var desiredAlpha = spr.alpha;
            spr.alpha = 0;
            
            FlxTween.tween(spr, {alpha: desiredAlpha}, 0.5, {ease: FlxEase.expoInOut});
        }, true);
    }

    function createArrows():Void
    {
        playStrums = new FlxTypedSpriteGroup<StaticArrow>();
        add(playStrums);

        oppoStrums = new FlxTypedSpriteGroup<StaticArrow>();
        add(oppoStrums);

        var theSex:FlxAtlasFrames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
		#if FILESYSTEM
		if (Settings.noteSkin != "default")
			theSex = FlxAtlasFrames.fromSparrow(options.NoteSkinSelection.loadedNoteSkins.get(Settings.noteSkin), File.getContent(Sys.getCwd() + "assets/skins/" + Settings.noteSkin + "/normal/NOTE_assets.xml"));
		#end

        var a = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"];
        
        for (i in 0...4)
        {
            var babyArrow:StaticArrow = new StaticArrow(0, 0);
            babyArrow.frames = theSex;
            babyArrow.x += Note.swagWidth * i;
            babyArrow.animation.addByPrefix('a', a[i]);
            babyArrow.animation.play("a");
            babyArrow.antialiasing = true;
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
            babyArrow.updateHitbox();
            playStrums.add(babyArrow);
        }

        for (i in 0...4)
        {
            var babyArrow:StaticArrow = new StaticArrow(0, 0);
            babyArrow.frames = theSex;
            babyArrow.x += Note.swagWidth * i;
            babyArrow.animation.addByPrefix('a', a[i]);
            babyArrow.animation.play("a");
            babyArrow.antialiasing = true;
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
            babyArrow.updateHitbox();
            oppoStrums.add(babyArrow);
        }

        playStrums.x = FlxG.width - playStrums.width - Settings.strumlineMargin;
        oppoStrums.x = Settings.strumlineMargin;

        playStrums.y = 50;
        if (Settings.downscroll)
            playStrums.y = FlxG.height - 50 - playStrums.height - 1;
        
        oppoStrums.y = playStrums.y;
    }

    var mousePastPos:Array<Float> = [];
    var ratePastPos:Array<Float> = [];
    var combPastPos:Array<Float> = [];

    var changingRate:Bool = false;
    var changingComb:Bool = false;

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        rPos.text = "Rating Position: " 
                  + Helper.truncateFloat(Settings.ratingPos[0], 2) + ", " 
                  + Helper.truncateFloat(Settings.ratingPos[1], 2);
                  
        cPos.text = "Combo Position: " 
                  + Helper.truncateFloat(Settings.comboPos[0], 2) + ", " 
                  + Helper.truncateFloat(Settings.comboPos[1], 2);
        
        rPos.setPosition(16, cPos.y - rPos.height - 16);
        cPos.setPosition(16, FlxG.height - cPos.height - 16);

        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            
            forEachOfType(FlxSprite, function(spr:FlxSprite)
            {
                FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.expoInOut});
            }, true);

            new FlxTimer().start(0.5, function(tmr:FlxTimer) 
            {
                close();
                OptionsState.acceptInput = true;
            });
        }

        if (FlxG.mouse.pressed)
        {
            if (FlxG.mouse.justPressed)
            {
                ratePastPos = [rate.x, rate.y];
                combPastPos = [comb.x, comb.y];
                mousePastPos = [FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y];
            }

            if ((FlxG.mouse.overlaps(rate) && !changingComb) || changingRate)
            {
                changingRate = true;

                rate.x = Math.round(ratePastPos[0] - (mousePastPos[0] - FlxG.mouse.getScreenPosition().x));
                rate.y = Math.round(ratePastPos[1] - (mousePastPos[1] - FlxG.mouse.getScreenPosition().y));
                
                Settings.ratingPos[0] = rate.x;
                Settings.ratingPos[1] = rate.y;
            }
            
            if ((FlxG.mouse.overlaps(comb) && !changingRate) || changingComb)
            {
                changingComb = true;

                comb.x = Math.round(combPastPos[0] - (mousePastPos[0] - FlxG.mouse.getScreenPosition().x));
                comb.y = Math.round(combPastPos[1] - (mousePastPos[1] - FlxG.mouse.getScreenPosition().y));
                
                Settings.comboPos[0] = comb.x;
                Settings.comboPos[1] = comb.y;
            }
        }

        if (FlxG.mouse.justReleased)
        {
            changingRate = false;
            changingComb = false;
        }

        if (FlxG.keys.justPressed.R)
        {
            Settings.ratingPos = [(FlxG.width / 3 + 5), (FlxG.height / 2 + 5)];
            Settings.comboPos = [(FlxG.width / 3 + 5), (FlxG.height / 2 + 155)];

            rate.setPosition(Settings.ratingPos[0], Settings.ratingPos[1]);
            comb.setPosition(Settings.comboPos[0], Settings.comboPos[1]);
        }
    }
}