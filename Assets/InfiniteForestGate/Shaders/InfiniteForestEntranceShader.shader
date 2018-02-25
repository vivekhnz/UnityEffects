Shader "Custom/InfiniteForestGate/Entrance"
{
	Properties
	{
		_GridTexture ("Grid texture", 2D) = "white" {}

		_UVScrollSpeed ("UV inward scroll speed", Float) = 1
		_PyramidCutoff ("Pyramid cutoff", Float) = 0.9
		_GridOpacityRamp ("Grid opacity ramp", Float) = 1
		_BaseColor ("Base color", Color) = (0, 0, 0, 1)
		
		_EdgeWidth ("Edge width", Float) = 0.03
		_LatticeMaxLength ("Lattice max length", Float) = 0.3
		_LatticeSliceWidth ("Lattice slice width", Float) = 0.015
		_LatticeMaxBlockLength ("Lattice max block length", Float) = 0.1

		_LatticeInitialOpacity ("Lattice initial opacity", Float) = 0.5
		_LatticeMaxOpacity ("Lattice max opacity", Float) = 0.75
		_LatticeOpacityDropoff ("Lattice opacity dropoff threshold", Float) = 0.9
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

        CGINCLUDE

		#pragma vertex vert
		#pragma fragment frag
		
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float4 uv_distance : TANGENT;
		};

		ENDCG

		// Face
		Pass
		{
			// alpha blending
			Blend SrcAlpha OneMinusSrcAlpha
			// don't write to the Z-buffer so the grid can be drawn on top
			ZWrite Off

			CGPROGRAM
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 distance : NORMAL;
				float4 screenUVDepth : TANGENT;
			};

			sampler2D _PortalSkyboxTexture;

			float3 _BaseColor;
			float _GridOpacityRamp;
			float3 _InnerPoint;

			float _LatticeMaxLength;
			float _LatticeSliceWidth;
			float _LatticeMaxBlockLength;

			float _LatticeInitialOpacity;
			float _LatticeMaxOpacity;
			float _LatticeOpacityDropoff;

			float _EdgeWidth;

			// adapted from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader/10625698#10625698
			float random(float2 p)
			{
				float2 K1 = float2(
					23.14069263277926, // e^pi (Gelfond's constant)
					2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
				);
				return frac(cos(dot(p,K1)) * 12345.6789);
			}

			float latticeBlock(float dist, float seed)
			{
				seed = seed % 1;
				float blockLength = _LatticeMaxBlockLength * seed;
				float cutoff = seed * _LatticeMaxLength;
				
				float t = (_Time.y + 10) * 0.1;
				float cycleProgress = t % (blockLength + cutoff);
				
				float upperBound = min(cycleProgress, cutoff);
				float lowerBound = min(cycleProgress - blockLength, cutoff);

				if (dist > lowerBound && dist < upperBound)
				{
					float initial = _LatticeInitialOpacity;
					float max = _LatticeMaxOpacity;
					float dropoff = _LatticeOpacityDropoff;

					float p = dist / cutoff;
					float inCurve = ((p * (max - initial)) / dropoff) + initial;
					float outCurve = (max * (1 - p)) / (1 - dropoff);
					float s = step(p, dropoff);
					return (inCurve * s) + (outCurve * (1 - s));
				}
				return 0;
			}

			float blend(float front, float back)
			{
				float m = ceil(front) * 0.75;
				return (front * m) + (back * (1 - m));
			}

			v2f vert (appdata v)
			{
				v2f o;
				v.vertex.z = 0;
				
				o.distance = v.uv_distance.zw;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				float4 screenPos = ComputeScreenPos(o.vertex);
				float depth = -UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w;
				o.screenUVDepth = float4(screenPos.xy, screenPos.w, depth);
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// fade out skybox towards the edges
				float2 correctedScreenUV = i.screenUVDepth.xy / i.screenUVDepth.z;
				float3 skybox = tex2D(_PortalSkyboxTexture, correctedScreenUV);
				skybox = lerp(skybox, _BaseColor, 1 - i.distance.x);
				
				// apply a dark tint at the edges
				float tintOpacity = pow(i.distance.x, _GridOpacityRamp / 4);
				float3 output = lerp(_BaseColor / 2, skybox, tintOpacity * 2);

				// divide the edge into discrete slices
				float div = i.distance.y / _LatticeSliceWidth;
				float slice = _LatticeSliceWidth * floor(div);
				
				// vary slice widths
				float variance = max(floor((4 * frac(div)) - 1), 0) / 3;
				slice += variance;
				float seed = random(slice.xx);

				// draw edge lattice
				float opacity = latticeBlock(i.distance.x, seed);
				for (int n = 0; n < 3; n++)
				{
					float s = seed + (0.1 * n);
					opacity = blend(latticeBlock(i.distance.x, s), opacity);
				}
				float3 lattice = opacity.xxx;

				// draw hard edge
				float p = ((_EdgeWidth * 2) - i.distance.x) / _EdgeWidth;
				output = lerp(output + lattice, float3(1, 1, 1), min(max(p, 0), 1));
				
				return fixed4(output, 1);
			}
			
			ENDCG
		}
		
		// Grid
		Pass
		{
			// use additive blending
			Blend One One
			ZWrite Off
			Cull Off

			CGPROGRAM
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float distance : NORMAL;
			};
			
            sampler2D _GridTexture;
			float4 _GridTexture_ST;

			float _UVScrollSpeed;
			float _PyramidCutoff;
			float _GridOpacityRamp;
			float3 _InnerPoint;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				o.distance = v.uv_distance.z;

				float2 pos = v.vertex.xy - _InnerPoint;
				float hypotenuse = length(pos);
				if (hypotenuse > 0)
				{
					// calculate progress through animation
					float t = (_Time.y * 0.4) % 1.75;
					float turningPoint = o.distance + 0.25;
					float progress = step(t, turningPoint);

					// return to initial position at a slower rate
					float inCurve = 2 * t;
					float maxOutCurve = t + turningPoint;
					float outCurve = lerp(inCurve, maxOutCurve, (sin(_Time.y) + 1) / 2);
					float curve = (inCurve * progress) + (outCurve * (1 - progress));
					
					// calculate amount to twist
					float twist = (-2 * pow(curve - (2 * o.distance) - 0.5, 2)) + 0.5;
					twist = max(twist, 0);
					twist *= pow(o.distance, 0.25);

					// twist vertices around center point
					float theta = atan2(pos.y, pos.x) + twist;
					float scale = 1 - (pow(o.distance, 2) * v.uv_distance.w * twist);
					pos.xy = float2(cos(theta), sin(theta)) * hypotenuse * scale;
				}
				o.vertex = UnityObjectToClipPos(float4(_InnerPoint + pos, v.vertex.zw));

				// scroll UVs inward
				o.uv = TRANSFORM_TEX(v.uv_distance.xy, _GridTexture);
				o.uv += float2(0, -(_Time.y * _UVScrollSpeed) % 1);
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// cut off grid at center to show central triangle
				float3 grid = tex2D(_GridTexture, i.uv).rgb;
				float gridOpacity = step(i.distance, _PyramidCutoff);

				// fade out grid at the outer edges
				gridOpacity *= pow(i.distance, _GridOpacityRamp);
				return fixed4(grid * gridOpacity, 1);
			}
			ENDCG
		}
	}
}