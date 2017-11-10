Shader "Custom/SIVADensity/Icon"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
					_HorizontalOffset * -0.05, 0, 0, 0);
				o.uv = v.uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float2 scaledUV = (i.uv * 2) - float2(0.5, 0.5);

				float timeScale = 10;
				float time = floor(_Time.y * timeScale) + 1;
				float sliceSize = 0.015;
				float slice = floor(scaledUV.y / sliceSize) * sliceSize;
				float progress = (scaledUV.y % sliceSize) / sliceSize;
				float sliceOffset = random(float2(0, slice) * _ScreenParams * time);
				float distortion = cos(progress * PI) * sliceOffset;
				float offset = distortion * 0.15;

				float2 uv = scaledUV + float2(offset, 0);

				float4 src = tex2D(_MainTex, uv);
				return float4(src.rgb, src.a * 0.075);
			}
			ENDCG
		}
	}
}
