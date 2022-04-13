// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ViewDir"
{
	Properties
	{
		
		_MainTex("_MainTex", 2D) = "white" {}
		_subsurface("subsurface", Range( 0 , 1)) = 1
		_clearcoat("clearcoat", Range( 0 , 1)) = 0
		_clearcoatGloss("clearcoatGloss", Range( 0 , 1)) = 0
		_sheen("sheen", Range( 0 , 1)) = 1
		_specular("specular", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
	LOD 100
		Cull Off
		 ZWrite On
        ZTest Off
		

		Pass
		{
			CGPROGRAM
			
			#pragma target 3.0 
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
		
			#include "UnityShaderVariables.cginc"
			#include "Utility/LightsData.cginc"
			#include "Utility/DisneyBSDF.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				
			};

			
		
			uniform sampler2D depth;
			uniform float4 depth_ST;
			uniform sampler2D normals;
			uniform float4 normals_ST;
			uniform sampler2D additionalData;
			uniform float4 additionalData_ST;
			uniform int LIGHT_ID;
			uniform sampler2D MADS;
			uniform float4 MADS_ST;
			uniform sampler2D albedo;
			uniform float4 albedo_ST;
			uniform float _clearcoat;
			uniform float _clearcoatGloss;
			uniform float _sheen;
			uniform float _subsurface;
			uniform float _specular;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			float GetLightsSum4_g12( float3 normals, float3 position, int id, out float4 LightColor, out float3 LightDir, float2 ScreenCoords, out float3 LightSpecDir, float3 viewDir )
			{
				LightColor = GetLightColor(id);
				LightDir = GetLightDirection(position,id);
				LightSpecDir = GetSpecularLightDirection(position,normals,viewDir,id);
				return GetLightAtten( normals,position,id,ScreenCoords);
			}
			
			float3 MyCustomExpression1_g15( float roughness, float4 baseColor, float3 normal, float3 LightDir, float3 ViewDir, float metallic, float Anisotropy, float clearcoat, float clearcoatGloss, float sheen, float4 sheenTint, float4 specularTint, float subsurface, float specular, float4x4 WorldToScreen, float3 SpecLightDir )
			{
				 Surface s;
				s.roughness=roughness;
				s.baseColor=baseColor;
				s.normal = normal;
				s.metallic = metallic;
				s.sheenTint = float4(1,1,1,1);
				s.anisotropy = Anisotropy;
				s.clearcoat = clearcoat;
				s.clearcoatGloss=clearcoatGloss;
				s.sheen = sheen;
				s.sheenTint= sheenTint;
				s.subsurface = subsurface;
				s.specular = specular;
				s.specularTint=specularTint;
				return Lighting(s,LightDir,ViewDir,WorldToScreen,SpecLightDir);
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				o.texcoord.xy = v.texcoord.xy;
				o.texcoord.zw = v.texcoord1.xy;
				
				// ase common template code
				
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			float4 frag (v2f i ,out float depthOutput : SV_Depth) : SV_Target0
			{
				
				// ase common template code
				float2 uvdepth = i.texcoord.xy * depth_ST.xy + depth_ST.zw;
				
				float2 uvnormals = i.texcoord.xy * normals_ST.xy + normals_ST.zw;
				float4 worldNormals148 = tex2D( normals, uvnormals );
				float3 normals4_g12 = worldNormals148.rgb;
				float2 uvadditionalData = i.texcoord.xy * additionalData_ST.xy + additionalData_ST.zw;
				float3 worldPosition145 = (tex2D( additionalData, uvadditionalData )).rgb;
				float3 position4_g12 = worldPosition145;
				int id4_g12 = LIGHT_ID;
				float4 LightColor4_g12 = float4( 0,0,0,0 );
				float3 LightDir4_g12 = float3( 0,0,0 );
				float2 ScreenCoords4_g12 = i.texcoord.xy;
				float3 LightSpecDir4_g12 = float3( 0,0,0 );
				float3 normalizeResult99 = normalize( ( _WorldSpaceCameraPos - worldPosition145 ) );
				float3 viewDir142 = normalizeResult99;
				float3 viewDir4_g12 = viewDir142;
				float localGetLightsSum4_g12 = GetLightsSum4_g12( normals4_g12 , position4_g12 , id4_g12 , LightColor4_g12 , LightDir4_g12 , ScreenCoords4_g12 , LightSpecDir4_g12 , viewDir4_g12 );
				float4 temp_output_138_6 = LightColor4_g12;
				float2 uvMADS = i.texcoord.xy * MADS_ST.xy + MADS_ST.zw;
				float4 tex2DNode9 = tex2D( MADS, uvMADS );
				float roughness1_g15 = ( 1.0 - tex2DNode9.a );
				float2 uvalbedo = i.texcoord.xy * albedo_ST.xy + albedo_ST.zw;
				float4 baseColor1_g15 = tex2D( albedo, uvalbedo );
				float3 normal1_g15 = worldNormals148.rgb;
				float3 LightDir1_g15 = LightDir4_g12;
				float3 ViewDir1_g15 = viewDir142;
				float metallic1_g15 = tex2DNode9.r;
				float Anisotropy1_g15 = tex2DNode9.g;
				float clearcoat1_g15 = _clearcoat;
				float clearcoatGloss1_g15 = _clearcoatGloss;
				float sheen1_g15 = _sheen;
				float4 sheenTint1_g15 = temp_output_138_6;
				float4 specularTint1_g15 = float4( 0,0,0,0 );
				float subsurface1_g15 = _subsurface;
				float specular1_g15 = _specular;
				float4x4 WorldToScreen1_g15 = unity_CameraToWorld;
				float3 SpecLightDir1_g15 = LightSpecDir4_g12;
				float3 localMyCustomExpression1_g15 = MyCustomExpression1_g15( roughness1_g15 , baseColor1_g15 , normal1_g15 , LightDir1_g15 , ViewDir1_g15 , metallic1_g15 , Anisotropy1_g15 , clearcoat1_g15 , clearcoatGloss1_g15 , sheen1_g15 , sheenTint1_g15 , specularTint1_g15 , subsurface1_g15 , specular1_g15 , WorldToScreen1_g15 , SpecLightDir1_g15 );
				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				
				depthOutput =tex2D( depth, uvdepth ).r;
				return  saturate( ( ( temp_output_138_6 * float4( localMyCustomExpression1_g15 , 0.0 ) * localGetLightsSum4_g12 ) + tex2D( _MainTex, uv_MainTex ) + float4(0,0,0,1) ) );
			}
			ENDCG
		}
	}
	
	CustomEditor "ASEMaterialInspector"
	
}/*ASEBEGIN
Version=18935
891;73;1031;786;2924.936;306.0735;2.193148;True;False
Node;AmplifyShaderEditor.SamplerNode;52;-2688,128;Inherit;True;Global;additionalData;additionalData;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;114;-2400,128;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-2176,128;Inherit;False;worldPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-2384,1152;Inherit;False;145;worldPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;97;-2432,1024;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-2176,1024;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;99;-2000,1024;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-2688,-304;Inherit;True;Global;normals;normals;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-1792,1024;Inherit;False;viewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-2368,-304;Inherit;False;worldNormals;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1792,704;Inherit;False;148;worldNormals;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-1792,464;Inherit;False;142;viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;135;-1790.018,531.5443;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-1776,-16;Inherit;True;Global;MADS;MADS;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;75;-1216,-32;Inherit;False;Global;LIGHT_ID;LIGHT_ID;7;0;Create;True;0;0;0;False;0;False;0;4;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-1792,638.7;Inherit;False;145;worldPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-1200,576;Inherit;False;148;worldNormals;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-1159.469,424.5349;Inherit;False;Property;_specular;specular;10;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1184,352;Inherit;False;Property;_subsurface;subsurface;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-1216,208;Inherit;False;Property;_clearcoatGloss;clearcoatGloss;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-1198.3,652.1;Inherit;False;142;viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;93;-1372,377;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-1200,144;Inherit;False;Property;_clearcoat;clearcoat;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;138;-1538,490;Inherit;False;Light;-1;;12;585925fa5124b194aa2fc951cbe4e70e;0;5;10;FLOAT3;0,0,0;False;9;FLOAT2;0,0;False;7;INT;0;False;5;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;4;FLOAT3;11;FLOAT3;8;FLOAT4;6;FLOAT;0
Node;AmplifyShaderEditor.CameraToWorldMatrix;131;-895.0718,56.65393;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1200,272;Inherit;False;Property;_sheen;sheen;9;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1776,-208;Inherit;True;Global;albedo;albedo;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;141;-896,231;Inherit;False;Disney BSDF;-1;;15;697ca22b933b18c42a3f923f25d77ee0;0;16;18;FLOAT3;0,0,0;False;17;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;COLOR;0,0,0,0;False;13;COLOR;0,0,0,0;False;14;FLOAT;0;False;15;FLOAT;0;False;8;FLOAT;0;False;7;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;1,1,1,1;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;73;-512,0;Inherit;True;Property;_MainTex;_MainTex;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-310.0659,-204.1319;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;134;-384,256;Inherit;False;Constant;_Vector1;Vector 1;12;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-176,-96;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;133;16,-32;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;55;-128,-320;Inherit;True;Global;depth;depth;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;56;228.49,-18.91446;Float;False;True;-1;2;ASEMaterialInspector;100;12;ViewDir;bed99430ed42b58479561ce4edd5a341;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;RenderType=Opaque=RenderType;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;114;0;52;0
WireConnection;145;0;114;0
WireConnection;98;0;97;0
WireConnection;98;1;147;0
WireConnection;99;0;98;0
WireConnection;142;0;99;0
WireConnection;148;0;2;0
WireConnection;93;0;9;4
WireConnection;138;10;144;0
WireConnection;138;9;135;0
WireConnection;138;7;75;0
WireConnection;138;5;146;0
WireConnection;138;2;149;0
WireConnection;141;18;138;11
WireConnection;141;17;131;0
WireConnection;141;9;122;0
WireConnection;141;10;123;0
WireConnection;141;11;124;0
WireConnection;141;12;138;6
WireConnection;141;14;121;0
WireConnection;141;15;126;0
WireConnection;141;8;9;2
WireConnection;141;7;9;1
WireConnection;141;2;93;0
WireConnection;141;3;1;0
WireConnection;141;4;150;0
WireConnection;141;5;138;8
WireConnection;141;6;143;0
WireConnection;69;0;138;6
WireConnection;69;1;141;0
WireConnection;69;2;138;0
WireConnection;74;0;69;0
WireConnection;74;1;73;0
WireConnection;74;2;134;0
WireConnection;133;0;74;0
WireConnection;56;0;55;1
WireConnection;56;1;133;0
ASEEND*/
//CHKSM=57CFE0E032A1E07B1A1DFE48B4B36EC8282AE960