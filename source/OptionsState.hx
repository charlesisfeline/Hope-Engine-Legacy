package;

import Checkbox.CheckBox;
import OptionTypes;
import Shaders.CRTCurve;
import Shaders.ChromaticAberration;
import Shaders.Grain;
import Shaders.Mosaic;
import Shaders.Scanline;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import openfl.Lib;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ShaderFilter;

using StringTools;
#if windows
import Discord.DiscordClient;
#end

class OptionsState extends MusicBeatState
{
    public static var acceptInput:Bool = true;
    var displayOptions:FlxTypedGroup<Option>;
    var displayCategories:FlxTypedGroup<OptionCategory>;
    var curSelected:Int = 0;
    var inCat:Bool = false;
    var highlightedAlphabet:Alphabet;
    var descText:FlxText;
    var descBG:FlxSprite;

    var categories:Array<OptionCategory> = [
        new OptionCategory("Preferences", [
            new OptionSubCategoryTitle("Gameplay"),
            new PressOption("Keybinds", "Change how YOU play.", function() {
                FlxG.state.openSubState(new KeybindSubstate());
                acceptInput = false;
            }),
            new ToggleOption("Downscroll", "Change the scroll direction from up to down (and vice versa)", "downscroll"),
            new ToggleOption("Ghost Tapping", "If activated, pressing while there's no notes to hit won't give you a miss penalty.", "ghost"),
            new ToggleOption("Middlescroll", "Put the notes in the middle.", "middleScroll"),
            new ValueOptionFloat("Lane Underlay", "Change the opacity of the lane underlay.\n(0 = invisible, 100 = visible)", "pfBGTransparency", 0, 100, 0.1, 100, null, 0, "%", 2),
            new ValueOptionFloat("Offset", "Feeling delayed/early? Change the notes offset here!", "offset", Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 0.1, 100, null, 0, "ms", 1),
            new ValueOptionInt("Safe Frames", "Change how the game judges your timing.\n(Lower hit frames = Tighter ratings)", "frames", 0, 20, 1, function () {
                Conductor.safeFrames = FlxG.save.data.frames;
                Conductor.recalculateTimings();
            }, 10),
            #if FILESYSTEM
            new ValueOptionInt("FPS Cap", "The maximum FPS the game can have", "fpsCap", Application.current.window.displayMode.refreshRate, 290, 1, 10, function () { (cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap); }, 60, " FPS"),
            #end
            new ValueOptionFloat("Scroll Speed", "Change your scroll speed.\n(1 = chart-dependent)", "scrollSpeed", 1, Math.POSITIVE_INFINITY, 0.1, 10, null, 1, "", 2),
            new SelectionOption("Accuracy Mode", "Change how accuracy is calculated.\n(Accurate = Simple, Complex = Milisecond Based)", "accuracyMod", ["Accurate", "Complex"]),
            new ToggleOption("Reset Button", "If activated, pressing R while in a song will cause a game over.", "resetButton"),

            new OptionSubCategoryTitle("Appearance"),
            #if FILESYSTEM
            new PressOption("Note Skins", "Change how your notes look.", function() {
                FlxG.state.openSubState(new NoteSkinSelection());
                acceptInput = false;
            }),
            #end
            new ValueOptionInt("Strumline Margin", "Change how far the strumline (the 4 grey notes) are from the edges of the screen.", "strumlineMargin", Std.int(Math.NEGATIVE_INFINITY), Std.int(Math.POSITIVE_INFINITY), 1, 10, null, 100),
            new ToggleOption("Note Splashes", "Toggle the splashes that show up when you hit a \"Sick!!\"", "noteSplashes"),
            new ToggleOption("Extensive Score Display", "Should the score text under the health bar have more info than just Score and Accuracy?", "accuracyDisplay"),
            new ToggleOption("Show NPS", "Shows your current Notes Per Second.\n(\"Extensive\" info text is needed for this!)", "npsDisplay"),
            new ToggleOption("Rating Colors", "Toggle rating colors\n(e.g. Good is colored green)", "ratingColor"),
            new ToggleOption("Fancy Health Bar", "Get the health bar a bit of glow up", "fancyHealthBar"),
            new ToggleOption("Health Bar Colors", "Colors the health bar to fit the character's theme.\nLike boyfriend's bar side (right) will be cyan.", "healthBarColors"),
            new ToggleOption("Hide Health Icons", "Hide the icons on the health bar.", "hideHealthIcons"),
            new ToggleOption("Song Position Bar", "Show the Song's position bar, where you can see the time left and the song's name.", "songPosition")
        ]),

        new StateCategory("Replays", new LoadReplayState()),
        #if FILESYSTEM
        new StateCategory("Mods Menu", new ModLoadingState()),
        #end

        new OptionCategory("Other", [
            new OptionSubCategoryTitle("Accessibility"),
            new ToggleOption("Flashing Lights", "If activated, flashing lights will appear.", "flashing"),
            new ToggleOption("Distractions", "Toggle stage distractions that can hinder your gameplay.\n(Train passing by, fast cars passing by, etc.)", "distractions"),
            
            new OptionSubCategoryTitle("Miscellaneous"),
            new ToggleOption("Show FPS", "Display an FPS counter at the top-left of the screen", "fps", function() {(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);}),
            new ToggleOption("Watermarks", "Show the watermark seen at the Main Menu", "watermarks"),
            #if FILESYSTEM
            new ToggleOption("Preload Songs", "Preloads the songs for no stutter after countdown, and freeplay song playing. (HIGH MEMORY)", "cacheMusic"),
            new ToggleOption("Preload Characters", "Preloads the character images for smoother character switching. (HIGH MEMORY)", "cacheImages"),
            #end
            new ToggleOption("Skip Results Screen", "Should the result screen not show up after the song?", "skipResultsScreen"),
            new ToggleOption("Botplay", "Make a bot play for you. Will disallow input.\n(Useful for showcasing charts, and looking at em)", "botplay"),

            new OptionSubCategoryTitle("Dangerous Stuff"),
            new PressOption("Erase Scores", "Remove SONG data.\n(Prompted, be careful!)", function() {
                ConfirmationPrompt.confirmThing = function():Void {
                    FlxG.save.data.songScores = null;
                    FlxG.save.data.songRanks = null;
                    for (key in Highscore.songScores.keys())
                    {
                        Highscore.songScores[key] = 0;
                    }
                    for (key in Highscore.songRanks.keys())
                    {
                        Highscore.songRanks[key] = 17;
                    }
                };
                ConfirmationPrompt.confirmDisplay = 'Yeah!';
                ConfirmationPrompt.denyDisplay = 'Nah.';
        
                ConfirmationPrompt.titleText = 'HALT!';
                ConfirmationPrompt.descText = 'Are you sure you want to delete ALL SCORES?'
                                            + '\nThis will reset SCORES and RANKS, you get to keep your settings.'
                                            + '\nThis is IRREVERSIBLE!';
                                            
                FlxG.state.openSubState(new ConfirmationPrompt());
            }),
            new PressOption("Erase Data", "Remove ALL data.\n(Prompted, be careful!)", function() {
                ConfirmationPrompt.confirmThing = function():Void {
                    FlxG.save.erase();
                    throw 'Erased data. Relaunch needed.';
                };
                ConfirmationPrompt.confirmDisplay = 'Yeah!';
                ConfirmationPrompt.denyDisplay = 'Nah.';
        
                ConfirmationPrompt.titleText = 'AYO!';
                ConfirmationPrompt.descText = 'Are you sure you want to delete ALL DATA?'
                                            + '\nThis will reset everything, from options to scores.'
                                            + '\nThis is IRREVERSIBLE!';
                                            
                FlxG.state.openSubState(new ConfirmationPrompt());
            }),
        ])

        #if debug
        ,new OptionCategory("Debug", [
            new OptionSubCategoryTitle("Colorblindness stuff"),
            new PressOption("Deuteranopia", "simulate Deuteranopia lmao", function() {
                var filters = FlxG.game.filters;
                var matrix:Array<Float> = [
					0.43, 0.72, -.15, 0, 0,
					0.34, 0.57, 0.09, 0, 0,
					-.02, 0.03,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

                filters.push(new ColorMatrixFilter(matrix));
                FlxG.game.setFilters(filters);
            }),
            new PressOption("Protanopia", "simulate Protanopia lmao", function() {
                var filters = FlxG.game.filters;
                var matrix:Array<Float> = [
					0.20, 0.99, -.19, 0, 0,
					0.16, 0.79, 0.04, 0, 0,
					0.01, -.01,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

                filters.push(new ColorMatrixFilter(matrix));
                FlxG.game.setFilters(filters);
            }),
            new PressOption("Tritanopia", "simulate Tritanopia lmao", function() {
                var filters = FlxG.game.filters;
                var matrix:Array<Float> = [
					0.97, 0.11, -.08, 0, 0,
					0.02, 0.82, 0.16, 0, 0,
					0.06, 0.88, 0.18, 0, 0,
					   0,    0,    0, 1, 0,
				];

                filters.push(new ColorMatrixFilter(matrix));
                FlxG.game.setFilters(filters);
            }),

            new OptionSubCategoryTitle("eh"),
            new PressOption("inveryt", "CHANGE COLOURS TO NEGATIVE OF IT (REAL)", function() {
                var filters = FlxG.game.filters;
                var matrix:Array<Float> = [
					-1,  0,  0, 0, 255,
					 0, -1,  0, 0, 255,
					 0,  0, -1, 0, 255,
					 0,  0,  0, 1,   0,
				];

                filters.push(new ColorMatrixFilter(matrix));
                FlxG.game.setFilters(filters);
            }),
            new PressOption("grayscale", "some 1980 type shit fr", function() {
                var filters = FlxG.game.filters;
                var matrix:Array<Float> = [
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					  0,   0,   0, 1, 0,
				];

                filters.push(new ColorMatrixFilter(matrix));
                FlxG.game.setFilters(filters);
            }),

            new OptionSubCategoryTitle("custom shaders"),
            new PressOption("chromatic aberraiton", "genocide (slow + reverb)", function() {
                var filters = FlxG.game.filters;
                filters.push(new ShaderFilter(new ChromaticAberration()));
                FlxG.game.setFilters(filters);
            }),
            new PressOption("ccurve", "lens distrocirtion moment\n(broken :((((()", function() {
                var filters = FlxG.game.filters;
                filters.push(new ShaderFilter(new CRTCurve()));
                FlxG.game.setFilters(filters);
            }),
            new PressOption("scanlines", "llines", function() {
                var filters = FlxG.game.filters;
                filters.push(new ShaderFilter(new Scanline(5.0)));
                FlxG.game.setFilters(filters);
            }),
            new PressOption("mosaic", "terraria", function() {
                var filters = FlxG.game.filters;
                filters.push(new ShaderFilter(new Mosaic(10, 10)));
                FlxG.game.setFilters(filters);
            }),
            new PressOption("grain", "grainy", function() {
                var filters = FlxG.game.filters;
                filters.push(new ShaderFilter(new Grain(1.5)));
                FlxG.game.setFilters(filters);
            }),

            new OptionSubCategoryTitle(""),
            new PressOption("remove all", "es", function() {
                FlxG.camera.fade(0xff000000, 0.3, false, function() {
                    FlxG.game.setFilters([]);
                    FlxG.camera.fade(0xff000000, 0.3, true);
                });
            }),
        ])
        #end
    ];

    override function create()
    {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Options Menu", null);
		#end
        
        var menuBG = new FlxSprite().loadGraphic(Paths.image("menuBGBlue"));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);
        
        
        displayOptions = new FlxTypedGroup<Option>();
        displayCategories = new FlxTypedGroup<OptionCategory>();

        for (cat in categories)
            displayCategories.add(cat);
        
        add(displayOptions);
        add(displayCategories);

        descBG = new FlxSprite().makeGraphic(Std.int((FlxG.width * 0.85) + 8), 72, 0xFF000000);
		descBG.alpha = 0.6;
		descBG.screenCenter(X);
		descBG.visible = false;
		add(descBG);

        descText = new FlxText(0, FlxG.height - 80, FlxG.width * 0.85, "");
		descText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.screenCenter(X);
		descText.borderSize = 3;
		add(descText);

        descBG.setPosition(descText.x - 4, descText.y - 4);

        changeSelection();

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!inCat)
        {
            for (option in displayCategories.members)
            {
                var i = displayCategories.members.indexOf(option);
                
                option.alphaDisplay.screenCenter(X);
    
                if (i == 0)
                    displayCategories.members[i].alphaDisplay.y = 175;
                else
                    displayCategories.members[i].alphaDisplay.y = displayCategories.members[i - 1].alphaDisplay.y + displayCategories.members[i - 1].alphaDisplay.height + 10;
            }
        }
        else
        {
            for (option in displayOptions.members)
            {
                var i = displayOptions.members.indexOf(option);

                displayOptions.members[i].x = 125;

                if (option is OptionSubCategoryTitle)
                {
                    option.screenCenter(X);
                }
            }
        }

        if (descText.text.trim() == '')
        {
            descBG.visible = false;
            descText.visible = false;
        }
        else
        {
            descBG.visible = true;
            descText.visible = true;
        }

        if (acceptInput)
        {
            if (controls.UP_P)
            {
                changeSelection(-1);
                if (highlightedAlphabet.isBold && inCat)
                    changeSelection(-1);
            }
    
            if (controls.DOWN_P)
            {
                changeSelection(1);
                if (highlightedAlphabet.isBold && inCat)
                    changeSelection(1);
            }  
    
            if (controls.BACK)
            {
                if (!inCat)
                {
                    FlxG.save.flush();
                    FlxG.switchState(new MainMenuState());
                }
                else
                {
                    inCat = false;
                    curSelected = 0;
                    remove(displayOptions);
                    add(displayCategories);

                    changeSelection();
                }
            }
    
            if (inCat)
            {
                if (displayOptions.members[curSelected] is ToggleOption ||
                    displayOptions.members[curSelected] is StateOption ||
                    displayOptions.members[curSelected] is PressOption)
                {
                    if (controls.ACCEPT)
                        displayOptions.members[curSelected].press();
                }
                else if (displayOptions.members[curSelected] is ValueOptionFloat ||
                            displayOptions.members[curSelected] is ValueOptionInt)
                {
                    if (controls.LEFT)
                        displayOptions.members[curSelected].left_H();
                    if (controls.RIGHT)
                        displayOptions.members[curSelected].right_H();
                }
                else if (displayOptions.members[curSelected] is SelectionOption)
                {
                    if (controls.LEFT_P)
                        displayOptions.members[curSelected].left();
                    if (controls.RIGHT_P)
                        displayOptions.members[curSelected].right();
                }

                // changeSelection();
                if (highlightedAlphabet.isBold && inCat)
                    changeSelection(1);
            }
            else
            {
                if (controls.ACCEPT)
                {
                    var thing = displayCategories.members[curSelected];
                    
                    if (thing is StateCategory)
                        thing.press();
                    else if (thing is OptionCategory)
                    {
                        curSelected = 0;
                        inCat = true;
                        
                        displayOptions.clear();
    
                        for (option in thing.options)
                            displayOptions.add(option);
    
                        remove(displayCategories);
                        add(displayOptions);
                    }

                    changeSelection();
                }
            }
        }
    }

    function changeSelection(huh:Int = 0)
    {
        curSelected += huh;

        if (huh != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));

        var bullShit:Int = 0;

        if (inCat)
        {
            if (curSelected < 0)
                curSelected = displayOptions.length - 1;
            if (curSelected > displayOptions.length - 1)
                curSelected = 0;

            for (item in displayOptions.members)
            {
                item.targetY = bullShit - curSelected;
                bullShit++;
    
                item.alpha = 0.6;
    
                if (item.targetY == 0 || item.alphaDisplay.isBold)
                {
                    item.alpha = 1;

                    if (!item.alphaDisplay.isBold)
                        descText.text = item.desc;
                }
            }

            if (displayOptions.members.length > 0)
                highlightedAlphabet = displayOptions.members[curSelected].alphaDisplay;
        }
        else
        {
            if (curSelected < 0)
                curSelected = displayCategories.length - 1;
            if (curSelected > displayCategories.length - 1)
                curSelected = 0;

            for (item in displayCategories.members)
            {
                item.alpha = 0.6;
    
                if (item == displayCategories.members[curSelected])
                {
                    item.alpha = 1;

                    descText.text = '';
                }
            }

            if (displayCategories.members.length > 0)
                highlightedAlphabet = displayCategories.members[curSelected].alphaDisplay;
        }
    }
}