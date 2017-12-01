Shader "Custom/TakenPuddle"
{
	Properties
	{
		_InnerColor ("Inner color", Color) = (0.0, 0.0, 0.0, 1)
		_OuterColor ("Outer color", Color) = (1.0, 1.0, 1.0, 1)

		_FringeTexture ("Fringe texture", 2D) = "white" {}
		_FringeRadius ("Fringe radius", Float) = 0.1
	}

    SubShader
	{
        Tags
        {
            "RenderType" = "Opaque" 
            "ForceNoShadowCasting"="True"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 barycentric : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 barycentric : TANGENT;
            };

            float4 _InnerColor;
            float4 _OuterColor;

            sampler2D _FringeTexture;
            float _FringeRadius;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.barycentric = v.barycentric;
                return o;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                return tex2D(_FringeTexture, float2(i.barycentric.x / _FringeRadius, 0));
            }
            ENDCG
        }
    }
}
