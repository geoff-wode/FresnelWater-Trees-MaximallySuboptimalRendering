#include <CommonParameters.fx>
#include <Waves.fx>

// Standard to-world transform:
float4x4 World;

// Height of the water table:
float WaterLevel;

// Control the appearance of high frequency waves produced by the bump map:
float Bumpiness;

// The view transformation for reflections off the surface:
float4x4 MirrorView;

DEFINE_SAMPLER(Reflection, LINEAR, LINEAR, LINEAR, MIRROR, MIRROR);
DEFINE_SAMPLER(Refraction, LINEAR, LINEAR, LINEAR, MIRROR, MIRROR);
DEFINE_SAMPLER(BumpMap, LINEAR, LINEAR, LINEAR, MIRROR, MIRROR);

struct VertexShaderInput
{
    float4 Position : POSITION0;
    float2 TexPos : TEXCOORD0;
};

struct VertexShaderOutput
{
    float4 Position			: POSITION0;
    float3 WorldPos			: TEXCOORD0;
    float2 BumpMapTexPos	: TEXCOORD1;
    float3 Normal			: TEXCOORD2;    
    float4 ReflectionTexPos : TEXCOORD3;
    float4 RefractionTexPos : TEXCOORD4;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

	WaveOutput wave = GenWave(input.TexPos, TotalTimeMS / 1000, WindDirection);

	input.Position.y = WaterLevel;// - abs(wave.Height);

    float4x4 wvp = mul(World, mul(View, Projection));

    output.Position = mul(input.Position, wvp);
	
	output.WorldPos = mul(input.Position, World);
	
	float2 animation = WindDirection * (TotalTimeMS / 1000) * WindSpeed;
	output.BumpMapTexPos = (input.TexPos + animation) / WaveLength;
	
	output.RefractionTexPos = output.Position;
	
	float4x4 mirrorWVP = mul(World, mul(MirrorView, Projection));
	output.ReflectionTexPos = mul(input.Position, mirrorWVP);

	output.Normal = mul(wave.Normal, World);

    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	// Get normal from bump map...
	float4 bumpColour = RangeDecompress(tex2D(SAMPLER(BumpMap), input.BumpMapTexPos));
	float2 perturbation = Amplitude * bumpColour.rg;

	// Get the reflected and refracted colours...
	float2 texPos;
	
	texPos.x = RangeCompress(input.ReflectionTexPos.x / input.ReflectionTexPos.w);
    texPos.y = RangeCompress(-input.ReflectionTexPos.y / input.ReflectionTexPos.w);
	float4 reflectionColour = tex2D(SAMPLER(Reflection), texPos + perturbation);

	texPos.x = RangeCompress(input.RefractionTexPos.x / input.RefractionTexPos.w);
    texPos.y = RangeCompress(-input.RefractionTexPos.y / input.RefractionTexPos.w);
	float4 refractionColour = tex2D(SAMPLER(Refraction), texPos + perturbation);

	// Add the perturbation of the bump map to the geometric normal produced by
	// the vertex shader...
	input.Normal.xz += perturbation;
	float3 N = normalize(input.Normal);
	
	// Get the view vector (V), light direction (L) and the half-vector (H)...
	float3 V = normalize(CameraPosition - input.WorldPos);
	float3 L = normalize(-SunDirection);
	float3 H = normalize(L + V);
	
	// Get the Fresnel term based on the normal at the pixel and the view angle...
	float fresnel = dot(V, N);

	// Combine the reflective and refractive colours based on the Fresnel term:
	float4 surfaceColour = lerp(reflectionColour, refractionColour, fresnel);
	
	// Add a small amount of murkiness:
	const float4 murkyColour = float4(0.2, 0.2, 0.5, 1);
	surfaceColour = lerp(surfaceColour, murkyColour, 0.2);

	// Do basic lighting...
	float NdotL = saturate(dot(N, L));
	float3 diffuse = surfaceColour * NdotL * SunLightColour;
	
	float shininess = 0;
	if (NdotL > 0)
	{
		shininess = pow(saturate(dot(N, H)), 64);
	}
	float3 specular = (1 - diffuse) * SunLightColour * shininess;

	// Combine all the bits of light together:
	float4 finalColour = float4(diffuse + specular, 1);

    return finalColour;
}

technique Water
{
    pass Pass1
    {
        // TODO: set renderstates here.

        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
