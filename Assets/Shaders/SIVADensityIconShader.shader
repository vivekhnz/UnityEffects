Shader "Custom/SIVADensity/Icon"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalizedJitterOffset ("Normalized jitter offset", Float) = -0.05
		_DistortionTimeScale ("Distortion time scale", Float) = 10
		_DistortionSliceSize ("Distortion slice size", Float) = 0.015
	}
	SubShader
	{
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			static const float PI = 3.14159265f;

			sampler2D _MainTex;
			float _NormalizedJitterOffset;
			float _DistortionTimeScale;
			float _DistortionSliceSize;
			float _DistortionAmplitude;
			float _Opacity;

			float _HorizontalOffset;

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

				o.vertex = UnityObjectToClipPos(v.vertex * 2) + float4(
					_HorizontalOffset * _NormalizedJitterOffset, 0, 0, 0);
				o.uv = v.uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float2 scaledUV = (i.uv * 2) - float2(0.5, 0.5);

				float time = floor(_Time.y * _DistortionTimeScale) + 1;
				float slice = floor(scaledUV.y / _DistortionSliceSize) * _DistortionSliceSize;
				float sliceProgress = (scaledUV.y % _DistortionSliceSize) / _DistortionSliceSize;
				float sliceOffset = random(slice * _ScreenParams * time);
				float distortion = cos(sliceProgress * PI) * sliceOffset;
				float offset = distortion * _DistortionAmplitude;

				float4 src = tex2D(_MainTex, scaledUV + float2(offset, 0));
				return float4(src.rgb, src.a * _Opacity);
			}
			ENDCG
		}
	}
}
