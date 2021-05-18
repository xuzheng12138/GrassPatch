#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float3 positionOS   : POSITION;
    float4 color        : COLOR;
    float2 uv           : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS               : SV_POSITION;
    float2 uv                       : TEXCOORD0;
    float4 positionWS               : TEXCOORD1;
    float4 color                    : TEXCOORD2;
};

sampler2D _BaseMap;
CBUFFER_START(UnityPerMaterial)
    half4   _BaseColor;
    half3 _ShadowColor;
    half _ShadowIntensity;
CBUFFER_END

///////////////////////////////////////////////////////////////////////////////////////
// Vertex Shader
///////////////////////////////////////////////////////////////////////////////////////
Varyings VertexShaderWork(Attributes input)
{
    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.positionWS.xyz = TransformObjectToWorld(output.positionCS);
    output.positionWS.w = ComputeFogFactor(output.positionCS.z);
    output.uv = input.uv;
    output.color = input.color;
    return output;
}

///////////////////////////////////////////////////////////////////////////////////////
// Fragment Shader
///////////////////////////////////////////////////////////////////////////////////////
half4 FragmentShaderWork(Varyings input) : SV_TARGET
{
    half4 color = tex2D(_BaseMap, input.uv) * input.color;
    Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS.xyz));
    half4 shadowColor = mainLight.shadowAttenuation + half4(_ShadowColor * _ShadowIntensity, 1);
    color = color * saturate(shadowColor);
    float fogFactor = input.positionWS.w;
    color = half4(MixFog(color.rgb, fogFactor), color.a);
    return color;
}