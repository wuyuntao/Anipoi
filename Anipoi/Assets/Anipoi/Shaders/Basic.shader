Shader "Anipoi/Basic"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_RampTex("Toon Ramp (RGB)", 2D) = "gray" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf ToonRamp
		#pragma target 3.0

		sampler2D _RampTex;

		half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half atten) {
			#ifndef USING_DIRECTIONAL_LIGHT
			lightDir = normalize(lightDir);
			#endif

			half lambert = dot(s.Normal, lightDir) * 0.5 + 0.5;
			half3 ramp = tex2D(_RampTex, float2(lambert, lambert)).rgb;

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten * 2;
			c.a = s.Alpha;

			return c;
		}

		sampler2D _MainTex;
		sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
		}
		ENDCG
	}

	FallBack "Mobile/Diffuse"
}
