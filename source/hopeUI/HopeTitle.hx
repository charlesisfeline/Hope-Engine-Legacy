package hopeUI;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

#if FILESYSTEM
import sys.FileSystem;
#end

class HopeTitle extends MusicBeatState 
{
	var completedIntro:Bool = false;
	var startedIntro:Bool = false;
	static var initialized:Bool = false;

	var creditsText:FlxText;

	override function create() 
	{
		#if FILESYSTEM
		if (!FileSystem.exists(Sys.getCwd() + "/assets/skins"))
			FileSystem.createDirectory(Sys.getCwd() + "/assets/skins");

		if (!FileSystem.exists(Sys.getCwd() + "/mods"))
			FileSystem.createDirectory(Sys.getCwd() + "/mods");

		// quick check
		for (skinName in FileSystem.readDirectory(Sys.getCwd() + "/assets/skins"))
		{
			if (skinName.trim() == 'default')
				FlxG.switchState(new WarningState("Uhoh!\n\nYou seem to have a folder in the note skins folder called \"default\".\n\nThe engine uses this name internally!\n\nPlease change it!",
					function()
					{
						Sys.exit(0);
					}));
		}

		for (mod in FileSystem.readDirectory(Sys.getCwd() + "/mods"))
		{
			if (mod.trim().toLowerCase() == 'hopeengine')
				FlxG.switchState(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"hopeengine\".\n\nThe engine uses this name internally!\n\nPlease change it!",
					function()
					{
						Sys.exit(0);
					}));

			if (mod.trim().toLowerCase() == 'none')
				FlxG.switchState(new WarningState("Uhoh!\n\nYou seem to have a folder in the mods folder called \"none\".\n\nThe engine uses this name internally!\n\nPlease change it!",
					function()
					{
						Sys.exit(0);
					}));
		}

		options.NoteSkinSelection.refreshSkins();
		#end

		#if desktop
		// only 1 thread
		if (!initialized)
		{
			DiscordClient.initialize();

			Application.current.onExit.add(function(exitCode)
			{
				DiscordClient.shutdown();
			});
		}
		#end

		Highscore.load();

		// Feeling dumb today
		Application.current.onExit.add(function(exitCode)
		{
			Settings.lastVolume = FlxG.sound.volume;
			Settings.lastMuted = FlxG.sound.muted;

			Settings.save();
			Achievements.save();
			FlxG.save.flush();
		});

		creditsText = new FlxText();
		creditsText.setFormat("VCR OSD Mono", 64, CENTER);
		add(creditsText);

		super.create();

		if (!initialized)
			startIntro();
		else
			skipIntro();
	}

	function startIntro():Void
	{
		startedIntro = true;
		
	}

	function skipIntro():Void
	{
		startedIntro = true;
		completedIntro = true;

		FlxG.camera.flash(FlxColor.WHITE, 4);
	}

	function analyzeBeat():Void
	{
		switch (curBeat)
		{

		}
	}

	override function beatHit() 
	{
		super.beatHit();

		if (startedIntro && !completedIntro)
			analyzeBeat();
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		creditsText.screenCenter(Y);
		
		// if (completedIntro && controls.ACCEPT)
			// FlxG.switchState()
	}
}