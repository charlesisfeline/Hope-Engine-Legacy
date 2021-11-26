package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class ModLoadingState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;
	
	override function create()
	{
		FlxG.mouse.visible = true;
		
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		var piss:ModThing = new ModThing(50, 50, "Test Mod", "Adds the \"Test\" song to freeplay!", "0.1.0", "");
		add(piss);

		super.create();
	}
    

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			FlxG.switchState(new OptionsMenu());
	}
}

class ModThing extends FlxSpriteGroup
{
	var nameDisplay:FlxText;
	var descDisplay:FlxText;

	var nameText:FlxText;
	var descText:FlxText;
	var versText:FlxText;

	public var checkBox:OptionsMenu.CheckBox;
	
	public function new(x:Float, y:Float, name:String = "Mod name not found.", desc:String = "Mod description not found.", ver:String = "", icon:String)
	{
		super(x, y);
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width - 125, 150, 0xFF000000);
		bg.alpha = 0.6;
		add(bg);

		var iconBG:FlxSprite = new FlxSprite().makeGraphic(150, 150, 0xFF000000);
		iconBG.alpha = 0.2;
		add(iconBG);

		var chkboxBG:FlxSprite = new FlxSprite(bg.width - 150).makeGraphic(150, 150, 0xFF000000);
		chkboxBG.alpha = 0.2;
		add(chkboxBG);

		nameText = new FlxText(iconBG.width + 5, 5, bg.width - 310, name);
		nameText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		nameText.borderSize = 2;
		add(nameText);

		descText = new FlxText(iconBG.width + 5, 37, bg.width - 310, desc);
		descText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		descText.borderSize = 2;
		add(descText);

		versText = new FlxText(iconBG.width + 5, height - 27, bg.width - 310, "v" + ver);
		versText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		versText.borderSize = 2;
		add(versText);
	}
}