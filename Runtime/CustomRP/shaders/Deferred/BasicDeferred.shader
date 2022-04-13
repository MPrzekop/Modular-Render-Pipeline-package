// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BasicDeferred"
{
    Properties
    {
        _MainTexture("MainTexture", 2D) = "white" {}
        _Tint("Tint", Color) = (1,1,1,0)
        _NormalMap("NormalMap", 2D) = "bump" {}
        _Smoothness("Smoothness", Float) = 0
        _Metallic("Metallic", Float) = 0
        _Aniso("Aniso", Float) = 0
        _MADS("MADS", 2D) = "white" {}
        _SmoothnessMin("SmoothnessMin", Float) = 0
        [HideInInspector] _texcoord( "", 2D ) = "white" {}

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="CustomDeferred" }
       LOD 100
        ZWrite On


        
        Pass
        {
            
            Name "Deferred"
            Cull Back
            ZTest lequal

            CGINCLUDE
            #pragma target 3.0
            ENDCG
            Blend Off
            AlphaToMask Off
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

            uniform float4 _Tint;
            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;
            uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST;
            uniform float _Metallic;
            uniform sampler2D _MADS;
            uniform float4 _MADS_ST;
            uniform float _Aniso;
            uniform float _SmoothnessMin;
            uniform float _Smoothness;


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
                float4 ase_texcoord3 : TEXCOORD3;
                float4 ase_texcoord4 : TEXCOORD4;
                float4 ase_texcoord5 : TEXCOORD5;
            };

            v2f vert(appdata v )
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
                o.ase_texcoord2.xyz = ase_worldTangent;
                float3 ase_worldNormal = UnityObjectToWorldNormal(v.normal);
                o.ase_texcoord3.xyz = ase_worldNormal;
                float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
                float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
                o.ase_texcoord4.xyz = ase_worldBitangent;
                
                float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.ase_texcoord5.xyz = ase_worldPos;
                
                o.ase_texcoord1.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.zw = 0;
                o.ase_texcoord2.w = 0;
                o.ase_texcoord3.w = 0;
                o.ase_texcoord4.w = 0;
                o.ase_texcoord5.w = 0;

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

            float4 frag(v2f i , out half4 outGBuffer1 : SV_Target1,
                        out half4 outGBuffer2 : SV_Target2, out half4 outGBuffer3 : SV_Target3):SV_Target
            {
                float2 uv_MainTexture = i.ase_texcoord1.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
                float4 tex2DNode1 = tex2D( _MainTexture, uv_MainTexture );
                clip( tex2DNode1.a - 0.4);
                
                float2 uv_NormalMap = i.ase_texcoord1.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
                float3 ase_worldTangent = i.ase_texcoord2.xyz;
                float3 ase_worldNormal = i.ase_texcoord3.xyz;
                float3 ase_worldBitangent = i.ase_texcoord4.xyz;
                float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
                float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
                float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
                float3 tanNormal7 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
                float3 worldNormal7 = float3(dot(tanToWorld0,tanNormal7), dot(tanToWorld1,tanNormal7), dot(tanToWorld2,tanNormal7));
                
                float2 uv_MADS = i.ase_texcoord1.xy * _MADS_ST.xy + _MADS_ST.zw;
                float4 tex2DNode44 = tex2D( _MADS, uv_MADS );
                float4 appendResult40 = (float4(( _Metallic * tex2DNode44.r ) , ( _Aniso * tex2DNode44.g ) , 0.0 , ( (_SmoothnessMin + (tex2DNode44.a - 0.0) * (1.0 - _SmoothnessMin) / (1.0 - 0.0)) * _Smoothness )));
                
                float3 ase_worldPos = i.ase_texcoord5.xyz;
                
                float4 gbuff0 = ( _Tint * tex2DNode1 );

                outGBuffer1 = float4( worldNormal7 , 0.0 );
                outGBuffer2 = appendResult40;
                outGBuffer3 = float4( ase_worldPos , 0.0 );
                return gbuff0;
            }
            ENDCG
        }

        
        Pass
        {
            
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            Cull off

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
                //v.vertex.xyz -= v.normal*0.1;
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
246;73;1194;786;857.9338;-169.9874;1;True;False
Node;AmplifyShaderEditor.SamplerNode;6;-640,0;Inherit;True;Property;_NormalMap;NormalMap;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;49;-236.9338,509.9874;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-896,-416;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-88.43398,255.2316;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-2.633911,445.0315;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-752,240;Inherit;True;Property;_MaskMap;MaskMap;3;0;Create;True;0;0;0;False;0;False;-1;None;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;19;232.2731,239.1485;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-299.4,-157.8;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;10;-112,-240;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.4;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-896,-224;Inherit;True;Property;_MainTexture;MainTexture;0;0;Create;True;0;0;0;False;0;False;-1;None;0000000000000000f000000000000000;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;40;60.21173,172.1208;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-93.63396,156.4315;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-384,240;Inherit;False;Property;_Metallic;Metallic;5;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-384,304;Inherit;False;Property;_Aniso;Aniso;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;44;-480,688;Inherit;True;Property;_MADS;MADS;7;0;Create;True;0;0;0;False;0;False;-1;None;4a0268f2146aa4c499dd08760b138f74;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;-480,608;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0;0.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;7;-257.6,35.2;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;48;-480,448;Inherit;False;Property;_SmoothnessMin;SmoothnessMin;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;39;269,-52.5;Float;False;False;-1;2;ASEMaterialInspector;100;11;New Amplify Shader;412702c1ed59f144bbb08d9d9dd0ff3d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;RenderType=Opaque=RenderType;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;38;269,-210.5;Float;False;True;-1;2;ASEMaterialInspector;100;11;BasicDeferred;412702c1ed59f144bbb08d9d9dd0ff3d;True;Deferred;0;0;Deferred;5;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;2;RenderType=Opaque=RenderType;LightMode=CustomDeferred;False;False;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;False;True;2;False;0;;0;0;Standard;0;0;2;True;True;False;;False;0
WireConnection;49;0;44;4
WireConnection;49;3;48;0
WireConnection;46;0;43;0
WireConnection;46;1;44;2
WireConnection;45;0;49;0
WireConnection;45;1;41;0
WireConnection;3;0;5;0
WireConnection;3;1;1;0
WireConnection;10;0;3;0
WireConnection;10;1;1;4
WireConnection;40;0;47;0
WireConnection;40;1;46;0
WireConnection;40;3;45;0
WireConnection;47;0;42;0
WireConnection;47;1;44;1
WireConnection;7;0;6;0
WireConnection;38;0;10;0
WireConnection;38;1;7;0
WireConnection;38;2;40;0
WireConnection;38;3;19;0
ASEEND*/
//CHKSM=C1E3E7BC84C090EFFC11519EEABFDB171567BC94