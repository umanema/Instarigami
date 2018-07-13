/// original by nimitz https://www.shadertoy.com/view/lsSGzy#, slightly modified

// !!!!!!!!!!!!! UNCOMMENT ONE OF THESE TO CHANGE EFFECTS !!!!!!!!!!!
// MODE IS THE PRIMARY MODE
#define MODE normalize
// #define MODE 

#define MODE3 *
// #define MODE3 +

#define MODE2 r +
//#define MODE2 

//#define DIRECTION +
#define DIRECTION -

#define SIZE 0.1

#define INVERT /
// #define INVERT *


float2 R:TARGETSIZE;
Texture2D tex0 <string uiname="TextureNoise";>;
Texture2D tex1 <string uiname="Texture";>;
SamplerState s0 <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = wrap;
    AddressV = wrap;
};


cbuffer cbPerDraw:register( b0 )
{
float4x4 tVP:VIEWPROJECTION;
float4x4 tW:WORLD;
float time;
float ray_brightness = 10.0;
float gamma = 5.0;
float ray_density = 4.5;
float curvature = 15.0;
float red =  4.0;
float green = 1.0;
float blue = .3;	
float alpha = 1.0;
float2 position = {0,0};
};

float noise( in float2 x )
{
	return tex0.Sample(s0, x*.01).x; // INCREASE MULTIPLIER TO INCREASE NOISE
}

// FLARING GENERATOR, A.K.A PURE AWESOME
float2x2 m2 = float2x2( 0.80,  0.60, -0.60,  0.80 );
float fbm( in float2 p )
{	
	float z=2.;       // EDIT THIS TO MODIFY THE INTENSITY OF RAYS
	float rz = -0.05; // EDIT THIS TO MODIFY THE LENGTH OF RAYS
	p *= 0.25;        // EDIT THIS TO MODIFY THE FREQUENCY OF RAYS
	for (int i= 1; i < 6; i++)
	{
		rz+= abs((noise(p)-0.5)*2.)/z;
		z = z*2.;
		p = mul(p*2.,m2);
	}
	return rz;
}


struct VS_IN
{
	float4 PosO:POSITION;
	float4 TexCd:TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP:SV_POSITION;
    float4 TexCd:TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
    output.PosWVP = mul(input.PosO,tW);
    output.TexCd = input.TexCd;
    return output;
}

float4 PS(vs2ps In) : SV_Target
{
    float t = DIRECTION time*.33; 
	float2 uv = In.TexCd.xy -0.5;
	//uv.y=1-In.TexCd.y;
	uv.x *= R.x/R.y;
	uv*= curvature* SIZE;
	uv+=position;
	
	float r = sqrt(dot(uv,uv)); // DISTANCE FROM CENTER, A.K.A CIRCLE
	float x = dot(MODE(uv), float2(.5,0.))+t;
	float y = dot(MODE(uv), float2(.0,.5))+t;
 
    float val;
    val = fbm(float2(MODE2 y * ray_density, MODE2 x MODE3 ray_density)); // GENERATES THE FLARING
	val = smoothstep(gamma*.02-.1,ray_brightness+(gamma*0.02-.1)+.001,val);
	val = sqrt(val); // WE DON'T REALLY NEED SQRT HERE, CHANGE TO 15. * val FOR PERFORMANCE
	
	float3 col = val INVERT float3(red,green,blue);
	col = 1.-col; // WE DO NOT NEED TO CLAMP THIS LIKE THE NIMITZ SHADER DOES!
    float rad= 30. * tex1.Sample(s0, float2(0,0)).x; // MODIFY THIS TO CHANGE THE RADIUS OF THE SUNS CENTER
	col = lerp(col,float(1.), rad - 266.667 * r); // REMOVE THIS TO SEE THE FLARING
	
	return float4(col,normalize(col.r+col.g+col.b)*alpha);
}

technique10 Phoenix
{
	pass P0
	{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	
	}
}



