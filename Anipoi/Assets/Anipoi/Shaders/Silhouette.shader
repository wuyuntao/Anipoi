Shader "Anipoi/Silhouette" {
  Properties {
    _Color("Color", Color) = (1,1,1,1)
    _SilhouetteColor("Silhouette Color", Color) = (0.5,0.5,0.5,1)
    _SilhouetteWidth("Silhouette Width", Range(0.00002, 0.05)) = 0.01
  }
  SubShader {
    Tags{ "RenderType" = "Opaque" }
    LOD 200

    Pass {
      Name "FRONT"
      Cull Back
      ZWrite On

      CGPROGRAM
      // use "vert" function as the vertex shader
      #pragma vertex vert
      // use "frag" function as the pixel (fragment) shader
      #pragma fragment frag
      
      float rand(float4 co)
      {
        return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
      }

      // vertex shader inputs
      struct appdata
      {
        float4 vertex : POSITION; // vertex position
        float2 uv : TEXCOORD0; // texture coordinate
      };

      // vertex shader outputs ("vertex to fragment")
      struct v2f
      {
        float2 uv : TEXCOORD0; // texture coordinate
        float4 vertex : SV_POSITION; // clip space position
      };

      // vertex shader
      v2f vert(appdata v)
      {
        v2f o;
        // transform position to clip space
        // (multiply with model*view*projection matrix)
        o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
        o.uv = v.uv;

        return o;
      }

      // color we will sample
      uniform fixed4 _Color;

      // pixel shader; returns low precision ("fixed4" type)
      // color ("SV_Target" semantic)
      fixed4 frag(v2f i) : SV_Target
      {
        return _Color;
      }
      ENDCG
    }

    Pass {
      Name "BACK"
      Cull Front
      ZWrite On

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

      uniform fixed4 _Color;
      uniform fixed4 _SilhouetteColor;
      uniform fixed _SilhouetteWidth;

      v2f vert(appdata v) {
        // just make a copy of incoming vertex data but scaled according to normal direction
        v2f o;
        o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

        float3 norm   = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
        float2 offset = TransformViewToProjection(norm.xy);

        o.pos.xy += offset * o.pos.z * _SilhouetteWidth;
        o.color = _Color * _SilhouetteColor;
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
}
