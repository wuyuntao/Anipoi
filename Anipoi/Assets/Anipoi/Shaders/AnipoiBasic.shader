Shader "Anipoi/Basic" {
  Properties{
    _Color("Color", Color) = (1, 1, 1, 1)
    _MainTex("Albedo (RGB)", 2D) = "white" {}
    _RampTex ("Ramp (RGB)", 2D) = "gray" {}
  }

  SubShader{
    Tags{ "RenderType" = "Opaque" }
    LOD 200

    CGPROGRAM
    // Physically based Standard lighting model, and enable shadows on all light types
    #pragma surface surf AnipoiBasic

    // Use shader model 3.0 target, to get nicer looking lighting
    #pragma target 3.0

    sampler2D _RampTex;

    half4 LightingAnipoiBasic(SurfaceOutput s, half3 lightDir, half atten) {
      half lambert = dot(s.Normal, lightDir) * 0.5 + 0.5;
      half3 ramp = tex2D(_RampTex, float2(lambert, lambert)).rgb;

      half4 c;
      c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten * 2;
      c.a = s.Alpha;
      return c;
    }

    sampler2D _MainTex;
    fixed4 _Color;

    struct Input {
      float2 uv_MainTex;
    };

    void surf(Input IN, inout SurfaceOutput o) {
      // Albedo comes from a texture tinted by color
      fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
      o.Albedo = c.rgb;
      o.Alpha = c.a;
    }
    ENDCG
  }

  FallBack "Diffuse"
}
