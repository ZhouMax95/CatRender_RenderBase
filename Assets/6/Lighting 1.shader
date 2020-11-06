// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My Light Shader2"
{
   properties{
    Tint("color",Color)=(1,1,1,0)
    _MainTex("Albedo",2D)="White"{}
    _Smoothness("Smoothness",Range(0.1,1))=0.5
    //_SpecularColor("SpecularColor",Color)=(1,1,1,1)
    //[NoScaleOffset]_HeightMap("Heights",2D)="gray"{}
    _BumpScale("Bump Scale",Float)=1
    [NoScaleOffset]_NormalMap("Normals",2D)="bump"{}
    [Gamma]_Metallic("Metallic",Range(0,1))=0.1
    _DetailTex("Detail Texture",2D)="gray"{}
    [NoScaleOffset]_DetailNormalMap("Detail Normals",2D)="bump"{}
    _DetailBumpScale("Detail Bump Scale",Float)=1
   }

   SubShader{

        
        pass{
        
        Tags{"LightMode"="ForwardBase"}
        CGPROGRAM
        
        #pragma target 3.0       

        #pragma vertex MyVertexProgram
        #pragma fragment MyFragmentProgram
        //#include "UnityCG.cginc"
        //#include "UnityLightingCommon.cginc"
        #include "UnityStandardBRDF.cginc"
        #include "UnityStandardUtils.cginc"
        #include "UnityPBSLighting.cginc"
        fixed4 Tint; 
        sampler2D _MainTex,_DetailTex;     
        float4 _MainTex_ST,_DetailTex_ST;   
        float _Smoothness;
        //float4 _SpecularColor;
        float _Metallic;
        //sampler2D _HeightMap;
        //float4 _HeightMap_TexelSize;
        sampler2D _NormalMap,_DetailNormalMap;
        float _BumpScale,_DetailBumpScale;

        struct dataToVertex{
            float4 position:POSITION;
            float3 normal:NORMAL;
            float4 tangent:TANGENT;
            float2 uv:TEXCOORD0;
            
        };

        struct Interpolators{
            float4 position:SV_POSITION;
            float4 uv:TEXCOORD0;
            float3 normal:TEXCOORD1;
            float4 tangent:TEXCOORD2;
            float3 worldPos:TEXCOORD3;
            #if defined(VERTEXLIGHT_ON)
                float3 vertexLightColor:TEXCOORD4;
            #endif
        };
        Interpolators MyVertexProgram(dataToVertex v){
            Interpolators i;
            //i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
            i.position=UnityObjectToClipPos(v.position);
            i.normal=UnityObjectToWorldNormal(v.normal);
            i.tangent=float4(UnityObjectToWorldDir(v.tangent.xyz),v.tangent.w);
            i.worldPos=mul(unity_ObjectToWorld,v.position);
            i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
	        i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
            return i;
        }

        void InitializeFragmentNormal(inout Interpolators i){
            //float h=tex2D(_HeightMap,i.uv);
            //i.normal=float3(0,h,0);

            //i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
            //i.normal.xy*=_BumpScale;
	        //i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));
            
            float3  mainNormal=UnpackScaleNormal(tex2D(_NormalMap,i.uv.xy),_BumpScale);
            float3 detailNormal=UnpackScaleNormal(tex2D(_DetailNormalMap,i.uv.zw),_DetailBumpScale);
	        //i.normal=(mainNormal+detailNormal)*0.5;
            
            //i.normal=(mainNormal+detailNormal)*0.5;
            //i.normal=float3(mainNormal.xy+detailNormal.xy,mainNormal.z*detailNormal.z);
            //i.normal=BlendNormals(mainNormal,detailNormal);       
            float3 tangentSpaceNormal=BlendNormals(mainNormal,detailNormal); 
            //tangentSpaceNormal = tangentSpaceNormal.xzy; 
            float3 binormal=cross(i.normal,i.tangent.xyz)*i.tangent.w;            
            i.normal = normalize(
		    tangentSpaceNormal.x * i.tangent +
		    tangentSpaceNormal.y * binormal +
		    tangentSpaceNormal.z * i.normal
	        );         

            //i.normal = i.normal.xzy;   
            //i.normal=normalize(i.normal);    

            //float2 du=float2(_HeightMap_TexelSize.x*0.5,0);
            //float u1=tex2D(_HeightMap,i.uv-du);
            //float u2=tex2D(_HeightMap,i.uv+du);
            //float3 tu=float3(1,u2-u1,0);
            
            //float2 dv=float2(0,_HeightMap_TexelSize.y*0.5);
            //float v1=tex2D(_HeightMap,i.uv-dv);
            //float v2=tex2D(_HeightMap,i.uv+dv);
            //float3 tv=float3(0,v2-v1,1);

            //i.normal=float3(u1-u2,1,v1-v2);
          
        }       

        float4 MyFragmentProgram(Interpolators o):SV_TARGET{
            //o.normal=normalize(o.normal);
            InitializeFragmentNormal(o);
            float3 lightDir=_WorldSpaceLightPos0.xyz;
            float3 viewDir=normalize(_WorldSpaceCameraPos-o.worldPos);
            
            fixed3 lightColor=_LightColor0.xyz;
            float3 albedo=tex2D(_MainTex,o.uv.xy).xyz*Tint.xyz; 
            albedo*=tex2D(_DetailTex,o.uv.zw)*unity_ColorSpaceDouble;
            
            float3 specularTint;
            float oneMinus;
            
            albedo=DiffuseAndSpecularFromMetallic(albedo,_Metallic,specularTint,oneMinus);
            
            UnityLight light;
            light.color=lightColor;
            light.dir=lightDir;
            light.ndotl=DotClamped(o.normal,lightDir);     
            UnityIndirect  indirectLight;
            indirectLight.diffuse=0;
            indirectLight.specular=0;     

            return UNITY_BRDF_PBS(albedo,specularTint,oneMinus,_Smoothness,o.normal,viewDir,light,indirectLight);
            
        }
   
        ENDCG
        }
    }
}
