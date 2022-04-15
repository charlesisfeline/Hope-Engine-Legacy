package shaders;

class Mosaic extends flixel.system.FlxAssets.FlxShader
{
	// taken from https://github.com/HaxeFlixel/flixel-demos/blob/master/Effects/MosaicEffect/source/openfl8/MosaicShader.hx
	@:glFragmentSource('
		#pragma header
		
		uniform vec2 uBlocksize;

		void main()
		{
			vec2 blocks = openfl_TextureSize / uBlocksize;
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
		}')
	public function new(blockWidth:Int = 1, blockHeight:Int = 1)
	{
		super();

		data.uBlocksize.value = [blockWidth, blockHeight];
	}
}
