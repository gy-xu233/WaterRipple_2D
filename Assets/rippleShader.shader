Shader "Unlit/rippleShader"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		iMouse("mouse", Vector) = (0, 0, 0, 0)
		_RippleWidth("Ripple Width", float) = 1.0
		_RippleHeight("Ripple Height", float) = 1.0
		_Counter("Counter",int) = 0
		_IfClick("IfClick",int) = 0
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

			sampler2D _bufferA;
		    float4 _bufferA_ST;
			float4 iMouse;
			float _RippleWidth;
			float _RippleHeight;
			int _IfClick;
			int _Counter;

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

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _bufferA);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{

				float3 e = float3(float2(_RippleWidth, _RippleHeight) / _ScreenParams.xy, 0.);

				float2 q = (i.screenPos.xy / i.screenPos.w);
				float4 c = tex2D(_bufferA, q);

				float p11 = c.y;

				float p10 = tex2D(_bufferA, q - e.zy).x;
				float p01 = tex2D(_bufferA, q - e.xz).x;
				float p21 = tex2D(_bufferA, q + e.xz).x;
				float p12 = tex2D(_bufferA, q + e.zy).x;

				float d = smoothstep(8.5, 0.5, length(iMouse - (q * _ScreenParams.xy)));

				d *= step(0.5, _IfClick);

				d += -(p11 - .5) * 2. + (p10 + p01 + p21 + p12 - 2.);
				d *= 0.99; 
				d *= step(0.5, _Counter);
				d = d * .5 + .5;

				return fixed4(d, c.x, 0, 0);
			}
			ENDCG
        }
        GrabPass{ "_bufferA" }
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

			sampler2D _bufferA;
			float4 _bufferA_ST;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _bufferA);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

            fixed4 frag(v2f i) : SV_Target
            {
				float3 e = float3(float2(1., 1.) / _ScreenParams.xy, 0.);
				float2 q = (i.screenPos.xy / i.screenPos.w);
				float p10 = tex2D(_bufferA, q - e.zy).x;
				float p01 = tex2D(_bufferA, q - e.xz).x;
				float p21 = tex2D(_bufferA, q + e.xz).x;
				float p12 = tex2D(_bufferA, q + e.zy).x;

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
