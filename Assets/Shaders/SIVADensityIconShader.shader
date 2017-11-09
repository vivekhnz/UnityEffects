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

				o.vertex = UnityObjectToClipPos(v.vertex) + float4(
					_HorizontalOffset * -0.05, 0, 0, 0);
				o.uv = v.uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float sliceSize = 0.01;
				float slice = floor(i.uv.y / sliceSize) * sliceSize;
				float progress = (i.uv.y % sliceSize) / sliceSize;
				// slice = lerp(0.5, slice, (i.uv.y % sliceSize) / sliceSize);
				float sliceOffset = random(float2(0, slice) * _ScreenParams * _Time);
				float distortion = lerp(0, sliceOffset, cos(progress * PI));
				float offset = distortion * 0.15;

				float2 uv = i.uv + float2(offset, 0);

				float4 src = tex2D(_MainTex, uv);
				return float4(src.rgb, src.a * 0.05);
			}
			ENDCG
		}
	}
}
