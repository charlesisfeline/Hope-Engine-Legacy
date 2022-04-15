package shaders;

class ChromaticAberration extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
			vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffset, 0.0));
			vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffset, 0.0));
			vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffset, 0.0));
			vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
			toUse.r = col1.r;
			toUse.g = col2.g;
			toUse.b = col3.b;
			//float someshit = col4.r + col4.g + col4.b;

			gl_FragColor = toUse;
		}')
	public function new(?rOffset:Float = -0.25, ?gOffset:Float = 0, ?bOffset:Float = 0.25)
	{
		super();
		set(rOffset, gOffset, bOffset);
	}

	public function set(rOffset:Float, gOffset:Float, bOffset:Float)
	{
		this.data.rOffset.value = [rOffset / 100];
		this.data.gOffset.value = [gOffset / 100];
		this.data.bOffset.value = [bOffset / 100];
	}
}
