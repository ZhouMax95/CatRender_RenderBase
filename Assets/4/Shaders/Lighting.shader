// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My Light Shader"
{
   properties{
    Tint("color",Color)=(1,1,1,0)
    _MainTex("Albedo",2D)="White"{}
    _Smoothness("Smoothness",Range(0.1,1))=0.5
    //_SpecularColor("SpecularColor",Color)=(1,1,1,1)
    [Gamma]_Metallic("Metallic",Range(0,1))=0.1
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
        };
        Interpolators MyVertexProgram(dataToVertex v){
            Interpolators i;
            i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
            i.position=UnityObjectToClipPos(v.position);
            i.normal=UnityObjectToWorldNormal(v.normal);
            i.worldPos=mul(unity_ObjectToWorld,v.position);
            return i;
        }
       
        float4 MyFragmentProgram(Interpolators o):SV_TARGET{
            o.normal=normalize(o.normal);
            float3 lightDir=_WorldSpaceLightPos0.xyz;
            float3 viewDir=normalize(_WorldSpaceCameraPos-o.worldPos);
            //float3 reflectionDir=reflect(-lightDir,o.normal);
           // float3 halfVector=normalize(lightDir+viewDir);
            fixed3 lightColor=_LightColor0.xyz;
            float3 albedo=tex2D(_MainTex,o.uv).xyz*Tint.xyz;
            //albedo*=1-max(_SpecularColor.r,max(_SpecularColor.g,_SpecularColor.b));
            float3 specularTint;//=albedo*_Metallic;
            float oneMinus;//=1-_Metallic;
            
            albedo=DiffuseAndSpecularFromMetallic(albedo,_Metallic,specularTint,oneMinus);
            //float3 diff=albedo*lightColor*dot(lightDir,o.normal);           
            //float3 specular =specularTint *lightColor *  pow(saturate(dot(halfVector,o.normal)),_Smoothness*100);

            UnityLight light;
            light.color=lightColor;
            light.dir=lightDir;
            light.ndotl=DotClamped(o.normal,lightDir);     
            UnityIndirect  indirectLight;
            indirectLight.diffuse=0;
            indirectLight.specular=0;     

            return UNITY_BRDF_PBS(albedo,specularTint,oneMinus,_Smoothness,o.normal,viewDir,light,indirectLight);
            //return float4(diff+specular,1);
        }
   
        ENDCG
        }
    }
}
