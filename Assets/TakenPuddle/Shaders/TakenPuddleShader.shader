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

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        float4 _Color;
            
        struct Input
        {
            float3 position : POSITION;
            float3 barycentric;
        };

        void vert(inout appdata_full i, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float4 pos = mul(unity_ObjectToWorld, i.vertex);
            
            o.barycentric = i.tangent.xyz;

            o.position = mul(unity_WorldToObject, pos);
        }
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = IN.barycentric;
            o.Alpha = 1;
        }
        
        ENDCG
    }
    Fallback "Diffuse"
}
