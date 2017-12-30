Shader "Custom/OxenfreeRewind"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Static noise texture", 2D) = "white" {}
		_NoiseScale ("Noise scale", Float) = 0.001
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
			
			sampler2D _MainTex;
			sampler2D _NoiseTex;

			float _NoiseScale;
			float _StaticIntensity;

			// adapted from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader/10625698#10625698
			float random(float2 p)
			{
				float2 K1 = float2(
					23.14069263277926, // e^pi (Gelfond's constant)
					2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
				);
				return frac(cos(dot(p,K1)) * 12345.6789);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 base = tex2D(_MainTex, i.uv).rgb;

				float2 uv = i.uv * _ScreenParams.xy * _NoiseScale;
				uv += float2((random(_Time.x) * 2) - 1, (random(_Time.x + 1) * 2) - 1);
				float3 noise = tex2D(_NoiseTex, uv);
			
				float3 result = lerp(base, noise, _StaticIntensity);
				return fixed4(result.rgb, 1);
			}
			ENDCG
		}
	}
}
