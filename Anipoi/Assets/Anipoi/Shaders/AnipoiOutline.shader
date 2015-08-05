Shader "Anipoi/Outline" {
	Properties {
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_RampTex ("Ramp (RGB)", 2D) = "gray" {}

		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_OutlineWidth ("Outline Width", Range (0.00002, 0.0003)) = 0.005
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		UsePass "Anipoi/Basic/FORWARD"
		// note that a vertex shader is specified here but its using the one above
		Pass {
			Name "OUTLINE"
			Tags { "LightMode" = "Always" }
			Cull Front
			ZWrite On
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : POSITION;
				UNITY_FOG_COORDS(0)
				float4 color : COLOR;
			};

			float _OutlineWidth;
			float4 _OutlineColor;

			v2f vert(appdata v) {
				// just make a copy of incoming vertex data but scaled according to normal direction
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				float2 offset = TransformViewToProjection(norm.xy);

				o.pos.xy += offset * o.pos.z * _OutlineWidth;
				o.color = _OutlineColor;
				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			half4 frag(v2f i) :COLOR {
				UNITY_APPLY_FOG(i.fogCoord, i.color);
				return i.color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
