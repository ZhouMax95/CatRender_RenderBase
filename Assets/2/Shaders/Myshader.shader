// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Myshader"
{
   properties{
    Tint("color",Color)=(1,1,1,0)
    _MainTex("Texture",2D)="White"{}
   }

   SubShader{

        
        pass{

        CGPROGRAM
           
        #pragma vertex MyVertexProgram
        #pragma fragment MyFragmentProgram
        fixed4 Tint; 
        sampler2D _MainTex;     
        float4 _MainTex_ST;   

        struct dataToVertex{
            float4 position:POSITION;
            float2 uv:TEXCOORD0;
        };

        struct Interpolators{
            float4 position:SV_POSITION;
            float2 uv:TEXCOORD0;
        };
        Interpolators MyVertexProgram(dataToVertex v){
            Interpolators i;
            i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
            i.position=UnityObjectToClipPos(v.position);
            return i;
        }
       
        float4 MyFragmentProgram(Interpolators o):SV_TARGET{
            return tex2D(_MainTex,o.uv)*Tint;
        }
   
        ENDCG
        }
    }
}
