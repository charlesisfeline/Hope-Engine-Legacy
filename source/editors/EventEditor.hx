package editors;

import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;

using StringTools;

#if FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class EventEditor extends MusicBeatState
{
	var UI_box:FlxUITabMenu;
	var fakeoutBox:FlxUITabMenu;

	override function create()
	{
		UI_box = new FlxUITabMenu(null, [{name: "1", label: 'Event Menu Bullshittery'},], true);
		UI_box.scrollFactor.set();
		UI_box.resize(300, 300);
		UI_box.x = (FlxG.width / 2) + 20;
		UI_box.screenCenter(Y);
		add(UI_box);

		fakeoutBox = new FlxUITabMenu(null, [{name: "1", label: 'Event Preview in Charter'},], true);
		fakeoutBox.scrollFactor.set();
		fakeoutBox.resize(50 * 8, 400);
		fakeoutBox.x = (FlxG.width / 2) - fakeoutBox.width - 20;
		fakeoutBox.screenCenter(Y);
		add(fakeoutBox);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
