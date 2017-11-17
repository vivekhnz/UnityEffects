Shader "Custom/PrometheanDissolve"
{
	Properties
	{
		_OuterColor ("Outer color", Color) = (0.5, 0.5, 0.5, 1)
		_InnerColor ("Inner color", Color) = (0.25, 0.25, 0.25, 1)

		_DissolveRadius ("Dissolve radius", Float) = 0

		_FringeTexture ("Fringe texture", 2D) = "white" {}
		_FringeRadius ("Fringe radius", Float) = 0.5

		_CracksTexture ("Cracks texture", 2D) = "white" {}
		_CracksRadius ("Cracks radius", Float) = 1
		_CracksTextureScale ("Cracks texture scale", Float) = 1
	}
    
    CGINCLUDE

    float4 _OuterColor;
    float4 _InnerColor;

    float3 _DissolveOrigin;
    float _DissolveRadius;

    sampler2D _FringeTexture;
    float _FringeRadius;
    
    sampler2D _CracksTexture;
    float _CracksRadius;
    float _CracksTextureScale;
        
    struct Input
    {
        float4 color : COLOR;
        float3 worldPos;
        float3 worldNormal;
    };
        
    void dissolveEffect(Input IN, inout SurfaceOutput o, float4 color)
    {
        o.Albedo = color;
        o.Alpha = 1;
        
        float dist = distance(_DissolveOrigin, IN.worldPos);
        clip(dist - _DissolveRadius);
        if (dist < _DissolveRadius + _CracksRadius)
        {
            float fringeProgress = (dist - _DissolveRadius) / _CracksRadius;
            float4 fringeColour = tex2D(_FringeTexture, float2(fringeProgress, 0));

            // calculate world space UVs
            float2 uv = IN.worldPos.xz;
            if (abs(IN.worldNormal.x) > 0.5) uv = IN.worldPos.yz;
            if (abs(IN.worldNormal.z) > 0.5) uv = IN.worldPos.xy;
            uv *= _CracksTextureScale;
            
            o.Emission = tex2D(_CracksTexture, uv) * fringeColour.rgb * fringeColour.a;
        }
        if (dist < _DissolveRadius + _FringeRadius)
        {
            float fringeProgress = (dist - _DissolveRadius) / _FringeRadius;
            float4 fringeColour = tex2D(_FringeTexture, float2(fringeProgress, 0));
            o.Emission += fringeColour.rgb * fringeColour.a;
        }
    }

    ENDCG

    SubShader
	{
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "ForceNoShadowCasting"="True"
        }

        Cull Front
        CGPROGRAM
        #pragma surface surf Lambert decal:blend
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            dissolveEffect(IN, o, _InnerColor);
        }
        
        ENDCG

        Cull Back
        CGPROGRAM
        #pragma surface surf Lambert decal:blend
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            dissolveEffect(IN, o, _OuterColor);
        }
        
        ENDCG
    }
    Fallback "Diffuse"
}
