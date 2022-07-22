package scripts;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import sys.io.File;
import openfl.events.MouseEvent;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextFieldType;
import openfl.text.TextField;
import openfl.display.Sprite;

using StringTools;

// Completing this soon - though it's a starter
// It's just quick-access notepad at this point

class ScriptEditor extends Sprite 
{
    public var content:TextField;

    var script:String;
    var state:String;
    var path:String;

    public function new(script:String, state:String, width:Int, height:Int, path:String)
    {
        super();

        this.script = script;
        this.state = state;
        this.path = path;

        content = new TextField();
        content.width = width;
        content.height = height;
        var a = new TextFormat("VCR OSD Mono", 24, 0xffbdbdbd);
        a.align = TextFormatAlign.LEFT;
        content.defaultTextFormat = a;
        // yeah.
        // i wish there was a different way to do this without new lines fucking it up
        for (i in 0...script.split("").length)
            content.appendText(script.split("")[i]);
        content.multiline = true;
        content.type = TextFieldType.INPUT;
        content.selectable = true;
        addChild(content);

        content.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
    }

    function onKey(k:KeyboardEvent)
    {
        if (k.keyCode == Keyboard.S && k.controlKey)
            File.saveContent(Paths.state(path), content.text.toString().trim());
    }

    public function mouseUpScroll(e:MouseEvent):Void
    {
        if (e.shiftKey)
            content.scrollH--;
    }

    public function mouseDownScroll(e:MouseEvent):Void
    {
        if (e.shiftKey)
            content.scrollH++;
    }
}