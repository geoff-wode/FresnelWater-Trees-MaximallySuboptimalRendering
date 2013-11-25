#ifndef COMMON_PARAMETERS_FX
#define COMMON_PARAMETERS_FX

// ----------------------------------------------

#define DEFINE_TEX_SAMPLER(tex, min, mag, mip, u, v)	\
	texture tex##Texture;					\
	sampler2D tex##Sampler = sampler_state	\
	{										\
		texture = <tex##Texture>;			\
		minfilter = min;					\
		magfilter = mag;					\
		mipfilter = mip;					\
		AddressU = u;						\
		AddressV = v;						\
	}

#define TEX_SAMPLER(tex)	tex##Sampler

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
