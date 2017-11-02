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

			sampler2D _MainTex;
			float _StaticIntensity;
			sampler2D _Noise;

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

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 src = tex2D(_MainTex, i.uv);
				float noise = tex2D(_Noise, i.uv).a * _StaticIntensity;
				src += float4(noise, noise, noise, 0);
				return src;
			}
			ENDCG
		}
	}
}
