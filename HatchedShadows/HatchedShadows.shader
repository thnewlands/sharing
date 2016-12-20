Shader "Custom/HatchedShadows" {
	Properties {
		_Color("Color", Color) = (1, 1, 1, 1)
		_ShadowColor("Shadow Color", Color) = (0, 0, 0, 0)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_ShadowTex("Shadow (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags {
			"RenderType" = "Opaque"
		}
		LOD 200

		CGPROGRAM
		#pragma surface surf CelShadingForward
		#pragma target 3.0

		struct SurfaceOutputCustom {
			fixed3 Albedo;
			fixed3 Normal;
			fixed Shadow;
			fixed3 Emission;
			half Specular;
			fixed Alpha;
		};
		//		fixed4 _ShadowColor;
	
		half4 LightingCelShadingForward(SurfaceOutputCustom s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);
			NdotL = smoothstep(-.1, .1, NdotL);
			half4 c;
			half4 sh;
			sh.rgb = 1-(s.Shadow);
			c.rgb = lerp(s.Albedo, s.Albedo*sh.rgb, 1-NdotL*atten) * _LightColor0.rgb;
			c.a = s.Alpha;
			return c;
		}

		sampler2D _MainTex;
		sampler2D _ShadowTex;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
			float2 uv_ShadowTex;
			float3 viewDir;
			float3 worldPos;
		};

		void surf(Input IN, inout SurfaceOutputCustom o) {
			// Albedo comes from a texture tinted by color
			half rim = 1 - saturate(dot (normalize(IN.viewDir), o.Normal));

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			//o.Shadow = pow (rim, .1) * tex2D(_ShadowTex, _WorldSpaceLightPos0.xyz+IN.uv_ShadowTex).a;
			o.Shadow = pow (rim, .1) * tex2D(_ShadowTex, IN.uv_ShadowTex).a;
		
		}
		ENDCG
	}
	FallBack "Diffuse"
}