Shader "Volume Outline"
//based on http://answers.unity3d.com/questions/1174716/gradient-glow-shader.html#comment-1175203
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BumpMap ("Bump", 2D) = "black" {}
         _Size ("Atmosphere Size Multiplier", Range(0,.5)) = 4
		 _Rim ("Fade Power", Range(0,8)) = 4
		 _RimOffset ("Rim Offset", Range(0,8)) = 4
    }

     SubShader {
         Tags { "RenderType"="Transparent" }
         LOD 200
 
         Cull Front
         
         CGPROGRAM
         // Physically based Standard lighting model, and enable shadows on all light types
         #pragma surface surf NegativeLambert fullforwardshadows alpha:fade
         #pragma vertex vert
 
         // Use shader model 3.0 target, to get nicer looking lighting
         #pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;

		 half4 LightingNegativeLambert (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
             s.Normal = normalize (s.Normal);
 
             half diff = max (0, dot (-s.Normal, lightDir));
 
             half4 c;
             c.rgb = (s.Albedo * _LightColor0 * diff) * atten;
             c.a = s.Alpha;
             return c;
         }

         struct Input {
             float3 viewDir;
			 float2 uv_MainTex;
			 float2 uv_BumpMap;
         };
 
         half _Size;
         half _Rim;
		 float _RimOffset;
         fixed4 _Color;
 
         void vert (inout appdata_full v) {
             v.vertex.xyz += v.normal * _Size;
			 v.normal *= -1;
         }
         
         void surf (Input IN, inout SurfaceOutput o) {
             half rim = saturate (dot (normalize (IN.viewDir), o.Normal));
             fixed4 c = _Color * tex2D(_MainTex, IN.uv_MainTex);
             o.Albedo = c.rgb;
             o.Alpha = c.r * lerp (0, 1 - c.r * 2, pow (rim * _RimOffset, _Rim));
         }
         ENDCG
   

    ZWrite On
    ZTest LEqual
    Blend Off
	cull back

    CGPROGRAM
    #pragma surface surf Lambert
 
    sampler2D _MainTex;
    sampler2D _BumpMap;
	fixed4 _Color;

    struct Input {
        float2 uv_MainTex;
        float2 uv_BumpMap;
    };
 
    void surf (Input IN, inout SurfaceOutput o) {
        fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
        o.Albedo = c.rgb;
        o.Alpha = c.a;
        o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
    }

    ENDCG
 }
}
