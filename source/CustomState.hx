package;

import flixel.FlxG;
import hscript.Parser;
import hscript.Interp;
import scripts.ScriptConsole.ConsolePrefix;
import scripts.ScriptEssentials;
import sys.io.File;
import sys.FileSystem;

class CustomState extends MusicBeatState
{
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
		parser = new Parser();
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;

		interp = new Interp();
		vars(interp);
		var ast = parser.parseString(script);
		interp.execute(ast);

		super.create();

        if (interp.variables.get("onCreate") != null)
			interp.variables.get("onCreate")();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        vars(interp);

		if (interp.variables.get("onUpdate") != null)
			interp.variables.get("onUpdate")(elapsed);

        if (FlxG.keys.justPressed.F5)
            CustomTransition.switchTo(new CustomState(scriptPath, state));
	}

	override function stepHit()
	{
		super.stepHit();

		if (interp.variables.get("onStepHit") != null)
			interp.variables.get("onStepHit")(curStep);
	}

	override function beatHit()
	{
		super.beatHit();

		if (interp.variables.get("onBeatHit") != null)
			interp.variables.get("onBeatHit")(curBeat);
	}

    function vars(interp:Interp)
    {
        ScriptEssentials.imports(interp);
        interp.variables.set("print", function(e:Dynamic) {
			Main.console.add(e, state);
		});
        interp.variables.set("curStep", curStep);
        interp.variables.set("curBeat", curBeat);
        interp.variables.set("add", add);
        interp.variables.set("remove", remove);
        interp.variables.set("insert", insert);
    }
}