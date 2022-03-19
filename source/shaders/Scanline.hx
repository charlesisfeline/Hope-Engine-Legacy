package shaders;

class Scanline extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float scale;

		void main()
		{
			if (mod(floor(openfl_TextureCoordv.y * openfl_TextureSize.y / scale), 2.0) == 0.0)
				gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
			else
				gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
		}')
		
	public function new(scale:Float = 1.0)
	{
		super();

		data.scale.value = [scale];
	}
}