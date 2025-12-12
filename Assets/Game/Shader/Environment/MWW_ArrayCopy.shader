Shader "Hidden/MWW_ArrayCopy"
{
    Properties
    {
        _MainTex ("Texture Array", 2DArray) = "white" {}
        _SliceIndex ("Slice Index", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct v2f { float2 uv : TEXCOORD0; float4 vertex : SV_POSITION; };

            UNITY_DECLARE_TEX2DARRAY(_MainTex);
            float _SliceIndex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样 Array 的指定层，Unity 会自动处理压缩格式的解压
                return UNITY_SAMPLE_TEX2DARRAY(_MainTex, float3(i.uv, _SliceIndex));
            }
            ENDCG
        }
    }
}