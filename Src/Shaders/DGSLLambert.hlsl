// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//
// This file was generated by exporting HLSL from Visual Studio's default "Lambert" material, and then modified to handle both texture scenarios, multiple lights, and work with FL 9.x
// <Visual Studio install folder>\Common7\IDE\Extensions\Microsoft\VsGraphics\Assets\Effects\Lambert.dgsl
//

Texture2D Texture1 : register(t0);

SamplerState TexSampler : register(s0);

cbuffer MaterialVars : register (b0)
{
    float4 MaterialAmbient;
    float4 MaterialDiffuse;
    float4 MaterialSpecular;
    float4 MaterialEmissive;
    float MaterialSpecularPower;
};

cbuffer LightVars : register (b1)
{
    float4 AmbientLight;
    float4 LightColor[4];
    float4 LightAttenuation[4];
    float3 LightDirection[4];
    float LightSpecularIntensity[4];
    uint IsPointLight[4];
    uint ActiveLights;
}

cbuffer ObjectVars : register(b2)
{
    float4x4 LocalToWorld4x4;
    float4x4 LocalToProjected4x4;
    float4x4 WorldToLocal4x4;
    float4x4 WorldToView4x4;
    float4x4 UVTransform4x4;
    float3 EyePosition;
};

cbuffer MiscVars : register(b3)
{
    float ViewportWidth;
    float ViewportHeight;
    float Time;
};

struct V2P
{
    float4 pos : SV_POSITION;
    float4 diffuse : COLOR;
    float2 uv : TEXCOORD0;
    float3 worldNorm : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    float3 toEye : TEXCOORD3;
    float4 tangent : TEXCOORD4;
    float3 normal : TEXCOORD5;
};

struct P2F
{
    float4 fragment : SV_Target;
};

//
// lambert lighting function
//
float3 LambertLighting(
    float3 lightNormal,
    float3 surfaceNormal,
    float3 lightColor,
    float3 pixelColor
)
{
    // compute amount of contribution per light
    float diffuseAmount = saturate(dot(lightNormal, surfaceNormal));
    float3 diffuse = diffuseAmount * lightColor * pixelColor;
    return diffuse;
}

//
// combines a float3 RGB value with an alpha value into a float4
//
float4 CombineRGBWithAlpha(float3 rgb, float a)
{
    return float4(rgb.r, rgb.g, rgb.b, a);
}

P2F main(V2P pixel)
{
    P2F result;

    float3 worldNormal = normalize(pixel.worldNorm);

    float3 local3 = MaterialAmbient.rgb * AmbientLight.rgb;
    [unroll]
    for (int i = 0; i < 4; i++)
    {
        local3 += LambertLighting(LightDirection[i], worldNormal, LightColor[i].rgb, pixel.diffuse.rgb);
    }

    local3 = saturate(local3);
    result.fragment = CombineRGBWithAlpha(local3, pixel.diffuse.a);

    return result;
}

P2F mainTk(V2P pixel)
{
    P2F result;

    float3 worldNormal = normalize(pixel.worldNorm);

    float3 local3 = MaterialAmbient.rgb * AmbientLight.rgb;
    [unroll]
    for (int i = 0; i < 4; i++)
    {
        local3 += LambertLighting(LightDirection[i], worldNormal, LightColor[i].rgb, pixel.diffuse.rgb);
    }

    local3 = saturate(local3);
    result.fragment = CombineRGBWithAlpha(local3, pixel.diffuse.a);

    if (result.fragment.a == 0.0f) discard;

    return result;
}

P2F mainTx(V2P pixel)
{
    P2F result;

    float3 worldNormal = normalize(pixel.worldNorm);

    float3 local3 = MaterialAmbient.rgb * AmbientLight.rgb;
    [unroll]
    for (int i = 0; i < 4; i++)
    {
        local3 += LambertLighting(LightDirection[i], worldNormal, LightColor[i].rgb, pixel.diffuse.rgb);
    }

    local3 = saturate(local3);
    float3 local4 = Texture1.Sample(TexSampler, pixel.uv).rgb * local3;
    float local5 = Texture1.Sample(TexSampler, pixel.uv).a * pixel.diffuse.a;
    result.fragment = CombineRGBWithAlpha(local4, local5);

    return result;
}

P2F mainTxTk(V2P pixel)
{
    P2F result;

    float3 worldNormal = normalize(pixel.worldNorm);

    float3 local3 = MaterialAmbient.rgb * AmbientLight.rgb;
    [unroll]
    for (int i = 0; i < 4; i++)
    {
        local3 += LambertLighting(LightDirection[i], worldNormal, LightColor[i].rgb, pixel.diffuse.rgb);
    }

    local3 = saturate(local3);
    float3 local4 = Texture1.Sample(TexSampler, pixel.uv).rgb * local3;
    float local5 = Texture1.Sample(TexSampler, pixel.uv).a * pixel.diffuse.a;
    result.fragment = CombineRGBWithAlpha(local4, local5);

    if (result.fragment.a == 0.0f) discard;

    return result;
}

