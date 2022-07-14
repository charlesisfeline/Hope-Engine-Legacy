package options;

import Checkbox.CheckBox;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class Option extends FlxSpriteGroup
{
	public var alphaDisplay:Alphabet;
	public var display:String = '';
	public var desc:String = '';
	public var targetY:Float = 0.0;
	public var additive:Float = FlxG.height * 0.48;

	public function new(display:String, desc:String)
	{
		super();

		this.display = display;
		this.desc = desc;

		alphaDisplay = new Alphabet(0, 0, display, false);
		this.add(alphaDisplay);
	}

	override function update(elapsed:Float)
	{
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		y = FlxMath.lerp(y, (scaledY * 120) + additive, Helper.boundTo(elapsed * 9.6, 0, 1));

		super.update(elapsed);
	}

	public function getTargetY():Float
	{
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		return (scaledY * 120) + additive;
	}

	public function press() {}

	public function left() {}

	public function right() {}

	public function left_H() {}

	public function right_H() {}
}

class OptionCategory extends FlxSpriteGroup
{
	public var name:String;
	public var options:Array<Option>;
	public var alphaDisplay:Alphabet;

	public function new(name:String, options:Array<Option>)
	{
		super();

		this.alphaDisplay = new Alphabet(0, 0, name, true);
		this.name = name;
		this.options = options;

		add(alphaDisplay);
	}

	public function press() {}
}

class StateCategory extends OptionCategory
{
	public var state:FlxState;

	public function new(name:String, state:FlxState)
	{
		super(name, []);
		this.state = state;
	}

	override function press()
	{
		CustomTransition.switchTo(Type.createInstance(Type.getClass(state), []));
	}
}

class StateOption extends Option
{
	public var state:FlxState;

	public function new(display:String, desc:String, state:FlxState)
	{
		super(display, desc);
		this.state = state;
	}

	override function press()
	{
		CustomTransition.switchTo(state);
	}
}

class OptionSubCategoryTitle extends Option
{
	public function new(name:String, ?color:FlxColor = FlxColor.WHITE)
	{
		super(name, '');

		remove(alphaDisplay, true);
		alphaDisplay.kill();
		alphaDisplay.destroy();

		alphaDisplay = new Alphabet(0, 0, name, true);
		add(alphaDisplay);

		alphaDisplay.color = color;
	}
}

class ToggleOption extends Option
{
	var theBool:String;
	var checkbox:CheckBox;
	var onChange:Void->Void;

	public function new(display:String, desc:String, boolValueToChange:String, ?onChange:Void->Void)
	{
		super(display, desc);

		this.onChange = onChange;

		theBool = boolValueToChange;
		alphaDisplay.x += 200;

		checkbox = new CheckBox(0, 0, Reflect.field(Settings, theBool));
		checkbox.setGraphicSize(150);
		checkbox.y = alphaDisplay.y + (alphaDisplay.height / 2) - (checkbox.height / 2);
		this.add(checkbox);
	}

	override function press()
	{
		Reflect.setField(Settings, theBool, !Reflect.field(Settings, theBool));
		checkbox.change(Reflect.field(Settings, theBool));

		if (onChange != null)
			onChange();
	}
}

class ValueOptionFloat extends Option
{
	var theNumber:String;
	var min:Float;
	var max:Float;
	var increment:Float;
	var shiftMultiplier:Float;
	var funneMultiplier:Float = 1;
	var onChange:Void->Void;
	var resetValue:Null<Float>;
	var unit:String;
	var precision:Int = 0;

	public function new(display:String, desc:String, numberValueToChange:String, min:Float, max:Float, ?increment:Float = 1.0, ?shiftMultiplier:Float = 1.0,
			?onChange:Void->Void, ?resetValue:Null<Float> = null, ?unit:String = '', ?precision:Int = 0)
	{
		super(display, desc);

		theNumber = numberValueToChange;
		this.min = min;
		this.max = max;
		this.increment = increment;
		this.shiftMultiplier = shiftMultiplier;
		this.onChange = onChange;
		this.resetValue = resetValue;
		this.unit = unit;
		this.precision = precision;

		updateDisplay();
	}

	override function left_H()
	{
		if (Reflect.field(Settings, theNumber) <= min)
			Reflect.setField(Settings, theNumber, min);
		else
			Reflect.setField(Settings, theNumber, Helper.truncateFloat(Reflect.field(Settings, theNumber) - (increment * funneMultiplier), precision));

		if (onChange != null)
			onChange();

		updateDisplay();
	}

	override function right_H()
	{
		if (Reflect.field(Settings, theNumber) >= max)
			Reflect.setField(Settings, theNumber, max);
		else
			Reflect.setField(Settings, theNumber, Helper.truncateFloat(Reflect.field(Settings, theNumber) + (increment * funneMultiplier), precision));

		if (onChange != null)
			onChange();

		updateDisplay();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.SHIFT)
			funneMultiplier = shiftMultiplier;
		else
			funneMultiplier = 1.0;

		if (FlxG.keys.justPressed.R && resetValue != null && targetY == 0)
		{
			Reflect.setField(Settings, theNumber, resetValue);

			if (onChange != null)
				onChange();
			
			updateDisplay();
		}

		super.update(elapsed);
	}

	function updateDisplay()
	{
		remove(alphaDisplay, true);
		alphaDisplay.kill();
		alphaDisplay.destroy();

		alphaDisplay = new Alphabet(0, 0, display + ' < ' + Reflect.field(Settings, theNumber) + unit + ' >', false);
		add(alphaDisplay);
	}
}

class ValueOptionInt extends Option
{
	var theNumber:String;
	var min:Int;
	var max:Int;
	var increment:Int;
	var shiftMultiplier:Int;
	var funneMultiplier:Int = 1;
	var onChange:Void->Void;
	var resetValue:Null<Int>;
	var unit:String;

	public function new(display:String, desc:String, numberValueToChange:String, min:Int, max:Int, ?increment:Int = 1, ?shiftMultiplier:Int = 1,
			?onChange:Void->Void, ?resetValue:Null<Int> = null, ?unit:String = '')
	{
		super(display, desc);

		theNumber = numberValueToChange;
		this.min = min;
		this.max = max;
		this.increment = increment;
		this.shiftMultiplier = shiftMultiplier;
		this.onChange = onChange;
		this.resetValue = resetValue;
		this.unit = unit;

		updateDisplay();
	}

	override function left_H()
	{
		if (Reflect.field(Settings, theNumber) <= min)
			Reflect.setField(Settings, theNumber, min);
		else
			Reflect.setField(Settings, theNumber, Reflect.field(Settings, theNumber) - (increment * funneMultiplier));

		if (onChange != null)
			onChange();

		updateDisplay();
	}

	override function right_H()
	{
		if (Reflect.field(Settings, theNumber) >= max)
			Reflect.setField(Settings, theNumber, max);
		else
			Reflect.setField(Settings, theNumber, Reflect.field(Settings, theNumber) + (increment * funneMultiplier));

		if (onChange != null)
			onChange();

		updateDisplay();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.SHIFT)
			funneMultiplier = shiftMultiplier;
		else
			funneMultiplier = 1;

		if (FlxG.keys.justPressed.R && resetValue != null && targetY == 0)
		{
			Reflect.setField(Settings, theNumber, resetValue);

			if (onChange != null)
				onChange();

			updateDisplay();
		}

		super.update(elapsed);
	}

	function updateDisplay()
	{
		remove(alphaDisplay, true);
		alphaDisplay.kill();
		alphaDisplay.destroy();

		alphaDisplay = new Alphabet(0, 0, display + ' < ' + Reflect.field(Settings, theNumber) + unit + ' >', false);
		add(alphaDisplay);
	}
}

class SelectionOption extends Option
{
	var theType:String;
	var curSelected:Int;
	var types:Array<String>;
	var onChange:Void->Void;

	public function new(display:String, desc:String, typeToChange:String, types:Array<String>, ?onChange:Void->Void)
	{
		super(display, desc);

		theType = typeToChange;
		this.types = types;
		this.onChange = onChange;

		updateDisplay();

		curSelected = Reflect.field(Settings, theType);
		changeSelection();
	}

	override function left()
	{
		changeSelection(-1);

		if (onChange != null)
			onChange();
	}

	override function right()
	{
		changeSelection(1);

		if (onChange != null)
			onChange();
	}

	function updateDisplay()
	{
		remove(alphaDisplay, true);
		alphaDisplay.kill();
		alphaDisplay.destroy();

		alphaDisplay = new Alphabet(0, 0, display + ' < ' + types[Reflect.field(Settings, theType)] + ' >', false);
		add(alphaDisplay);
	}

	function changeSelection(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected < 0)
			curSelected = types.length - 1;
		if (curSelected > types.length - 1)
			curSelected = 0;

		Reflect.setField(Settings, theType, curSelected);
		updateDisplay();
	}
}

class PressOption extends Option
{
	var funnePress:Void->Void;

	public function new(display:String, desc:String, press:Void->Void)
	{
		super(display, desc);

		this.funnePress = press;
	}

	override function press()
	{
		funnePress();
	}
}
