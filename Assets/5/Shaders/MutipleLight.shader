// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My Mutiple Light Shader"
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

        #pragma multi_compile_VERTEXLIGHT_ON
        #pragma vertex MyVertexProgram
        #pragma fragment MyFragmentProgram 
         
        //#pragma multi_compile_fwdadd  
        //#pragma multi_compile DIRECTIONAL POINT SPOT
        #include "UnityPBSLighting.cginc"

        #if !defined(MY_LIGHTING_INCLUDE)
        #define MY_LIGHTING_INCLUDE
        #include "My Lighting.cginc"
        #endif

        ENDCG
        }

        pass{
        
        Tags{"LightMode"="ForwardAdd"}
        Blend One One
        Zwrite Off
        CGPROGRAM
        
        #pragma target 3.0       

        #pragma vertex MyVertexProgram
        #pragma fragment MyFragmentProgram 
       
        #include "UnityPBSLighting.cginc"

        #if !defined(MY_LIGHTING_INCLUDE)
        #define MY_LIGHTING_INCLUDE
        #include "My Lighting.cginc"
        #endif

        ENDCG
        }

    }
}
