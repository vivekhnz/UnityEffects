Shader "Custom/SIVADensityShader"
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

			float _StaticIntensity;

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

			// adapted from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader/10625698#10625698
			float random(float2 p)
			{
				float2 K1 = float2(
					23.14069263277926, // e^pi (Gelfond's constant)
					2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
				);
				return frac(cos(dot(p,K1)) * 12345.6789);
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			float4 frag(v2f i) : SV_Target
			{
				float4 src = tex2D(_MainTex, i.uv);
				float rand = random(i.uv * _ScreenParams * _Time.y);
				float noise = rand * _StaticIntensity;
				src += float4(noise, noise, noise, 0);
				return src;
			}
			ENDCG
		}
	}
}
