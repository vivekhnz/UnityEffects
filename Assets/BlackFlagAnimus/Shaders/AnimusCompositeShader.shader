Shader "Custom/BlackFlagAnimus/Composite"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "black" {}
        
		_ScanTimeMultiplier ("Scan time multiplier", Float) = 0.075
		_ScanFringeWidth ("Scan fringe width", Float) = 0.02
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
 
            sampler2D _MainTex;
            sampler2D _WireframeTex;
            sampler2D _CameraDepthTexture;
            
            float3 _BackgroundColor;
            float _ScanTimeMultiplier;
            float _ScanFringeWidth;
             
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
                float start = (_Time.y * _ScanTimeMultiplier) % 1;
                float end = start + _ScanFringeWidth;

                // hide objects that have not been scanned
                if (depth > end)
                {
                    return float4(_BackgroundColor, 1);
                }

                // render scan fringe
                float3 output = tex2D(_WireframeTex, i.uv);
                if (depth > start && depth < end && depth < 1)
                {
                    float progress = (depth - start) / (end - depth);
                    output = lerp(output, float3(1, 1, 1), progress);
                }

                // show objects that have been scanned
                return float4(output, 1);
            }
             
            ENDCG
 
        } 
    }
    Fallback "Diffuse"
}