package;

import flixel.FlxG;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import lime.ui.Window;
import scripts.ScriptConsole.ConsolePrefix;
import scripts.ScriptEditor;
import scripts.ScriptEssentials;
import sys.FileSystem;
import sys.io.File;

// DOESN'T WORK YET!!

class CustomSubState extends MusicBeatSubstate
{
	public static var instance:CustomSubState;
	public static var openedConsole:Bool = false;
	public static var window:Window;

	public var interp:Interp;
	public var parser:Parser;
	public var script:String;

	public var substate:ConsolePrefix;
	public var scriptPath:String;

	public function new(scriptPath:String, substate:ConsolePrefix)
	{
		super();

		this.substate = substate;
		this.scriptPath = scriptPath;

		try
		{
			script = File.getContent(Paths.state(scriptPath));

			justDo();
		}
		catch (e)
		{
			Main.console.add(e.toString(), substate);
		}
	}

	function justDo()
	{

		instance = this;
		parser = new Parser();
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;
		parser.resumeErrors = true;

		interp = new Interp();
		vars(interp);
		var ast = parser.parseString(script);

		try
		{
			interp.execute(ast);

			if (interp.variables.get("onCreate") != null)
				interp.variables.get("onCreate")();
		}
		catch (e)
		{
			Main.console.add(e, substate);
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		try
		{
			vars(interp);

			if (interp.variables.get("onUpdate") != null)
				interp.variables.get("onUpdate")(elapsed);
		}
		catch (e)
		{
			Main.console.add(e, substate);
		}

		if (FlxG.keys.justPressed.F5)
			CustomTransition.switchTo(new CustomState(scriptPath, substate));

		if (FlxG.keys.justPressed.F4 && !openedConsole)
		{
			var attr = {
				resizable: true,
				title: "Hope Engine Substate Script Editor",
				context: {
					background: 0x000000
				},
				x: lime.app.Application.current.window.x - 120,
				y: lime.app.Application.current.window.y - 120
			}
			window = lime.app.Application.current.createWindow(attr);
			var edit = new ScriptEditor(script, substate, window.width, window.height, scriptPath);
			window.stage.addChild(edit);
			window.onClose.add(function() {
				openedConsole = false;
			}, true);
			window.onResize.add(function(_, _) {
				edit.x = 0;
				edit.y = 0;
				edit.content.width = window.width;
				edit.content.height = window.height;
			});

			openedConsole = true;
		}
	}

	override function stepHit()
	{
		super.stepHit();

		try
		{
			if (interp.variables.get("onStepHit") != null)
				interp.variables.get("onStepHit")(curStep);
		}
		catch (e)
		{
			Main.console.add(e, substate);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		try
		{
			if (interp.variables.get("onBeatHit") != null)
				interp.variables.get("onBeatHit")(curBeat);
		}
		catch (e)
		{
			Main.console.add(e, substate);
		}
	}

	function vars(interp:Interp)
	{
		ScriptEssentials.imports(interp);
		interp.variables.set("print", function(e:Dynamic)
		{
			Main.console.add(e, substate);
		});
		interp.variables.set("curStep", curStep);
		interp.variables.set("curBeat", curBeat);
	}

	override function destroy() 
	{
		if (window != null)
		{
			window.close();
			openedConsole = false;
			window = null;
		}

		super.destroy();
	}
}
