Shader "Custom/BlackFlagAnimus/Composite"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "black" {}
    }
    SubShader 
    {
        Cull Off ZWrite Off ZTest Always
        
        CGINCLUDE

        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        static const float PI = 3.14159265f;

        sampler2D _MainTex;
        sampler2D _WireframeTex;
        sampler2D _CameraDepthTexture;
        
        float3 _BackgroundColor;
        float3 _FogColor;
        float _FogAlpha;
        float _ScanProgress;
        float _ScanFringeWidth;
        float _ScanLineOpacity;
        float _WipeAlpha;
            
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
        
        ENDCG

        // In
        Pass
        {
            CGPROGRAM

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

                // apply solid color wipe
                output = lerp(output, float3(1, 1, 1), _WipeAlpha);

                // show objects that have been scanned
                return float4(output, 1);
            }
            
            ENDCG
        }

        // Out
        Pass
        {
            CGPROGRAM

            float4 frag(v2f i) : COLOR 
            {
                // retrieve depth
                float rawDepth = DecodeFloatRG(tex2D(_CameraDepthTexture, i.uv));
                float depth = Linear01Depth(rawDepth);
                
                // calculate scan fringe
                float end = 1 - (_ScanProgress * (_ScanFringeWidth + 1));
                float start = end + _ScanFringeWidth;

                // calculate fog
                float3 white = float3(1, 1, 1);
                float3 scene = tex2D(_MainTex, i.uv);
                float3 fog = lerp(white, _FogColor, _ScanProgress * 0.33);
                
                // render wireframe with scan lines
                float3 wireframe = tex2D(_WireframeTex, i.uv);
                float y = i.uv.y + (_Time.y * 0.1);
                float scanLineVisibility = (sin(300 * PI * y) + 1) / 2;
                wireframe = lerp(wireframe, white, scanLineVisibility * _ScanLineOpacity);

                float3 output = fog;
                if (depth > start)
                {
                    // blend between wireframe and fog
                    output = lerp(wireframe, fog, _FogAlpha);
                }
                else if (depth > end)
                {
                    // render scan fringe
                    float progress = (depth - start) / (end - start);
                    output = lerp(fog, scene, progress);
                }
                else if (depth < start)
                {
                    // show objects that have not been scanned
                    output = scene;
                }
                
                // apply solid color wipe
                output = lerp(output, float3(0, 0, 0), _WipeAlpha);
                return float4(output, 1);
            }
            
            ENDCG
        }
    }
    Fallback "Diffuse"
}