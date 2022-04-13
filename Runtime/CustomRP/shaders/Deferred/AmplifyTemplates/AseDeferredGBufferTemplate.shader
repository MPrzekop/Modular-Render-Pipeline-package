Shader /*ase_name*/ "ASETemplateShaders/DeferredGBuffer" /*end*/
{
    Properties
    {
        /*ase_props*/
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100
        ZWrite On


        /*ase_pass*/
        Pass
        {
            /*ase_main_pass*/
            Name "Deferred"
            Cull Off
            ZTest lequal

            /*ase_all_modules*/
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_prepassfinal
            #ifndef UNITY_PASS_DEFERRED
            #define UNITY_PASS_DEFERRED
            #endif
            #include "UnityCG.cginc"
            /*ase_pragma*/
            /*ase_globals*/

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                /*ase_vdata:p=p;n=n*/
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                /*ase_interp(1,):sp=sp.xyzw*/
            };

            v2f vert(appdata v /*ase_vert_input*/)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                /*ase_vert_code:v=appdata;o=v2f*/

                v.vertex.xyz += /*ase_vert_out:Local Vertex;Float3;_Vertex*/ float3(0, 0, 0) /*end*/;
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

            float4 frag(v2f i /*ase_frag_input*/, out half4 outGBuffer1 : SV_Target1,
                        out half4 outGBuffer2 : SV_Target2, out half4 outGBuffer3 : SV_Target3):SV_Target
            {
                /*ase_frag_code:i=v2f*/
                float4 gbuff0 = /*ase_frag_out:GBuffer0;Float4*/0/*end*/;

                outGBuffer1 = /*ase_frag_out:GBuffer1;Float4*/0/*end*/;
                outGBuffer2 = /*ase_frag_out:GBuffer2;Float4*/0/*end*/;
                outGBuffer3 = /*ase_frag_out:GBuffer3;Float4*/0/*end*/;
                return gbuff0;
            }
            ENDCG
        }

        /*ase_pass*/
        Pass
        {
            
            Name "ShadowCaster"
            Tags
            {
                "LightMode"="ShadowCaster"
            }
            Cull off

            ZWrite On
            ZTest Always
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #ifndef UNITY_PASS_SHADOWCASTER
            #define UNITY_PASS_SHADOWCASTER
            #endif
            #include "UnityCG.cginc"
            /*ase_pragma*/
            /*ase_globals*/

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                /*ase_vdata:p=p;n=n*/
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                /*ase_interp(1,):sp=sp.xyzw*/
            };


            v2f vert(appdata v /*ase_vert_input*/)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                /*ase_vert_code:v=appdata;o=v2f*/

                v.vertex.xyz += /*ase_vert_out:Local Vertex;Float3;_Vertex*/ float3(0, 0, 0) /*end*/;
                //v.vertex.xyz -= v.normal*0.1;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i /*ase_frag_input*/) : SV_Target
            {
                /*ase_frag_code:i=v2f*/
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
        /*ase_pass_end*/
    }
    CustomEditor "ASEMaterialInspector"
}