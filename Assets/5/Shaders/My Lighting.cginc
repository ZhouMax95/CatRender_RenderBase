 #include "UnityPBSLighting.cginc"
 #include "AutoLight.cginc"     
        fixed4 Tint; 
        sampler2D _MainTex;     
        float4 _MainTex_ST;   
        float _Smoothness;
        //float4 _SpecularColor;
        float _Metallic;

        struct dataToVertex{
            float4 position:POSITION;
            float3 normal:NORMAL;
            float2 uv:TEXCOORD0;
            
        };

        struct Interpolators{
            float4 position:SV_POSITION;
            float2 uv:TEXCOORD0;
            float3 normal:TEXCOORD1;
            float3 worldPos:TEXCOORD2;
            #if defined(VERTEXLIGHT_ON)
                float3 vertexLightColor:TEXCOORD3;
            #endif
        };

        void ComputeVertexLightColor(inout Interpolators i){
        #if defined(VERTEXLIGHT_ON)
            float3 lightPos=float3(unity_4LightPosX0.x,unity_4LightPosY0.x,unity_4LightPosZ0.x);
            
            float3 lightVec=lightPos-i.worldPos;
            float3 lightDir=normalize(lightVec);
            float ndotl=DotClamped(i.normal.lightDir);
            float attenuation=1/(1+dot(lightVec,lightVec)*unity_4LightAtten0.x);
            //i.vertexLightColor=unity_LightColor[0].rgb*ndotl*attenuation;
            i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
		    );
            //i.vertexLightColor=unity_LightColor[0].rgb;
        #endif
        }

        UnityIndirect CreatIndirectLight(Interpolators i){
            UnityIndirect indirectLight;
            indirectLight.diffuse=0;
            indirectLight.specular=0;

            #if defined(VERTEXLIGHT_ON)
                indirectLight.diffuse=i.vertexLightColor;
            #endif
            return indirectLight;
        }   

        Interpolators MyVertexProgram(dataToVertex v){
            Interpolators i;
            i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
            i.position=UnityObjectToClipPos(v.position);
            i.normal=UnityObjectToWorldNormal(v.normal);
            i.worldPos=mul(unity_ObjectToWorld,v.position);
            ComputeVertexLightColor(i);
            return i;
        }
       
        UnityLight CreateLight(Interpolators i){           
            UnityLight light;           
            #if defined(POINT)||defined(POINT_COOKIE)||defined(SPOT)
                light.dir=normalize(_WorldSpaceLightPos0.xyz-i.worldPos);
            #else 
                light.dir=_WorldSpaceLightPos0.xyz;
            #endif
            //light.dir=_WorldSpaceLightPos0.xyz;
            light.dir=normalize(_WorldSpaceLightPos0.xyz-i.worldPos);
            //float3 lightVec=_WorldSpaceLightPos0.xyz-i.worldPos;
            //float attenuation=1/(1+dot(lightVec,lightVec));
            UNITY_LIGHT_ATTENUATION(attenuation,0,i.worldPos);
            light.color=_LightColor0.rgb*attenuation;           
            light.ndotl=DotClamped(i.normal,light.dir);
            return light;
        }

        float4 MyFragmentProgram(Interpolators o):SV_TARGET{
            o.normal=normalize(o.normal);
            //float3 lightDir=normalize(_WorldSpaceLightPos0.xyz-o.worldPos);
            float3 viewDir=normalize(_WorldSpaceCameraPos-o.worldPos);
            //float3 reflectionDir=reflect(-lightDir,o.normal);
           // float3 halfVector=normalize(lightDir+viewDir);
            //fixed3 lightColor=_LightColor0.xyz;
            float3 albedo=tex2D(_MainTex,o.uv).xyz*Tint.xyz;
            //albedo*=1-max(_SpecularColor.r,max(_SpecularColor.g,_SpecularColor.b));
            float3 specularTint;//=albedo*_Metallic;
            float oneMinus;//=1-_Metallic;
            
            albedo=DiffuseAndSpecularFromMetallic(albedo,_Metallic,specularTint,oneMinus);
            //float3 diff=albedo*lightColor*dot(lightDir,o.normal);           
            //float3 specular =specularTint *lightColor *  pow(saturate(dot(halfVector,o.normal)),_Smoothness*100);

            //UnityLight light;
            //light.color=lightColor;
            //light.dir=lightDir;
            //light.ndotl=DotClamped(o.normal,lightDir); 
    
            //UnityIndirect  indirectLight;
            //indirectLight.diffuse=0;
            //indirectLight.specular=0;     

            return UNITY_BRDF_PBS(albedo,specularTint,oneMinus,_Smoothness,o.normal,viewDir,CreateLight(o),CreatIndirectLight(o));
            //return float4(diff+specular,1);
        }