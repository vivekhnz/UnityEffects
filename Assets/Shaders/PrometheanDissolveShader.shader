Shader "Custom/PrometheanDissolve"
{
	Properties
	{
		_Color ("Color", Float) = (0.5, 0.5, 0.5, 1)
		_DissolveRadius ("Dissolve radius", Float) = 0
		_FringeTexture ("Fringe texture", 2D) = "white" {}
		_FringeRadius ("Fringe radius", Float) = 0.5
	}
    SubShader
	{
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "ForceNoShadowCasting"="True"
        }
        CGPROGRAM
        #pragma surface surf Lambert decal:blend

        float4 _Color;
        float3 _DissolveOrigin;
        float _DissolveRadius;
        sampler2D _FringeTexture;
        float _FringeRadius;
        
        struct Input
        {
            float4 color : COLOR;
            float3 worldPos;
        };
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color;
            
            float dist = distance(_DissolveOrigin, IN.worldPos);
            if (dist > _DissolveRadius)
            {
                o.Alpha = 1;
                if (dist < _DissolveRadius + _FringeRadius)
                {
                    float fringeProgress = (dist - _DissolveRadius) / _FringeRadius;
                    float4 fringeColour = tex2D(_FringeTexture, float2(fringeProgress, 0));
                    o.Emission = fringeColour.rgb * fringeColour.a;
                }
            }
            else
            {
                o.Alpha = 0;
            }
        }
        
        ENDCG
        }
        Fallback "Diffuse"
}
