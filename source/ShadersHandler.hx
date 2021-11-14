package;

import flixel.FlxG;
import openfl.filters.ShaderFilter;

class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new Shaders.ChromaticAberration());
    public static var currentChrome:Float = 0.0;
	
	public static function setChrome(chromeOffset:Float):Void
	{
        currentChrome = chromeOffset * 100;
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];

		
	}
}