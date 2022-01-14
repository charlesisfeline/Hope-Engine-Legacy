package;

import DialogueSubstate.DialogueStyle;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import lime.utils.Assets;
import openfl.Lib;
import openfl.filters.BlurFilter;
import openfl.filters.ShaderFilter;

using StringTools;

#if FILESYSTEM
import Sys;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;
#end

#if windows
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var isPlaylistMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;

	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var misses:Int = 0;

	public static var weekShits:Int = 0;
	public static var weekBads:Int = 0;
	public static var weekGoods:Int = 0;
	public static var weekSicks:Int = 0;
	public static var weekMisses:Int = 0;
	
	public static var weekName:String = "";

	public static var peakCombo:Int = 0;
	public static var weekPeakCombo:Array<Int> = [];

	public static var weekAccuracies:Array<Float> = [];

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var lastSongCamPos:FlxPoint;

	var songLength:Float = 0;
	
	#if windows
	var iconRPC:String = "";
	#end

	private var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	// so that sustains are always below normal notes
	private var displaySustains:FlxTypedGroup<Note>;
	private var displayNotes:FlxTypedGroup<Note>;

	public var strumLine:FlxSprite;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedSpriteGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedSpriteGroup<StaticArrow> = null;
	public static var pfBackgrounds:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	public var health:Float = 1; //making public because sethealth doesnt work without it
	private var combo:Int = 0;
	public static var accuracy:Float = 0.00; // makin it public so that ResultsScreen can access it
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;
	public static var songRecording:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var whosFocused:Character = dad;

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var cityLights:FlxTypedGroup<FlxSprite>;

	var limo:FlxSprite;
	var stageCurtains:FlxSprite;
	var darkener:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var botPlayWarning:FlxText;
	var warningSections:Array<Int> = [];

	var loadedNoteTypeInterps:Map<String, Interp>;

	var bfSide:FlxSprite;
	var enemySide:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	public static var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;
	
	var daLogo:FlxSprite;
	// var comboCountText:Count;

	var scrollSpeedText:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;
	public static var daPixelZoom:Float = 6;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;

	var repNotes:Array<Array<Array<Float>>> = [];
	var repSustains:Array<Array<Array<Float>>> = [];
	var repPresses:Array<Array<Float>> = [];

	private var executeModchart = false;

	static var originalPlaylistLength:Int = -1;

	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }

	// Modchart shit
	public var parser:Parser;
	public var interp:Interp;
	var modchart:String;
	var ast:Dynamic;

	// Note type shit and misc
	var originalDownscroll:Bool;
	var originalSpeed:Float;
	var warningText:FlxText;

	// skin stuff
	var noteSplashAtlas:FlxAtlasFrames;

	override public function create()
	{
		instance = this;

		parser = new hscript.Parser();
		parser.allowTypes = true;

		loadedNoteTypeInterps = new Map<String, Interp>();

		#if FILESYSTEM
		Paths.destroyCustomImages();
		#end
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (originalPlaylistLength == -1)
			originalPlaylistLength = storyPlaylist.length;

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;
		peakCombo = 0;

		// reset when it's a start of a new week
		if (storyPlaylist.length == originalPlaylistLength)
		{
			weekShits = 0;
			weekBads = 0;
			weekGoods = 0;
			weekSicks = 0;
			weekMisses = 0;
			weekPeakCombo = [];
			weekAccuracies = [];
			weekName = "";
		}

		accuracy = 0.00;
		songScore = 0;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		// We out here using hscript modcharts
		executeModchart = Paths.exists(Paths.modchart(songLowercase  + "/modchart"));

		#if FILESYSTEM
		if (Paths.currentMod != null && Paths.currentMod.length > 0 && !executeModchart)
		{
			executeModchart = FileSystem.exists(Paths.modModchart(songLowercase + "/modchart"));
			trace("EXECUTING A MOD'S MODCHART: " + executeModchart + "\nMODCHART PATH: " + Paths.modModchart(songLowercase + "/modchart"));
		}
		#end

	
		if (executeModchart)
		{
			interp = new hscript.Interp();

			#if FILESYSTEM
			if (Paths.currentMod != null && Paths.currentMod.length > 0)
				modchart = File.getContent(Paths.modModchart(songLowercase + "/modchart"));
			#end

			if (modchart == null)
			{
				#if FILESYSTEM
				modchart = File.getContent(Paths.modchart(songLowercase  + "/modchart"));
				#else
				modchart = Assets.getText(Paths.modchart(songLowercase  + "/modchart"));
				#end
			}

			ast = parser.parseString(modchart);
			interpVariables(interp);
			interp.variables.set("cutsceneDuration", 0);
			interp.execute(ast);
		}
		
		trace(executeModchart ? "Modchart exists!" : "Modchart doesn't exist, tried path " + Paths.modchart(songLowercase  + "/modchart"));

		#if windows
		iconRPC = SONG.player2;
		if (!HealthIcon.splitWhitelist.contains(SONG.player2))
			iconRPC = SONG.player2.split("-")[0];
		
		DiscordClient.changePresence(SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ");
		#end

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);
	

		noteSplashAtlas = Paths.getSparrowAtlas('note_splashes', 'shared');
		
		// THIS SHIT AINT ENOUGH FOR A NULL CHECK
		#if FILESYSTEM
		if (FlxG.save.data.currentNoteSkin != "default" && NoteSkinSelection.loadedSplashes.get(FlxG.save.data.currentNoteSkin) != null && FileSystem.exists(Sys.getCwd() + "assets/skins/" + FlxG.save.data.currentNoteSkin + "/normal/note_splashes.xml"))
			noteSplashAtlas = FlxAtlasFrames.fromSparrow(NoteSkinSelection.loadedSplashes.get(FlxG.save.data.currentNoteSkin), File.getContent(Sys.getCwd() + "assets/skins/" + FlxG.save.data.currentNoteSkin + "/normal/note_splashes.xml"));
		#end

		switch (SONG.stage)
		{
			case 'halloween': 
			{
				curStage = 'spooky';

				var hallowTex = Paths.getSparrowAtlas('halloween_bg','week2');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);

				isHalloween = true;
			}
			case 'philly': 
			{
				curStage = 'philly';

				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				if(FlxG.save.data.distractions){
					add(phillyCityLights);
				}

				for (i in 0...5)
				{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain','week3'));
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train','week3'));
				if(FlxG.save.data.distractions)
					add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes','week3'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street','week3'));
				add(street);
			}
			case 'city':
			{
				defaultCamZoom = 0.75;
				curStage = 'city';

				var city:FlxSprite = new FlxSprite(-200, -250).loadGraphic(Paths.image('stage/city', 'squared'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 1.25));
				city.antialiasing = true;
				add(city);

				cityLights = new FlxTypedGroup<FlxSprite>();
				if(FlxG.save.data.distractions){
					add(cityLights);
				}

				for (i in 0...5)
				{
						var light:FlxSprite = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('stage/lights' + i, 'squared'));
						light.scrollFactor.set(0.3, 0.3);
						light.setGraphicSize(Std.int(city.width * 1.25));
						light.visible = false;
						light.antialiasing = true;
						cityLights.add(light);
				}
				
				var sidewalk:FlxSprite = new FlxSprite(0, -90).loadGraphic(Paths.image('stage/sidewalk','squared'));
				sidewalk.setGraphicSize(Std.int(city.width * 1.25));
				sidewalk.scrollFactor.set(0.95, 0.95);
				sidewalk.screenCenter(X);
				sidewalk.antialiasing = true;
				add(sidewalk);

				darkener = new FlxSprite(0, -100).loadGraphic(Paths.image('stage/darkener', 'squared'));
				darkener.setGraphicSize(Std.int(city.width * 5));
			}
			case 'limo':
			{
				curStage = 'limo';
				defaultCamZoom = 0.90;

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset','week4'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo','week4');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);
				if(FlxG.save.data.distractions){
					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}
				}

				// var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay','week4'));
				// overlayShit.alpha = 0.5;
				// add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
				// overlayShit.shader = new OverlayShader();

				var limoTex = Paths.getSparrowAtlas('limo/limoDrive','week4');

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol','week4'));
				// add(limo);
			}
			case 'mall':
			{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls','week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop','week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if(FlxG.save.data.distractions){
						add(upperBoppers);
					}


					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator','week5'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree','week5'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop','week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if(FlxG.save.data.distractions){
						add(bottomBoppers);
					}


					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow','week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa','week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					if(FlxG.save.data.distractions){
						add(santa);
					}
			}
			case 'mallEvil':
			{
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG','week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree','week5'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow",'week5'));
						evilSnow.antialiasing = true;
					add(evilSnow);
					}
			case 'school':
			{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky','week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool','week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet','week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees','week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (songLowercase == 'roses')
					{
						if(FlxG.save.data.distractions)
							bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					if(FlxG.save.data.distractions)
						add(bgGirls);
			}
			case 'schoolEvil':
			{
					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool','week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

					/* 
							var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
							bg.scale.set(6, 6);
							// bg.setGraphicSize(Std.int(bg.width * 6));
							// bg.updateHitbox();
							add(bg);
							var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
							fg.scale.set(6, 6);
							// fg.setGraphicSize(Std.int(fg.width * 6));
							// fg.updateHitbox();
							add(fg);
							wiggleShit.effectType = WiggleEffectType.DREAMY;
							wiggleShit.waveAmplitude = 0.01;
							wiggleShit.waveFrequency = 60;
							wiggleShit.waveSpeed = 0.8;
						*/

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
								var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
								var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
								// Using scale since setGraphicSize() doesnt work???
								waveSprite.scale.set(6, 6);
								waveSpriteFG.scale.set(6, 6);
								waveSprite.setPosition(posX, posY);
								waveSpriteFG.setPosition(posX, posY);
								waveSprite.scrollFactor.set(0.7, 0.8);
								waveSpriteFG.scrollFactor.set(0.9, 0.8);
								// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
								// waveSprite.updateHitbox();
								// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
								// waveSpriteFG.updateHitbox();
								add(waveSprite);
								add(waveSpriteFG);
						*/
			}
			case 'stage':
			{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
			}
			case 'void':
			{
				// literally nothing.
				// This stage is used for recording stuff, lmao
				defaultCamZoom = 0.9;
				curStage = 'void';
			}
			default:
			{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
			}
		}
		var gfVersion:String = 'gf';

		switch (SONG.gfVersion)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
			default:
				gfVersion = 'gf';
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'kube-beta':
				dad.y += 150;
		}
		
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if(FlxG.save.data.distractions)
				{
					resetFastCar();
					add(fastCar);
				}
			case 'mall':
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				if(FlxG.save.data.distractions)
				{
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					add(evilTrail); 
				}
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'void':
				remove(boyfriend);
				remove(gf);
				remove(dad);
		}

		add(gf);

		camPos.set(dad.getGraphicMidpoint().x + 150, dad.getGraphicMidpoint().y - 100);

		if (lastSongCamPos != null)
			camPos = lastSongCamPos;

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		if (curStage == 'city')
			add(darkener);

		if (curStage == 'stage')
			add(stageCurtains);

		// var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		// doof.scrollFactor.set();
		// doof.finishThing = startCountdown;
			
		botPlayWarning = new FlxText(10, 10, 0, "Many notes in some sections.\nBotPlay may not work as intended.");
		botPlayWarning.setFormat(null, 20, FlxColor.WHITE, LEFT, OUTLINE, 0xFF000000);
		botPlayWarning.borderSize = 3;
		botPlayWarning.visible = false;

		warningText = new FlxText(0, 0, 0, "POSSIBLE WARNINGS:");
		warningText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warningText.borderSize = 3;
		warningText.visible = false;
		warningText.x = 5;
		warningText.y = FlxG.height - warningText.height - 5;
		add(warningText);
		warningText.cameras = [camHUD];

		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 50;

		pfBackgrounds = new FlxTypedGroup<FlxSprite>();
		add(pfBackgrounds);

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedSpriteGroup<StaticArrow>();
		cpuStrums = new FlxTypedSpriteGroup<StaticArrow>();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		if (FlxG.save.data.botplay && loadRep)
			FlxG.save.data.botplay = false;
		
		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 1.2 / Application.current.window.frameRate);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite();
			add(songPosBG);

			songPosBar = new FlxBar(0, 20, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.45), 12, this, 'songPositionBar', 0, 90000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.WHITE);
			songPosBar.screenCenter(X);
			if (FlxG.save.data.downscroll)
				songPosBar.y = FlxG.height - songPosBar.height - 20; 
			add(songPosBar);

			songPosBG.makeGraphic(Std.int(songPosBar.width + 8), Std.int(songPosBar.height + 8), 0xFF000000);
			songPosBG.setPosition(songPosBar.x - 4, songPosBar.y - 4);
			songPosBG.alpha = 0.7;

			songName = new FlxText(0, 0, FlxG.width, SONG.song.toUpperCase(), 16);
			songName.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.y = songPosBar.y + (songPosBar.height / 2) - (songName.height / 2);
			songName.scrollFactor.set();
			songName.borderSize = 4;
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).makeGraphic(Std.int(FlxG.width * 0.45), 20, 0xFF000000);
		if (FlxG.save.data.downscroll)
			healthBarBG.y = FlxG.height * 0.1 - healthBarBG.height;
		healthBarBG.screenCenter(X);
		
		if (!FlxG.save.data.fancyHealthBar)
			healthBarBG.alpha = 0.7;
		
		healthBarBG.scrollFactor.set();

		if (FlxG.save.data.fancyHealthBar)
		{
			enemySide = new FlxSprite(0, healthBarBG.y - 32).loadGraphic(Paths.image('enemy_side'));
			enemySide.screenCenter(X);
			enemySide.scrollFactor.set();
			enemySide.color = dad.getColor();

			bfSide = new FlxSprite(0, healthBarBG.y - 32).loadGraphic(Paths.image('bf_side'));
			bfSide.screenCenter(X);
			bfSide.scrollFactor.set();
			bfSide.color = boyfriend.getColor();

			add(enemySide);
			add(bfSide);

			enemySide.antialiasing = true;
			bfSide.antialiasing = true;

			enemySide.cameras = [camHUD];
			bfSide.cameras = [camHUD];
		}

		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		
		if (FlxG.save.data.healthBarColors)
			healthBar.createFilledBar(dad.getColor(), boyfriend.getColor());
		else
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);

		add(healthBar);

		// comboCountText = new Count(10, 10, "");
		// add(comboCountText);

		scoreTxt = new FlxText(0, 0, FlxG.width, "", 20);
		scoreTxt.setFormat('Funkerin Regular', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.antialiasing = true;
		scoreTxt.borderSize = 2;
		scoreTxt.scrollFactor.set();					

		scoreTxt.y = healthBarBG.y + 35;

		replayTxt = new FlxText(healthBarBG.x, healthBarBG.y - 25, healthBarBG.width, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 3;
		replayTxt.scrollFactor.set();

		if (loadRep) 
			add(replayTxt);

		botPlayState = new FlxText(healthBarBG.x, healthBarBG.y - 25, healthBarBG.width, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.borderSize = 3;
		botPlayState.scrollFactor.set();

		scrollSpeedText = new FlxText(0, 0, 0, "");
		scrollSpeedText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollSpeedText.borderSize = 3;
		add(scrollSpeedText);
		
		if(FlxG.save.data.botplay && !loadRep) 
			add(botPlayState);

		if (FlxG.save.data.botplay)
			iconP1 = new HealthIcon('bf-bot' + (SONG.noteStyle == "pixel" ? "-pixel" : ""), true);
		else
			iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y + (healthBar.height / 2) - ((iconP1.height / 2) * 1.125);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y + (healthBar.height / 2) - ((iconP2.height / 2) * 1.125);

		if (!FlxG.save.data.hideHealthIcons)
		{
			add(iconP1);
			add(iconP2);
		}

		add(scoreTxt);
		add(botPlayWarning);

		scrollSpeedText.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		// notes.cameras = [camHUD];
		displaySustains.cameras = [camHUD];
		displayNotes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botPlayWarning.cameras = [camHUD];
		
		if (FlxG.save.data.songPosition)
			songPosBar.cameras = [camHUD];

		if (loadRep)
			replayTxt.cameras = [camHUD];

		if(FlxG.save.data.botplay && !loadRep)
			botPlayState.cameras = [camHUD];
		
		startingSong = true;
		
		trace('starting');

		var duration = 0;
		
		if (executeModchart)
		{
			interpVariables(interp);
			
			if (interp.variables.get("onStart") != null)
				interp.variables.get("onStart")();

			if (interp.variables.get("cutsceneDuration") > 0)
				duration = interp.variables.get("cutsceneDuration");
		}

		new FlxTimer().start(duration, function(tmr:FlxTimer) 
		{
			if (isStoryMode)
			{
				// we soft-codin this bitch in
				#if FILESYSTEM
				if (FileSystem.exists(Paths.dialogueStartFile(curSong.replace(" ", "-").toLowerCase())))
				{
					inCutscene = true;
	
					// also, does opening substates need the parent state to update ATLEAST once?
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						startDialogue();
					});
				}
				#else
				if (Assets.exists("assets/data/" + StringTools.replace(curSong," ", "-").toLowerCase() + '/dialogueStart.txt'))
				{
					inCutscene = true;
	
					// also, does opening substates need the parent state to update ATLEAST once?
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						startDialogue();
					});
				}
				#end
				else
					startCountdown();
			}
			else
				startCountdown();
		});

		if (!loadRep)
			rep = new Replay("na");

		super.create();
	}

	// TO DO: REMAKE THIS FOR FULL "ENGINE" RELEASE
	/*
	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		// pre lowercasing the song name (schoolIntro)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
			}
		if (songLowercase == 'roses' || songLowercase == 'thorns')
		{
			remove(black);

			if (songLowercase == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (songLowercase == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}*/

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	var pfBG1:FlxSprite;
	var pfBG2:FlxSprite;

	function startDialogue():Void
	{
		#if FILESYSTEM
		if (FileSystem.exists(Paths.dialogueStartFile(curSong.replace(" ", "-").toLowerCase())))
		{
			if (SONG.noteStyle == "pixel")
				openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(File.getContent(Paths.dialogueStartFile(curSong.replace(" ", "-").toLowerCase()))), (SONG.song.toLowerCase() == "thorns" ? DialogueStyle.PIXEL_SPIRIT : DialogueStyle.PIXEL_NORMAL), startCountdown));
			else
				openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(File.getContent(Paths.dialogueStartFile(curSong.replace(" ", "-").toLowerCase()))), DialogueStyle.NORMAL, startCountdown));
		}
		#else
		if (Assets.exists("assets/data/" + StringTools.replace(curSong," ", "-").toLowerCase() + '/dialogueStart.txt'))
		{
			if (SONG.noteStyle == "pixel")
				openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(Assets.getText('assets/data/' + StringTools.replace(SONG.song," ", "-").toLowerCase() + '/dialogueStart.txt')), (SONG.song.toLowerCase() == "thorns" ? DialogueStyle.PIXEL_SPIRIT : DialogueStyle.PIXEL_NORMAL), startCountdown));
			else
				openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(Assets.getText('assets/data/' + StringTools.replace(SONG.song," ", "-").toLowerCase() + '/dialogueStart.txt')), DialogueStyle.NORMAL, startCountdown));
		}
		#end
	}

	var stupidFuckingCamera:FlxCamera;

	function startCountdown():Void
	{
		inCutscene = false;

		var theSex:FlxAtlasFrames = Paths.getSparrowAtlas('NOTE_assets');
		#if FILESYSTEM
		if (FlxG.save.data.currentNoteSkin != "default")
			theSex = FlxAtlasFrames.fromSparrow(NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin), File.getContent(Sys.getCwd() + "assets/skins/" + FlxG.save.data.currentNoteSkin + "/normal/NOTE_assets.xml"));
		#end

		generateStaticArrows(0, theSex);
		generateStaticArrows(1, theSex);

		if (executeModchart)
		{
			if (interp.variables.get("onStartCountdown") != null)
				interp.variables.get("onStartCountdown")();
		}

		if (FlxG.save.data.pfBGTransparency > 0)
		{
			pfBG1 = new FlxSprite(playerStrums.x - 10, -10).makeGraphic(Std.int(playerStrums.width + 20), Std.int(FlxG.height + 20), 0xFF000000);
			pfBG2 = new FlxSprite(cpuStrums.x - 10, -10).makeGraphic(Std.int(cpuStrums.width + 20), Std.int(FlxG.height + 20), 0xFF000000);

			pfBG1.alpha = FlxG.save.data.pfBGTransparency / 100;
			pfBG2.alpha = FlxG.save.data.pfBGTransparency / 100;

			pfBG1.scrollFactor.set();
			pfBG2.scrollFactor.set();

			pfBackgrounds.add(pfBG1);
			pfBackgrounds.add(pfBG2);

			pfBG1.cameras = [camHUD];
			pfBG2.cameras = [camHUD];
		}

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			if (!songRecording)
				countdownThing(swagCounter, true);
			
			swagCounter += 1;
		}, 4);

		stupidFuckingCamera = new FlxCamera();
		
		if (songRecording)
		{
			stupidFuckingCamera.bgColor = 0xcc000000;
			FlxG.cameras.add(stupidFuckingCamera);
			camHUD.visible = false;
			camGame.setFilters([new BlurFilter()]);
			daLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('YEAHHH WE FUNKIN'));
			daLogo.scale.set(0.75, 0.75);
			daLogo.updateHitbox();
			daLogo.screenCenter();
			daLogo.scrollFactor.set();
			daLogo.antialiasing = true;
			daLogo.cameras = [stupidFuckingCamera];
			add(daLogo);
		}
	}

	public function countdownThing(thing:Int, ?songCountdown:Bool = false):Void
	{
		var altSuffix:String = "";
		var pixel1:String = "";

		if (SONG.noteStyle == "pixel")
		{
			pixel1 = "pixelUI/";
			altSuffix = "-pixel";
		}

		var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixel1 + "ready" + altSuffix));
		var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixel1 + "set" + altSuffix));
		var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixel1 + "go" + altSuffix));

		ready.cameras = [camHUD];
		set.cameras = [camHUD];
		go.cameras = [camHUD];

		if (executeModchart && songCountdown)
		{
			if (interp.variables.get("onCountdownTick") != null)
				interp.variables.get("onCountdownTick")(thing);
		}

		switch (thing)
		{
			case 0:
				FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
			case 1:
				if (SONG.noteStyle == "pixel")
					ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

				ready.updateHitbox();
				ready.screenCenter();
				add(ready);

				FlxTween.tween(ready, {y: ready.y + 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						ready.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
			case 2:
				if (SONG.noteStyle == "pixel")
					set.setGraphicSize(Std.int(set.width * daPixelZoom));

				set.updateHitbox();
				set.screenCenter();
				add(set);
				
				FlxTween.tween(set, {y: set.y + 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						set.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
			case 3:
				if (SONG.noteStyle == "pixel")
					go.setGraphicSize(Std.int(go.width * daPixelZoom));

				go.updateHitbox();
				go.screenCenter();
				add(go);
				
				FlxTween.tween(go, {y: go.y + 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						go.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			case 4:
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		if (songRecording)
			{
				FlxG.sound.music.onComplete = function()
				{
					canPause = false;
					FlxG.sound.music.volume = 0;
					vocals.volume = 0;
					FlxTween.tween(daLogo, {alpha: 0}, 1);
					FlxG.cameras.fade();
					new FlxTimer().start(5, function(tmr:FlxTimer)
					{
						endSong();
					});
				}
			}
		else
			FlxG.sound.music.onComplete = endSong;

		#if FILESYSTEM
		if (FileSystem.exists(Paths.dialogueEndFile(curSong.replace(" ", "-").toLowerCase())) && isStoryMode)
			FlxG.sound.music.onComplete = function() {
				inCutscene = true;

				FlxG.sound.music.volume = 0;
				vocals.volume = 0;
				
				if (SONG.noteStyle == "pixel")
					openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(File.getContent(Paths.dialogueEndFile(curSong.replace(" ", "-").toLowerCase()))), (SONG.song.toLowerCase() == "thorns" ? DialogueStyle.PIXEL_SPIRIT : DialogueStyle.PIXEL_NORMAL), endSong));
				else
					openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(File.getContent(Paths.dialogueEndFile(curSong.replace(" ", "-").toLowerCase()))), DialogueStyle.NORMAL, endSong));
			};
		#else
		if (Assets.exists("assets/data/" + StringTools.replace(curSong," ", "-").toLowerCase() + '/dialogueEnd.txt') && isStoryMode)
			FlxG.sound.music.onComplete = function() {
				inCutscene = true;

				FlxG.sound.music.volume = 0;
				vocals.volume = 0;
				
				if (SONG.noteStyle == "pixel")
					openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(Assets.getText('assets/data/' + StringTools.replace(SONG.song," ", "-").toLowerCase() + '/dialogueEnd.txt')), (SONG.song.toLowerCase() == "thorns" ? DialogueStyle.PIXEL_SPIRIT : DialogueStyle.PIXEL_NORMAL), endSong));
				else
					openSubState(new DialogueSubstate(CoolUtil.awesomeDialogueFile(Assets.getText('assets/data/' + StringTools.replace(SONG.song," ", "-").toLowerCase() + '/dialogueEnd.txt')), DialogueStyle.NORMAL, endSong));
			};
		#end

		vocals.play();

		if (executeModchart)
		{
			if (interp.variables.get("onSongStart") != null)
				interp.variables.get("onSongStart")();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite();
			add(songPosBG);

			songPosBar = new FlxBar(0, 20, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.45), 12, this, 'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.WHITE);
			songPosBar.screenCenter(X);
			if (FlxG.save.data.downscroll)
				songPosBar.y = FlxG.height - songPosBar.height - 20; 
			add(songPosBar);

			songPosBG.makeGraphic(Std.int(songPosBar.width + 8), Std.int(songPosBar.height + 8), 0xFF000000);
			songPosBG.setPosition(songPosBar.x - 4, songPosBar.y - 4);
			songPosBG.alpha = 0.7;

			songName = new FlxText(0, 0, FlxG.width, SONG.song.toUpperCase(), 16);
			songName.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.y = songPosBar.y + (songPosBar.height / 2) - (songName.height / 2);
			songName.scrollFactor.set();
			songName.borderSize = 4;
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		
		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ");
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		// so that sustains will always be below notes
		displaySustains = new FlxTypedGroup<Note>();
		add(displaySustains);

		displayNotes = new FlxTypedGroup<Note>();
		add(displayNotes);

		notes = new FlxTypedGroup<Note>();
		// add(notes);

		var noteData:Array<SwagSection>;
		noteData = songData.notes;

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		
		// Per song offset check
		#if FILESYSTEM
		var songPath = 'assets/data/' + songLowercase + '/.offset';

		if (Paths.currentMod != null)
			songPath = Sys.getCwd() + "mods/" + Paths.currentMod + "/" + songPath;

		if(FileSystem.exists(songPath))
		{
			trace('Found offset file: ' + songPath);
			trace('Fetched offset: ' + File.getContent(songPath));
			songOffset = Std.parseFloat(File.getContent(songPath));
		}
		else 
		{
			trace('Offset file not found. Creating one @: ' + songPath);
			File.saveContent(songPath, '0');
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var theSex:FlxAtlasFrames = Paths.getSparrowAtlas('NOTE_assets');
		
		#if FILESYSTEM
		if (FlxG.save.data.currentNoteSkin != "default")
			theSex = FlxAtlasFrames.fromSparrow(NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin), File.getContent(Sys.getCwd() + "assets/skins/" + FlxG.save.data.currentNoteSkin + "/normal/NOTE_assets.xml"));
		#end

		var noteTypesDetected:Array<String> = [];

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, songNotes[3], theSex);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				swagNote.sectionNumber = daBeats;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (!swagNote.noHolds)
				{
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
	
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Math.abs(Conductor.stepCrochet / FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)), daNoteData, oldNote, true, songNotes[3], theSex);
						sustainNote.strumTimeSus = daStrumTime + (Conductor.stepCrochet * susNote);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
	
						sustainNote.sectionNumber = daBeats;
						sustainNote.mustPress = gottaHitNote;	
	
						if (sustainNote.mustPress)
							sustainNote.x += FlxG.width / 2; // general offset
						else
							sustainNote.wasEnemyNote = true;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
				else
					swagNote.wasEnemyNote = true;

				if (!noteTypesDetected.contains(songNotes[3]) && (songNotes[3] != "hopeEngine/normal" && songNotes[3] != null))
					noteTypesDetected.push(songNotes[3]);
			}

			if (section.sectionNotes.length > 200) // this prolly applies for both sides but whatever frame drops still happen anyway :/
			{
				warningSections.push(section.sectionNotes.length);
				trace("HOLY FUCK THATS A LOT " + section.sectionNotes.length);
			}

			repNotes.push([]);
			repSustains.push([]);
			
			daBeats += 1;
		}
		
		for (noteType in noteTypesDetected)
		{
			var a = noteType.split("/");
			
			#if FILESYSTEM
			var noteHENT = File.getContent(Sys.getCwd() + Paths.noteHENT(a[1], a[0]));
			#else
			var noteHENT = Assets.getText(Paths.noteHENT(a[1], a[0]));
			#end

			if (noteHENT.contains("FlxG.save.data.flashing") && !warningText.text.contains("\nFlashing lights"))
			{
				warningText.visible = true;
				warningText.text += "\nFlashing lights";
				warningText.x = 5;
				warningText.y = FlxG.height - warningText.height - 5;
			}

			if (noteHENT.contains("shake") && !warningText.text.contains("\nShaking"))
			{
				warningText.visible = true;
				warningText.text += "\nShaking";
				warningText.x = 5;
				warningText.y = FlxG.height - warningText.height - 5;
			}

			if (noteHENT.contains("FlxG.save.data") && !warningText.text.contains("\nChanging Options"))
			{
				warningText.visible = true;
				warningText.text += "\nChanging Options";
				warningText.x = 5;
				warningText.y = FlxG.height - warningText.height - 5;
			}

			var daInterp = new Interp();
			var daAst = parser.parseString(noteHENT);
			interpVariables(daInterp);
			daInterp.execute(daAst);

			loadedNoteTypeInterps.set(noteType, daInterp);
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}
	

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, ?skin:FlxAtlasFrames, ?inverted:Bool = false):Void
	{
		for (i in 0...4)
		{

			var babyArrow:StaticArrow = new StaticArrow(0, strumLine.y, SONG.noteStyle == 'pixel');

			switch (SONG.noteStyle)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

					#if FILESYSTEM
					if (FlxG.save.data.currentNoteSkin != "default" && 
						NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin + "-pixel") != null)
					{
						babyArrow.loadGraphic(NoteSkinSelection.loadedNoteSkins.get(FlxG.save.data.currentNoteSkin + "-pixel"), true, 17, 17);
					}
					#end

					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
				
				case 'normal':
					if (skin == null)
						babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets'); 
					else
						babyArrow.frames = skin;
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
	
					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
	
					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}

				default:
					if (skin == null)
						babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets'); 
					else
						babyArrow.frames = skin;
					
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			// What's with the "-1"? I have no fucking idea. Offset's shitting.
			if (FlxG.save.data.downscroll)
				babyArrow.y -= babyArrow.height - 1;

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}
		
			babyArrow.y -= 10;
			babyArrow.alpha = 0;

			var wantedAlpha:Float = 1;
			
			if (FlxG.save.data.middleScroll && player == 0)
				wantedAlpha = 0.1;
			
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: wantedAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.2 + (0.2 * i)});
			

			babyArrow.playAnim('static');
			babyArrow.staticWidth = babyArrow.width;
			babyArrow.staticHeight = babyArrow.height;

			if (inverted)
			{
				cpuStrums.x = FlxG.width - cpuStrums.width - FlxG.save.data.strumlineMargin;
				playerStrums.x = FlxG.save.data.strumlineMargin;
			}
			else
			{
				playerStrums.x = FlxG.width - cpuStrums.width - FlxG.save.data.strumlineMargin;
				cpuStrums.x = FlxG.save.data.strumlineMargin;
			}

			if (FlxG.save.data.middleScroll)
			{
				cpuStrums.screenCenter(X);
				playerStrums.screenCenter(X);
			}
			
			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			playerStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets();
			});
			
			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("Paused on " + SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ");
			#end
			
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
				DiscordClient.changePresence(SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ", null, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ");
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ");
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	var bfAnimationBullshit:Array<Bool> = [];

	var originalNoteSpeed:Float = SONG.speed;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (executeModchart && songStarted)
			interpVariables(interp);

		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (FlxG.save.data.scrollSpeed == 1 && FlxG.save.data.botplay)
		{
			scrollSpeedText.text = HelperFunctions.truncateFloat(SONG.speed, 2)+ "";
			scrollSpeedText.x = FlxG.width - scrollSpeedText.width - 5;
			scrollSpeedText.y = FlxG.height - scrollSpeedText.height - 5;

			if (FlxG.keys.justPressed.Q)
				SONG.speed -= 1;

			if (FlxG.keys.justPressed.E)
				SONG.speed += 1;

			if (FlxG.keys.justPressed.A)
				SONG.speed -= 0.1;

			if (FlxG.keys.justPressed.D)
				SONG.speed += 0.1;

			if (FlxG.keys.pressed.Z)
				SONG.speed -= 0.01;

			if (FlxG.keys.pressed.C)
				SONG.speed += 0.01;

			if (FlxG.keys.pressed.V)
				SONG.speed = originalNoteSpeed; // reset to original

			if (FlxG.keys.pressed.F)
				SONG.speed = 0; // set to zero
		}

		if (FlxG.keys.justPressed.SPACE && !inCutscene) 
		{
			FlxG.sound.play(Paths.sound('hey'));
			boyfriend.playAnim('hey', true);
		}

		if (FlxG.save.data.fancyHealthBar)
		{
			if (bfSide.scale.x > 1 || bfSide.scale.y > 1)
				{
					bfSide.scale.x -= elapsed / (FlxG.save.data.fpsCap / 120);
					bfSide.scale.y -= elapsed / (FlxG.save.data.fpsCap / 120);
					bfSide.y = healthBarBG.y - (32 * bfSide.scale.y);
					bfSide.updateHitbox();
					bfSide.screenCenter(X);
				}
	
			if (enemySide.scale.x > 1 || enemySide.scale.y > 1)
				{
					enemySide.scale.x -= elapsed / (FlxG.save.data.fpsCap / 120);
					enemySide.scale.y -= elapsed / (FlxG.save.data.fpsCap / 120);
					enemySide.y = healthBarBG.y - (32 * enemySide.scale.y);
					enemySide.updateHitbox();
					enemySide.screenCenter(X);
				}
		}

		if (FlxG.save.data.pfBGTransparency > 0 && startedCountdown)
		{
			pfBG1.x = playerStrums.x - 10;
			pfBG2.x = cpuStrums.x - 10;

			pfBG1.setGraphicSize(Std.int(playerStrums.width + 20), Std.int(pfBG1.height));

			if (!FlxG.save.data.middleScroll)
				pfBG2.setGraphicSize(Std.int(cpuStrums.width + 20), Std.int(pfBG2.height));
		}

		if (boyfriend != null)
		{
			bfAnimationBullshit = [
				boyfriend.animation.curAnim.name.startsWith("hey"),
				boyfriend.animation.curAnim.name.startsWith("hit"),
				boyfriend.animation.curAnim.name.startsWith("dodge"),
			];
		}

		if (bfAnimationBullshit.contains(true) && boyfriend.animation.curAnim.finished)
			boyfriend.dance();

		if (executeModchart)
		{
			if (interp.variables.get("onUpdate") != null)
				interp.variables.get("onUpdate")(elapsed);
		}

		
		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ") - " : "") + "Score: " + songScore + " - Misses: " + misses + " - Accuracy: " + HelperFunctions.truncateFloat(accuracy, 2) + "%";
		else
			scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ") - " : "") + Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause && songStarted && !inCutscene)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState());
		}
		
		if (FlxG.keys.justPressed.SEVEN)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, 10 / Application.current.window.frameRate)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, 10 / Application.current.window.frameRate)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;


		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));

		if (FlxG.keys.justPressed.ZERO)
		{
			if (FlxG.keys.pressed.SHIFT)
				FlxG.switchState(new AnimationDebug(SONG.player1));
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if(allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch(curSong)
					{
						case 'Philly Nice':
						{
							// General duration of the song
							if(curBeat < 250)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 184 && curBeat != 216)
								{
									if(curBeat % 16 == 8)
									{
										// Just a garantee that it'll trigger just once
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else 
										triggeredAlready = false;
								}
							}
						}
						case 'Bopeebo':
						{
							// Where it starts || where it ends
							if(curBeat > 5 && curBeat < 130)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
						case 'Blammed':
						{
							if(curBeat > 30 && curBeat < 190)
							{
								if(curBeat < 90 || curBeat > 128)
								{
									if(curBeat % 4 == 2)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Cocoa':
						{
							if(curBeat < 170)
							{
								if(curBeat < 65 || curBeat > 130 && curBeat < 145)
								{
									if(curBeat % 16 == 15)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Eggnog':
						{
							if(curBeat > 10 && curBeat != 111 && curBeat < 220)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
					}
				}
			}

			if (camFollow.x != dad.getMidpoint().x + 150 + dad.cameraOffset[0] && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !inCutscene)
			{
				var offsetX = dad.cameraOffset[0];
				var offsetY = dad.cameraOffset[1];
				
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);

				whosFocused = dad;
			}

			if (camFollow.x != boyfriend.getMidpoint().x - 100 + boyfriend.cameraOffset[0] && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !inCutscene)
			{
				var offsetX = boyfriend.cameraOffset[0];
				var offsetY = boyfriend.cameraOffset[1];

				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				whosFocused = boyfriend;
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick("sectionShit", Std.int(curStep / 16));

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Dead on " + SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ");
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.pressed.R && FlxG.save.data.resetButton)
			health = 0;

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500 / Math.abs(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed))
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				if (dunceNote.isSustainNote)
					displaySustains.add(dunceNote);
				else
					displayNotes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var noteY = (daNote.mustPress ? playerStrums.members[daNote.noteData].y : strumLineNotes.members[daNote.noteData].y);
				
				if (FlxG.save.data.downscroll)
				{
					if (daNote.positionLockY)
						daNote.y = (noteY + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));

					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null && daNote.positionLockY)
							daNote.y = (noteY + (SONG.noteStyle == 'pixel' ? 0 : 1.5) + (Conductor.songPosition - daNote.prevNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2))) - daNote.height;

						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (noteY - Note.swagWidth / 2))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (noteY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					if (daNote.positionLockY)
						daNote.y = (noteY - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));
					
					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null && daNote.positionLockY)
							daNote.y = (noteY - (SONG.noteStyle == 'pixel' ? 0 : 1.5) - (Conductor.songPosition - daNote.prevNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2))) + daNote.prevNote.height;

						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (noteY + Note.swagWidth / 2))
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (noteY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}

				}

				// botplay code
				if (daNote.mustPress && FlxG.save.data.botplay)
				{
					if (daNote.canBeHit)
					{
						if (daNote.strumTime <= Conductor.songPosition && !daNote.canMiss)
							goodNoteHit(daNote);
					}
				}

				if (!daNote.mustPress && !daNote.wasGoodHit && daNote.strumTime <= Conductor.songPosition)
				{
					camZooming = true;

					var altAnim:Bool = false;

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = true;
					}

					if (FlxG.save.data.fancyHealthBar)
					{
						enemySide.scale.set(1.125, 1.125);
						enemySide.updateHitbox();
					}

					if (!daNote.wasEnemyNote)
						sing(boyfriend, daNote.noteData, altAnim);
					else
						sing(dad, daNote.noteData, altAnim);

					lightStrumNote(cpuStrums, daNote.noteData);

					if (executeModchart)
					{
						if (interp.variables.get("dadSing") != null)
							interp.variables.get("dadSing")(daNote);
					}

					if (daNote.noteType != "hopeEngine/normal")
					{
						if (loadedNoteTypeInterps.exists(daNote.noteType))
						{
							if (loadedNoteTypeInterps.get(daNote.noteType).variables.get("dadNoteHit") != null)
								loadedNoteTypeInterps.get(daNote.noteType).variables.get("dadNoteHit")(daNote);
						}
					}

					daNote.wasGoodHit = true;

					if (SONG.needsVoices)
						vocals.volume = 1;

					// vocals.fadeOut((Conductor.stepCrochet / 1000) * 2, 1, function(_){vocals.volume = 0;});

					daNote.active = false;

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if (daNote.mustPress && !daNote.wasGoodHit)
				{
					if (daNote.visibleLock)
						daNote.visible = playerStrums.members[daNote.noteData].visible;

					if (daNote.positionLockX)
						daNote.x = playerStrums.members[daNote.noteData].x;
					
					if (!daNote.isSustainNote)
					{
						if (daNote.angleLock)
						{
							if (!daNote.upSpriteOnly)
								daNote.angle = playerStrums.members[daNote.noteData].angle;
							else
								daNote.angle = Note.noteAngles[daNote.noteData] + playerStrums.members[daNote.noteData].angle;
						}

						if (daNote.alphaLock)
							daNote.alpha = playerStrums.members[daNote.noteData].alpha;
					}
					else
					{
						if (daNote.alphaLock)
							daNote.alpha = 0.6 * playerStrums.members[daNote.noteData].alpha;
					}
				}
				else if (!daNote.wasGoodHit)
				{
					if (daNote.visibleLock)
						daNote.visible = strumLineNotes.members[daNote.noteData].visible;

					if (daNote.positionLockX)
						daNote.x = strumLineNotes.members[daNote.noteData].x;

					if (!daNote.isSustainNote)
					{
						if (daNote.angleLock)
						{
							if (!daNote.upSpriteOnly)
								daNote.angle = strumLineNotes.members[daNote.noteData].angle;
							else
								daNote.angle = Note.noteAngles[daNote.noteData] + strumLineNotes.members[daNote.noteData].angle;
						}

						if (daNote.alphaLock)
							daNote.alpha = strumLineNotes.members[daNote.noteData].alpha;
					}
					else
					{
						if (daNote.alphaLock)
							daNote.alpha = 0.6 * strumLineNotes.members[daNote.noteData].alpha;
					}
				}

				// put the sustains in the middle so that it looks cool

				if (daNote.mustPress && daNote.isSustainNote && daNote.positionLockX)
					daNote.x = playerStrums.members[daNote.noteData].x + (playerStrums.members[daNote.noteData].staticWidth / 2) - (daNote.width / 2);
				else if (!daNote.mustPress && daNote.isSustainNote && daNote.positionLockX)
					daNote.x = cpuStrums.members[daNote.noteData].x + (cpuStrums.members[daNote.noteData].staticWidth / 2) - (daNote.width / 2);
				

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.mustPress && daNote.tooLate && !daNote.wasGoodHit && daNote.rating != "miss")
				{
					if (!daNote.canMiss)
					{
						health -= 0.075;
						vocals.volume = 0;
						noteMiss(daNote.noteData, daNote);
					}
					
					if (daNote.noteType != "hopeEngine/normal")
					{
						if (loadedNoteTypeInterps.exists(daNote.noteType))
						{
							if (loadedNoteTypeInterps.get(daNote.noteType).variables.get("onNoteMiss") != null)
								loadedNoteTypeInterps.get(daNote.noteType).variables.get("onNoteMiss")(daNote);
						}
					}

					daNote.rating = "miss";
				}

				if ((daNote.tooLate && !daNote.wasGoodHit) || (daNote.isSustainNote && daNote.wasGoodHit))
				{
					if (!FlxG.save.data.downscroll)
					{
						if (daNote.y + daNote.frameHeight + 10 < 0)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}
					else
					{
						if (daNote.y - 10 > FlxG.height)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}
				}
			});
		}

		

		if (!inCutscene)
			keyShit();

		cpuStrums.forEach(function(spr:StaticArrow)
		{
			if (spr.animation.finished)
			{
				spr.playAnim('static');
				spr.centerOffsets();
			}
		});


		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		if (!paused)
		{
			var waitTime = 0;
			if (!loadRep && !FlxG.save.data.botplay)
				rep.SaveReplay(repNotes, repSustains, repPresses);
	
			if (FlxG.save.data.fpsCap > 290)
				(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
	
			canPause = false;
			FlxG.sound.music.volume = 0;
			vocals.volume = 0;

			if (SONG.validScore)
			{
				var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");

				Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
				Highscore.saveRank(songHighscore, Std.parseInt(Ratings.GenerateLetterRank(accuracy, true)), storyDifficulty);
			}

			if (executeModchart)
			{
				if (interp.variables.get("onSongEnd") != null)
				{
					interp.variables.get("onSongEnd")();
					waitTime = 1;
				}
			}
	
			new FlxTimer().start(waitTime, function(tmr:FlxTimer) 
			{
				if (offsetTesting)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					Conductor.changeBPM(102);
					offsetTesting = false;
					LoadingState.loadAndSwitchState(new OptionsState());
					FlxG.save.data.offset = offsetTest;
				}
				else
				{
					if (isStoryMode)
					{
						campaignScore += Math.round(songScore);
		
						weekShits += shits;
						weekBads += bads;
						weekGoods += goods;
						weekSicks += sicks;
						weekMisses += misses;
						weekPeakCombo.push(peakCombo);
						weekAccuracies.push(HelperFunctions.truncateFloat(accuracy, 2));
		
						storyPlaylist.remove(storyPlaylist[0]);
		
						if (storyPlaylist.length <= 0)
						{
		
							transIn = FlxTransitionableState.defaultTransIn;
							transOut = FlxTransitionableState.defaultTransOut;
	
							originalPlaylistLength = -1;
		
							// FlxG.sound.playMusic(Paths.music('freakyMenu'));
							// FlxG.switchState(new StoryMenuState());
	
							if (!FlxG.save.data.skipResultsScreen)
							{
								boyfriend.stunned = true;
	
								persistentUpdate = false;
								// paused = true;
	
								vocals.stop();
								FlxG.sound.music.stop();
								openSubState(new ResultsScreen());
							}
							else
							{
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
								Conductor.changeBPM(102);
								FlxG.switchState(new StoryMenuState());
							}
		
							if (SONG.validScore)
								Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
	
							#if !UNLOCK_ALL_WEEKS
							FlxG.save.data.weeksUnlocked.push(true);
							#end
							
							FlxG.save.flush();
						}
						else
						{
							lastSongCamPos = new FlxPoint(camFollow.x, camFollow.y);
							var difficulty:String = "";
		
							difficulty = CoolUtil.difficultySuffix();
		
							trace('LOADING NEXT SONG');
							// pre lowercasing the next story song name
							var nextSongLowercase = StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase();
							trace(nextSongLowercase + difficulty);
		
							FlxTransitionableState.skipNextTransIn = true;
							FlxTransitionableState.skipNextTransOut = true;
							prevCamFollow = camFollow;
		
							PlayState.SONG = Song.loadFromJson(nextSongLowercase + difficulty, PlayState.storyPlaylist[0], (Paths.currentMod != null && Paths.currentMod.length > 0 ? "mods/" + Paths.currentMod : ""));
							FlxG.sound.music.stop();
		
							LoadingState.loadAndSwitchState(new PlayState());
						}
					}
					else
					{
						// FlxG.sound.playMusic(Paths.music('freakyMenu'));
						// FlxG.switchState(new FreeplayState());
	
						if (!FlxG.save.data.skipResultsScreen)
						{
							boyfriend.stunned = true;
	
							persistentUpdate = false;
							// paused = true;
	
							vocals.stop();
							FlxG.sound.music.stop();
							openSubState(new ResultsScreen());
						}
						else
						{
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							Conductor.changeBPM(102);
							
							if (!loadRep)
								FlxG.switchState(new FreeplayState());
							else
								FlxG.switchState(new LoadReplayState());
						}
						
					}
				}
			});
		}
		
	}


	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;

	private function popUpScore(daNote:Note, ?repDiff:Float, ?comboBreak:Bool = false):Void
	{
		var noteDiff = (repDiff != null ? repDiff : (daNote.strumTime - Conductor.songPosition));
		var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
		vocals.volume = 1;
		
		var wasEarlyOrLate:Bool = false;

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		var comboSpr1:FlxSprite = null;
		var comboSpr2:FlxSprite = null;
		

		if (FlxG.save.data.accuracyMod == 1 && !daNote.isSustainNote)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		if (daRating == 'sick') // if it's only sick (because the other ones will only be late/early anyways)
		{
			if (noteDiff > Conductor.safeZoneOffset * 0.1 || noteDiff < Conductor.safeZoneOffset * -0.1)
				wasEarlyOrLate = true;
		}

		if (combo > peakCombo)
			peakCombo = combo;

		if (daNote.canScore)
		{
			switch(daRating)
			{
				case 'shit':
					score = -300;
					health -= 0.2;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					goods++;
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}
		}
		else
			score = 0;

		songScore += Math.round(score);
		songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (SONG.noteStyle == "pixel")
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var ratingImageName:String = daRating;

		// display "sick" with 1 exclamation point if it was an early sick
		// doesn't really affect score I just thought it would be funny
		if (daRating == 'sick' && wasEarlyOrLate)
			ratingImageName = 'sickButNotReally';

		if (FlxG.save.data.familyFriendly)
		{
			// shit displays "bad" and bad displays "okay"
			if (daRating == 'shit')
				ratingImageName = 'bad';
			else if (daRating == 'bad')
				ratingImageName = 'okay';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + ratingImageName + pixelShitPart2));
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.updateHitbox();


		rating.x = FlxG.width / 2 + 5;
		rating.y = boyfriend.y - rating.height - 50;
		
		var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
		if(FlxG.save.data.botplay) msTiming = 0;

		if (msTiming >= 0.03 && offsetTesting)
		{
			//Remove Outliers
			hits.shift();
			hits.shift();
			hits.shift();
			hits.pop();
			hits.pop();
			hits.pop();
			hits.push(msTiming);

			var total = 0.0;

			for(i in hits)
				total += i;
			
			offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = rating.x + 150;
		comboSpr.y = rating.y + 75;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		
		if (comboBreak)
		{
			comboSpr1 = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'comboBreak1' + pixelShitPart2));
			comboSpr1.screenCenter();
			comboSpr1.x = rating.x + 150;
			comboSpr1.y = rating.y + 75;
			comboSpr1.acceleration.y = 600;
			comboSpr1.angularAcceleration = FlxG.random.int(-100, -50);
			comboSpr1.velocity.y -= 150;

			comboSpr2 = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'comboBreak2' + pixelShitPart2));
			comboSpr2.screenCenter();
			comboSpr2.x = rating.x + 150;
			comboSpr2.y = rating.y + 75;
			comboSpr2.acceleration.y = 600;
			comboSpr2.angularAcceleration = FlxG.random.int(50, 100);
			comboSpr2.velocity.y -= 150;

			if (SONG.noteStyle != "pixel")
			{
				comboSpr1.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr1.antialiasing = true;

				comboSpr2.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr2.antialiasing = true;
			}
			else
			{
				comboSpr1.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
				comboSpr2.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			comboSpr1.updateHitbox();
			comboSpr2.updateHitbox();
		}

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboSpr.updateHitbox();
		
		add(rating);

		if (SONG.noteStyle != "pixel")
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		if (comboBreak)
		{
			add(comboSpr1);
			add(comboSpr2);
		}
		
		var count:Count = null;

		if (combo > 9 || comboBreak)
		{
			count = new Count(rating.x, rating.y + 100, Std.string(combo));
			add(count);
			count.disconnect();
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		if (comboBreak)
		{
			FlxTween.tween(comboSpr1, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					comboSpr1.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			FlxTween.tween(comboSpr2, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					comboSpr2.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
		}
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	var currentPressRecords:Array<Array<Null<Float>>> = [
		[null, null, null], 
		[null, null, null], 
		[null, null, null], 
		[null, null, null]
	];

	private function keyShit():Void // I've invested in emma stocks
		{
			// control arrays, order L D U R
			var holdArray:Array<Bool> = [
				controls.LEFT, 
				controls.DOWN, 
				controls.UP, 
				controls.RIGHT
			];
			var pressArray:Array<Bool> = [
				controls.LEFT_P,
				controls.DOWN_P,
				controls.UP_P,
				controls.RIGHT_P
			];
			var releaseArray:Array<Bool> = [
				controls.LEFT_R,
				controls.DOWN_R,
				controls.UP_R,
				controls.RIGHT_R
			];
		
			// Prevent player input if botplay is on
			if (FlxG.save.data.botplay || loadRep)
			{
				holdArray = [false, false, false, false];
				pressArray = [false, false, false, false];
				releaseArray = [false, false, false, false];
			}

			// record presses
			if (!loadRep)
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					{
						currentPressRecords[spr.ID][0] = Conductor.songPosition;
					}

					if (releaseArray[spr.ID] && currentPressRecords[spr.ID][0] != null && spr.animation.curAnim.name != 'confirm')
					{
						currentPressRecords[spr.ID][1] = Conductor.songPosition;
						currentPressRecords[spr.ID][2] = spr.ID;
						repPresses.push(currentPressRecords[spr.ID]);
						currentPressRecords[spr.ID] = [null, null, null];
					}
				});
			}
			
			// HOLDS, check for sustain notes
			if (holdArray.contains(true) && !boyfriend.stunned && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
						goodNoteHit(daNote);
				});
			}
		
			// PRESSES, check for note hits
			if (pressArray.contains(true) && !boyfriend.stunned && generatedMusic)
			{
				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false,false,false,false]; // we don't want to do judgments for more than one presses
				
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						if (!directionsAccounted[daNote.noteData])
						{
							if (directionList.contains(daNote.noteData))
							{
								directionsAccounted[daNote.noteData] = true;
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					}
				});
		
				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
		
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		
				var dontCheck = false;

				for (i in 0...pressArray.length)
				{
					if (pressArray[i] && !directionList.contains(i))
						dontCheck = true;
				}

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0 && !dontCheck)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}

					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							scoreTxt.color = FlxColor.WHITE;
							goodNoteHit(coolNote);
						}
					}
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}

				if (dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay)
				{
					if (mashViolations > 8)
					{
						trace('mash violations ' + mashViolations);
						scoreTxt.color = FlxColor.RED;
						noteMiss(0,null);
					}
					else
						mashViolations++;
				}

			}
			
			notes.forEachAlive(function(daNote:Note)
			{
				// very frame-droppy? part of this shit

				// replay code
				if (loadRep)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.strumTime <= Conductor.songPosition)
					{
						// [strumTime, noteDiff, noteData]
						for (note in rep.replay.notes[daNote.sectionNumber])
						{
							if (daNote.noteData == note[2] && HelperFunctions.truncateFloat(daNote.strumTime, 5) == HelperFunctions.truncateFloat(note[0], 5))
							{
								goodNoteHit(daNote, true, note[1]);
								rep.replay.notes[daNote.sectionNumber].remove([note[0], note[1], note[2]]);
								break;
							}
						}
					}

					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						// [strumTime, noteData]
						for (sus in rep.replay.sustains[daNote.sectionNumber])
						{
							if (daNote.noteData == sus[1] && HelperFunctions.truncateFloat(daNote.strumTime, 5) == HelperFunctions.truncateFloat(sus[0], 5))
							{
								goodNoteHit(daNote);
								// rep.replay.sustains[daNote.sectionNumber].remove([sus[0], sus[1]]);
								break;
							}
						}
					}
				}
			});

			// replay presses
			if (loadRep)
			{
				for (pressTimes in rep.replay.presses)
				{
					if (Conductor.songPosition > pressTimes[0] && Conductor.songPosition < pressTimes[1] && 
						playerStrums.members[Std.int(pressTimes[2])].animation.curAnim.name != 'pressed') 
					{
						playerStrums.members[Std.int(pressTimes[2])].animation.play('pressed');

						if (!rep.replay.properties.get("ghost_tapping"))
							noteMiss(Std.int(pressTimes[2]), null);
					}
					else if (Conductor.songPosition > pressTimes[1] &&
						playerStrums.members[Std.int(pressTimes[2])].animation.curAnim.name == 'pressed')
					{
						playerStrums.members[Std.int(pressTimes[2])].playAnim('static');
						rep.replay.presses.remove(pressTimes);
					}
				}
			}
			
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botplay))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.playAnim('idle');
			}
		
			playerStrums.forEach(function(spr:StaticArrow)
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.playAnim('pressed');
				
				if (!holdArray[spr.ID] && !FlxG.save.data.botplay && !loadRep)
					spr.playAnim('static');

				if (spr.animation.finished && FlxG.save.data.botplay && !loadRep)
					spr.playAnim('static');

				if (loadRep && spr.animation.finished && spr.animation.curAnim.name == 'confirm')
					spr.playAnim('static');
			});
		}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');

			var brokenCombo = (combo > 0 ? true : false);
			
			combo = 0;
			misses++;
			
			if (daNote != null)
				popUpScore(daNote, null, brokenCombo);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), 0.4);

			if (daNote != null)
			{
				if (daNote.wasEnemyNote)
					miss(dad, direction);
				else
					miss(boyfriend, direction);
			}
			else
				miss(boyfriend, direction);

			updateAccuracy();
		}
	}
	
	function updateAccuracy() 
	{
		totalPlayed += 1;
		accuracy = Math.max(0.00, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0.00, totalNotesHitDefault / totalPlayed * 100);
	}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff = (note.strumTime - Conductor.songPosition);
		note.rating = Ratings.CalculateRating(noteDiff);
		
		if (controlArray[note.noteData])
			goodNoteHit(note, (mashing > getKeyPresses(note)));
	}

	function goodNoteHit(note:Note, resetMashViolation = true, ?repDiff:Float):Void
	{
		if (mashing != 0)
			mashing = 0;

		var altAnim:Bool = false;

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].altAnim)
				altAnim = true;
		}

		var noteDiff = (repDiff != null ? repDiff : (note.strumTime - Conductor.songPosition));
		note.rating = Ratings.CalculateRating(noteDiff);

		var splash:NoteSplash = null;

		if (note.rating == "sick" && FlxG.save.data.noteSplashes && !note.isSustainNote)
		{
			splash = new NoteSplash(note.noteData, noteSplashAtlas);
			var strumNote = playerStrums.members[note.noteData];

			if (SONG.noteStyle != "pixel")
				splash.antialiasing = true;

			splash.x =  strumNote.x + (strumNote.staticWidth / 2) - (splash.width / 2);
			splash.y =  strumNote.y + (strumNote.staticHeight / 2) - (splash.height / 2);

			add(splash);
			splash.cameras = [camHUD];
		}

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (note.noteType != "hopeEngine/normal")
			{
				if (loadedNoteTypeInterps.exists(note.noteType))
				{
					if (loadedNoteTypeInterps.get(note.noteType).variables.get("onNoteHit") != null)
						loadedNoteTypeInterps.get(note.noteType).variables.get("onNoteHit")(note, splash);
				}
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note, repDiff);
			}
			else
			{
				totalNotesHit += 1;
				health += 0.023;
			}

			if (FlxG.save.data.fancyHealthBar)
			{
				bfSide.scale.set(1.125, 1.125);
				bfSide.updateHitbox();
			}

			if (note.wasEnemyNote)
				sing(dad, note.noteData, altAnim);
			else
				sing(boyfriend, note.noteData, altAnim);
			
			lightStrumNote(playerStrums, note.noteData);

			if (executeModchart)
			{
				if (interp.variables.get("bfSing") != null)
					interp.variables.get("bfSing")(note);
			}
			
			note.wasGoodHit = true;

			if (SONG.needsVoices)
				vocals.volume = 1;

			// vocals.fadeOut((Conductor.stepCrochet / 1000) * 2, 1, function(_){vocals.volume = 0;});

			if (!note.isSustainNote)
			{
				if (!loadRep)
					repNotes[note.sectionNumber].push([note.strumTime, noteDiff, note.noteData]);

				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				if (!loadRep)
					repSustains[note.sectionNumber].push([note.strumTime, note.noteData]);
			}
			
			updateAccuracy();
		}
	}
	
	var DIRECTIONS:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
	
	function sing(character:Character, direction:Int, ?isAlt:Bool = false)
	{
		var canAlt = character.animation.getByName('sing' + DIRECTIONS[direction] + "-alt") != null;
		var alt:String = (isAlt && canAlt ? "-alt" : "");
		
		character.holdTimer = 0;
		character.playAnim('sing' + DIRECTIONS[direction] + alt, true);
	}

	function miss(character:Character, direction:Int)
	{
		var canMiss = character.animation.getByName('sing' + DIRECTIONS[direction] + "miss") != null;
		
		if (canMiss)
			character.playAnim('sing' + DIRECTIONS[direction] + 'miss', true);
	}

	function lightStrumNote(strum:FlxTypedSpriteGroup<StaticArrow>, dir:Int)
	{
		strum.forEach(function(spr:StaticArrow)
		{
			if (dir == spr.ID)
			{
				spr.playAnim('confirm', true);
			}
		});
	}

	// TO DO: Dump this somewhere else :)
	function interpVariables(funnyInterp:Interp):Void
	{
		// imports
		funnyInterp.variables.set("FlxTypedGroup", FlxTypedGroup);
		funnyInterp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		funnyInterp.variables.set("FlxSprite", FlxSprite);
		funnyInterp.variables.set("Character", Character);
		funnyInterp.variables.set("FlxRandom", FlxRandom);
		funnyInterp.variables.set("FlxTween", FlxTween);
		funnyInterp.variables.set("FlxTimer", FlxTimer);
		funnyInterp.variables.set("FlxMath", FlxMath);
		funnyInterp.variables.set("FlxEase", FlxEase);
		funnyInterp.variables.set("FlxText", FlxText);
		funnyInterp.variables.set("Ratings", Ratings);
		funnyInterp.variables.set("Paths", Paths);
		funnyInterp.variables.set("Math", Math);
		funnyInterp.variables.set("FlxG", FlxG);
		funnyInterp.variables.set("Std", Std);
		
		// state funcs
		funnyInterp.variables.set("add", add);
		funnyInterp.variables.set("remove", remove);
		
		// characters
		funnyInterp.variables.set("boyfriend", boyfriend);
		funnyInterp.variables.set("dad", dad);
		funnyInterp.variables.set("gf", gf);

		// other shit
		funnyInterp.variables.set("MCFuncs", ModchartFunctions);

		// note shit
		funnyInterp.variables.set("strumLineNotes", strumLineNotes);
		funnyInterp.variables.set("playerStrums", playerStrums);
		funnyInterp.variables.set("cpuStrums", cpuStrums);
		funnyInterp.variables.set("notes", notes);
		funnyInterp.variables.set("displayNotes", displayNotes);
		funnyInterp.variables.set("displaySustains", displaySustains);

		// ui
		funnyInterp.variables.set("healthBar", healthBar);
		funnyInterp.variables.set("strumLine", strumLine);
		funnyInterp.variables.set("healthBarBG", healthBarBG);
		funnyInterp.variables.set("iconP1", iconP1);
		funnyInterp.variables.set("iconP2", iconP2);

		// option stuff
		funnyInterp.variables.set("downscroll", FlxG.save.data.downscroll);
		funnyInterp.variables.set("distractions", FlxG.save.data.distractions);
		funnyInterp.variables.set("customNoteskin", FlxG.save.data.currentNoteSkin);

		// playstate
		funnyInterp.variables.set("difficulty", storyDifficulty);
		funnyInterp.variables.set("isStoryMode", isStoryMode);
		funnyInterp.variables.set("isHalloween", isHalloween);
		funnyInterp.variables.set("defaultCamZoom", defaultCamZoom);
		funnyInterp.variables.set("health", health);
		funnyInterp.variables.set("PlayState", PlayState.instance);
		funnyInterp.variables.set("PlayStateClass", PlayState);
		funnyInterp.variables.set("getScore", function() { return songScore; });
		funnyInterp.variables.set("setScore", function(huh:Int) { songScore = huh; });
		funnyInterp.variables.set("noteMiss", noteMiss);
		funnyInterp.variables.set("goodNoteHit", goodNoteHit);
		
		// cameras
		funnyInterp.variables.set("camHUD", camHUD);
		funnyInterp.variables.set("camGame", camGame);
		funnyInterp.variables.set("camFollow", camFollow);
		
		// song
		funnyInterp.variables.set("songPosition", Conductor.songPosition);
		funnyInterp.variables.set("bpm", Conductor.bpm);
		funnyInterp.variables.set("stepCrochet", Conductor.stepCrochet);
		funnyInterp.variables.set("crochet", Conductor.crochet);
		funnyInterp.variables.set("curStep", curStep);
		funnyInterp.variables.set("curBeat", curBeat);

		// uhh fuckin idk???
		funnyInterp.variables.set("FlxColor", function(huh:String) { return FlxColor.colorLookup.get(huh); });
		funnyInterp.variables.set("FlxTextBorderStyle", {
			NONE: FlxTextBorderStyle.NONE,
			SHADOW: FlxTextBorderStyle.SHADOW,
			OUTLINE: FlxTextBorderStyle.OUTLINE,
			OUTLINE_FAST: FlxTextBorderStyle.OUTLINE_FAST
		});
		funnyInterp.variables.set("FlxTextAlign", {
			CENTER: FlxTextAlign.CENTER,
			LEFT: FlxTextAlign.LEFT,
			RIGHT: FlxTextAlign.RIGHT,
			JUSTIFY: FlxTextAlign.JUSTIFY
		});
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if(FlxG.save.data.distractions){
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if(FlxG.save.data.distractions){
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if(FlxG.save.data.distractions){
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if(FlxG.save.data.distractions){
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}
	
			if (startedMoving)
			{
				phillyTrain.x -= 400;
	
				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;
	
					if (trainCars <= 0)
						trainFinishing = true;
				}
	
				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}

	}

	function trainReset():Void
	{
		if(FlxG.save.data.distractions){
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		if (songName != null)
		{
			if (songName.text != "")
				songName.text = SONG.song.toUpperCase() + " (" + FlxStringUtil.formatTime((FlxG.sound.music.length - Conductor.songPosition) / 1000) + ")";
		}

		if (executeModchart)
		{
			if (interp.variables.get("stepHit") != null)
				interp.variables.get("stepHit")(curStep);
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(SONG.song + " (" + CoolUtil.difficultyFromInt(storyDifficulty) + ") ", null, true, songLength - Conductor.songPosition);
		#end

	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (songRecording && canPause)
		{
			new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				daLogo.scale.set(0.85, 0.85);
				FlxTween.tween(daLogo, {"scale.x": 0.75, "scale.y": 0.75}, Conductor.crochet / 1500, {ease: FlxEase.quadOut});
			});
		}

		if (executeModchart)
		{
			if (interp.variables.get("beatHit") != null)
				interp.variables.get("beatHit")(curBeat);
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf' && !dad.animation.curAnim.name.startsWith("sing")) 
		{
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
				dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
				dad.playAnim('danceRight');
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		if (curBeat % gfSpeed == 0) 
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !bfAnimationBullshit.contains(true))
			boyfriend.dance();

		if (!dad.animation.curAnim.name.startsWith("sing"))
			dad.dance();

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				if(FlxG.save.data.distractions)
					bgGirls.dance();
			case 'mall':
				if(FlxG.save.data.distractions)
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if(FlxG.save.data.distractions)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
	
					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case "philly":
				if(FlxG.save.data.distractions)
				{
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
	
						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
					}
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if(FlxG.save.data.distractions)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
			case 'city':
				if(FlxG.save.data.distractions)
				{
					if (curBeat % 4 == 0)
					{
						cityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, cityLights.length - 1);
	
						cityLights.members[curLight].visible = true;
						cityLights.members[curLight].alpha = 1;
					}
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if(FlxG.save.data.distractions)
				lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}