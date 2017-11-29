Shader "Custom/SIVADensity/Background"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_StaticIntensity ("Static intensity", Float) = 0.25
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _StaticIntensity;
			sampler2D _Noise;
			sampler2D _SIVALogo;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				// apply abberation to UVs
				float2 center = float2(0.5, 0.5);
				float2 rUV = i.uv;
				float2 gUV = lerp(i.uv, center, 0.05 * _StaticIntensity);
				float2 bUV = lerp(i.uv, center, 0.1 * _StaticIntensity);

				// sample input texture
				float r = tex2D(_MainTex, rUV).r;
				float g = tex2D(_MainTex, gUV).g;
				float b = tex2D(_MainTex, bUV).b;
				float4 src = float4(r, g, b, 1);
				
				// add static noise
				src += float4(
					tex2D(_Noise, rUV).a * _StaticIntensity,
					tex2D(_Noise, gUV).a * _StaticIntensity,
					tex2D(_Noise, bUV).a * _StaticIntensity, 0);

				return src;
			}
			ENDCG
		}
	}
}
