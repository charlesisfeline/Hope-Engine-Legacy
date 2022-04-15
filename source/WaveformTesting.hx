package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxStrip;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import lime.media.vorbis.VorbisFile;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import sys.thread.Thread;

class WaveformTesting extends FlxState
{
	var fuck:FlxSprite;

	var audioBuffer:AudioBuffer;
	var bytes:Bytes;

	var MAX_WIDTH:Int = 360;
	var MAX_HEIGHT:Int = 720;

	override public function create()
	{
		super.create();

		fuck = new FlxSprite().makeGraphic(MAX_WIDTH, MAX_HEIGHT, FlxColor.BLACK);
		add(fuck);

		audioBuffer = AudioBuffer.fromFile("./assets/music/freakyMenu.ogg");
		Sys.println("Channels        : " + audioBuffer.channels + "\nBits per sample : " + audioBuffer.bitsPerSample);

		bytes = audioBuffer.data.toBytes();
		Sys.println(bytes.length);

		FlxG.sound.playMusic(Sound.fromAudioBuffer(audioBuffer));

		Thread.create(function()
		{
			var currentTime:Float = Sys.time();
			var finishedTime:Float;

			var index:Int = 0;
			var drawIndex:Int = 0;
			var samplesPerRow:Int = 600;

			var min:Float = 0;
			var max:Float = 0;

			Sys.println("Interating");

			while ((index * 4) < (bytes.length - 1))
			{
				var byte:Int = bytes.getUInt16(index * 4);

				if (byte > 65535 / 2)
					byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0)
				{
					if (sample > max)
						max = sample;
				}
				else if (sample < 0)
				{
					if (sample < min)
						min = sample;
				}

				if ((index % samplesPerRow) == 0)
				{
					var pixelsMin:Float = Math.abs(min * 300);
					var pixelsMax:Float = max * 300;

					fuck.pixels.fillRect(new Rectangle((MAX_WIDTH / 2) - pixelsMin, drawIndex, pixelsMin + pixelsMax, 1), FlxColor.WHITE);
					drawIndex += 1;

					min = 0;
					max = 0;

					if (drawIndex > MAX_HEIGHT)
						break;
				}

				index += 1;
			}

			finishedTime = Sys.time();

			Sys.println("Took " + (finishedTime - currentTime) + " seconds.");
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
