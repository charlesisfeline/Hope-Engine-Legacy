import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroupIterator;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.ui.Keyboard;
#if windows
import Discord.DiscordClient;
import sys.thread.Thread;
#end


class GameplayCustomizeState extends MusicBeatState
{
    var showPosition:Bool = false;

    var indicators:FlxTypedGroup<FlxSpriteGroup>;

    var defaultAccuracyY:Float = FlxG.height - 25;
    var defaultX:Float = FlxG.width * 0.55 - 135;
    var defaultY:Float = FlxG.height / 2 - 50;
    
    var healthBarBG:FlxSprite;
    var background:FlxSprite;
    var strumLine:FlxSprite;
    var enemySide:FlxSprite;
    var bfSide:FlxSprite;
    var front:FlxSprite;
    var curt:FlxSprite;
    var sick:FlxSprite;
    
    var text:FlxText;

    var bf:Boyfriend;
    
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrums:FlxTypedGroup<FlxSprite>;
    
    var comboCount:Count;

    private var camHUD:FlxCamera;
    private var camGame:FlxCamera;
    
    public override function create() {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay", null);
		#end

        background = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        curt = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains','shared'));
        front = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));

		Conductor.changeBPM(102);
		persistentUpdate = true;

        super.create();

        camGame = new FlxCamera();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);

        FlxCamera.defaultCameras = [camGame];

        background.scrollFactor.set(0.9,0.9);
        curt.scrollFactor.set(0.9,0.9);
        front.scrollFactor.set(0.9,0.9);

        indicators = new FlxTypedGroup<FlxSpriteGroup>();

        // make the sick a tad bit more accurate
        sick = new FlxSprite().loadGraphic(Paths.image('sick','shared'));
        sick.setGraphicSize(Std.int(sick.width * 0.7));
        sick.updateHitbox();
		sick.antialiasing = true;
        sick.scrollFactor.set();

        // also the combo count :)
        comboCount = new Count(0, 0, Std.string(FlxG.random.int(0, 999, [69, 420]))); // no you can't get 69 or 420 :))

		var camFollow = new FlxObject(0, 0, 1, 1);
        bf = new Boyfriend(770, 450, 'bf');

		var camPos:FlxPoint = new FlxPoint(background.getGraphicMidpoint().x, background.getGraphicMidpoint().y);
		camFollow.setPosition(camPos.x, camPos.y);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
        strumLine.alpha = 0;

        healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar', "shared"));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

        enemySide = new FlxSprite(0, healthBarBG.y - 32).loadGraphic(Paths.image('enemy_side', 'shared'));
        enemySide.screenCenter(X);
        enemySide.scrollFactor.set();

        bfSide = new FlxSprite(0, healthBarBG.y - 32).loadGraphic(Paths.image('bf_side', 'shared'));
        bfSide.screenCenter(X);
        bfSide.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 50;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<FlxSprite>();

        add(background);
        add(front);
        add(curt);

        add(bf);

		add(camFollow);
        add(strumLine);

        for (item in [sick])
        {
            var itemIndi = new PositionIndicator(2, item);
            indicators.add(itemIndi);
            itemIndi.visible = showPosition;
        }
        
        
        if (FlxG.save.data.fancyHealthBar)
        {
            add(enemySide);
            add(bfSide);

            enemySide.antialiasing = true;
            bfSide.antialiasing = true;
        }
        
        add(healthBarBG);
        add(strumLineNotes);
        add(indicators);

        enemySide.cameras = [camHUD];
        bfSide.cameras = [camHUD];
        sick.cameras = [camHUD];
        strumLine.cameras = [camHUD];
        playerStrums.cameras = [camHUD];
        comboCount.cameras = [camHUD];
        healthBarBG.cameras = [camHUD];
        indicators.cameras = [camHUD];
        
		generateStaticArrows(0);
		generateStaticArrows(1);

        add(sick);
        add(comboCount);

        text = new FlxText(5, -40, 0, "Drag around gameplay elements, R to reset, Escape to go back. Press 5 to see position lines.", 12);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(text);

        text.cameras = [camHUD];
        strumLineNotes.cameras = [camHUD];

		FlxTween.tween(text,{y: 18},2,{ease: FlxEase.elasticInOut});

        if (!FlxG.save.data.changedHit)
        {
            FlxG.save.data.changedHitX = defaultX;
            FlxG.save.data.changedHitY = defaultY;
        }

        if (!FlxG.save.data.changedAccuracy)
            FlxG.save.data.changedAccuracyY = defaultAccuracyY;
    

        sick.x = FlxG.save.data.changedHitX;
        sick.y = FlxG.save.data.changedHitY;

        FlxG.mouse.visible = true;
    }

    override function update(elapsed:Float) 
    {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        comboCount.setPosition(sick.x, sick.y + 100);

        FlxG.camera.zoom = FlxMath.lerp(0.65, FlxG.camera.zoom, 0.95);
        camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

        // SCREEN POSITION. not world position.
        var mouseX = FlxG.mouse.getScreenPosition(camHUD).x;
        var mouseY = FlxG.mouse.getScreenPosition(camHUD).y;

        var sickOverlap:Bool = ((mouseX >= sick.x && mouseX <= sick.x + sick.width) && 
                                (mouseY >= sick.y && mouseY <= sick.y + sick.height));

        if (FlxG.keys.justPressed.FIVE)
        {
            showPosition = !showPosition;
            for (item in indicators.members)
                item.visible = showPosition;
        }

        if (FlxG.mouse.pressed)
        {
            if (sickOverlap)
            {
                sick.x = mouseX - sick.width / 2;
                sick.y = mouseY - sick.height / 2;
            }
        }

        if (!FlxG.save.data.downscroll)
        {
            for (i in playerStrums)
                i.y = strumLine.y;
            for (i in strumLineNotes)
                i.y = strumLine.y;
        }
        else
        {
            for (i in playerStrums)
                i.y = strumLine.y - i.height - 1;
            for (i in strumLineNotes)
                i.y = strumLine.y - i.height - 1;
        }
        

        if (FlxG.mouse.justReleased)
        {
            if (sickOverlap)
            {
                FlxG.save.data.changedHitX = sick.x;
                FlxG.save.data.changedHitY = sick.y;
                FlxG.save.data.changedHit = true;
            }
        }

        if (FlxG.keys.justPressed.R)
        {
            sick.x = defaultX;
            sick.y = defaultY;
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = false;
        }

        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OptionsMenu());
        }

    }

    override function beatHit() 
    {
        super.beatHit();

        bf.playAnim('idle');

        // disable camera zoom because it's disorientating as fuck
        // FlxG.camera.zoom += 0.015;
        // camHUD.zoom += 0.010;

    }

    // ripped from play state cuz im lazy
    
	private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
                babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
                babyArrow.animation.addByPrefix('green', 'arrowUP');
                babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
                babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
                babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
                babyArrow.antialiasing = true;
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                switch (Math.abs(i))
                {
                    case 0:
                        babyArrow.x += Note.swagWidth * 0;
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                        babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                    case 1:
                        babyArrow.x += Note.swagWidth * 1;
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                        babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                    case 2:
                        babyArrow.x += Note.swagWidth * 2;
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                        babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                    case 3:
                        babyArrow.x += Note.swagWidth * 3;
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                        babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
                }
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();

                if (FlxG.save.data.downscroll)
                    babyArrow.y -= babyArrow.height - 1;
    
                babyArrow.ID = i;
    
                if (player == 1)
                    playerStrums.add(babyArrow);
    
                babyArrow.animation.play('static');
                if (player == 0) {
                    babyArrow.x += 50 + FlxG.save.data.strumlineXOffset;
                } else {
                    babyArrow.x += ((FlxG.width / 2) * player + 144 - FlxG.save.data.strumlineXOffset);
                }
    
                strumLineNotes.add(babyArrow);
            }
        }
}

// this is for the lines you see when you
// activate "Position Indicator"
class PositionIndicator extends FlxSpriteGroup
{
    var objectToTrack:FlxSprite;
    var xLine:FlxSprite;
    var yLine:FlxSprite;
    var positionDisplay:FlxText;

    /**
     * Create a new Position indicator.
     * @param size How wide both lines will be.
     * @param objectToTrack Object to track every frame.
     */
    public function new(size:Int, objectToTrack:FlxSprite)
    {
        super();

        this.objectToTrack = objectToTrack;
        xLine = new FlxSprite(objectToTrack.x - size / 2, 0).makeGraphic(size, FlxG.height);
        yLine = new FlxSprite(0, objectToTrack.y - size / 2).makeGraphic(FlxG.width, size);
        positionDisplay = new FlxText(xLine.x, yLine.y, 0, "", 8);
        positionDisplay.setFormat(null, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        add(xLine);
        add(yLine);
        add(positionDisplay);
    }

    override function update(elapsed:Float)
    {
        xLine.x = objectToTrack.x - (xLine.width / 2);
        yLine.y = objectToTrack.y - (yLine.height / 2);

        positionDisplay.setPosition(xLine.x - positionDisplay.width, yLine.y - positionDisplay.height);
        positionDisplay.text = 'x: ${Std.int(objectToTrack.x)}, y: ${Std.int(objectToTrack.y)}';
    }
}