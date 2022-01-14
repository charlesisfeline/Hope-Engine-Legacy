package;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Shader;
import openfl.display.ShaderData;
import openfl.display.ShaderParameter;

class ChromaticAberration extends FlxShader
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
		
	public function new()
	{
		super();

		this.data.rOffset.value = [0.25 / 100];
		this.data.gOffset.value = [0.0];
		this.data.bOffset.value = [-0.25 / 100];
	}
}

class CRTCurve extends FlxShader 
{
	// taken from https://gist.github.com/Beeblerox/54324d9d5aa19b27651b7cda9130f5dd
	// breaks when you resize window LMAO
	
	@:glFragmentSource("
		#pragma header

		uniform float power;
		
		vec2 curve(vec2 uv, float power)
		{
			uv = (uv - 0.5) * 2.0;
			uv *= 1.1;	
			uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0) * power;
			uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0) * power;
			uv  = (uv / 2.0) + 0.5;
			uv =  uv * 0.92 + 0.04;
			return uv;
		}
		
		void main()
		{
			vec2 q = openfl_TextureCoordv;
			vec2 piss = curve(uv, power);

			if (piss.x < 0.0 || piss.x > 1.0)
				discard;
			
			if (piss.y < 0.0 || piss.y > 1.0)
				discard;
			
			gl_FragColor = texture2D(bitmap, piss);
		}"
	)
	
	public function new(power:Float = 1.0) 
	{
		super();

		data.power.value = [power];
	}
}

class Mosaic extends FlxShader
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


class Scanline extends FlxShader
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

class Grain extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		/*
		Film Grain post-process shader v1.1
		Martins Upitis (martinsh) devlog-martinsh.blogspot.com
		2013

		--------------------------
		This work is licensed under a Creative Commons Attribution 3.0 Unported License.
		So you are free to share, modify and adapt it for your needs, and even use it for commercial use.
		I would also love to hear about a project you are using it.

		Have fun,
		Martins
		--------------------------

		Perlin noise shader by toneburst:
		http://machinesdontcare.wordpress.com/2009/06/25/3d-perlin-noise-sphere-vertex-shader-sourcecode/
		*/
		uniform float uTime;

		const float permTexUnit = 1.0/256.0;        // Perm texture texel-size
		const float permTexUnitHalf = 0.5/256.0;    // Half perm texture texel-size

		float width = openfl_TextureSize.x;
		float height = openfl_TextureSize.y;

		uniform float grainamount; //grain amount
		bool colored = false; //colored noise?
		float coloramount = 0.6;
		float grainsize = 1.6; //grain particle size (1.5 - 2.5)
		float lumamount = 1.0; //

		//a random texture generator, but you can also use a pre-computed perturbation texture
		vec4 rnm(in vec2 tc)
		{
			float noise =  sin(dot(tc + vec2(uTime,uTime),vec2(12.9898,78.233))) * 43758.5453;

			float noiseR =  fract(noise)*2.0-1.0;
			float noiseG =  fract(noise*1.2154)*2.0-1.0;
			float noiseB =  fract(noise*1.3453)*2.0-1.0;
			float noiseA =  fract(noise*1.3647)*2.0-1.0;

			return vec4(noiseR,noiseG,noiseB,noiseA);
		}

		float fade(in float t) {
			return t*t*t*(t*(t*6.0-15.0)+10.0);
		}

		float pnoise3D(in vec3 p)
		{
			vec3 pi = permTexUnit*floor(p)+permTexUnitHalf; // Integer part, scaled so +1 moves permTexUnit texel
			// and offset 1/2 texel to sample texel centers
			vec3 pf = fract(p);     // Fractional part for interpolation

			// Noise contributions from (x=0, y=0), z=0 and z=1
			float perm00 = rnm(pi.xy).a ;
			vec3  grad000 = rnm(vec2(perm00, pi.z)).rgb * 4.0 - 1.0;
			float n000 = dot(grad000, pf);
			vec3  grad001 = rnm(vec2(perm00, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
			float n001 = dot(grad001, pf - vec3(0.0, 0.0, 1.0));

			// Noise contributions from (x=0, y=1), z=0 and z=1
			float perm01 = rnm(pi.xy + vec2(0.0, permTexUnit)).a ;
			vec3  grad010 = rnm(vec2(perm01, pi.z)).rgb * 4.0 - 1.0;
			float n010 = dot(grad010, pf - vec3(0.0, 1.0, 0.0));
			vec3  grad011 = rnm(vec2(perm01, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
			float n011 = dot(grad011, pf - vec3(0.0, 1.0, 1.0));

			// Noise contributions from (x=1, y=0), z=0 and z=1
			float perm10 = rnm(pi.xy + vec2(permTexUnit, 0.0)).a ;
			vec3  grad100 = rnm(vec2(perm10, pi.z)).rgb * 4.0 - 1.0;
			float n100 = dot(grad100, pf - vec3(1.0, 0.0, 0.0));
			vec3  grad101 = rnm(vec2(perm10, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
			float n101 = dot(grad101, pf - vec3(1.0, 0.0, 1.0));

			// Noise contributions from (x=1, y=1), z=0 and z=1
			float perm11 = rnm(pi.xy + vec2(permTexUnit, permTexUnit)).a ;
			vec3  grad110 = rnm(vec2(perm11, pi.z)).rgb * 4.0 - 1.0;
			float n110 = dot(grad110, pf - vec3(1.0, 1.0, 0.0));
			vec3  grad111 = rnm(vec2(perm11, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
			float n111 = dot(grad111, pf - vec3(1.0, 1.0, 1.0));

			// Blend contributions along x
			vec4 n_x = mix(vec4(n000, n001, n010, n011), vec4(n100, n101, n110, n111), fade(pf.x));

			// Blend contributions along y
			vec2 n_xy = mix(n_x.xy, n_x.zw, fade(pf.y));

			// Blend contributions along z
			float n_xyz = mix(n_xy.x, n_xy.y, fade(pf.z));

			// We are done, return the final noise value.
			return n_xyz;
		}

		//2d coordinate orientation thing
		vec2 coordRot(in vec2 tc, in float angle)
		{
			float aspect = width/height;
			float rotX = ((tc.x*2.0-1.0)*aspect*cos(angle)) - ((tc.y*2.0-1.0)*sin(angle));
			float rotY = ((tc.y*2.0-1.0)*cos(angle)) + ((tc.x*2.0-1.0)*aspect*sin(angle));
			rotX = ((rotX/aspect)*0.5+0.5);
			rotY = rotY*0.5+0.5;
			return vec2(rotX,rotY);
		}

		void main()
		{
			vec2 texCoord = openfl_TextureCoordv.st;

			vec3 rotOffset = vec3(1.425,3.892,5.835); //rotation offset values
			vec2 rotCoordsR = coordRot(texCoord, uTime + rotOffset.x);
			vec3 noise = vec3(pnoise3D(vec3(rotCoordsR*vec2(width/grainsize,height/grainsize),0.0)));

			if (colored)
			{
				vec2 rotCoordsG = coordRot(texCoord, uTime + rotOffset.y);
				vec2 rotCoordsB = coordRot(texCoord, uTime + rotOffset.z);
				noise.g = mix(noise.r,pnoise3D(vec3(rotCoordsG*vec2(width/grainsize,height/grainsize),1.0)),coloramount);
				noise.b = mix(noise.r,pnoise3D(vec3(rotCoordsB*vec2(width/grainsize,height/grainsize),2.0)),coloramount);
			}

			vec3 col = texture2D(bitmap, openfl_TextureCoordv).rgb;

			//noisiness response curve based on scene luminance
			vec3 lumcoeff = vec3(0.299,0.587,0.114);
			float luminance = mix(0.0,dot(col, lumcoeff),lumamount);
			float lum = smoothstep(0.2,0.0,luminance);
			lum += luminance;


			noise = mix(noise,vec3(0.0),pow(lum,4.0));
			col = col+noise*grainamount;

			gl_FragColor =  vec4(col,1.0);
		}')

	public function new(grainAmount:Float)
	{
		super();
		data.uTime.value = [0.0];
		data.grainamount.value = [grainAmount];
	}

	override function __update() 
	{
		super.__update();
		data.uTime.value[0] += FlxG.elapsed;
	}
}