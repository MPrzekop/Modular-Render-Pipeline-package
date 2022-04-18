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
		[Toggle(_WORLDSPACENORMALS_ON)] _Worldspacenormals("World space normals", Float) = 0
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
			#pragma shader_feature_local _WORLDSPACENORMALS_ON
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
			uniform float4x4 MY_UNITY_MATRIX_I_V;
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
				float4 tex2DNode2 = tex2D( normals, uvnormals );
				#ifdef _WORLDSPACENORMALS_ON
				float4 staticSwitch153 = float4( mul( MY_UNITY_MATRIX_I_V, float4( (tex2DNode2).rgb , 0.0 ) ).xyz , 0.0 );
				#else
				float4 staticSwitch153 = tex2DNode2;
				#endif
				float4 worldNormals148 = staticSwitch153;
				float3 normals4_g12 = worldNormals148.rgb;
				float2 uvadditionalData = i.texcoord.xy * additionalData_ST.xy + additionalData_ST.zw;
				float4 appendResult164 = (float4((tex2D( additionalData, uvadditionalData )).rgb , 1.0));
				float4 worldPosition145 = mul( MY_UNITY_MATRIX_I_V, appendResult164 );
				float3 position4_g12 = worldPosition145.xyz;
				int id4_g12 = LIGHT_ID;
				float4 LightColor4_g12 = float4( 0,0,0,0 );
				float3 LightDir4_g12 = float3( 0,0,0 );
				float2 ScreenCoords4_g12 = i.texcoord.xy;
				float3 LightSpecDir4_g12 = float3( 0,0,0 );
				float4 normalizeResult99 = normalize( ( float4( _WorldSpaceCameraPos , 0.0 ) - worldPosition145 ) );
				float4 viewDir142 = normalizeResult99;
				float3 viewDir4_g12 = viewDir142.xyz;
				float localGetLightsSum4_g12 = GetLightsSum4_g12( normals4_g12 , position4_g12 , id4_g12 , LightColor4_g12 , LightDir4_g12 , ScreenCoords4_g12 , LightSpecDir4_g12 , viewDir4_g12 );
				float4 temp_output_138_6 = LightColor4_g12;
				float2 uvMADS = i.texcoord.xy * MADS_ST.xy + MADS_ST.zw;
				float4 tex2DNode9 = tex2D( MADS, uvMADS );
				float roughness1_g15 = ( 1.0 - tex2DNode9.a );
				float2 uvalbedo = i.texcoord.xy * albedo_ST.xy + albedo_ST.zw;
				float4 baseColor1_g15 = tex2D( albedo, uvalbedo );
				float3 normal1_g15 = worldNormals148.rgb;
				float3 LightDir1_g15 = LightDir4_g12;
				float3 ViewDir1_g15 = viewDir142.xyz;
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
404;73;1459;779;3665.858;292.7682;1.3;True;False
Node;AmplifyShaderEditor.SamplerNode;52;-3264,176;Inherit;True;Global;additionalData;additionalData;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;163;-2928,192;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;164;-2736,288;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Matrix4X4Node;159;-2990.365,-517.0896;Inherit;False;Global;MY_UNITY_MATRIX_I_V;MY_UNITY_MATRIX_I_V;12;0;Create;True;0;0;0;False;0;False;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-2211.935,210.1944;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;2;-3128,-275;Inherit;True;Global;normals;normals;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-2086.037,129.046;Inherit;False;worldPosition;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;97;-2432,1024;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;161;-2818.755,-372.0427;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-2384,1152;Inherit;False;145;worldPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-2176,1024;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-2551.242,-481.2071;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;99;-2000,1024;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;153;-2333.675,-79.11578;Inherit;False;Property;_Worldspacenormals;World space normals;11;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-2030,-231;Inherit;False;worldNormals;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-1792,1024;Inherit;False;viewDir;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;135;-1872,416;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;75;-2032,560;Inherit;False;Global;LIGHT_ID;LIGHT_ID;7;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;9;-1776,-16;Inherit;True;Global;MADS;MADS;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;144;-1824,320;Inherit;False;142;viewDir;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1792,704;Inherit;False;148;worldNormals;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-1792,638.7;Inherit;False;145;worldPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-1216,208;Inherit;False;Property;_clearcoatGloss;clearcoatGloss;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;93;-1372,377;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraToWorldMatrix;131;-1120,64;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-1198.3,652.1;Inherit;False;142;viewDir;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-1776,-208;Inherit;True;Global;albedo;albedo;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;124;-1200,272;Inherit;False;Property;_sheen;sheen;9;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-1200,144;Inherit;False;Property;_clearcoat;clearcoat;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1184,352;Inherit;False;Property;_subsurface;subsurface;6;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;138;-1538,490;Inherit;False;Light;-1;;12;585925fa5124b194aa2fc951cbe4e70e;0;5;10;FLOAT3;0,0,0;False;9;FLOAT2;0,0;False;7;INT;0;False;5;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;4;FLOAT3;11;FLOAT3;8;FLOAT4;6;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-1159.469,424.5349;Inherit;False;Property;_specular;specular;10;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-1200,576;Inherit;False;148;worldNormals;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;141;-896,231;Inherit;False;Disney BSDF;-1;;15;697ca22b933b18c42a3f923f25d77ee0;0;16;18;FLOAT3;0,0,0;False;17;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;COLOR;0,0,0,0;False;13;COLOR;0,0,0,0;False;14;FLOAT;0;False;15;FLOAT;0;False;8;FLOAT;0;False;7;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;1,1,1,1;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;73;-512,0;Inherit;True;Property;_MainTex;_MainTex;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;134;-384,256;Inherit;False;Constant;_Vector1;Vector 1;12;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-310.0659,-204.1319;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-176,-96;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;114;-2640,176;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;133;16,-32;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;55;-128,-320;Inherit;True;Global;depth;depth;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.InverseViewMatrixNode;160;-2895.464,-621.0894;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;56;228.49,-18.91446;Float;False;True;-1;2;ASEMaterialInspector;100;11;ViewDir;bed99430ed42b58479561ce4edd5a341;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;RenderType=Opaque=RenderType;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;163;0;52;0
WireConnection;164;0;163;0
WireConnection;162;0;159;0
WireConnection;162;1;164;0
WireConnection;145;0;162;0
WireConnection;161;0;2;0
WireConnection;98;0;97;0
WireConnection;98;1;147;0
WireConnection;158;0;159;0
WireConnection;158;1;161;0
WireConnection;99;0;98;0
WireConnection;153;1;2;0
WireConnection;153;0;158;0
WireConnection;148;0;153;0
WireConnection;142;0;99;0
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
WireConnection;114;0;164;0
WireConnection;133;0;74;0
WireConnection;56;0;55;1
WireConnection;56;1;133;0
ASEEND*/
//CHKSM=20D301C4AA34082315807FFC1EA15631F1D64AE6