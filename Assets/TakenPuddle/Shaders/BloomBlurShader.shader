// adapted from https://github.com/Broxxar/GlowingObjectOutlines/blob/master/Assets/Resources/Blur.shader

Shader "Custom/Bloom/Blur"
{
    Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off
		ZWrite On
		ZTest Always

        CGINCLUDE

        #include "UnityCG.cginc"
        #pragma vertex vert
        #pragma fragment frag

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
			float4 screenPos : TEXCOORD1;
        };

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
			o.screenPos = ComputeScreenPos(o.vertex);
            return o;
        }
        
        sampler2D _MainTex;
		sampler2D _DepthTex;
		sampler2D _CameraDepthTexture;

        float2 _BlurSize;

        ENDCG

		// Mask
		Pass
        {
            CGPROGRAM
            float4 frag(v2f i) : COLOR 
            {
                float camDepth = Linear01Depth(tex2Dproj(_CameraDepthTexture,
                    UNITY_PROJ_COORD(i.screenPos)).r);
                float objDepth = tex2D(_DepthTex, i.uv).a;
                if (objDepth - camDepth > 0) return float4(0, 0, 0, 1);
                return float4(tex2D(_DepthTex, i.uv).rgb, 1);
            }
            ENDCG
        }

		// Horizontal
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 s = tex2D(_MainTex, i.uv) * 0.38774;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x * 2, 0)) * 0.06136;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x, 0)) * 0.24477;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x * -1, 0)) * 0.24477;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x * -2, 0)) * 0.06136;

				return s;
			}
			ENDCG
		}

		// Vertical
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 s = tex2D(_MainTex, i.uv) * 0.38774;
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y * 2)) * 0.06136;
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y)) * 0.24477;			
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y * -1)) * 0.24477;
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y * -2)) * 0.06136;

				return s;
			}
			ENDCG
		}
    }
    Fallback "Diffuse"
}