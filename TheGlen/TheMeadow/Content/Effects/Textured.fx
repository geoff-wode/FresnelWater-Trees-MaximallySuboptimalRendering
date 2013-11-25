float4x4 World;
float4x4 ViewProjection;

// TODO: add effect parameters here.

sampler2D TiledTextureSampler = sampler_state
	{
        minfilter = linear;
        magfilter = linear;
        mipfilter = linear;
        addressU = mirror;
        addressV = mirror;
	};

sampler2D TextureSampler = sampler_state
	{
        minfilter = linear;
        magfilter = linear;
        mipfilter = linear;
	};

struct VertexShaderInput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};

struct VertexShaderOutput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

    float4 worldPosition = mul(input.Position, World);
    output.Position = mul(worldPosition, ViewProjection);
    // output.Position = mul(viewPosition, Projection);

	output.TexCoord = input.TexCoord;

    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
    return tex2D(TextureSampler, input.TexCoord);
}

float4 TiledTexturePixelShaderFunction(VertexShaderOutput input) : COLOR0
{
    return tex2D(TextureSampler, input.TexCoord);
}

technique Standard
{
    pass Pass1
    {
        VertexShader = compile vs_1_1 VertexShaderFunction();
        PixelShader = compile ps_1_1 PixelShaderFunction();
    }
}

technique Tiled
{
    pass Pass1
    {
        VertexShader = compile vs_1_1 VertexShaderFunction();
        PixelShader = compile ps_1_1 TiledTexturePixelShaderFunction();
    }
}
