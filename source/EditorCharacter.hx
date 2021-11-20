package;

// kiss my neck tonite at 4pm
import Character.CharacterJSON;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxAction;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.zip.Writer;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class EditorCharacter extends MusicBeatState
{
    var _file:FileReference;
	var UI_box:FlxUITabMenu;

    var characterName:FlxInputText;
    var animationName:FlxInputText;
    var prefix:FlxInputText;
    var postfix:FlxInputText;

    override function create() 
    {
        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
        
        var tabs = [
			{name: "Assets", label: 'Assets'},
            {name: "Animations", label: 'Animations'},
            {name: "Miscellaneous", label: 'Miscellaneous'}
		];
        
        UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.scrollFactor.set();
		UI_box.resize(480, 400);
		UI_box.x = FlxG.width - UI_box.width - 20;
		UI_box.y = 20;
		add(UI_box);
    }

    function addAssetStuff():Void
    {
        
    }
}