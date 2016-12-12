// simple "dissolving" shader by genericuser (radware.wordpress.com)
// clips materials, using an image as guidance.
// use clouds or random noise as the slice guide for best results.

// modified by thnewlands to include IQ's cubemapping shader (thnewlands.com)

  Shader "Custom Shaders/Dissolving Box Projected" {
  
    Properties {
      _MainTex ("Texture (RGB)", 2D) = "white" {}
      _SliceGuide ("Slice Guide (RGB)", 2D) = "white" {}
	    _SliceTiling ("Slice Tiling", float) = 0.1
      _SliceAmount ("Slice Amount", Range(0.0, 1.0)) = 0.5
    }
    
    SubShader {
      Tags { "RenderType" = "Opaque" }
      Cull Off
      CGPROGRAM
      //if you're not planning on using shadows, remove "addshadow" for better performance
      #pragma surface surf Lambert vertex:vert 

      struct Input {
          float2 uv_MainTex;
		  INTERNAL_DATA
		  float3 pos;
      };

	  //from IQ's Boxmapping example here: https://www.shadertoy.com/view/MtsGWH
	  //IQ uses: License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
	  float4 boxmap( sampler2D sam, float3 p, float3 n, float k )
		{
			float3 m = pow( abs(n), k );
			float4 x = tex2D( sam, p.yz );
			float4 y = tex2D( sam, p.zx );
			float4 z = tex2D( sam, p.xy );
			return (x*m.x + y*m.y + z*m.z)/(m.x+m.y+m.z);
		}

		 //get the local position
	   void vert (inout appdata_full v, out Input o) {
          UNITY_INITIALIZE_OUTPUT(Input,o);
          o.pos = v.vertex;
      }

	    sampler2D _MainTex;
      sampler2D _SliceGuide;
      float _SliceAmount;
	    float _SliceTiling;

      void surf (Input IN, inout SurfaceOutput o) {
		      //sample boxmap using local position of each vertex (offset by _SliceTiling) and their normals
          clip(boxmap(_SliceGuide, IN.pos * _SliceTiling, o.Normal, 32.0).rgb - _SliceAmount);
          o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
      }
      ENDCG
    }
    Fallback "Diffuse"
  }
