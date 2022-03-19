package editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

#if desktop
import Discord.DiscordClient;
#end

typedef Week = {
    var weekName:String;
    var characters:Array<String>;
    var tracks:Array<String>;
    var difficultyLock:Null<String>;
}

class WeekEditor extends MusicBeatState 
{
    var yellowBG:FlxSprite;
    var txtWeekTitle:FlxText;
    var txtTracklist:FlxText;
    
    var UI_box:FlxUITabMenu;

    var _week:Week = {
        weekName: 'Tutorial',
        characters: ['', 'gf', 'bf'],
        tracks: ['Tutorial'],
        difficultyLock: null
    }

    override function create()
    {
        #if desktop
		DiscordClient.changePresence("Week Editor");
		#end

        FlxG.mouse.visible = true;

        var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

        yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
        add(yellowBG);

        txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = "VCR OSD Mono";
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);

        txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, _week.weekName.toUpperCase(), 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
        add(txtWeekTitle);

        // hi psych engine
		var tracksText:Alphabet = new Alphabet(0, 0, "TRACKS", false);
		tracksText.color = 0xFFe55777;
		tracksText.x = FlxG.width * 0.055;
		tracksText.y = txtTracklist.y;
		add(tracksText);

        var tabs = [
            {name: "1", label: 'Week Data'},
            {name: "2", label: 'Songs'},
            {name: "3", label: 'Characters'}
		];
        
        UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(350, 200);
		UI_box.x = 16;
		UI_box.y = 16;
        add(UI_box);

        var saveButton:FlxButton = new FlxButton(0, 0, "SAVE FILE", saveJSON);
        saveButton.x = UI_box.x + UI_box.width + 16;
        saveButton.y = UI_box.y;
        add(saveButton);

        var loadButton:FlxButton = new FlxButton(0, 0, "LOAD FILE", loadJSON);
        loadButton.x = UI_box.x + UI_box.width + 16;
        loadButton.y = saveButton.y + saveButton.height + 16;
        add(loadButton);

        createWeekDataUI();
        
        super.create();
    }

    var weekNameInput:FlxInputText;

    function createWeekDataUI():Void 
    {
        var weekNameTitle:FlxText = new FlxText(10, 10, "Week Name (at the top right)");

        weekNameInput = new FlxInputText(10, weekNameTitle.y + weekNameTitle.height, 330, _week.weekName);
        weekNameInput.callback = function(s:String, y:String) {
            _week.weekName = weekNameInput.text;
            txtWeekTitle.text = _week.weekName.toUpperCase();
            txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
        }
        weekNameInput.callback("", "");
        
        var tab = new FlxUI(null, UI_box);
        tab.name = "1";
        tab.add(weekNameTitle);
        tab.add(weekNameInput);
        UI_box.addGroup(tab);
    }

    function createSongsUI():Void
    {
        
    }

    function updateVisuals():Void
    {
        
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (controls.BACK && !FlxG.keys.justPressed.BACKSPACE)
			FlxG.switchState(new MainMenuState());

        if (FlxG.keys.pressed.CONTROL)
        {
            if (FlxG.keys.justPressed.S)
                saveJSON();
            else if (FlxG.keys.justPressed.E)
                loadJSON();
        }
    }

    var _file:FileReference;

    private function loadJSON()
    {
        var imageFilter:FileFilter = new FileFilter('JSON', 'json');
        
        _file = new FileReference();
        _file.addEventListener(Event.SELECT, onLoadComplete);
        _file.addEventListener(Event.CANCEL, onLoadCancel);
        _file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file.browse([imageFilter]);
    }

    var path:String = null;
    
    function onLoadComplete(_)
    {
        _file.removeEventListener(Event.SELECT, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        
        #if sys
		@:privateAccess
		{
            if (_file.__path != null) 
                path = _file.__path;
        }

        _week = cast Json.parse(File.getContent(path).trim());
        _file = null;

        trace(_week);
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end

        weekNameInput.text = _week.weekName;
        weekNameInput.callback("", "");
        path = null;
    }

    function onLoadCancel(_):Void
    {
        _file.removeEventListener(Event.SELECT, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file = null;
    }

    function onLoadError(_):Void
    {
        _file.removeEventListener(Event.SELECT, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file = null;
    }

    private function saveJSON()
    {
        var data:String = Json.stringify(_week, null, "\t");

        if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data.trim(), "week.json");
        }
    }

    function onSaveComplete(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    function onSaveCancel(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    function onSaveError(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }
}