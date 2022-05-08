package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;
import flixel.util.FlxColor;

/**
 * @author Lars Doucet
 */
class InputTextFix extends FlxInputText implements IResizable implements IFlxUIWidget implements IHasParams
{
	static var texts:Array<InputTextFix> = [];
	public var name:String;

	public var broadcastToFlxUI:Bool = true;

	public static inline var CHANGE_EVENT:String = "change_input_text"; // change in any way
	public static inline var ENTER_EVENT:String = "enter_input_text"; // hit enter in this text field
	public static inline var DELETE_EVENT:String = "delete_input_text"; // delete text in this text field
	public static inline var INPUT_EVENT:String = "input_input_text"; // input text in this text field

	var usedCamera:FlxCamera = FlxG.camera;

	public function new(X:Float = 0, Y:Float = 0, Width:Int = 150, ?Text:String, size:Int = 8, TextColor:Int = FlxColor.BLACK,
			BackgroundColor:Int = FlxColor.WHITE, EmbeddedFont:Bool = true, ?camera:FlxCamera)
	{
		super(X, Y, Width, Text, size, EmbeddedFont);

		if (camera != null)
			this.usedCamera = camera;

		texts.push(this);
	}

	public function resize(w:Float, h:Float):Void
	{
		width = w;
		height = h;
		calcFrame();
	}

	private override function onChange(action:String):Void
	{
		super.onChange(action);
		if (broadcastToFlxUI)
		{
			switch (action)
			{
				case FlxInputText.ENTER_ACTION: // press enter
					FlxUI.event(ENTER_EVENT, this, text, params);
				case FlxInputText.DELETE_ACTION, FlxInputText.BACKSPACE_ACTION: // deleted some text
					FlxUI.event(DELETE_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
				case FlxInputText.INPUT_ACTION: // text was input
					FlxUI.event(INPUT_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
			}
		}
	}

	override function destroy() 
	{
		texts.remove(this);
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var a:Array<Bool> = [];

        for (text in texts)
            a.push(text.hasFocus);

        if (a.contains(true))
        {
			FlxG.sound.muteKeys = null;
			FlxG.sound.volumeDownKeys = null;
			FlxG.sound.volumeUpKeys = null;
        }
        else
        {
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
        }

		#if FLX_MOUSE
		if (FlxG.mouse.justPressed)
		{
			var hadFocus:Bool = hasFocus;
			if (FlxG.mouse.getScreenPosition(usedCamera).x >= x
				&& FlxG.mouse.getScreenPosition(usedCamera).x <= x + width
				&& FlxG.mouse.getScreenPosition(usedCamera).y >= y
				&& FlxG.mouse.getScreenPosition(usedCamera).y <= y + height)
			{
				caretIndex = getCaretIndex();
				hasFocus = true;
				if (!hadFocus && focusGained != null)
					focusGained();
			}
			else
			{
				hasFocus = false;
				if (hadFocus && focusLost != null)
					focusLost();
			}
		}
		#end
	}
}
