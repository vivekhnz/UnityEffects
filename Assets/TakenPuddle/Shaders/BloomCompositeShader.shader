Shader "Custom/Bloom/Composite"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "black" {}
        _BlurredTex ("Blurred Texture", 2D) = "black" {}
		_Intensity ("Intensity", Float) = 1
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
            sampler2D _BlurredTex;
            float _Intensity;
             
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
                // additively blend scene and blurred textures
                float4 scene = tex2D(_MainTex, i.uv);
                float4 blurred = tex2D(_BlurredTex, i.uv);
                return scene + (blurred * _Intensity);
            }
             
            ENDCG
 
        } 
    }
    Fallback "Diffuse"
}