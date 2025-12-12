Shader "Hidden/MWW_Internal_Paint"
{
    Properties
    {
        _MainTex ("Texture Array (Read Only)", 2DArray) = "white" {}
        _PaintUV ("Paint Center UV", Vector) = (0,0,0,0)
//        _BrushSize ("Brush Size", Float) = 5.0
        _BrushUVRadius ("Brush UV Size", Vector) = (0.1, 0.1, 0, 0)
        _BrushStrength ("Brush Strength", Float) = 1.0
        _TargetLayerIndex ("Target Layer Index (0-7)", Int) = 0
        _IsEraser ("Is Eraser", Int) = 0
        _RenderSlice ("Current Render Slice (0 or 1)", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZTest Always
        ZWrite Off
        Cull Off

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

            UNITY_DECLARE_TEX2DARRAY(_MainTex);
            float2 _PaintUV;
            // float _BrushSize;
            float _BrushStrength;
            int _TargetLayerIndex;
            int _IsEraser;
            int _RenderSlice;
            float4 _BrushUVRadius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f input) : SV_Target
            {
                // 1. 读取所有 8 个通道的旧权重
                // 这是一个 Array Texture，我们从中采样两层
                float4 layer03 = UNITY_SAMPLE_TEX2DARRAY(_MainTex, float3(input.uv, 0)); // Slice 0
                float4 layer47 = UNITY_SAMPLE_TEX2DARRAY(_MainTex, float3(input.uv, 1)); // Slice 1

                // 将权重解包到数组中方便操作
                float weights[8];
                weights[0] = layer03.r; weights[1] = layer03.g; weights[2] = layer03.b; weights[3] = layer03.a;
                weights[4] = layer47.r; weights[5] = layer47.g; weights[6] = layer47.b; weights[7] = layer47.a;

                // 2. 计算笔刷强度 (距离衰减)
                // 计算当前像素到点击点的 UV 向量差
                float2 uvOffset = input.uv - _PaintUV;

                // 归一化距离：将 X 差值除以 X 半径，Y 差值除以 Y 半径
                // 这样，无论原本是不是椭圆，除完之后都在同一个单位圆内比较
                // max(..., 1e-5) 是为了防止除以0
                float2 normDist = uvOffset / max(_BrushUVRadius.xy, 1e-5);
                
                // 计算归一化后的长度。如果 length < 1.0，说明在笔刷范围内
                float dist = length(normDist);
                
                // 计算遮罩 (保持原本的线性柔和衰减)
                float mask = saturate(1.0 - dist);
                float strength = _BrushStrength * mask;

                // 3. 执行归一化混合算法 (核心逻辑移植)
                int targetIndex = _TargetLayerIndex;
                float oldTargetWeight = weights[targetIndex];
                
                // 目标值：绘制向 1.0 靠拢，擦除向 0.0 靠拢
                float targetValue = _IsEraser ? 0.0 : 1.0;
                float newTargetWeight = lerp(oldTargetWeight, targetValue, strength);

                float remainingSpace = 1.0 - newTargetWeight;

                // 计算其他通道的总和
                float sumOthers = 0;
                for (int i = 0; i < 8; i++)
                {
                    if (i != targetIndex) sumOthers += weights[i];
                }

                // 分配权重
                for (int j = 0; j < 8; j++)
                {
                    if (j == targetIndex)
                    {
                        weights[j] = newTargetWeight;
                    }
                    else
                    {
                        if (sumOthers > 0.0001)
                        {
                            float scale = remainingSpace / sumOthers;
                            weights[j] *= scale;
                        }
                        else
                        {
                            // 极端情况：如果原本其他都是0 (例如第一次绘制)，
                            // 在 Paint 模式下，remainingSpace 会被浪费掉吗？
                            // 按照你的逻辑是置0。但在 Erase 模式下，如果 Eraser 把 Target 变小了，
                            // 其他通道全是 0，会导致总和 < 1。
                            // 通常 Erase 只需要减少 Target 即可，背景层（通常是0层）应该兜底。
                            // 这里为了严格匹配你的 C# 算法，保持置 0。
                            weights[j] = 0; 
                        }
                    }
                }

                // 4. 根据当前渲染的是哪个 Slice，返回对应的 4 个通道
                if (_RenderSlice == 0)
                {
                    return float4(weights[0], weights[1], weights[2], weights[3]);
                }
                else
                {
                    return float4(weights[4], weights[5], weights[6], weights[7]);
                }
            }
            ENDCG
        }
    }
}