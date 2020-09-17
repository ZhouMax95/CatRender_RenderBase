// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TextureSpalating"
{
   properties{
         Tint("color",Color)=(1,1,1,0)
         _MainTex("Texture",2D)="White"{}
         [NoScaleOffset]_Texture1("_Texture1",2D)="White"{}
         [NoScaleOffset]_Texture2("_Texture2",2D)="White"{}
         [NoScaleOffset]_Texture3("_Texture3",2D)="White"{}
         [NoScaleOffset]_Texture4("_Texture4",2D)="White"{}
   }

   SubShader{

        
        pass{

        CGPROGRAM
           
        #pragma vertex MyVertexProgram
        #pragma fragment MyFragmentProgram

        #include "UnityCG.cginc"
        fixed4 Tint; 
        sampler2D _MainTex,_Texture1,_Texture2,_Texture3,_Texture4;     
        float4 _MainTex_ST;   

        struct dataToVertex{
            float4 position:POSITION;
            float2 uv:TEXCOORD0;
        };

        struct Interpolators{
            float4 position:SV_POSITION;
            float2 uv:TEXCOORD0;
            float2 uvSpalat:TEXCOORD1;
        };
        Interpolators MyVertexProgram(dataToVertex v){
            Interpolators i;
            i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;     
            i.uvSpalat=v.uv;       
            i.position=UnityObjectToClipPos(v.position);
            return i;
        }
       
        float4 MyFragmentProgram(Interpolators o):SV_TARGET{
            float4 splat = tex2D(_MainTex,o.uvSpalat);
            float4 color;
            return color = tex2D(_Texture1,o.uv)*splat.r+
                           tex2D(_Texture2,o.uv)*splat.g+
                           tex2D(_Texture3,o.uv)*splat.b+
                           tex2D(_Texture4,o.uv)*(1-splat.r-splat.g-splat.b);
        }
   
        ENDCG
        }
    }
}
