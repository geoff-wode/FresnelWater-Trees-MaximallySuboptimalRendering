#include <CommonParameters.fx>

float4x4 World;

float4x4 MirrorView;
float WaveLength;
float WaveHeight;

DEFINE_TEX_SAMPLER(Reflection, LINEAR, LINEAR, LINEAR, MIRROR, MIRROR);
DEFINE_TEX_SAMPLER(Refraction, LINEAR, LINEAR, LINEAR, MIRROR, MIRROR);
DEFINE_TEX_SAMPLER(Bump, LINEAR, LINEAR, LINEAR, MIRROR, MIRROR);

struct WaterVSInput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};

struct WaterVSOutput
{
    float4 Position : POSITION0;	// Mandatory VS output.
    
    float4 texReflect : TEXCOORD0;	// Projective coordinate for reflection texture.
    float4 texRefract : TEXCOORD1;	// Projective coordinate for refraction texture.
    float2 BumpMapCoord : TEXCOORD2;		// Normal map coordinate.
    float4 Position3D : TEXCOORD3;			// 3D position of the vertex.
};

WaterVSOutput WaterVS(WaterVSInput input)
{
    WaterVSOutput output;

	float4x4 wvp = mul(World, mul(View, Projection));
    output.Position = mul(input.Position, wvp);

	float4x4 m = mul(World, mul(MirrorView, Projection));    
    output.texReflect = mul(input.Position, m);
    
    // The projected position for the refracted pixel is just the screen position...
    output.texRefract = output.Position;
    
    // Get the real-world position of the vertex...
    output.Position3D = mul(input.Position, World);

	// Get the texture coordinate as defined by wind direction...    
    float yDot = dot(input.TexCoord, WindDirection.xz);
    float2 crossV = cross(normalize(WindDirection), float3(0, 1, 0));
    float xDot = dot(input.TexCoord, crossV);
    
    float2 animation =	float2(xDot, yDot + TotalTimeMS / 1000 * WindSpeed);

    // Get the bump map texture coordinate for this vertex...
    output.BumpMapCoord = (input.TexCoord + animation) / WaveLength;

    return output;
}

float4 WaterPS(WaterVSOutput input) : COLOR0
{
	float4 bumpColour = tex2D(TEX_SAMPLER(Bump), input.BumpMapCoord);
	float2 bumpCoords = RangeDecompress(bumpColour.rg) * WaveHeight;

	float2 texCoords = float2(input.texReflect.x, -input.texReflect.y) / input.texReflect.w;
    float4 reflectedColour = tex2D(TEX_SAMPLER(Reflection), RangeCompress(texCoords) + bumpCoords);

	texCoords = float2(input.texRefract.x, -input.texRefract.y) / input.texRefract.w;
    float4 refractedColour = tex2D(TEX_SAMPLER(Refraction), RangeCompress(texCoords) + bumpCoords);
    
    // Get amount of refracted vs. reflected light...
    float3 eyeV = normalize(CameraPosition - input.Position3D);

	float3 surfaceNormal = RangeDecompress(bumpColour.rbg);

	float fresnel = dot(eyeV, surfaceNormal);

    float4 colour = lerp(reflectedColour, refractedColour, fresnel);

	// Add a watery hint to the colour...
	const float4 hint = float4(0.3, 0.3, 0.5, 1);	
	colour = lerp(colour, hint, 0.2);
	
	float3 surfaceReflection = -reflect(SunDirection, surfaceNormal);
	float specular = dot(normalize(surfaceReflection), normalize(eyeV));
	specular = pow(specular, 256);
	
	colour.rgb += specular;

    return colour;
}

technique Water
{
    pass Pass1
    {
        // TODO: set renderstates here.

        VertexShader = compile vs_1_1 WaterVS();
        PixelShader = compile ps_2_0 WaterPS();
    }
}
