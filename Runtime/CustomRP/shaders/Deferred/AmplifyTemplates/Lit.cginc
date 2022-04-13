

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

            struct Output
            {
                #if TARGET_BUFFER_0
                half4 dest0 : SV_Target0;
                #endif
                #if TARGET_BUFFER_1
                half4 dest1 : SV_Target1;
                #endif
                #if TARGET_BUFFER_2
                half4 dest2 : SV_Target2;
                #endif
                #if TARGET_BUFFER_3
                half4 dest3 : SV_Target3;
                #endif
            };


            /*ase_globals*/

            v2f vert(appdata v /*ase_vert_input*/)
            {
                v2f o;
                o.texcoord.xy = v.texcoord.xy;
                o.texcoord.zw = v.texcoord1.xy;

                // ase common template code
                /*ase_vert_code:v=appdata;o=v2f*/

                v.vertex.xyz += /*ase_vert_out:Local Vertex;Float3*/ float3(0, 0, 0) /*end*/;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            Output frag(v2f i /*ase_frag_input*/)
            {
                Output myColorVar;
                // ase common template code
                /*ase_frag_code:i=v2f*/
                #if TARGET_BUFFER_0
                myColorVar.dest0 = /*ase_frag_out:Albedo;Float4*/fixed4(1, 0, 0, 1)/*end*/;
                #endif
                #if TARGET_BUFFER_1
                myColorVar.dest1 = /*ase_frag_out:World normals;Float4*/fixed4(1, 0, 0, 1)/*end*/;
                #endif
                #if TARGET_BUFFER_2
                myColorVar.dest2 = /*ase_frag_out:MADS;Float4*/fixed4(1, 0, 0, 1)/*end*/;
                #endif
                #if TARGET_BUFFER_3
                myColorVar.dest3 = /*ase_frag_out:AdditionalMask;Float4*/fixed4(1, 0, 0, 1)/*end*/;
                #endif

                return myColorVar;
            }