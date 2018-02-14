Shader "Custom/InfiniteForestGate/Entrance"
{
	Properties
	{
		_GridTexture ("Grid texture", 2D) = "white" {}

		_UVScrollSpeed ("UV inward scroll speed", Float) = 1
		_PyramidCutoff ("Pyramid cutoff", Float) = 0.9
		_GridOpacityRamp ("Grid opacity ramp", Float) = 1
		_BaseColor ("Base color", Color) = (0, 0, 0, 1)
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
				float distance : NORMAL;
				float4 screenUVDepth : TANGENT;
			};

			sampler2D _PortalSkyboxTexture;

			float3 _BaseColor;
			float _GridOpacityRamp;

			v2f vert (appdata v)
			{
				v2f o;
				
				o.distance = v.uv_distance.z;
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
				skybox = lerp(skybox, _BaseColor, 1 - i.distance);
				
				// apply a dark tint at the edges
				float tintOpacity = pow(i.distance, _GridOpacityRamp / 4);
				float3 output = lerp(_BaseColor / 2, skybox, tintOpacity * 2);

				// draw edge lattice
				float a = 0.03;
				float b = 0.06;
				float p = (b - i.distance) / (b - a);
				output = lerp(output, float3(1, 1, 1), min(max(p, 0), 1));
				
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
					float t = (_Time.y * 0.75) % 1.75;
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