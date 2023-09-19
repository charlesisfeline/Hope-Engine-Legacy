package ui;

import flixel.input.keyboard.FlxKey;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.util.FlxColor;

using StringTools;

class InputTextFix extends FlxUIInputText
{	
	public static var isTyping:Bool = false;
	public static var texts:Array<InputTextFix> = [];
	
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 150, ?Text:String, size:Int = 8, TextColor:Int = FlxColor.BLACK,
		BackgroundColor:Int = FlxColor.WHITE, EmbeddedFont:Bool = true)
	{
		super(X, Y, Width, Text, size, EmbeddedFont);

		texts.push(this);
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		var m = FlxG.mouse.getScreenPosition(camera);
		var s = getScreenPosition(camera);

		#if FLX_MOUSE
		if (FlxG.mouse.justPressed)
		{
			var hadFocus:Bool = hasFocus;
			
			if ((m.x >= x && m.x <= s.x + width) && (m.y >= s.y && m.y <= s.y + height))
			{
				caretIndex = getCharIndexAtPoint(m.x - s.x, m.y - s.x);
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

		// CTRL+SHIFT+B changes the text to crochet value in MILLIseconds
		// CTRL+SHIFT+S changes the text to step crochet value in MILLIseconds
		
		// CTRL+SHIFT+ALT+B changes the text to crochet value in seconds
		// CTRL+SHIFT+ALT+S changes the text to step crochet value in seconds
		
		if (FlxG.keys.pressed.CONTROL && hasFocus)
		{
			// paste
			if (FlxG.keys.justPressed.V)
			{
				var clip = openfl.desktop.Clipboard.generalClipboard.getData(TEXT_FORMAT);
				var spl = text.split("");

				trace(clip.toString());

				spl.insert(caretIndex, clip.toString());

				text = spl.join("");
				caretIndex += clip.toString().length;
				onChange(FlxInputText.INPUT_ACTION);
			}

			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.ALT)
				{
					if (FlxG.keys.justPressed.B)
					{
						text = (Conductor.crochet) + "";
						caretIndex = text.length;
						onChange(FlxInputText.INPUT_ACTION);
					}

					if (FlxG.keys.justPressed.S)
					{
						text = (Conductor.stepCrochet) + "";
						caretIndex = text.length;
						onChange(FlxInputText.INPUT_ACTION);
					}
				}
				else
				{
					if (FlxG.keys.justPressed.B)
					{
						text = (Conductor.crochet / 1000) + "";
						caretIndex = text.length;
						onChange(FlxInputText.INPUT_ACTION);
					}
	
					if (FlxG.keys.justPressed.S)
					{
						text = (Conductor.stepCrochet / 1000) + "";
						caretIndex = text.length;
						onChange(FlxInputText.INPUT_ACTION);
					}
				}
			}
		}

		var a:Array<Bool> = [];

		for (fix in texts)
			a.push(fix.hasFocus);

		isTyping = a.contains(true);
		
		if (a.contains(true))
		{
			FlxG.sound.volumeDownKeys = null;
			FlxG.sound.volumeUpKeys = null;
			FlxG.sound.muteKeys = null;
		}
		else
		{
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		}

		FlxG.stage.window.onTextInput.add(onTextInput);
	}

	// onTextInput triggers A LOT for some reason
	var canType:Bool = false;

	// supports SHIFT and CAPSLOCK stuff
	function onTextInput(s:String):Void
	{
		if (hasFocus && canType)
		{
			var toFilter = s;

			var newText:String = filter(toFilter);

			if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength))
			{
				text = insertSubstring(text, newText, caretIndex);
				caretIndex++;
				onChange(FlxInputText.INPUT_ACTION);

				canType = false;
			}
		}
	}

	override function onKeyDown(e:KeyboardEvent):Void
	{
		var key:Int = e.keyCode;

		if (hasFocus)
		{
			// Do nothing for Shift, Ctrl, Esc, and flixel console hotkey
			if (key == 16 || key == 17 || key == 220 || key == 27 || key == 20)
			{
				return;
			}
			// do nothing for copy and paste keybinds
			else if (FlxG.keys.pressed.CONTROL)
			{
				if (key == 67 || key == 86)
					return;
			}
			// Left arrow
			else if (key == 37)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text; // forces scroll update
				}
			}
			// Right arrow
			else if (key == 39)
			{
				if (caretIndex < text.length)
				{
					caretIndex++;
					text = text; // forces scroll update
				}
			}
			// End key
			else if (key == 35)
			{
				caretIndex = text.length;
				text = text; // forces scroll update
			}
			// Home key
			else if (key == 36)
			{
				caretIndex = 0;
				text = text;
			}
			// Backspace
			else if (key == 8)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(FlxInputText.BACKSPACE_ACTION);
				}
			}
			// Delete
			else if (key == 46)
			{
				if (text.length > 0 && caretIndex < text.length)
				{
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(FlxInputText.DELETE_ACTION);
				}
			}
			// Enter
			else if (key == 13)
			{
				onChange(FlxInputText.ENTER_ACTION);
			}
			else
				canType = true;
		}
	}

	override function set_text(Text:String):String 
	{
		Text = Text.replace("\r", "");
		return super.set_text(Text);
	}

	override function destroy() 
	{
		texts.remove(this);
		FlxG.stage.window.onTextInput.remove(onTextInput);
		super.destroy();
	}
}
