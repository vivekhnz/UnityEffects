Shader "Custom/InfiniteForestGate/Entrance"
{
	Properties
	{
		_GridTexture ("Grid texture", 2D) = "white" {}

		_BaseColor ("Base color", Color) = (0, 0, 0, 1)
		_UVScrollSpeed ("UV inward scroll speed", Float) = 1
		_PyramidCutoff ("Pyramid cutoff", Float) = 0.9
		_GridOpacityRamp ("Grid opacity ramp", Float) = 1
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 uv_distance : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float distance : NORMAL;
			};
			
            sampler2D _GridTexture;
			float4 _GridTexture_ST;

			float3 _BaseColor;
			float _UVScrollSpeed;
			float _PyramidCutoff;
			float _GridOpacityRamp;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				// scroll UVs inward
				o.uv = TRANSFORM_TEX(v.uv_distance.xy, _GridTexture);
				o.uv += float2(0, -(_Time.y * _UVScrollSpeed) % 1);
				
				o.distance = v.uv_distance.z;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// cut off grid at center to show central triangle
				float3 grid = tex2D(_GridTexture, i.uv).rgb;
				float gridOpacity = step(i.distance, _PyramidCutoff);

				// fade out grid at the outer edges
				gridOpacity *= pow(i.distance, _GridOpacityRamp);
				
				float3 result = _BaseColor + (grid * gridOpacity);
				return fixed4(result, 1);
			}
			ENDCG
		}
	}
}
