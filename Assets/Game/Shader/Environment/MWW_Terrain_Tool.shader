Shader "Unlit/MWW_Terrain_Tool"
{
    Properties
    {
        _ControlTex ("ControlTex", 2DArray) = "white" {}
//        _Splat0 ("Splat0", 2D) = "white" {}
//        _Splat1 ("Splat1", 2D) = "white" {}
//        _Splat2 ("Splat2", 2D) = "white" {}
//        _Splat3 ("Splat3", 2D) = "white" {}
        _Splat("Splat", 2DArray ) = "grey" {}
        [Space()]
        [Header(LayersColor)]
        [Space()]
        _Lay1Color("Lay1Color", Color) = (1,1,1,1)
        _Lay2Color("Lay2Color", Color) = (1,1,1,1)
        _Lay3Color("Lay3Color", Color) = (1,1,1,1)
        _Lay4Color("Lay4Color", Color) = (1,1,1,1)
        _Lay5Color("Lay5Color", Color) = (1,1,1,1)
        _Lay6Color("Lay6Color", Color) = (1,1,1,1)
        _Lay7Color("Lay7Color", Color) = (1,1,1,1)
        _Lay8Color("Lay8Color", Color) = (1,1,1,1)
        [Space()]
        _Splat_NMP("Splat_nmp", 2DArray) = "Bump" {}
        [Space()]
        [Header(LayersTiling)]
        [Space()]
        _Lay1Tilling("Lay1Tilling", float) = 1
        _Lay2Tilling("Lay2Tilling", float) = 1
        _Lay3Tilling("Lay3Tilling", float) = 1
        _Lay4Tilling("Lay4Tilling", float) = 1
        _Lay5Tilling("Lay5Tilling", float) = 1
        _Lay6Tilling("Lay6Tilling", float) = 1
        _Lay7Tilling("Lay7Tilling", float) = 1
        _Lay8Tilling("Lay8Tilling", float) = 1
        [Space]
        [Header(NormalScale)]
        [Space()]
        _Lay1NMPScale("Lay1NMPScale", float) = 1
        _Lay2NMPScale("Lay2NMPScale", float) = 1
        _Lay3NMPScale("Lay3NMPScale", float) = 1
        _Lay4NMPScale("Lay4NMPScale", float) = 1
        _Lay5NMPScale("Lay5NMPScale", float) = 1
        _Lay6NMPScale("Lay6NMPScale", float) = 1
        _Lay7NMPScale("Lay7NMPScale", float) = 1
        _Lay8NMPScale("Lay8NMPScale", float) = 1
        
        [Space]
        [Header(Mask)]
        [Space()]
        _Splat_Mask("Splat_Mask", 2DArray) = "white" {}
        
        [Space]
        [Header(Metallic)]
        [Space()]
        _Lay1Metallic("Lay1Metallic", Range(0,2)) = 1
        _Lay2Metallic("Lay2Metallic", Range(0,2)) = 1
        _Lay3Metallic("Lay3Metallic", Range(0,2)) = 1
        _Lay4Metallic("Lay4Metallic", Range(0,2)) = 1
        _Lay5Metallic("Lay5Metallic", Range(0,2)) = 1
        _Lay6Metallic("Lay6Metallic", Range(0,2)) = 1
        _Lay7Metallic("Lay7Metallic", Range(0,2)) = 1
        _Lay8Metallic("Lay8Metallic", Range(0,2)) = 1
        
        [Header(AO)]
        [Space()]
        _Lay1AO("Lay1AO", Range(0,2)) = 1
        _Lay2AO("Lay2AO", Range(0,2)) = 1
        _Lay3AO("Lay3AO", Range(0,2)) = 1
        _Lay4AO("Lay4AO", Range(0,2)) = 1
        _Lay5AO("Lay5AO", Range(0,2)) = 1
        _Lay6AO("Lay6AO", Range(0,2)) = 1
        _Lay7AO("Lay7AO", Range(0,2)) = 1
        _Lay8AO("Lay8AO", Range(0,2)) = 1
        
        [Header(Smothness)]
        [Space()]
        _Lay1Smoothness("Lay1Smoothness", Range(0,2)) = 1
        _Lay2Smoothness("Lay2Smoothness", Range(0,2)) = 1
        _Lay3Smoothness("Lay3Smoothness", Range(0,2)) = 1
        _Lay4Smoothness("Lay4Smoothness", Range(0,2)) = 1
        _Lay5Smoothness("Lay5Smoothness", Range(0,2)) = 1
        _Lay6Smoothness("Lay6Smoothness", Range(0,2)) = 1
        _Lay7Smoothness("Lay7Smoothness", Range(0,2)) = 1
        _Lay8Smoothness("Lay8Smoothness", Range(0,2)) = 1
        
        [Space]
        [Header(Height)]
        [Space()]
        _Splat1_Height("Splat1_Height", Range(-1.1, 1)) = 0
        _Splat2_Height("Splat2_Height", Range(-1.1, 1)) = 0
        _Splat3_Height("Splat3_Height", Range(-1.1, 1)) = 0
        _Splat4_Height("Splat4_Height", Range(-1.1, 1)) = 0
        _Splat5_Height("Splat5_Height", Range(-1.1, 1)) = 0
        _Splat6_Height("Splat6_Height", Range(-1.1, 1)) = 0
        _Splat7_Height("Splat7_Height", Range(-1.1, 1)) = 0
        _Splat8_Height("Splat8_Height", Range(-1.1, 1)) = 0
        [Space]
        _Weight("Blend Weight" , Range(0.01,1)) = 0.2
        
        [Toggle(_MULTI_SPLAT_ON)] _Multi_Splat( "Multi Splat" , Float) = 0
        
        [HideInInspector] _RNM0 ("RNM0", 2D) = "black" {}
        [HideInInspector] _RNM1 ("RNM1", 2D) = "black" {}
        [HideInInspector] _RNM2 ("RNM2", 2D) = "black" {}
    }
    
    HLSLINCLUDE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Assets/ThirdPart/Bakery/shader/BakeryDecodeLightmap.hlsl"

    CBUFFER_START(UnityPerMaterial)

    half4 _Lay1Color;
    half4 _Lay2Color;
    half4 _Lay3Color;
    half4 _Lay4Color;
    half4 _Lay5Color;
    half4 _Lay6Color;
    half4 _Lay7Color;
    half4 _Lay8Color;

    half _Splat1_Height;
    half _Splat2_Height;
    half _Splat3_Height;
    half _Splat4_Height;
    half _Splat5_Height;
    half _Splat6_Height;
    half _Splat7_Height;
    half _Splat8_Height;
    half _Weight;
    half _Lay1Tilling;
    half _Lay2Tilling;
    half _Lay3Tilling;
    half _Lay4Tilling;
    half _Lay5Tilling;
    half _Lay6Tilling;
    half _Lay7Tilling;
    half _Lay8Tilling;
    
    half _Lay1NMPScale;
    half _Lay2NMPScale;
    half _Lay3NMPScale;
    half _Lay4NMPScale;
    half _Lay5NMPScale;
    half _Lay6NMPScale;
    half _Lay7NMPScale;
    half _Lay8NMPScale;

    half _Lay1Smoothness;
    half _Lay2Smoothness;
    half _Lay3Smoothness;
    half _Lay4Smoothness;
    half _Lay5Smoothness;
    half _Lay6Smoothness;
    half _Lay7Smoothness;
    half _Lay8Smoothness;

    half _Lay1AO;
    half _Lay2AO;
    half _Lay3AO;
    half _Lay4AO;
    half _Lay5AO;
    half _Lay6AO;
    half _Lay7AO;
    half _Lay8AO;

    half _Lay1Metallic;
    half _Lay2Metallic;
    half _Lay3Metallic;
    half _Lay4Metallic;
    half _Lay5Metallic;
    half _Lay6Metallic;
    half _Lay7Metallic;
    half _Lay8Metallic;

    float4 _ControlTex_TexelSize;
    float4 _Splat_TexelSize;

    CBUFFER_END

    TEXTURE2D_ARRAY( _ControlTex);
    SAMPLER( sampler_ControlTex);
    // TEXTURE2D( _Splat0); SAMPLER( sampler_Splat0);
    // TEXTURE2D( _Splat1); SAMPLER( sampler_Splat1);
    // TEXTURE2D( _Splat2); SAMPLER( sampler_Splat2);
    // TEXTURE2D( _Splat3); SAMPLER( sampler_Splat3);
    TEXTURE2D_ARRAY(_Splat);
    SAMPLER( sampler_Splat);
    
    TEXTURE2D_ARRAY(_Splat_NMP);
    SAMPLER( sampler_Splat_NMP);
    
    TEXTURE2D_ARRAY(_Splat_Mask);
    SAMPLER( sampler_Splat_Mask);
    
    

    float3 blend(float4 lay1, float4 lay2, half4 splat_control)
    {
        // return lay1.a > lay2.a ? lay1.rgb : lay2.rgb;
        // return lay1.a * splat_control.b > lay2.a * splat_control.a ? lay1.rgb : lay2.rgb;
        float b1 = lay1.a * splat_control.b;
        float b2 = lay2.a * splat_control.a;
        float ma = max(b1,b2);
        b1 = max(b1 - (ma - 0.3), 0) * splat_control.b;
        b2 = max(b2 - (ma - 0.3), 0) * splat_control.a;

        return (lay1.rgb * b1 + lay2.rgb * b2)/(b1 + b2);
    }

    inline half4 Blend(half high1 ,half high2,half high3,half high4 , half4 control) 
    {
        half4 blend = half4(high1, high2, high3, high4) * control;
        half ma = max(blend.r, max(blend.g, max(blend.b, blend.a)));
        //与权重最大的通道进行对比，高度差在_Weight范围内的将会保留,_Weight不可以为0
        blend = max(blend - ma + _Weight , 0) * control;
        return blend/(blend.r + blend.g + blend.b + blend.a);
    }

    inline void Blend8(
    half high1, half high2, half high3, half high4,
    half high5, half high6, half high7, half high8,
    half4 control1, half4 control2,
    out half4 outBlend1, out half4 outBlend2)  // 用 out 参数返回两组结果
    {
        // 第一步：计算所有通道的初始混合值
        half4 blend1 = half4(high1, high2, high3, high4) * control1;
        half4 blend2 = half4(high5, high6, high7, high8) * control2;
        
        // 第二步：找出全局最大值（8个通道中的最大值）
        half ma = max(
            max(blend1.r, max(blend1.g, max(blend1.b, blend1.a))),
            max(blend2.r, max(blend2.g, max(blend2.b, blend2.a)))
        );
        
        // 第三步：用全局最大值处理所有通道
        blend1 = max(blend1 - ma + _Weight, 0) * control1;
        blend2 = max(blend2 - ma + _Weight, 0) * control2;
        
        // 第四步：全局归一化（所有8个通道的总和）
        half sum = blend1.r + blend1.g + blend1.b + blend1.a +
                   blend2.r + blend2.g + blend2.b + blend2.a;
        
        outBlend1 = blend1 / sum;
        outBlend2 = blend2 / sum;
    }

    ENDHLSL
    
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
            #pragma multi_compile _ LIGHTMAP_ON
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #pragma shader_feature_local _MULTI_SPLAT_ON

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;

                UNITY_VERTEX_INPUT_INSTANCE_ID
        
            };

            struct v2f
            {
                float4 uvMainAndLM : TEXCOORD0;
                float4 positionWSWithFog : TEXCOORD1;
                float4 uvSplat01                : TEXCOORD2; // xy: splat0, zw: splat1
                float4 uvSplat23                : TEXCOORD3; // xy: splat2, zw: splat3
                #ifdef _MULTI_SPLAT_ON
                float4 uvSplat45                : TEXCOORD4; // xy: splat4, zw: splat5
                float4 uvSplat67                : TEXCOORD5; // xy: splat6, zw: splat7
                #endif 
                float3 normalWS : NORMAL;
                float4 tangentWS : TANGENT;
                float4 positionCS : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata input)
            {
                v2f output = (v2f)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs inputVertex = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionWSWithFog.xyz = inputVertex.positionWS;
                output.positionCS = inputVertex.positionCS;

                output.uvMainAndLM.xy = input.uv;
                float2 lmUV = input.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
                output.uvMainAndLM.zw = lmUV;
                output.normalWS = normalInput.normalWS;

                //LayerTiling
                output.uvSplat01.xy = input.uv * (10/_Lay1Tilling);
                output.uvSplat01.zw = input.uv * (10/_Lay2Tilling);
                output.uvSplat23.xy = input.uv * (10/_Lay3Tilling);
                output.uvSplat23.zw = input.uv * (10/_Lay4Tilling);
                
                #ifdef _MULTI_SPLAT_ON
                    output.uvSplat45.xy = input.uv * (10/_Lay5Tilling);
                    output.uvSplat45.zw = input.uv * (10/_Lay6Tilling);
                    output.uvSplat67.xy = input.uv * (10/_Lay7Tilling);
                    output.uvSplat67.zw = input.uv * (10/_Lay8Tilling);
                #endif
                
                // real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, input.tangentOS.w);

                output.tangentWS = tangentWS;

                half fogFactor = 0;
                fogFactor = ComputeFogFactor(output.positionCS.z);
                output.positionWSWithFog.w = fogFactor;
                
                return output;
            }

            half4 frag (v2f input) : SV_Target
            {
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float3 positionWS = input.positionWSWithFog.xyz;
                // float2 worldUV = positionWS.xz;
                // float4 scaleOffset = 0;
                // scaleOffset.xy = 1 / 10;
                // scaleOffset.zw = 0;
                //
                // worldUV = input.uvMainAndLM * (10 / _Lay2Tilling);// + scaleOffset.zw;
                
                // sample the texture
                float2 splatUV = (input.uvMainAndLM.xy * (_ControlTex_TexelSize.zw - 1.0f) + 0.5f) * _ControlTex_TexelSize.xy;
                half4 splat0 = SAMPLE_TEXTURE2D_ARRAY(_ControlTex, sampler_ControlTex, splatUV, 0);
                half4 splat1 = SAMPLE_TEXTURE2D_ARRAY(_ControlTex, sampler_ControlTex, splatUV, 1);

                half4 albedo = 0;
                albedo.a = 1;

                float3 normalTS = 0;
                float metallic = 0;
                float smoothness = 0;
                float occlusion = 0;
                
                // 这里是Layers 的Albedo
                half4 lay1 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat01.xy, 0) ;
                half4 lay2 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat01.zw, 1);
                half4 lay3 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat23.xy, 2);
                half4 lay4 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat23.zw, 3);
                #ifdef _MULTI_SPLAT_ON
                    half4 lay5 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat45.xy, 4);
                    half4 lay6 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat45.zw, 5);
                    half4 lay7 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat67.xy, 6);
                    half4 lay8 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat67.zw, 7);
                #endif
                

                // 这里是Layers 的NMP
                half4 lay1_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat01.xy , 0);
                lay1_nmp.rgb = UnpackNormalScale(lay1_nmp, _Lay1NMPScale);
                half4 lay2_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat01.zw, 1);
                lay2_nmp.rgb = UnpackNormalScale(lay2_nmp, _Lay2NMPScale);
                half4 lay3_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat23.xy, 2);
                lay3_nmp.rgb = UnpackNormalScale(lay3_nmp, _Lay3NMPScale);
                half4 lay4_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat23.zw, 3);
                lay4_nmp.rgb = UnpackNormalScale(lay4_nmp, _Lay4NMPScale);

                #ifdef _MULTI_SPLAT_ON
                    half4 lay5_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.xy , 4);
                    // half4 lay5_nmp_1 = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.xy + _Time.y * half2(-0.025, -0.025), 4);
                    // lay5_nmp = (lay5_nmp + lay5_nmp_1) / 2;
                    lay5_nmp.rgb = UnpackNormalScale(lay5_nmp, _Lay5NMPScale);
                    half4 lay6_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.zw, 5);
                    lay6_nmp.rgb = UnpackNormalScale(lay6_nmp, _Lay6NMPScale);
                    half4 lay7_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat67.xy, 6);
                    lay7_nmp.rgb = UnpackNormalScale(lay7_nmp, _Lay7NMPScale);
                    half4 lay8_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat67.zw, 7);
                    lay8_nmp.rgb = UnpackNormalScale(lay8_nmp, _Lay8NMPScale);
                #endif
                
                // 这里是Layers 的Mask
                half4 lay1_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat01.xy, 0);
                half4 lay2_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat01.zw, 1);
                half4 lay3_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat23.xy, 2);
                half4 lay4_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat23.zw, 3);

                #ifdef _MULTI_SPLAT_ON
                    half4 lay5_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat45.xy, 4);
                    half4 lay6_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat45.zw, 5);
                    half4 lay7_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat67.xy, 6);
                    half4 lay8_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat67.zw, 7);
                #endif
                
                // finalCol.rgb += (lay1.rgb * col.r + lay2.rgb * col.g + lay3.rgb * col.b + lay4.rgb * col.a);
                //这里 混合的时候，lay4.a + _Splat3_Height > 1，所以lay4.a + _Splat3_Height 会被截断为1
                lay1_mask.b += _Splat1_Height;
                lay2_mask.b += _Splat2_Height;
                lay3_mask.b += _Splat3_Height;
                lay4_mask.b += _Splat4_Height;

                #ifdef _MULTI_SPLAT_ON
                    lay5_mask.b += _Splat5_Height;
                    lay6_mask.b += _Splat6_Height;
                    lay7_mask.b += _Splat7_Height;
                    lay8_mask.b += _Splat8_Height;
                #endif
                
                // finalCol.rgb = blend(lay3, lay4, col);

                // half4 blend = Blend(lay1_mask.b,lay2_mask.b,lay3_mask.b,lay4_mask.b, splat0);
                half4 blend0 = 0;
                half4 blend1 = 1;

                #ifdef _MULTI_SPLAT_ON
                    Blend8(lay1_mask.b, lay2_mask.b, lay3_mask.b, lay4_mask.b,
                    lay5_mask.b, lay6_mask.b, lay7_mask.b, lay8_mask.b,
                    splat0, splat1, blend0, blend1);

                #else
                    Blend8(lay1_mask.b, lay2_mask.b, lay3_mask.b, lay4_mask.b,
                    0, 0, 0, 0,
                    splat0, splat1, blend0, blend1);
                #endif

                blend0 = saturate(blend0);
                blend1 = saturate(blend1);
                
                //----------Albedo----------
                albedo.rgb = blend0.r * lay1.rgb * _Lay1Color.rgb * _Lay1Color.a
                    + blend0.g * lay2.rgb * _Lay2Color.rgb * _Lay2Color.a
                    + blend0.b * lay3.rgb * _Lay3Color.rgb * _Lay3Color.a
                    + blend0.a * lay4.rgb * _Lay4Color.rgb * _Lay4Color.a;

                #ifdef _MULTI_SPLAT_ON
                    albedo.rgb += blend1.r * lay5.rgb * _Lay5Color.rgb * _Lay5Color.a
                        + blend1.g * lay6.rgb * _Lay6Color.rgb * _Lay6Color.a
                        + blend1.b * lay7.rgb * _Lay7Color.rgb * _Lay7Color.a
                        + blend1.a * lay8.rgb * _Lay8Color.rgb * _Lay8Color.a;//混合
                #endif
                
                //---------NMP----------
                half3 normalTS_1 = blend0.r * lay1_nmp.rgb
                    + blend0.g * lay2_nmp.rgb
                    + blend0.b * lay3_nmp.rgb
                    + blend0.a * lay4_nmp.rgb;
                
                #ifdef _MULTI_SPLAT_ON
                        normalTS_1 += blend1.r * lay5_nmp.rgb
                        + blend1.g * lay6_nmp.rgb
                        + blend1.b * lay7_nmp.rgb
                        + blend1.a * lay8_nmp.rgb;
                #endif
                
                normalTS.rgb = normalTS_1;
                
                //---------Mask----------
                metallic = blend0.r * lay1_mask.r * _Lay1Metallic
                    + blend0.g * lay2_mask.r * _Lay2Metallic
                    + blend0.b * lay3_mask.r * _Lay3Metallic
                    + blend0.a * lay4_mask.r * _Lay4Metallic;
                #ifdef  _MULTI_SPLAT_ON
                    metallic += blend1.r * lay5_mask.r * _Lay5Metallic
                        + blend1.g * lay6_mask.r * _Lay6Metallic
                        + blend1.b * lay7_mask.r * _Lay7Metallic
                        + blend1.a * lay8_mask.r * _Lay8Metallic;
                #endif        
                smoothness = blend0.r * lay1_mask.a * _Lay1Smoothness +
                                blend0.g * lay2_mask.a * _Lay2Smoothness +
                                    blend0.b * lay3_mask.a * _Lay3Smoothness +
                                        blend0.a * lay4_mask.a * _Lay4Smoothness;
                
                #ifdef  _MULTI_SPLAT_ON
                smoothness += blend1.r * lay5_mask.a * _Lay5Smoothness
                                + blend1.g * lay6_mask.a * _Lay6Smoothness
                                + blend1.b * lay7_mask.a * _Lay7Smoothness
                                + blend1.a * lay8_mask.a * _Lay8Smoothness;
                #endif
                
                occlusion = blend0.r * lay1_mask.g * _Lay1AO
                    + blend0.g * lay2_mask.g * _Lay2AO
                    + blend0.b * lay3_mask.g * _Lay3AO
                    + blend0.a * lay4_mask.g * _Lay4AO;

                #ifdef  _MULTI_SPLAT_ON
                occlusion += blend1.r * lay5_mask.g * _Lay5AO
                    + blend1.g * lay6_mask.g * _Lay6AO
                    + blend1.b * lay7_mask.g * _Lay7AO
                    + blend1.a * lay8_mask.g * _Lay8AO;
                #endif
                occlusion = FastLinearToSRGB(occlusion);
                // SurfaceData
                SurfaceData surfaceData = (SurfaceData)0;

                surfaceData.albedo = albedo.rgb;
                surfaceData.normalTS = normalTS.rgb;
                // 这里可以暂时忽略
                surfaceData.metallic = metallic;
                surfaceData.smoothness = smoothness;
                surfaceData.occlusion = LerpWhiteTo(occlusion, 1) ;

                // InputData
                InputData inputData = (InputData)0;
                inputData.positionWS = input.positionWSWithFog.xyz;
                half3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
                float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                float3 bitangent = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                inputData.tangentToWorld = tangentToWorld;
                inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                inputData.viewDirectionWS = viewDirWS;

                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.positionWSWithFog.w);
                
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                
                // --- 【开始 Bakery 集成】 ---
                float3 bakeryDiffuse = 0;
                float3 bakerySpecular = 0;

                #if defined(LIGHTMAP_ON)
                    // 1. 获取 Lightmap UV
                    float2 lmUV = input.uvMainAndLM.zw;

                    // 2. 采样 Unity 默认 Lightmap 得到基础 L0
                    // Bakery 的算法依赖这个基础光照贴图
                    float3 L0 = DecodeLightmap(SAMPLE_TEXTURE2D(unity_Lightmap, samplerunity_Lightmap, lmUV), half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h));

                    // 3. 调用 Bakery 函数计算 SH Diffuse 和 Specular
                    // 参数对应：L0, WorldNormal, LightmapUV, ViewDir, Smoothness, Albedo, Metallic, [Out]Diffuse, [Out]Spec
                    BakerySpecSHFull_float(
                        L0, 
                        inputData.normalWS, 
                        lmUV, 
                        inputData.viewDirectionWS, 
                        surfaceData.smoothness, 
                        surfaceData.albedo, 
                        surfaceData.metallic, 
                        bakeryDiffuse,   // 输出：漫反射部分
                        bakerySpecular   // 输出：高光部分
                    );

                    // 4. 将 Bakery 的 Diffuse 赋值给 InputData.bakedGI
                    // 这样 UniversalFragmentPBR 就会使用 Bakery 的漫反射 GI
                    inputData.bakedGI = bakeryDiffuse;
                #else
                    // 如果没有 Lightmap，回退到默认探针
                    inputData.bakedGI = EvaluateAmbientProbeSRGB(inputData.normalWS);
                #endif
                
                // 简单的光照计算
                half4 color = UniversalFragmentPBR(inputData, surfaceData);
                color.rgb += bakerySpecular;
                color.rgb = MixFog(color.rgb, inputData.fogCoord);

                // color.rgb = inputData.normalWS;
                // Light mainLight = GetMainLight();
                // float3 lightDir = mainLight.direction;
                // float3 normalWS = TransformTangentToWorld(lay1_nmp.rgb, tangentToWorld, true);
                // color.rgb = max(0, dot(normalWS, lightDir)) * lay1.rgb;
                
                return color;
            }
            
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            

            HLSLPROGRAM
            //#pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // GPU Instancing支持
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/CommonMaterial.hlsl"

            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float2 uv           : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.texcoord;
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
            
            ZWrite On
            
            
            HLSLPROGRAM
            #pragma target 2.0

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uvMainAndLM : TEXCOORD0;
                float4 positionWSWithFog : TEXCOORD1;
                float4 uvSplat01                : TEXCOORD2; // xy: splat0, zw: splat1
                float4 uvSplat23                : TEXCOORD3; // xy: splat2, zw: splat3
                #ifdef _MULTI_SPLAT_ON
                float4 uvSplat45                : TEXCOORD4; // xy: splat4, zw: splat5
                float4 uvSplat67                : TEXCOORD5; // xy: splat6, zw: splat7
                #endif 
                float3 normalWS : NORMAL;
                float4 tangentWS : TANGENT;
                float4 positionCS : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #pragma shader_feature_local _MULTI_SPLAT_ON

            v2f DepthNormalsVertex(appdata input)
            { 
                v2f output = (v2f)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs inputVertex = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionWSWithFog.xyz = inputVertex.positionWS;
                output.positionCS = inputVertex.positionCS;
                output.uvMainAndLM.xy = input.uv;
                output.normalWS = normalInput.normalWS;

                //LayerTiling
                output.uvSplat01.xy = input.uv * (10/_Lay1Tilling);
                output.uvSplat01.zw = input.uv * (10/_Lay2Tilling);
                output.uvSplat23.xy = input.uv * (10/_Lay3Tilling);
                output.uvSplat23.zw = input.uv * (10/_Lay4Tilling);
                #ifdef _MULTI_SPLAT_ON
                    output.uvSplat45.xy = input.uv * (10/_Lay5Tilling);
                    output.uvSplat45.zw = input.uv * (10/_Lay6Tilling);
                    output.uvSplat67.xy = input.uv * (10/_Lay7Tilling);
                    output.uvSplat67.zw = input.uv * (10/_Lay8Tilling);
                #endif

                // real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, input.tangentOS.w);

                output.tangentWS = tangentWS;

                half fogFactor = 0;
                fogFactor = ComputeFogFactor(output.positionCS.z);
                output.positionWSWithFog.w = fogFactor;
                
                return output;
            }

            void DepthNormalsFragment(
                v2f input
                , out half4 outNormalWS : SV_Target0
            #ifdef _WRITE_RENDERING_LAYERS
                , out float4 outRenderingLayers : SV_Target1
            #endif
            ){
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float3 positionWS = input.positionWSWithFog.xyz;
              
                float2 splatUV = (input.uvMainAndLM.xy * (_ControlTex_TexelSize.zw - 1.0f) + 0.5f) * _ControlTex_TexelSize.xy;
                half4 splat0 = SAMPLE_TEXTURE2D_ARRAY(_ControlTex, sampler_ControlTex, splatUV, 0);
                half4 splat1 = SAMPLE_TEXTURE2D_ARRAY(_ControlTex, sampler_ControlTex, splatUV, 1);

                float3 normalTS = 0;

                // 这里是Layers 的NMP
                half4 lay1_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat01.xy , 0);
                lay1_nmp.rgb = UnpackNormalScale(lay1_nmp, _Lay1NMPScale);
                half4 lay2_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat01.zw, 1);
                lay2_nmp.rgb = UnpackNormalScale(lay2_nmp, _Lay2NMPScale);
                half4 lay3_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat23.xy, 2);
                lay3_nmp.rgb = UnpackNormalScale(lay3_nmp, _Lay3NMPScale);
                half4 lay4_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat23.zw, 3);
                lay4_nmp.rgb = UnpackNormalScale(lay4_nmp, _Lay4NMPScale);
                #ifdef _MULTI_SPLAT_ON
                    half4 lay5_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.xy , 4);
                    // half4 lay5_nmp_1 = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.xy + _Time.y * half2(-0.025, -0.025), 4);
                    // lay5_nmp = (lay5_nmp + lay5_nmp_1) / 2;
                    lay5_nmp.rgb = UnpackNormalScale(lay5_nmp, _Lay5NMPScale);
                    half4 lay6_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.zw, 5);
                    lay6_nmp.rgb = UnpackNormalScale(lay6_nmp, _Lay6NMPScale);
                    half4 lay7_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat67.xy, 6);
                    lay7_nmp.rgb = UnpackNormalScale(lay7_nmp, _Lay7NMPScale);
                    half4 lay8_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat67.zw, 7);
                    lay8_nmp.rgb = UnpackNormalScale(lay8_nmp, _Lay8NMPScale);
                #endif
                
                // 这里是Layers 的Mask
                half4 lay1_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat01.xy, 0);
                half4 lay2_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat01.zw, 1);
                half4 lay3_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat23.xy, 2);
                half4 lay4_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat23.zw, 3);

                #ifdef _MULTI_SPLAT_ON
                    half4 lay5_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat45.xy, 4);
                    half4 lay6_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat45.zw, 5);
                    half4 lay7_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat67.xy, 6);
                    half4 lay8_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat67.zw, 7);
                #endif
                
                // finalCol.rgb += (lay1.rgb * col.r + lay2.rgb * col.g + lay3.rgb * col.b + lay4.rgb * col.a);
                //这里 混合的时候，lay4.a + _Splat3_Height > 1，所以lay4.a + _Splat3_Height 会被截断为1
                lay1_mask.b += _Splat1_Height;
                lay2_mask.b += _Splat2_Height;
                lay3_mask.b += _Splat3_Height;
                lay4_mask.b += _Splat4_Height;

                #ifdef _MULTI_SPLAT_ON
                    lay5_mask.b += _Splat5_Height;
                    lay6_mask.b += _Splat6_Height;
                    lay7_mask.b += _Splat7_Height;
                    lay8_mask.b += _Splat8_Height;
                #endif
                
                // finalCol.rgb = blend(lay3, lay4, col);

                // half4 blend = Blend(lay1_mask.b,lay2_mask.b,lay3_mask.b,lay4_mask.b, splat0);
                half4 blend0 = 0;
                half4 blend1 = 1;

                #ifdef _MULTI_SPLAT_ON
                    Blend8(lay1_mask.b, lay2_mask.b, lay3_mask.b, lay4_mask.b,
                    lay5_mask.b, lay6_mask.b, lay7_mask.b, lay8_mask.b,
                    splat0, splat1, blend0, blend1);

                #else
                    Blend8(lay1_mask.b, lay2_mask.b, lay3_mask.b, lay4_mask.b,
                    0, 0, 0, 0,
                    splat0, splat1, blend0, blend1);
                #endif

                blend0 = saturate(blend0);
                blend1 = saturate(blend1);

                //---------NMP----------
                //---------NMP----------
                half3 normalTS_1 = blend0.r * lay1_nmp.rgb
                    + blend0.g * lay2_nmp.rgb
                    + blend0.b * lay3_nmp.rgb
                    + blend0.a * lay4_nmp.rgb;
                
                #ifdef _MULTI_SPLAT_ON
                        normalTS_1 += blend1.r * lay5_nmp.rgb
                        + blend1.g * lay6_nmp.rgb
                        + blend1.b * lay7_nmp.rgb
                        + blend1.a * lay8_nmp.rgb;
                #endif
                
                normalTS.rgb = normalTS_1;

                float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                float3 bitangent = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                half3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
                normalWS = NormalizeNormalPerPixel(normalWS);

                outNormalWS = half4(normalWS, 1);

                #ifdef _WRITE_RENDERING_LAYERS
                    uint renderingLayers = GetMeshRenderingLayer();
                    outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
                #endif
            }

            ENDHLSL
        }

        Pass
        {
            Name "PixelDepthOffset"
            Tags
            {
                "LightMode" = "PixelDepthOffset"
            }
            
            ZWrite On
            
            
            HLSLPROGRAM
            #pragma target 2.0

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uvMainAndLM : TEXCOORD0;
                float4 positionWSWithFog : TEXCOORD1;
                float4 uvSplat01                : TEXCOORD2; // xy: splat0, zw: splat1
                float4 uvSplat23                : TEXCOORD3; // xy: splat2, zw: splat3
                #ifdef _MULTI_SPLAT_ON
                float4 uvSplat45                : TEXCOORD4; // xy: splat4, zw: splat5
                float4 uvSplat67                : TEXCOORD5; // xy: splat6, zw: splat7
                #endif 
                float3 normalWS : NORMAL;
                float4 tangentWS : TANGENT;
                float4 positionCS : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // -------------------------------------
            // Shader Stages
            #pragma vertex Vertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #pragma shader_feature_local _MULTI_SPLAT_ON

            v2f Vertex(appdata input)
            { 
                v2f output = (v2f)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs inputVertex = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionWSWithFog.xyz = inputVertex.positionWS;
                output.positionCS = inputVertex.positionCS;
                output.uvMainAndLM.xy = input.uv;
                output.normalWS = normalInput.normalWS;

                //LayerTiling
                output.uvSplat01.xy = input.uv * (10/_Lay1Tilling);
                output.uvSplat01.zw = input.uv * (10/_Lay2Tilling);
                output.uvSplat23.xy = input.uv * (10/_Lay3Tilling);
                output.uvSplat23.zw = input.uv * (10/_Lay4Tilling);
                #ifdef _MULTI_SPLAT_ON
                    output.uvSplat45.xy = input.uv * (10/_Lay5Tilling);
                    output.uvSplat45.zw = input.uv * (10/_Lay6Tilling);
                    output.uvSplat67.xy = input.uv * (10/_Lay7Tilling);
                    output.uvSplat67.zw = input.uv * (10/_Lay8Tilling);
                #endif

                // real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, input.tangentOS.w);

                output.tangentWS = tangentWS;

                half fogFactor = 0;
                fogFactor = ComputeFogFactor(output.positionCS.z);
                output.positionWSWithFog.w = fogFactor;
                
                return output;
            }

            void DepthNormalsFragment(
                v2f input
                , out float4 albedo : SV_Target0
                , out half4 normal : SV_Target1
                , out half4 mask : SV_Target2
            ){
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float3 positionWS = input.positionWSWithFog.xyz;
              
                float2 splatUV = (input.uvMainAndLM.xy * (_ControlTex_TexelSize.zw - 1.0f) + 0.5f) * _ControlTex_TexelSize.xy;
                half4 splat0 = SAMPLE_TEXTURE2D_ARRAY(_ControlTex, sampler_ControlTex, splatUV, 0);
                half4 splat1 = SAMPLE_TEXTURE2D_ARRAY(_ControlTex, sampler_ControlTex, splatUV, 1);

                float metallic = 0;
                float smoothness = 0;
                float occlusion = 0;

                // 这里是Layers 的Albedo
                half4 lay1 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat01.xy, 0) ;
                half4 lay2 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat01.zw, 1);
                half4 lay3 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat23.xy, 2);
                half4 lay4 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat23.zw, 3);
                #ifdef _MULTI_SPLAT_ON
                    half4 lay5 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat45.xy, 4);
                    half4 lay6 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat45.zw, 5);
                    half4 lay7 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat67.xy, 6);
                    half4 lay8 = SAMPLE_TEXTURE2D_ARRAY(_Splat, sampler_Splat, input.uvSplat67.zw, 7);
                #endif

                float3 normalTS = 0;

                // 这里是Layers 的NMP
                half4 lay1_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat01.xy , 0);
                lay1_nmp.rgb = UnpackNormalScale(lay1_nmp, _Lay1NMPScale);
                half4 lay2_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat01.zw, 1);
                lay2_nmp.rgb = UnpackNormalScale(lay2_nmp, _Lay2NMPScale);
                half4 lay3_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat23.xy, 2);
                lay3_nmp.rgb = UnpackNormalScale(lay3_nmp, _Lay3NMPScale);
                half4 lay4_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat23.zw, 3);
                lay4_nmp.rgb = UnpackNormalScale(lay4_nmp, _Lay4NMPScale);
                #ifdef _MULTI_SPLAT_ON
                    half4 lay5_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.xy , 4);
                    // half4 lay5_nmp_1 = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.xy + _Time.y * half2(-0.025, -0.025), 4);
                    // lay5_nmp = (lay5_nmp + lay5_nmp_1) / 2;
                    lay5_nmp.rgb = UnpackNormalScale(lay5_nmp, _Lay5NMPScale);
                    half4 lay6_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat45.zw, 5);
                    lay6_nmp.rgb = UnpackNormalScale(lay6_nmp, _Lay6NMPScale);
                    half4 lay7_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat67.xy, 6);
                    lay7_nmp.rgb = UnpackNormalScale(lay7_nmp, _Lay7NMPScale);
                    half4 lay8_nmp = SAMPLE_TEXTURE2D_ARRAY(_Splat_NMP, sampler_Splat_NMP, input.uvSplat67.zw, 7);
                    lay8_nmp.rgb = UnpackNormalScale(lay8_nmp, _Lay8NMPScale);
                #endif
                
                // 这里是Layers 的Mask
                half4 lay1_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat01.xy, 0);
                half4 lay2_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat01.zw, 1);
                half4 lay3_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat23.xy, 2);
                half4 lay4_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat23.zw, 3);

                #ifdef _MULTI_SPLAT_ON
                    half4 lay5_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat45.xy, 4);
                    half4 lay6_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat45.zw, 5);
                    half4 lay7_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat67.xy, 6);
                    half4 lay8_mask = SAMPLE_TEXTURE2D_ARRAY(_Splat_Mask, sampler_Splat_Mask, input.uvSplat67.zw, 7);
                #endif
                
                // finalCol.rgb += (lay1.rgb * col.r + lay2.rgb * col.g + lay3.rgb * col.b + lay4.rgb * col.a);
                //这里 混合的时候，lay4.a + _Splat3_Height > 1，所以lay4.a + _Splat3_Height 会被截断为1
                lay1_mask.b += _Splat1_Height;
                lay2_mask.b += _Splat2_Height;
                lay3_mask.b += _Splat3_Height;
                lay4_mask.b += _Splat4_Height;

                #ifdef _MULTI_SPLAT_ON
                    lay5_mask.b += _Splat5_Height;
                    lay6_mask.b += _Splat6_Height;
                    lay7_mask.b += _Splat7_Height;
                    lay8_mask.b += _Splat8_Height;
                #endif
                
                // finalCol.rgb = blend(lay3, lay4, col);

                // half4 blend = Blend(lay1_mask.b,lay2_mask.b,lay3_mask.b,lay4_mask.b, splat0);
                half4 blend0 = 0;
                half4 blend1 = 1;

                #ifdef _MULTI_SPLAT_ON
                    Blend8(lay1_mask.b, lay2_mask.b, lay3_mask.b, lay4_mask.b,
                    lay5_mask.b, lay6_mask.b, lay7_mask.b, lay8_mask.b,
                    splat0, splat1, blend0, blend1);

                #else
                    Blend8(lay1_mask.b, lay2_mask.b, lay3_mask.b, lay4_mask.b,
                    0, 0, 0, 0,
                    splat0, splat1, blend0, blend1);
                #endif

                blend0 = saturate(blend0);
                blend1 = saturate(blend1);

                //----------Albedo----------
                albedo.rgb = blend0.r * lay1.rgb * _Lay1Color.rgb * _Lay1Color.a
                    + blend0.g * lay2.rgb * _Lay2Color.rgb * _Lay2Color.a
                    + blend0.b * lay3.rgb * _Lay3Color.rgb * _Lay3Color.a
                    + blend0.a * lay4.rgb * _Lay4Color.rgb * _Lay4Color.a;

                #ifdef _MULTI_SPLAT_ON
                    albedo.rgb += blend1.r * lay5.rgb * _Lay5Color.rgb * _Lay5Color.a
                        + blend1.g * lay6.rgb * _Lay6Color.rgb * _Lay6Color.a
                        + blend1.b * lay7.rgb * _Lay7Color.rgb * _Lay7Color.a
                        + blend1.a * lay8.rgb * _Lay8Color.rgb * _Lay8Color.a;//混合
                #endif

                float4 shadowCoord = float4(ComputeNormalizedDeviceCoordinatesWithZ(positionWS, GetWorldToHClipMatrix()), 1.0);
                float2 shadowUV = shadowCoord.xy /= max(0.00001, shadowCoord.w); // Prevent division by zero.
                half attenuation = half(SAMPLE_TEXTURE2D(_ScreenSpaceShadowmapTexture, sampler_PointClamp, shadowUV.xy).x);

                float4x4 viewMatrix = GetWorldToViewMatrix();
                float depth = LinearEyeDepth(positionWS, viewMatrix);
                // float depth = positionWS.y;
                albedo = half4(lerp(albedo.rgb * 0.25, albedo.rgb  ,attenuation), depth);
                // albedo.rgb = attenuation;
                //---------NMP----------
                half3 normalTS_1 = blend0.r * lay1_nmp.rgb
                    + blend0.g * lay2_nmp.rgb
                    + blend0.b * lay3_nmp.rgb
                    + blend0.a * lay4_nmp.rgb;
                
                #ifdef _MULTI_SPLAT_ON
                        normalTS_1 += blend1.r * lay5_nmp.rgb
                        + blend1.g * lay6_nmp.rgb
                        + blend1.b * lay7_nmp.rgb
                        + blend1.a * lay8_nmp.rgb;
                #endif
                
                normalTS.rgb = normalTS_1;

                float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                float3 bitangent = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                half3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
                normalWS = NormalizeNormalPerPixel(normalWS);

                normal = half4(normalWS, 1);

                //---------Mask----------
                metallic = blend0.r * lay1_mask.r * _Lay1Metallic
                    + blend0.g * lay2_mask.r * _Lay2Metallic
                    + blend0.b * lay3_mask.r * _Lay3Metallic
                    + blend0.a * lay4_mask.r * _Lay4Metallic;
                #ifdef  _MULTI_SPLAT_ON
                    metallic += blend1.r * lay5_mask.r * _Lay5Metallic
                        + blend1.g * lay6_mask.r * _Lay6Metallic
                        + blend1.b * lay7_mask.r * _Lay7Metallic
                        + blend1.a * lay8_mask.r * _Lay8Metallic;
                #endif        
                smoothness = blend0.r * lay1_mask.a * _Lay1Smoothness +
                                blend0.g * lay2_mask.a * _Lay2Smoothness +
                                    blend0.b * lay3_mask.a * _Lay3Smoothness +
                                        blend0.a * lay4_mask.a * _Lay4Smoothness;
                
                #ifdef  _MULTI_SPLAT_ON
                smoothness += blend1.r * lay5_mask.a * _Lay5Smoothness
                                + blend1.g * lay6_mask.a * _Lay6Smoothness
                                + blend1.b * lay7_mask.a * _Lay7Smoothness
                                + blend1.a * lay8_mask.a * _Lay8Smoothness;
                #endif
                
                occlusion = blend0.r * lay1_mask.g * _Lay1AO
                    + blend0.g * lay2_mask.g * _Lay2AO
                    + blend0.b * lay3_mask.g * _Lay3AO
                    + blend0.a * lay4_mask.g * _Lay4AO;

                #ifdef  _MULTI_SPLAT_ON
                occlusion += blend1.r * lay5_mask.g * _Lay5AO
                    + blend1.g * lay6_mask.g * _Lay6AO
                    + blend1.b * lay7_mask.g * _Lay7AO
                    + blend1.a * lay8_mask.g * _Lay8AO;
                #endif
                occlusion = FastLinearToSRGB(occlusion);

                mask = half4(metallic, 1 - smoothness, occlusion ,0);
              
            }

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

    }

//    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "MWWTerrainShaderGUI"
}

