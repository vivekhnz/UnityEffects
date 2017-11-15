Shader "Custom/PrometheanDissolve"
{
	Properties
	{
		_DissolveOrigin ("Dissolve origin", Vector) = (0,0,0)
		_DissolveRadius ("Dissolve radius", Float) = 0
	}
    SubShader
	{
      Tags { "RenderType"="Opaque" "Queue"="Geometry+1" "ForceNoShadowCasting"="True" }
      CGPROGRAM
      #pragma surface surf Lambert decal:blend

      float3 _DissolveOrigin;
      float _DissolveRadius;
      
	  struct Input
	  {
          float4 color : COLOR;
          float3 worldPos;
      };
      
	  void surf (Input IN, inout SurfaceOutput o)
	  {
          o.Albedo = 1;
          
          float dist = distance(_DissolveOrigin, IN.worldPos);
          if (dist > _DissolveRadius)
          {
              o.Alpha = 1;
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
