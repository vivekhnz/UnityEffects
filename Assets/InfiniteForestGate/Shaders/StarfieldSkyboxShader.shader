Shader "Custom/InfiniteForestGate/Skybox"
{
	Properties
	{
		_StarfieldTexture ("Starfield texture", 2D) = "white" {}
		_BackgroundColor ("Background color", Color) = (0, 0, 0, 1)
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

		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			
			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			float3 starfield = 0;
			starfield += tex2D(_StarfieldTexture, frac(i.uv * 2));
			starfield += tex2D(_StarfieldTexture, frac(i.uv * 3)) * 0.5;
			starfield += tex2D(_StarfieldTexture, frac(i.uv * 4)) * 0.25;
			return fixed4(_BackgroundColor + starfield.rgb, 1);
		}

		ENDCG

		Pass { CGPROGRAM ENDCG }
		Pass { CGPROGRAM ENDCG }
		Pass { CGPROGRAM ENDCG }
		Pass { CGPROGRAM ENDCG }
		Pass { CGPROGRAM ENDCG }
		Pass { CGPROGRAM ENDCG }
	}
}