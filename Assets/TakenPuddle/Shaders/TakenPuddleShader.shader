Shader "Custom/TakenPuddle"
{
	Properties
	{
		_Color ("Color", Color) = (0.0, 0.0, 0.0, 1)
	}

    SubShader
	{
        Tags
        {
            "RenderType" = "Opaque" 
            "ForceNoShadowCasting"="True"
        }

        Cull Off
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        float4 _Color;
            
        struct Input
        {
            float4 color : COLOR;
        };

        void vert(inout appdata_full v)
        {
            float3 origin = mul(unity_WorldToObject, float4(0, 0, 0, 1));
            float3 up = mul(unity_ObjectToWorld, float4(0, 1, 0, 1));

            // v.vertex.xz += dir.xz * sin(_Time.y) * 0.1;
            // v.vertex.xyz += up * lerp(1, 1.5, sin(_Time.y));
            v.color = float4(v.vertex.x, v.vertex.y, v.vertex.z, 1);
        }
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = IN.color;
            o.Alpha = 1;
        }
        
        ENDCG
    }
    Fallback "Diffuse"
}
