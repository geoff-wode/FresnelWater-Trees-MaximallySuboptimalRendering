#ifndef COMMON_PARAMETERS_FX
#define COMMON_PARAMETERS_FX

// ----------------------------------------------

#define DEFINE_SAMPLER(tex, min, mag, mip, u, v)	\
	texture tex;							\
	sampler2D tex##Sampler = sampler_state	\
	{										\
		texture = <tex>;					\
		minfilter = min;					\
		magfilter = mag;					\
		mipfilter = mip;					\
		AddressU = u;						\
		AddressV = v;						\
	}

#define SAMPLER(tex)	tex##Sampler

// ----------------------------------------------
// Shared parameters
// ----------------------------------------------

// Common transforms...
shared float4x4 View;
shared float4x4 Projection;

// Time-related values...

// The total amount of time that's passed since the start of the game:
shared float TotalTimeMS;

// The amount of time that's passed since the last frame was rendered:
shared float ElapsedTimeMS;

// Weather-related phenomena...
shared float WindSpeed;
shared float3 WindDirection;

shared float3 SunDirection;
const float4 SunLightColour = float4(0.9, 0.9, 0.9, 1);
shared float AmbientLight = 0.3f;

// The current position of the camera...
shared float3 CameraPosition;

// ----------------------------------------------

// Range-compression from [-1,1] to [0,1] range.
float RangeCompress(float v) { return (0.5f * v) + 0.5f; }
float2 RangeCompress(float2 v) { return (0.5f * v) + 0.5f; }
float3 RangeCompress(float3 v) { return (0.5f * v) + 0.5f; }
float4 RangeCompress(float4 v) { return (0.5f * v) + 0.5f; }

// Range-decompression from [0,1] to [-1,1] range.
float RangeDecompress(float v) { return (v - 0.5f) * 2.0f; }
float2 RangeDecompress(float2 v) { return (v - 0.5f) * 2.0f; }
float3 RangeDecompress(float3 v) { return (v - 0.5f) * 2.0f; }
float4 RangeDecompress(float4 v) { return (v - 0.5f) * 2.0f; }


// ----------------------------------------------

// Compute the Fresnal term.
float FresnelTerm(float3 eyeVector, float3 normal) { return dot(eyeVector, normal); }

// ----------------------------------------------

// Bilinear smoothing values:
float TextureSize;
float TexelSize;

// Vertex Texture Fetch can't do bilinear sampling of texels, so it has to be
// done the old-fashioned way...
float4 tex2DlodBilinear(sampler texSampler, float4 uv)
{
	// By god, this is expensive:
	
	// Original pixel:
	float4 height00 = tex2Dlod(texSampler, uv);
	// 'East' pixel:
	float4 height10 = tex2Dlod(texSampler, uv + float4(TexelSize, 0, 0, 0));
	// 'South' pixel:
	float4 height01 = tex2Dlod(texSampler, uv + float4(0, TexelSize, 0, 0));
	// 'South-east' pixel:
	float4 height11 = tex2Dlod(texSampler, uv + float4(TexelSize, TexelSize, 0, 0));
	
	// Get the texture coordinate as a fraction between 0 and 1:
	float2 f = frac(uv.xy * TextureSize);
	
	// Interpolate horizontally:
	float4 h = lerp(height00, height10, f.x);
	
	// Interpolate vertically:
	float4 v = lerp(height01, height11, f.x);
	
	// Interpolate diagonally:
	float4 r = lerp(h, v, f.y);
	
	return r;
}

// ----------------------------------------------

// Unused technique just to keep the compiler happy...
technique NullTechnique
{
    pass Pass1
    {
        VertexShader = NULL;
        PixelShader = NULL;
    }
}
#endif // COMMON_PARAMETERS_FX
