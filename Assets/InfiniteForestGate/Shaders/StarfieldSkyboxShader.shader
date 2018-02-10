Shader "Custom/InfiniteForestGate/Skybox"
{
	Properties
	{
		_StarfieldTexture ("Starfield texture", 2D) = "white" {}
		_BackgroundColor ("Background color", Color) = (0, 0, 0, 1)
		_RotationSpeed ("Rotation speed", Float) = 0.03
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Background"
		}

		Cull Off
		Fog
		{
			Mode Off
		}
		Lighting Off

		CGINCLUDE

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
		};

		sampler2D _StarfieldTexture;
		float3 _BackgroundColor;
		float _RotationSpeed;

		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			
			return o;
		}

		fixed4 rotateStarfield(float2 uv, bool clockwise)
		{
			float amount = (_Time.y * _RotationSpeed * 0.75) * (clockwise ? 1 : -1);
			float2 relative = uv - 0.5;
			float hypotenuse = length(relative);
			float base = atan2(relative.y, relative.x);
			
			float3 starfield = 0;
			
			float theta = base + (amount * 2);
			float2 rotated = float2(cos(theta), sin(theta)) * hypotenuse;
			starfield += tex2D(_StarfieldTexture, frac((rotated) * 1.0));
			
			theta = base + (amount * 1.5);
			rotated = float2(cos(theta), sin(theta)) * hypotenuse;
			starfield += tex2D(_StarfieldTexture, frac((rotated) * 1.5));

			theta = base + (amount * 1);
			rotated = float2(cos(theta), sin(theta)) * hypotenuse;
			starfield += tex2D(_StarfieldTexture, frac((rotated) * 2.0));

			return fixed4(_BackgroundColor + starfield.rgb, 1);
		}

		fixed4 scrollStarfield(float2 uv, float2 direction)
		{
			float2 amount = direction * _Time.y * _RotationSpeed;

			float3 starfield = 0;
			starfield += tex2D(_StarfieldTexture, frac((uv * 1.0) + amount));
			starfield += tex2D(_StarfieldTexture, frac((uv * 1.5) + amount));
			starfield += tex2D(_StarfieldTexture, frac((uv * 2) + amount));
			return fixed4(_BackgroundColor + starfield.rgb, 1);
		}

		ENDCG

		Pass
		{
			CGPROGRAM

			fixed4 frag (v2f i) : SV_Target
			{
				// clockwise
				return rotateStarfield(i.uv, true);
			}

			ENDCG
		}
		Pass
		{
			CGPROGRAM

			fixed4 frag (v2f i) : SV_Target
			{
				// anticlockwise
				return rotateStarfield(i.uv, false);
			}

			ENDCG
		}
		Pass
		{
			CGPROGRAM

			fixed4 frag (v2f i) : SV_Target
			{
				// down
				return scrollStarfield(i.uv, float2(0, 1));
			}

			ENDCG
		}
		Pass
		{
			CGPROGRAM

			fixed4 frag (v2f i) : SV_Target
			{
				// up
				return scrollStarfield(i.uv, float2(0, -1));
			}

			ENDCG
		}
		Pass
		{
			CGPROGRAM

			fixed4 frag (v2f i) : SV_Target
			{
				// right
				return scrollStarfield(i.uv, float2(-1, 0));
			}

			ENDCG
		}
		Pass
		{
			CGPROGRAM

			fixed4 frag (v2f i) : SV_Target
			{
				// left
				return scrollStarfield(i.uv, float2(1, 0));
			}

			ENDCG
		}
	}
}