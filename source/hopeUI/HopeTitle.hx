package hopeUI;

import flixel.FlxG;
import flixel.FlxSprite;

class HopeTitle extends MusicBeatState
{
	override function create()
	{
		#if desktop
		Discord.DiscordClient.changePresence("HOPE - Title Screen", "I hope this goes well...");
		#end
		var logo = new FlxSprite().loadGraphic(Paths.image("hopeUI/logo"));
		logo.setGraphicSize(Std.int(FlxG.width * 0.6));
		logo.updateHitbox();
		logo.screenCenter();
		logo.antialiasing = true;
		add(logo);
		
		super.create();

		FlxG.camera.fade(2.5, true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
