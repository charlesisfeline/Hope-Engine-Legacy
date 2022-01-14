package;

import Character.Animation;
import PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxSliceSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import haxe.Json;

using StringTools;
#if FILESYSTEM
import sys.io.File;
#end

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var strumTimeSus:Float = 0; // for sustain note consistency

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	// note type shit
	public var noteType:String = "hopeEngine/normal";
	public var canScore:Null<Bool> = true; // if false, no score will be added :(
	public var canMiss:Null<Bool> = false; // if true, you can miss it without penalty
	public var noHolds:Null<Bool> = false; // if true, it has no sus notes
	public var setScale:Null<Float> = 1;
	public var upSpriteOnly:Null<Bool> = false;

	public var wasEnemyNote = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var sectionNumber:Int = 0;

	public var positionLockX:Null<Bool> = true;
	public var positionLockY:Null<Bool> = true;
	public var angleLock:Null<Bool> = true;
	public var alphaLock:Null<Bool> = true;
	public var visibleLock:Null<Bool> = true;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	var offsetMultiplier:Array<Float> = [1, 1];
	var animOffset:Array<Int> = [0, 0];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?setNoteType:String = "hopeEngine/normal", ?skin:FlxAtlasFrames)
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

				#if FILESYSTEM
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

					#if FILESYSTEM
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
			case 0: animation.play('purpleScroll');
			case 1: animation.play('blueScroll');
			case 2: animation.play('greenScroll');
			case 3: animation.play('redScroll');
		}

		var pissShit = PlayState.SONG.noteStyle == "pixel" ? "-pixel" : "";
		
		if (pissShit == "-pixel")
			antialiasing = false;

		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

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

			if (prevNote.isSustainNote)
			{

				switch (prevNote.noteData)
				{
					case 0: prevNote.animation.play('purplehold');
					case 1: prevNote.animation.play('bluehold');
					case 2: prevNote.animation.play('greenhold');
					case 3: prevNote.animation.play('redhold');
				}
				
				if (FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;

				prevNote.updateHitbox();
			}
		}

		if (this.noteType != "hopeEngine/normal")
			changeType(this.noteType);
	}

	var dirs = ["purple", "blue", "green", "red"];

	public function changeType(type:String)
	{
		var a = type.split("/");
		#if FILESYSTEM
		var noteJSON = Json.parse(File.getContent(Sys.getCwd() + Paths.noteJSON(a[1], a[0])));
		#else
		var noteJSON = Json.parse(openfl.utils.Assets.getText(Paths.noteJSON(a[1], a[0])));
		#end

		var previousMod = Paths.currentMod;
		if (a[0] != "hopeEngine") Paths.setCurrentMod(a[0]);
		frames = Paths.getSparrowAtlas("styles/" + noteJSON.assetName + (PlayState.SONG.noteStyle == "pixel" ? "-pixel" : ""));
		Paths.setCurrentMod(previousMod);

		this.upSpriteOnly = (noteJSON.upSpriteOnly != null ? noteJSON.upSpriteOnly : false);
		this.canScore = (noteJSON.canScore != null ? noteJSON.canScore : true);
		this.canMiss = (noteJSON.canMiss != null ? noteJSON.canMiss : false);
		this.offsetMultiplier = (noteJSON.offsetMultipler != null ? noteJSON.offsetMultipler : [1, 1]);
		this.setScale = (noteJSON.scale != null ? noteJSON.scale : 1);
		
		this.positionLockX = (noteJSON.positionLockX != null ? noteJSON.positionLockX : true);
		this.positionLockY = (noteJSON.positionLockY != null ? noteJSON.positionLockY : true);
		this.angleLock = (noteJSON.angleLock != null ? noteJSON.angleLock : true);
		this.alphaLock = (noteJSON.alphaLock != null ? noteJSON.alphaLock : true);
		this.visibleLock = (noteJSON.visibleLock != null ? noteJSON.visibleLock : true);

		if (this.upSpriteOnly)
		{
			if (isSustainNote)
			{
				// THIS FORMATTING LOOKS BETTER IN VSCODE I SWEAR
				animation.addByPrefix('holdend', noteJSON.sprites.up.holdEnd.prefix, 
											     noteJSON.sprites.up.holdEnd.frameRate, 
												 noteJSON.sprites.up.holdEnd.looped, 
												 noteJSON.sprites.up.holdEnd.flipX, 
												 noteJSON.sprites.up.holdEnd.flipY);
				animation.play('holdend');
	
				if (prevNote.isSustainNote)
				{
					prevNote.animation.addByPrefix('hold', noteJSON.sprites.up.holdPiece.prefix,
														   noteJSON.sprites.up.holdPiece.frameRate,
														   noteJSON.sprites.up.holdPiece.looped,
														   noteJSON.sprites.up.holdPiece.flipX,
														   noteJSON.sprites.up.holdPiece.flipY);
														   
					prevNote.animation.play('hold');
					prevNote.updateHitbox();
				}
			}
			else
			{
				animation.addByPrefix('Scroll', noteJSON.sprites.up.note.prefix,
												noteJSON.sprites.up.note.frameRate,
												noteJSON.sprites.up.note.looped,
												noteJSON.sprites.up.note.flipX,
												noteJSON.sprites.up.note.flipY);
				animation.play('Scroll');
			}
		}
		else
		{
			if (isSustainNote)
			{
				// THIS FORMATTING LOOKS BETTER IN VSCODE I SWEAR
				animation.addByPrefix('purpleholdend', noteJSON.sprites.left.holdEnd.prefix, 
												 	   noteJSON.sprites.left.holdEnd.frameRate, 
												 	   noteJSON.sprites.left.holdEnd.looped, 
												 	   noteJSON.sprites.left.holdEnd.flipX, 
													   noteJSON.sprites.left.holdEnd.flipY);

				animation.addByPrefix('blueholdend', noteJSON.sprites.down.holdEnd.prefix, 
													 noteJSON.sprites.down.holdEnd.frameRate, 
													 noteJSON.sprites.down.holdEnd.looped, 
													 noteJSON.sprites.down.holdEnd.flipX, 
													 noteJSON.sprites.down.holdEnd.flipY);

				animation.addByPrefix('greenholdend', noteJSON.sprites.up.holdEnd.prefix, 
													  noteJSON.sprites.up.holdEnd.frameRate, 
													  noteJSON.sprites.up.holdEnd.looped, 
													  noteJSON.sprites.up.holdEnd.flipX, 
													  noteJSON.sprites.up.holdEnd.flipY);
				
				animation.addByPrefix('redholdend', noteJSON.sprites.right.holdEnd.prefix,
													noteJSON.sprites.right.holdEnd.frameRate, 
													noteJSON.sprites.right.holdEnd.looped, 
													noteJSON.sprites.right.holdEnd.flipX, 
													noteJSON.sprites.right.holdEnd.flipY);
													 
				animation.play(dirs[this.noteData] + 'holdend');
	
				if (prevNote.isSustainNote)
				{
					prevNote.animation.addByPrefix('purplehold', noteJSON.sprites.left.holdPiece.prefix,
														   		 noteJSON.sprites.left.holdPiece.frameRate,
														   		 noteJSON.sprites.left.holdPiece.looped,
														   		 noteJSON.sprites.left.holdPiece.flipX,
														   	   	 noteJSON.sprites.left.holdPiece.flipY);

					prevNote.animation.addByPrefix('bluehold', noteJSON.sprites.down.holdPiece.prefix,
															   noteJSON.sprites.down.holdPiece.frameRate,
															   noteJSON.sprites.down.holdPiece.looped,
															   noteJSON.sprites.down.holdPiece.flipX,
															   noteJSON.sprites.down.holdPiece.flipY);

					prevNote.animation.addByPrefix('greenhold', noteJSON.sprites.up.holdPiece.prefix,
																noteJSON.sprites.up.holdPiece.frameRate,
																noteJSON.sprites.up.holdPiece.looped,
																noteJSON.sprites.up.holdPiece.flipX,
																noteJSON.sprites.up.holdPiece.flipY);

					prevNote.animation.addByPrefix('redhold', noteJSON.sprites.right.holdPiece.prefix,
															  noteJSON.sprites.right.holdPiece.frameRate,
															  noteJSON.sprites.right.holdPiece.looped,
															  noteJSON.sprites.right.holdPiece.flipX,
															  noteJSON.sprites.right.holdPiece.flipY);

					prevNote.animation.play(dirs[this.noteData] + 'hold');
					prevNote.updateHitbox();
				}
			}
			else
			{
				animation.addByPrefix('purpleScroll', noteJSON.sprites.left.note.prefix,
													  noteJSON.sprites.left.note.frameRate,
													  noteJSON.sprites.left.note.looped,
													  noteJSON.sprites.left.note.flipX,
													  noteJSON.sprites.left.note.flipY);
				
				animation.addByPrefix('blueScroll', noteJSON.sprites.down.note.prefix,
													noteJSON.sprites.down.note.frameRate,
													noteJSON.sprites.down.note.looped,
													noteJSON.sprites.down.note.flipX,
													noteJSON.sprites.down.note.flipY);

				animation.addByPrefix('greenScroll', noteJSON.sprites.up.note.prefix,
													 noteJSON.sprites.up.note.frameRate,
													 noteJSON.sprites.up.note.looped,
													 noteJSON.sprites.up.note.flipX,
													 noteJSON.sprites.up.note.flipY);

				animation.addByPrefix('redScroll', noteJSON.sprites.right.note.prefix,
												   noteJSON.sprites.right.note.frameRate,
												   noteJSON.sprites.right.note.looped,
												   noteJSON.sprites.right.note.flipX,
												   noteJSON.sprites.right.note.flipY);
												
				animation.play(dirs[this.noteData] + 'Scroll');
			}

			// Set animoffset (awesome)
			if (isSustainNote)
			{
				if (animation.curAnim.name.endsWith("end"))
				{
					switch (noteData)
					{
						case 0: animOffset = noteJSON.sprites.left.holdEnd.offset;
						case 1: animOffset = noteJSON.sprites.down.holdEnd.offset;
						case 2: animOffset = noteJSON.sprites.up.holdEnd.offset;
						case 3: animOffset = noteJSON.sprites.right.holdEnd.offset;
					}
				}
				else if (animation.curAnim.name.endsWith("hold"))
				{
					switch (noteData)
					{
						case 0: animOffset = noteJSON.sprites.left.holdPiece.offset;
						case 1: animOffset = noteJSON.sprites.down.holdPiece.offset;
						case 2: animOffset = noteJSON.sprites.up.holdPiece.offset;
						case 3: animOffset = noteJSON.sprites.right.holdPiece.offset;
					}
				}
			}
			else
			{
				switch (noteData)
				{
					case 0: animOffset = noteJSON.sprites.left.note.offset;
					case 1: animOffset = noteJSON.sprites.down.note.offset;
					case 2: animOffset = noteJSON.sprites.up.note.offset;
					case 3: animOffset = noteJSON.sprites.right.note.offset;
				}
			}
		}

		// if (PlayState.SONG.noteStyle == "pixel")
		// 	setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		// else
		// 	setGraphicSize(Std.int(width * 0.7));

		if (animOffset == null)
			animOffset = [0, 0];
		
		if (this.upSpriteOnly)
			unblandNote('direction');

		if (noteJSON.unblandWhat != null)
			unblandNote(noteJSON.unblandWhat);

		updateHitbox();
		
		setGraphicSize(Std.int(width * this.setScale));

		if (noteType != "hopeEngine/normal") // huh, normal notes have an offset of their own...
			offset.set(offset.x + animOffset[0], offset.y + animOffset[1]);
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
				if (!isSustainNote)
					this.angle = noteAngles[this.noteData];
			case 'both':
				this.color = noteColors[this.noteData];
				if (!isSustainNote)
					this.angle = noteAngles[this.noteData];
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
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * offsetMultiplier[0]
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * offsetMultiplier[1])
					canBeHit = true;
				else
					canBeHit = false;		
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

		// sus note consistency bullshit

		if (animation.curAnim != null && animation.curAnim.name.endsWith('hold'))
		{
			if (FlxG.save.data.scrollSpeed != 1)
				scale.y = Conductor.stepCrochet / 100 * (PlayState.SONG.noteStyle != "pixel" ? 1.045 : 7.6) * FlxG.save.data.scrollSpeed;
			else
				scale.y = Conductor.stepCrochet / 100 * (PlayState.SONG.noteStyle != "pixel" ? 1.045 : 7.6) * Math.abs(PlayState.SONG.speed);

			updateHitbox();
		}

		if (isSustainNote)
			this.strumTime = strumTimeSus + Math.abs(Conductor.stepCrochet / FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed : FlxG.save.data.scrollSpeed, 2));
	}
}