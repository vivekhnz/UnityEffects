Shader "Custom/BlackFlagAnimus/Composite"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "black" {}
    }
    SubShader 
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
 
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

			static const float PI = 3.14159265f;
 
            sampler2D _MainTex;
            sampler2D _WireframeTex;
            sampler2D _CameraDepthTexture;
            
            float3 _BackgroundColor;
			float _ScanProgress;
            float _ScanFringeWidth;
            float _ScanLineOpacity;
            float _FlashBrightness;
             
            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
             
            v2f vert (appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = o.pos.xy / 2 + 0.5;
                return o;
            }
            
            float4 frag(v2f i) : COLOR 
            {
                // retrieve depth
                float rawDepth = DecodeFloatRG(tex2D(_CameraDepthTexture, i.uv));
				float depth = Linear01Depth(rawDepth);
                
                // calculate scan fringe
                float end = _ScanProgress;
                float start = end - _ScanFringeWidth;

                float3 output = tex2D(_MainTex, i.uv);
                output = lerp(_BackgroundColor, output, pow(_ScanProgress, 2.5));
                if (depth > end)
                {
                    // hide objects that have not been scanned
                    output = tex2D(_WireframeTex, i.uv);
                }
                else if (depth > start && depth < 1)
                {
                    // render scan fringe
                    float progress = (depth - start) / (end - start);
                    output = lerp(output, float3(1, 1, 1), progress);
                }

                // render scan lines
                float y = i.uv.y + (_Time.y * 0.1);
                float scanLineVisibility = (sin(300 * PI * y) + 1) / 2;
                output = lerp(output, float3(1, 1, 1), scanLineVisibility * _ScanLineOpacity);

                // apply brightness flash
                output = lerp(output, float3(1, 1, 1), _FlashBrightness);

                // show objects that have been scanned
                return float4(output, 1);
            }
             
            ENDCG
 
        } 
    }
    Fallback "Diffuse"
}