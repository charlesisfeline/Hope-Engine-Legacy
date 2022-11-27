package shaders;

// https://www.shadertoy.com/view/4lSGRw
// Removes Chromatic Aberration that was included in the shader
class LensDistortion extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
		#pragma header

        uniform float factor;

        vec2 computeUV(vec2 uv, float k, float kcube)
        {
            vec2 t = uv - .5;
            float r2 = t.x * t.x + t.y * t.y;
            float f = 0.;
            
            if( kcube == 0.0) {
                f = 1. + r2 * k;
            } else {
                f = 1. + r2 * ( k + kcube * sqrt( r2 ) );
            }
            
            vec2 nUv = f * t + .5;
            // nUv.y = 1. - nUv.y;
         
            return nUv;
        }

		void main()
		{
			vec2 uv = openfl_TextureCoordv.xy;
            float k = 1.0 * sin( factor * .9 );
            float kcube = .5 * sin( factor );
            
            gl_FragColor = texture2D(bitmap, computeUV(uv, k, kcube));
		}')

	public function new(?factor:Float = 3.7)
	{
		super();

        data.factor.value = [3.7];
	}
}