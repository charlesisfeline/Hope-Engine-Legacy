package ui;

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
	}

	override function destroy() 
	{
		texts.remove(this);
		super.destroy();
	}
}
