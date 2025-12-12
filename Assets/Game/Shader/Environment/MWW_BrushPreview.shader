Shader "Hidden/MWW_BrushPreview"
{
    Properties
    {
        _MainTex ("Brush Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _IsCustom ("Is Custom Texture", Float) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        // 关闭深度写入，防止遮挡
        ZWrite Off
        // 只要不被物体挡住就显示 (LEqual)，稍微抬高了顶点所以不会穿插
        ZTest LEqual
        // 标准透明混合
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float _IsCustom;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;
                
                if (_IsCustom > 0.5)
                {
                    // --- 优化后的自定义纹理显示 ---
                    fixed4 tex = tex2D(_MainTex, i.uv);
                    
                    // 1. 颜色叠加：让纹理的黑白细节显现出来 (纹理越白，颜色越亮)
                    // 乘以 2.0 是为了让显示更明亮清晰
                    col.rgb = _Color.rgb * tex.rgb; 
                    
                    // 2. 透明度处理：纹理黑色的地方透明
                    // 稍微增强一点 Alpha，防止半透明纹理看不清
                    col.a = saturate(tex.r * _Color.a * 4.0);
                }
                else
                {
                    // --- 默认圆形 (保持不变) ---
                    float dist = distance(i.uv, float2(0.5, 0.5));
                    float alpha = 1.0 - smoothstep(0.45, 0.5, dist);
                    col.a *= alpha;
                }
                
                // 防止 Alpha 溢出
                col.a = saturate(col.a);

                return col;
            }
            ENDCG
        }
    }
}