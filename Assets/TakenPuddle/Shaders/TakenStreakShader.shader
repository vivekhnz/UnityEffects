Shader "Custom/TakenPuddle/Streaks"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_NoiseTex ("Noise Texture", 2D) = "black" {}
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#include "UnityCG.cginc"
			
			struct appdata_particles
			{
				float4 vertex    : POSITION;
				float4 color     : COLOR;
				float4 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed3 color    : COLOR;
				float  depth	: DEPTH;
			};
			
			sampler2D _NoiseTex;

			fixed4 _Color;
			float3 _Origin;
			float _Radius;

			static const float PI = 3.14159265f;

			float calcRipple(float d, float random)
			{
				float t = _Time.y * 6;
				float x = (t + d + random) % 10;
				float ripple = 0;
				
				if (x < 1)
				{
					float z = PI * x;
					ripple = (cos(z) - 1) / 2;
				}
				else if (x < 4)
				{
					float z = (PI * (x + 0.5)) / 1.5;
					ripple = (cos(z) - 2) / 3;
				}
				else if (x < 5)
				{
					float z = PI * x;
					ripple = (sin(z) / 8) - 1;
				}
				else if (x < 7)
				{
					float z = PI * x;
					ripple = (cos(z) - 7) / 8;
				}
				else if (x < 8)
				{
					float z = PI * x;
					ripple = ((3 * cos(z)) - 1) / 4;
				}
				else if (x < 10)
				{
					float z = (6 * (x - 8)) / 17;
					ripple = 0.5 - pow(z, 2);
				}
				return ripple;
			}

			float calcRippleInfluence(float shift)
			{
				float a = 10;
				float duration = 2 * a;
				float t = (_Time.y + (shift * 3)) % duration;
				float ti = (t - duration) / (-a / t);
				return (cos(pow(ti, 2)) + 1) / 2;
			}

			v2f vert(appdata_particles IN)
			{
				v2f OUT;

				// calculate depth
				float z = -UnityObjectToViewPos(IN.vertex).z * _ProjectionParams.w;
				
				// extract particle center position and per-particle random value
				float3 center = IN.texcoord0.xyz;
				float random = IN.texcoord0.w;

				// randomly distribute particle within emission shape
				float progress = lerp(0.1, 1, pow(random, 0.75));
				float3 offsetDir = normalize(center - _Origin);
				float3 offset = offsetDir * progress * _Radius;

				// sample noise from texture
				float xAngle = (atan(offsetDir.x / offsetDir.y) / PI) + 0.5;
				float yAngle = (atan(offsetDir.z / offsetDir.y) / PI) + 0.5;
				float noise = tex2Dlod(_NoiseTex, float4(xAngle, yAngle, 0, 0)).r;
				
				// calculate ripple
				float d = pow(length(offset) / _Radius, 4);
				float ripple = calcRipple(d, random) * calcRippleInfluence(noise);
				
				// scale particle size based on proximity
				float3 relativeOffset = IN.vertex.xyz - center;
				float scale = max(0.9 - (z * 10), 0) + 0.1;
				scale = scale * max(1 - (z * lerp(3, 5, random)), 0);

				// adjust radius by ripple offset
				progress = progress + (ripple * 0.075);
				offset = offsetDir * progress * _Radius;
				float3 position = _Origin + offset + (relativeOffset * scale);

				OUT.vertex = UnityObjectToClipPos(position);
				OUT.color = IN.color * _Color;
				OUT.depth = z;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif
				
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				return fixed4(IN.color.rgb, IN.depth);
			}

			ENDCG
		}
	}
}