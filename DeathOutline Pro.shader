Shader "DeathOutline"
{
    Properties
    {
        _MainTex("噪声贴图",2D) = "white" {}
        [HDR]_Color1("过度颜色1",Color)=(1,1,1)
        _Range1("过度亮度1",Range(0,10))=1
        [HDR]_Color2("过度颜色2",Color)=(1,1,1)
        _Range2("过度亮度2",Range(0,10))=1
        _Width("描边宽度",Range(-5,5))=1
        _Speed1("变化速度X轴",Range(-1,1))=0.5
        _Speed2("变化速度Y轴",Range(-1,1))=0.5
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        
        Pass
        {
            Stencil
            {
                Ref 1          
                Comp NotEqual    
                Pass replace   
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 nDirWS : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
                float3 nDirVS : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_ST;
            
            float3 _Color1,_Color2;

            float _Width,_Speed1,_Speed2,_Range1,_Range2;

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.xyz = v.vertex.xyz+v.normal*0.01*_Width;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.nDirVS = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                
                float2 screenUV = i.screenPos.xy/i.screenPos.w;
                float ver_MainTex = tex2D(_MainTex,screenUV+float2(_Time.y*_Speed1,_Time.y*_Speed2)).r;
                float3 col = lerp(_Color1*_Range1,_Color2*_Range2,ver_MainTex);
                
                return float4(col,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
