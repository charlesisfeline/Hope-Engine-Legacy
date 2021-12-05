package;

import Character.Animation;
import PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var wasEnemyNote = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:Int = 0;
	public var sectionNumber:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	var offsetMultipliers:Array<Array<Float>> = [
		[1, 1],
		[0.3, 0.2],
		[0.6, 0.4],
	];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?setNoteType:Int = 0, ?skin:FlxAtlasFrames)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		
		this.noteType = setNoteType;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		switch (PlayState.SONG.noteStyle)
		{
			case 'pixel':
				loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

				#if sys
				if (FlxG.save.data.currentNoteSkin != "default" && 
					NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin + "-pixel") != null)
					loadGraphic(NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin + "-pixel"), true, 17, 17);
				#end

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('pixelUI/arrowEnds'), true, 7, 6);

					#if sys
					if (FlxG.save.data.currentNoteSkin != "default" && 
						NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin + "-pixelEnds") != null)
						loadGraphic(NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin + "-pixelEnds"), true, 7, 6);
					#end

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}
			

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
			default:
				frames = skin;

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		var pissShit = PlayState.SONG.noteStyle == "pixel" ? "-pixel" : "";
		
		if (pissShit == "-pixel")
			antialiasing = false;

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{

				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}
				
				if (FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;

				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		if (this.noteType != 0)
			changeType(this.noteType);
	}

	public function changeType(type:Int)
	{
		noteType = type;
		var styles = ["death", "flash", "tabi"];
		var imageName = styles[type - 1];
		var pissShit = PlayState.SONG.noteStyle == "pixel" ? "-pixel" : "";
		
		var a = Paths.getSparrowAtlas("styles/" + imageName.toUpperCase() + pissShit);
		frames = a;
		
		if (isSustainNote)
		{
			animation.addByPrefix('holdend', 'hold end');
			animation.play('holdend');

			if (prevNote.isSustainNote)
			{
				prevNote.animation.addByPrefix('hold', 'hold piece');
				prevNote.animation.play('hold');

				prevNote.updateHitbox();
			}
		}
		else
		{
			animation.addByPrefix('Scroll', 'note');
			animation.play('Scroll');
		}

		if (!isSustainNote)
			unblandNote('direction');

		if (styles[type - 1] == "tabi")
			unblandNote();
		
		updateHitbox();
	}

	public static var noteColors:Array<FlxColor> = [0xc24b99, 0x00ffff, 0x12fa05, 0xf9393f];
	public static var noteAngles:Array<Float> = [-90, 180, 0, 90];

	public function unblandNote(unblandWhat:String = 'color')
	{
		switch (unblandWhat.toLowerCase())
		{
			case 'color':
				this.color = noteColors[this.noteData];
			case 'direction':
				this.angle = noteAngles[this.noteData];
			default:
				trace('Yo shit ain\'t a note property goddamn');
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (offsetMultipliers[noteType] != null)
				{
					if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * (offsetMultipliers[noteType][0])
						&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * (offsetMultipliers[noteType][1]))
						canBeHit = true;
					else
						canBeHit = false;
				}
				else
				{
					if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
						&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
						canBeHit = true;
					else
						canBeHit = false;					
				}
				
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
			canBeHit = false;

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}

		if (animation.curAnim != null && animation.curAnim.name.endsWith('hold'))
		{
			if (FlxG.save.data.scrollSpeed != 1)
				scale.y = Conductor.stepCrochet / 100 * (PlayState.SONG.noteStyle != "pixel" ? 1.045 : 7.6) * FlxG.save.data.scrollSpeed;
			else
				scale.y = Conductor.stepCrochet / 100 * (PlayState.SONG.noteStyle != "pixel" ? 1.045 : 7.6) * Math.abs(PlayState.SONG.speed);

			updateHitbox();
		}
	}
}