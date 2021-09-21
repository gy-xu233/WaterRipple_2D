Shader "Unlit/computeRippleShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_HeightTex("Texture",2D) = "black"{}
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float4 screenPos : TEXCOORD1;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float4 screenPos : TEXCOORD1;
				};

				sampler2D _HeightTex;
				float4 _HeightTex_ST;
				sampler2D _MainTex;
				float4 _MainTex_ST;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _HeightTex);
					o.screenPos = ComputeScreenPos(o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float3 e = float3(float2(1., 1.) / _ScreenParams.xy, 0.);
					float2 q = (i.screenPos.xy / i.screenPos.w);
					float p10 = tex2D(_HeightTex, q - e.zy).x;
					float p01 = tex2D(_HeightTex, q - e.xz).x;
					float p21 = tex2D(_HeightTex, q + e.xz).x;
					float p12 = tex2D(_HeightTex, q + e.zy).x;

					float3 grad = normalize(float3(p21 - p01, p12 - p10, 1.));
					float4 c = tex2D(_MainTex, q.xy + grad.xy * 0.65);
					float3 light = normalize(float3(.2,-.5,.7));
					float diffuse = dot(grad,light);
					float spec = pow(max(0.,-reflect(light,grad).z),32.);
					float4 col = (c * 0.75 + float4(.7,.8,1.,1.) * .25) * max(diffuse,0.) + spec;
					return col;
				}
				ENDCG
			}
		}
}
