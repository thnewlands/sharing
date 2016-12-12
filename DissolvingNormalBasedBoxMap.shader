// simple "dissolving" shader by genericuser (radware.wordpress.com)
// clips materials, using an image as guidance.
// use clouds or random noise as the slice guide for best results.

// modified by thnewlands to include normal based box map via: http://www.shaderslab.com/index.php?post/Texture-changing-with-normal-value

  Shader "Custom Shaders/Dissolving Normal Based Box Map" {
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
		float3 slicecube;
		float2 sliceuv; 

		// Main constraint of working this way is that curved faces pull out artifacts
		// http://www.shaderslab.com/index.php?post/Texture-changing-with-normal-value
		float cutoff = .9; //cutoff for orientation, configured for 90deg angles
		if(o.Normal.y > cutoff || o.Normal.y < -cutoff)
		{
			sliceuv = IN.pos.xz;
		}
		if(o.Normal.x > cutoff || o.Normal.x < -cutoff)
		{
			sliceuv = IN.pos.yz;
		}
		if(o.Normal.z > cutoff || o.Normal.z < -cutoff)
		{
			sliceuv = IN.pos.yx;
		}

		//slice
		slicecube = tex2D(_SliceGuide, sliceuv * _SliceTiling).rgb;
		clip(slicecube.rgb - _SliceAmount); 
        o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
      }
      ENDCG
    }
    Fallback "Diffuse"
  }
