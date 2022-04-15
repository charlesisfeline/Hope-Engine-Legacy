package editors;

import DialogueSubstate.DialogueSettings;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;

class DialogueEditor extends MusicBeatState
{
	var UI_box:FlxUITabMenu;

	var _settings:DialogueSettings = {
		bgMusic: {
			name: "breakfast",
			fadeIn: {
				to: 0.8,
				from: 0,
				duration: 1
			}
		},
		bg: {
			alpha: 0.5,
			duration: 0,
			color: "000000"
		}
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		usesMouse = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
