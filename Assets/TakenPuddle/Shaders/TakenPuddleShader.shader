Shader "Custom/TakenPuddle"
{
	Properties
	{
		_FringeTexture ("Fringe texture", 2D) = "white" {}
		_FringeMultiplier ("Fringe multiplier", Float) = 5
        
		_TimeScale ("Time scale", Float) = 0.1
		_NoiseAmplitude ("Noise amplitude", Float) = 2
		_NoiseWavelength ("Noise wavelength", Float) = 0.2
	}

    SubShader
	{
        Tags
        {
            "RenderType" = "Opaque" 
            "ForceNoShadowCasting"="True"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            // -----------------------------------------------------
            // NOISE function (adapted)
            //
            // By Morgan McGuire @morgan3d, http://graphicscodex.com
            // Reuse permitted under the BSD license.
            // -----------------------------------------------------
            #define NOISE fbm
            #define NUM_NOISE_OCTAVES 5
            float hash(float n) { return frac(sin(n) * 1e4); }
            float noise(float3 x) {
                const float3 step = float3(110, 241, 171);
                float3 i = floor(x);
                float3 f = frac(x);
                float n = dot(i, step);
                float3 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(lerp( hash(n + dot(step, float3(0, 0, 0))), hash(n + dot(step, float3(1, 0, 0))), u.x),
                            lerp( hash(n + dot(step, float3(0, 1, 0))), hash(n + dot(step, float3(1, 1, 0))), u.x), u.y),
                        lerp(lerp( hash(n + dot(step, float3(0, 0, 1))), hash(n + dot(step, float3(1, 0, 1))), u.x),
                            lerp( hash(n + dot(step, float3(0, 1, 1))), hash(n + dot(step, float3(1, 1, 1))), u.x), u.y), u.z);
            }
            float fbm(float3 x) {
                float v = 0.0;
                float a = 0.5;
                float3 shift = float3(100, 100, 100);
                for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
                    v += a * noise(x);
                    x = x * 2.0 + shift;
                    a *= 0.5;
                }
                return v;
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float4 barycentric : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 pos : POSITION1;
                float3 barycentric : TANGENT;
            };
            
            sampler2D _FringeTexture;
            float _FringeMultiplier;

            float _TimeScale;
		    float _NoiseAmplitude;
		    float _NoiseWavelength;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = v.vertex.xyz;
                o.barycentric = v.barycentric;
                return o;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                // adapted from https://www.redblobgames.com/x/1730-terrain-shader-experiments/noisy-hex-rendering.html

                float seed = _Time.y * _TimeScale;
                float2 offset = i.pos.xy / _NoiseWavelength;
                float3 noisy = i.barycentric + _NoiseAmplitude * float3(
                    NOISE(float3(offset.x, offset.y, 0.9 + seed)),
                    NOISE(float3(offset.x, offset.y, 0.5 + seed)),
                    NOISE(float3(offset.x, offset.y, 0.4 + seed)));

                float max_gb = max(noisy.g, noisy.b);
                if (noisy.r > max_gb)
                {
                    float diff = noisy.r - max_gb;
                    float fringe = diff * _FringeMultiplier;
                    return float4(tex2D(_FringeTexture, float2(fringe, 0)).rgb, 1);
                }
                else
                {
                    clip(-1);
                }
                return float4(0, 0, 0, 1);
            }
            ENDCG
        }
    }
}
