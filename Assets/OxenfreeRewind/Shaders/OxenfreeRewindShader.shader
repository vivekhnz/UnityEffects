Shader "Custom/OxenfreeRewind"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Static noise texture", 2D) = "white" {}
		
		_NoiseScale ("Noise scale", Float) = 0.001
		_MaxWaveDisplacement ("Max wave displacement", Float) = 0.05
		_MaxJitterDisplacement ("Max jitter displacement", Float) = 0.02
		_JitterDelay ("Jitter function time delay", Float) = 0.1
		_BaseJitterRatio ("Constant to wave jitter ratio", Float) = 0.25
		_TintIntensity ("Tint intensity", Float) = 0.05
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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 noiseUV : TEXCOORD1;
			};

			static const float PI = 3.14159265f;
			
			sampler2D _MainTex;
			sampler2D _NoiseTex;

			float _NoiseScale;
			float _MaxWaveDisplacement;
			float _MaxJitterDisplacement;
			float _JitterDelay;
			float _BaseJitterRatio;
			float _TintIntensity;

			float _Intensity;

			// adapted from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader/10625698#10625698
			float random(float2 p)
			{
				float2 K1 = float2(
					23.14069263277926, // e^pi (Gelfond's constant)
					2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
				);
				return frac(cos(dot(p,K1)) * 12345.6789);
			}

			float rewind(float y)
			{
				// calculate 'rewind' wave
				float t = (1 - y) + (_Time.y * 0.4);
				float A = cos(2 * PI * t) + 1;
				float B = cos(7 * PI * t) + 1;
				return (A * B) / 4;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				// randomly displace UVs for noise texture
				o.noiseUV = o.uv * _ScreenParams.xy * _NoiseScale;
				o.noiseUV += float2((random(_Time.x) * 2) - 1, (random(_Time.x + 1) * 2) - 1);
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// derive effect intensity values
				float iWaveDisplacement = max(0, min(4 * _Intensity, 1));
				float iJitterDisplacement = max(0, min((4 * _Intensity) - 1, 1));
				float iStatic = max(0, min((4 * _Intensity) - 2, 1));
				float iStaticOverlay = max(0, min((4 * _Intensity) - 3, 1));

				// calculate displacement 'wave'
				float t = rewind(i.uv.y);

				// calculate delayed displacement 'jitter'
				float rowNoise = tex2D(_NoiseTex, float2(0, i.noiseUV.y)).r;
				float tDelayed = rewind(i.uv.y + _JitterDelay);
				float constantJitterAmplitude = (cos(_Time.y * PI) + 3) / 4;
				float waveJitter = min(tDelayed, 1 - _BaseJitterRatio);
				float constantJitter = constantJitterAmplitude * _BaseJitterRatio;
				float jitter = rowNoise * (waveJitter + constantJitter);
				
				// apply displacement to main texture
				float2 displacement = float2(0, 0);
				displacement.x += t * _MaxWaveDisplacement * iWaveDisplacement;
				displacement.x += jitter * _MaxJitterDisplacement * iJitterDisplacement;
				float3 base = tex2D(_MainTex, i.uv + displacement).rgb;
				
				// blend between main texture and static noise
				float3 pointNoise = tex2D(_NoiseTex, i.noiseUV);
				float3 blended = lerp(base, pointNoise, t * iStatic);

				// apply a blue tint based on effect intensity
				float3 tinted = lerp(blended, float3(0, 0, 1), _Intensity * _TintIntensity);

				// blend with static overlay
				float3 result = lerp(tinted, pointNoise, iStaticOverlay);
				return fixed4(result.rgb, 1);
			}
			ENDCG
		}
	}
}
