// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TangentVis"
{
    Properties
    {
        
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
       LOD 100
        Cull Off
        ZWrite On
        ZTest lequal
        
        
        Pass
        {
            
            Name "Deferred"
            

            CGINCLUDE
            #pragma target 3.0
            ENDCG
            Blend Off
            AlphaToMask Off
            Cull Back
            ColorMask RGBA
            ZWrite On
            ZTest LEqual
            Offset 0 , 0
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_prepassfinal
            #ifndef UNITY_PASS_DEFERRED
            #define UNITY_PASS_DEFERRED
            #endif
            #include "UnityCG.cginc"
            #define ASE_NEEDS_VERT_NORMAL

            

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 ase_tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
            };

            v2f vert(appdata v )
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
                o.ase_texcoord1.xyz = ase_worldTangent;
                
                float3 ase_worldNormal = UnityObjectToWorldNormal(v.normal);
                o.ase_texcoord2.xyz = ase_worldNormal;
                
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.w = 0;
                o.ase_texcoord2.w = 0;

                v.vertex.xyz +=  float3(0, 0, 0) ;
                o.pos = UnityObjectToClipPos(v.vertex);
                #if ASE_SHADOWS
                #if UNITY_VERSION >= 560
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
                #else
						TRANSFER_SHADOW( o );
                #endif
                #endif
                return o;
            }

            void frag(v2f i , out half4 outGBuffer0 : SV_Target0, out half4 outGBuffer1 : SV_Target1,
                      out half4 outGBuffer2 : SV_Target2, out half4 outGBuffer3 : SV_Target3)
            {
                float3 ase_worldTangent = i.ase_texcoord1.xyz;
                
                float3 ase_worldNormal = i.ase_texcoord2.xyz;
                

                outGBuffer0 = float4( ase_worldTangent , 0.0 );
                outGBuffer1 = float4( ase_worldNormal , 0.0 );
                outGBuffer2 = 0;
                outGBuffer3 = 0;
            }
            ENDCG
        }

        
        Pass
        {
            
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            ZTest LEqual
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #ifndef UNITY_PASS_SHADOWCASTER
            #define UNITY_PASS_SHADOWCASTER
            #endif
            #include "UnityCG.cginc"
            
            

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                
            };


            v2f vert(appdata v )
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                

                v.vertex.xyz +=  float3(0, 0, 0) ;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i ) : SV_Target
            {
                
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
        
    }
    CustomEditor "ASEMaterialInspector"
	
	
}/*ASEBEGIN
Version=18935
389;73;1352;786;889;362;1;True;False
Node;AmplifyShaderEditor.VertexTangentNode;1;-433,-167;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;4;-409,69;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;True;-1;2;ASEMaterialInspector;100;11;TangentVis;412702c1ed59f144bbb08d9d9dd0ff3d;True;Deferred;0;0;Deferred;5;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;RenderType=Opaque=RenderType;False;False;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;False;True;2;False;0;;0;0;Standard;0;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;ASEMaterialInspector;100;1;New Amplify Shader;412702c1ed59f144bbb08d9d9dd0ff3d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;RenderType=Opaque=RenderType;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
WireConnection;2;0;1;0
WireConnection;2;1;4;0
ASEEND*/
//CHKSM=8404F37B244D09C2B0996B0FBD884A9AFB8143CB