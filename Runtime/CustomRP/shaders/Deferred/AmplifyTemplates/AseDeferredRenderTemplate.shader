Shader /*ase_name*/ "ASETemplateShaders/DeferredRender" /*end*/
{
	Properties
	{
		
		/*ase_props*/
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off
		 ZWrite On
        ZTest Off
		/*ase_pass*/

		Pass
		{
			CGPROGRAM
			#pragma target 3.0 
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
		
			/*ase_pragma*/

			struct appdata
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				/*ase_vdata:p=p;uv0=tc0.xy;uv1=tc1.xy*/
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				/*ase_interp(1,7):sp=sp.xyzw;uv0=tc0.xy;uv1=tc0.zw*/
			};

			
		
			/*ase_globals*/
			
			v2f vert ( appdata v /*ase_vert_input*/)
			{
				v2f o;
				o.texcoord.xy = v.texcoord.xy;
				o.texcoord.zw = v.texcoord1.xy;
				
				// ase common template code
				/*ase_vert_code:v=appdata;o=v2f*/
				
				v.vertex.xyz += /*ase_vert_out:Local Vertex;Float3*/ float3(0,0,0) /*end*/;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			float4 frag (v2f i /*ase_frag_input*/,out float depthOutput : SV_Depth) : SV_Target0
			{
				
				// ase common template code
				/*ase_frag_code:i=v2f*/
				
				depthOutput =/*ase_frag_out:depth;Float*/0.5/*end*/;
				return  /*ase_frag_out:Fragment;Float4*/fixed4(1,0,0,1)/*end*/;
			}
			ENDCG
		}
	}
}