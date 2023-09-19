package;

import flixel.FlxG;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import lime.ui.Window;
import lime.utils.Assets;
import scripts.ScriptConsole.ConsolePrefix;
import scripts.ScriptEditor;
import scripts.ScriptEssentials;
import sys.FileSystem;
import sys.io.File;

class CustomState extends MusicBeatState
{
	public static var instance:CustomState;
	public static var openedConsole:Bool = false;
	public static var window:Window;

	public var interp:Interp;
	public var parser:Parser;
	public var script:String;

	public var state:ConsolePrefix;
	public var scriptPath:String;

	public function new(scriptPath:String, state:ConsolePrefix)
	{
		super();

		this.state = state;
		this.scriptPath = scriptPath;

		try
		{
			script = File.getContent(Paths.state(scriptPath));
		}
		catch (e)
		{
			Main.console.add(e.toString(), state);
		}
	}

	override function create()
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
			Main.console.add(e, state);
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
			Main.console.add(e, state);
		}

		if (FlxG.keys.justPressed.F5)
		{
			resetting = true;
			CustomTransition.switchTo(new CustomState(scriptPath, state));
		}

		if (FlxG.keys.justPressed.F4 && !openedConsole)
		{
			var attr = {
				resizable: true,
				title: "Hope Engine State Script Editor",
				context: {
					background: 0x000000
				},
				x: lime.app.Application.current.window.x - 120,
				y: lime.app.Application.current.window.y - 120
			}
			window = lime.app.Application.current.createWindow(attr);
			var edit = new ScriptEditor(script, state, window.width, window.height, scriptPath);
			window.stage.addChild(edit);
			window.onClose.add(function() {
				openedConsole = false;
				FlxG.mouse.visible = false;
			}, true);
			window.onResize.add(function(_, _) {
				edit.x = 0;
				edit.y = 0;
				edit.content.width = window.width;
				edit.content.height = window.height;
			});

			FlxG.mouse.visible = true;

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
			Main.console.add(e, state);
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
			Main.console.add(e, state);
		}
	}

	function vars(interp:Interp)
	{
		ScriptEssentials.imports(interp);
		interp.variables.set("print", function(e:Dynamic)
		{
			Main.console.add(e, state);
		});
		interp.variables.set("curStep", curStep);
		interp.variables.set("curBeat", curBeat);
	}

	var resetting:Bool = false;

	override function destroy() 
	{
		if (window != null && !resetting)
		{
			window.close();
			openedConsole = false;
			window = null;
		}

		super.destroy();
	}
}
