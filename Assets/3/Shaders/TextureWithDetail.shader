// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TextureWithDetail"
{
   properties{
    Tint("color",Color)=(1,1,1,0)
    _MainTex("Texture",2D)="White"{}
    _DetailTex("Detail",2D)="Gray"{}
   }

   SubShader{

        
        pass{

        CGPROGRAM
           
        #pragma vertex MyVertexProgram
        #pragma fragment MyFragmentProgram

        #include "UnityCG.cginc"
        fixed4 Tint; 
        sampler2D _MainTex,_DetailTex;     
        float4 _MainTex_ST,_DetailTex_ST;   

        struct dataToVertex{
            float4 position:POSITION;
            float2 uv:TEXCOORD0;
        };

        struct Interpolators{
            float4 position:SV_POSITION;
            float2 uv:TEXCOORD0;
            float2 detailUv:TEXCOORD1;
        };
        Interpolators MyVertexProgram(dataToVertex v){
            Interpolators i;
            i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
            i.detailUv=TRANSFORM_TEX(v.uv,_DetailTex);
            i.position=UnityObjectToClipPos(v.position);
            return i;
        }
       
        float4 MyFragmentProgram(Interpolators o):SV_TARGET{
            float4 color = tex2D(_MainTex,o.uv)*Tint;
            return color*=tex2D(_DetailTex,o.detailUv)*unity_ColorSpaceDouble;
        }
   
        ENDCG
        }
    }
}
