Shader "Custom/TakenStreaks"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
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
			};
			
			fixed4 _Color;
			float3 _Origin;
			float _Radius;

			v2f vert(appdata_particles IN)
			{
				v2f OUT;

				// calculate depth
				float z = -UnityObjectToViewPos(IN.vertex).z * _ProjectionParams.w;
				
				// extract particle center position and per-particle random value
				float3 center = IN.texcoord0.xyz;
				float random = IN.texcoord0.w;

				// randomly distribute particle within sphere
				float progress = lerp(0.1, 1, pow(random, 0.75));
				float3 offset = normalize(center - _Origin) * progress * _Radius;
				
				// scale particle size based on proximity
				float3 relativeOffset = IN.vertex.xyz - center;
				float scale = max(0.9 - (z * 10), 0) + 0.1;
				scale = scale * max(1 - (z * lerp(3, 5, random)), 0);
				float3 position = _Origin + offset + (relativeOffset * scale);

				OUT.vertex = UnityObjectToClipPos(position);
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif
				
				return OUT;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				return fixed4(IN.color.rgb, 0);
			}

			ENDCG
		}
	}
}