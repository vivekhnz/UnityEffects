Shader "Custom/BlackFlagAnimus/Wireframe"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_WireframeBackgroundColor ("Background color", Color) = (0.0, 0.0, 0.0, 1)
		_WireframeLineColor ("Line color", Color) = (1.0, 1.0, 1.0, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float3 _WireframeBackgroundColor;
			float3 _WireframeLineColor;
			float _WireframeScanProgress;
            float _ScanFringeWidth;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

            struct v2g 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float depth : DEPTH;
				float2 screenPos : TEXCOORD1;
            };
			
            struct g2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float4 barycentric : TANGENT;
            };
             
            v2g vert (appdata v) 
            {
                v2g o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.depth = -UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w;
				
				// calculate screen position
				float4 screenPos = ComputeScreenPos(o.pos);
                o.screenPos = screenPos.xy / screenPos.w;

				return o;
            }

			[maxvertexcount(3)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> tris)
			{
				g2f o;

				v2g a = i[0];
				v2g b = i[1];
				v2g c = i[2];

				// calculate midpoints
				float2 midpointAB = (a.screenPos + b.screenPos) / 2;
				float2 midpointAC = (a.screenPos + c.screenPos) / 2;
				float2 midpointBC = (b.screenPos + c.screenPos) / 2;

				// calculate and attach barycentric coordinates
				o.pos = a.pos;
				o.uv = a.uv;
				o.barycentric.xyz = float3(distance(midpointAB, a.screenPos), 0, 0);
				o.barycentric.w = a.depth;
				tris.Append(o);

				o.pos = b.pos;
				o.uv = b.uv;
				o.barycentric.xyz = float3(0, distance(midpointAC, b.screenPos), 0);
				o.barycentric.w = b.depth;
				tris.Append(o);
				
				o.pos = c.pos;
				o.uv = c.uv;
				o.barycentric.xyz = float3(0, 0, distance(midpointBC, c.screenPos));
				o.barycentric.w = c.depth;
				tris.Append(o);
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				// retrieve distance to edge and depth values
				float dist = min(min(i.barycentric.x, i.barycentric.y), i.barycentric.z);
				float depth = i.barycentric.w;

				// calculate scan fringe
                float end = _WireframeScanProgress;
                float start = end - _ScanFringeWidth;

				// hide objects that have not been scanned
                if (depth > end)
                {
                    return fixed4(_WireframeBackgroundColor, 1);
                }

				// render scan fringe
                if (depth > start && depth < end)
                {
					// calculate line visibility
					float visibility = pow(1 - depth, 2);
					float threshold = (1 - depth) * 0.0004;
					if (dist > threshold)
					{
						visibility *= pow(threshold / dist, lerp(0.75, 2, depth));
					}
					float3 color = lerp(_WireframeBackgroundColor, _WireframeLineColor, visibility);

					// calculate fringe visibility
                    float progress = (depth - start) / (end - start);
					float t = 16 * pow(progress - 0.5, 4);
                    return fixed4(lerp(color, _WireframeBackgroundColor, t), 1);
                }

				return fixed4(_WireframeBackgroundColor, 1);
			}
			ENDCG
		}
	}
}
