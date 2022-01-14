package;

import Checkbox.CheckBox;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxMath;
import lime.app.Application;

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
        y = FlxMath.lerp(y, (scaledY * 120) + additive, 9 / lime.app.Application.current.window.frameRate);

        super.update(elapsed);
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
        FlxG.switchState(state);
    }
}

class StateOption extends Option
{
    public var state:FlxState;
    
    public function new (display:String, desc:String, state:FlxState)
    {
        super(display, desc);
        this.state = state;
    }

    override function press()
    {
        FlxG.switchState(state);
    }
}

class OptionSubCategoryTitle extends Option
{
    public function new(name:String)
    {
        super(name, '');

        remove(alphaDisplay, true);
        alphaDisplay.kill();
        alphaDisplay.destroy();

        alphaDisplay = new Alphabet(0, 0, name, true); 
        add(alphaDisplay);
    }
}

class ToggleOption extends Option
{
    var theBool:String;
    var checkbox:CheckBox;
    var onChange:Void->Void;

    /**
     * Toggle Option, options with checkboxes on the side.
     * @param display Text to display.
     * @param desc Description to be shown.
     * @param boolValueToChange FlxG save data `bool` value to be changed.
     */
    public function new(display:String, desc:String, boolValueToChange:String, ?onChange:Void->Void)
    {
        super(display, desc);

        this.onChange = onChange;
        
        theBool = boolValueToChange;
        alphaDisplay.x += 200;

        checkbox = new CheckBox(0, 0, Reflect.field(FlxG.save.data, theBool));
        checkbox.setGraphicSize(150);
        checkbox.y = alphaDisplay.y + (alphaDisplay.height / 2) - (checkbox.height / 2);
        this.add(checkbox);
    }

    override function press() 
    {
        Reflect.setField(FlxG.save.data, theBool, !Reflect.field(FlxG.save.data, theBool));
        checkbox.change(Reflect.field(FlxG.save.data, theBool));
        
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
    
    /**
     * Value option, but a float: Pressing left or right will 
     * increase/decrease by the `increment` provided. 
     * 
     * Changing the shift multiplier to anything else than `1` will
     * add a multiplier when you press SHIFT!
     * 
     * @param display Text to display. (slightly changed with the value provided)
     * @param desc Description to be shown.
     * @param numberValueToChange FlxG save data `float` value to be changed.
     * @param min Minimum value
     * @param max Maximum value
     * @param increment How much to change each left press.
     * @param shiftMultiplier How much to multiply `increment` by when pressing SHIFT
     */
    public function new(display:String, desc:String, numberValueToChange:String, min:Float, max:Float, ?increment:Float = 1.0, ?shiftMultiplier:Float = 1.0, ?onChange:Void->Void, ?resetValue:Null<Float> = null, ?unit:String = '', ?precision:Int = 0)
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
        if (Reflect.field(FlxG.save.data, theNumber) <= min)
            Reflect.setField(FlxG.save.data, theNumber, min);
        else
            Reflect.setField(FlxG.save.data, theNumber, HelperFunctions.truncateFloat(Reflect.field(FlxG.save.data, theNumber) - (increment * funneMultiplier), precision));

        updateDisplay();
    }

    override function right_H()
    {
        if (Reflect.field(FlxG.save.data, theNumber) >= max)
            Reflect.setField(FlxG.save.data, theNumber, max);
        else
            Reflect.setField(FlxG.save.data, theNumber, HelperFunctions.truncateFloat(Reflect.field(FlxG.save.data, theNumber) + (increment * funneMultiplier), precision));

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
            Reflect.setField(FlxG.save.data, theNumber, resetValue);
            updateDisplay();
        }
        
        super.update(elapsed);
    }

    function updateDisplay()
    {
        remove(alphaDisplay, true);
        alphaDisplay.kill();
        alphaDisplay.destroy();

        alphaDisplay = new Alphabet(0, 0, display + ' < ' + Reflect.field(FlxG.save.data, theNumber) + unit + ' >', false); 
        add(alphaDisplay);

        if (onChange != null)
            onChange();
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
    
    /**
     * Value option, but an Int: Pressing left or right will 
     * increase/decrease by the `increment` provided. 
     * 
     * Changing the shift multiplier to anything else than `1` will
     * add a multiplier when you press SHIFT!
     * 
     * @param display Text to display. (slightly changed with the value provided)
     * @param desc Description to be shown.
     * @param numberValueToChange FlxG save data `float` value to be changed.
     * @param min Minimum value
     * @param max Maximum value
     * @param increment How much to change each left press.
     * @param shiftMultiplier How much to multiply `increment` by when pressing SHIFT
     */
    public function new(display:String, desc:String, numberValueToChange:String, min:Int, max:Int, ?increment:Int = 1, ?shiftMultiplier:Int = 1, ?onChange:Void->Void, ?resetValue:Null<Int> = null, ?unit:String = '')
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
        if (Reflect.field(FlxG.save.data, theNumber) <= min)
            Reflect.setField(FlxG.save.data, theNumber, min);
        else
            Reflect.setField(FlxG.save.data, theNumber, Reflect.field(FlxG.save.data, theNumber) - (increment * funneMultiplier));

        updateDisplay();
    }

    override function right_H()
    {
        if (Reflect.field(FlxG.save.data, theNumber) >= max)
            Reflect.setField(FlxG.save.data, theNumber, max);
        else
            Reflect.setField(FlxG.save.data, theNumber, Reflect.field(FlxG.save.data, theNumber) + (increment * funneMultiplier));

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
            Reflect.setField(FlxG.save.data, theNumber, resetValue);
            updateDisplay();
        }
        
        super.update(elapsed);
    }

    function updateDisplay()
    {
        remove(alphaDisplay, true);
        alphaDisplay.kill();
        alphaDisplay.destroy();

        alphaDisplay = new Alphabet(0, 0, display + ' < ' + Reflect.field(FlxG.save.data, theNumber) + unit + ' >', false); 
        add(alphaDisplay);

        if (onChange != null)
            onChange();
    }
}

class SelectionOption extends Option
{
    var theType:String;
    var curSelected:Int;
    var types:Array<String>;
    
    public function new(display:String, desc:String, typeToChange:String, types:Array<String>)
    {
        super(display, desc);
        
        theType = typeToChange;
        this.types = types;

        updateDisplay();
        changeSelection();
    }

    override function left()
    {
        changeSelection(-1);
    }

    override function right()
    {
        changeSelection(1);
    }

    function updateDisplay()
    {
        remove(alphaDisplay, true);
        alphaDisplay.kill();
        alphaDisplay.destroy();

        alphaDisplay = new Alphabet(0, 0, display + ' < ' + types[Reflect.field(FlxG.save.data, theType)] + ' >', false); 
        add(alphaDisplay);
    }

    function changeSelection(huh:Int = 0)
    {
        curSelected += huh;

        if (huh != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));
        
        if (curSelected < 0)
            curSelected = types.length - 1;
        if (curSelected > types.length - 1)
            curSelected = 0;

        Reflect.setField(FlxG.save.data, theType, curSelected);
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