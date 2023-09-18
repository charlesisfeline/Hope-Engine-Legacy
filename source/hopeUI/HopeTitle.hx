package hopeUI;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxAngle;

class HopeTitle extends MusicBeatState
{
	var logo:FlxSprite;

	override function create()
	{
		#if desktop
		Discord.DiscordClient.changePresence("HOPE - Title Screen", null);
		#end
		
		logo = new FlxSprite().loadGraphic(Paths.image("hopeUI/logo"));
		logo.setGraphicSize(Std.int(FlxG.width * 0.6));
		logo.updateHitbox();
		logo.screenCenter();
		logo.antialiasing = true;
		add(logo);
		
		super.create();

		FlxG.camera.fade(4.5, true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
