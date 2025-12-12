using UnityEngine;
using UnityEditor;

public class MWWTerrainShaderGUI : ShaderGUI
{
    private static class Styles
    {
        public static readonly GUIContent[] layerLabels = new GUIContent[8]
        {
            new GUIContent("■ Layer 1"),
            new GUIContent("■ Layer 2"),
            new GUIContent("■ Layer 3"),
            new GUIContent("■ Layer 4"),
            new GUIContent("■ Layer 5"),
            new GUIContent("■ Layer 6"),
            new GUIContent("■ Layer 7"),
            new GUIContent("■ Layer 8")
        };
    }

    // 折叠状态 - 使用SessionState保持折叠状态
    private const string TEXTURE_FOLDOUT_KEY = "TerrainShader_TextureFoldout";
    private const string LAYER_FOLDOUT_KEY = "TerrainShader_LayerFoldout_";
    private const string ADVANCED_FOLDOUT_KEY = "TerrainShader_AdvancedFoldout";
    private const string COMPACT_MODE_KEY = "TerrainShader_CompactMode";

    private static bool compactMode
    {
        get => SessionState.GetBool(COMPACT_MODE_KEY, false);
        set => SessionState.SetBool(COMPACT_MODE_KEY, value);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material material = materialEditor.target as Material;
        if (material == null) return;

        EditorGUI.BeginChangeCheck();

        // 标题栏
        DrawHeader();

        // 紧凑模式切换
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Display Mode", EditorStyles.boldLabel, GUILayout.Width(100));
        compactMode = GUILayout.Toggle(compactMode, "Compact View", "Button", GUILayout.Width(100));
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        if (compactMode)
        {
            DrawCompactGUI(materialEditor, properties, material);
        }
        else
        {
            DrawStandardGUI(materialEditor, properties, material);
        }

        if (EditorGUI.EndChangeCheck())
        {
            UpdateKeywords(material);
        }
    }

    private void DrawHeader()
    {
        EditorGUILayout.Space();
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.Label("Terrain Multi-Layer Shader", EditorStyles.boldLabel);
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();
        EditorGUILayout.Space();
    }

    private void DrawCompactGUI(MaterialEditor materialEditor, MaterialProperty[] properties, Material material)
    {
        // 主控制
        EditorGUILayout.BeginVertical("HelpBox");
        EditorGUILayout.LabelField("Main Controls", EditorStyles.miniLabel);
        
        var controlTex = FindProperty("_ControlTex", properties);
        var multiSplat = FindProperty("_Multi_Splat", properties);
        var blendWeight = FindProperty("_Weight", properties);
        
        materialEditor.TexturePropertySingleLine(new GUIContent("Control"), controlTex);
        materialEditor.ShaderProperty(multiSplat, new GUIContent("8 Layers"));
        materialEditor.ShaderProperty(blendWeight, new GUIContent("Blend"));
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

        // 纹理数组
        EditorGUILayout.BeginVertical("HelpBox");
        EditorGUILayout.LabelField("Texture Arrays", EditorStyles.miniLabel);
        
        var splatArray = FindProperty("_Splat", properties);
        var normalArray = FindProperty("_Splat_NMP", properties);
        var maskArray = FindProperty("_Splat_Mask", properties);
        
        materialEditor.TexturePropertySingleLine(new GUIContent("Albedo"), splatArray);
        materialEditor.TexturePropertySingleLine(new GUIContent("Normal"), normalArray);
        materialEditor.TexturePropertySingleLine(new GUIContent("Mask"), maskArray);
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

        // 层级参数 - 表格形式
        bool useEightLayers = material.IsKeywordEnabled("_MULTI_SPLAT_ON");
        int layerCount = useEightLayers ? 8 : 4;

        EditorGUILayout.BeginVertical("HelpBox");
        EditorGUILayout.LabelField("Layer Parameters", EditorStyles.miniLabel);
        
        // 使用滚动视图以防止内容过长
        for (int i = 0; i < layerCount; i++)
        {
            DrawCompactLayer(materialEditor, properties, i);
        }
        
        EditorGUILayout.EndVertical();
    }

    private void DrawCompactLayer(MaterialEditor editor, MaterialProperty[] props, int index)
    {
        int layerNum = index + 1;
        
        var color = FindProperty($"_Lay{layerNum}Color", props);
        var tiling = FindProperty($"_Lay{layerNum}Tilling", props);
        var height = FindProperty($"_Splat{layerNum}_Height", props);
        var metallic = FindProperty($"_Lay{layerNum}Metallic", props);
        var smoothness = FindProperty($"_Lay{layerNum}Smoothness", props);
        
        EditorGUILayout.BeginHorizontal();
        
        // 层级标签与颜色
        EditorGUILayout.ColorField(GUIContent.none, color.colorValue, false, false, false, 
            GUILayout.Width(20), GUILayout.Height(16));
        EditorGUILayout.LabelField($"L{layerNum}", GUILayout.Width(25));
        
        // 紧凑的属性 - 使用正确的方式显示
        EditorGUILayout.LabelField("T:", GUILayout.Width(15));
        tiling.floatValue = EditorGUILayout.FloatField(tiling.floatValue, GUILayout.Width(35));
        
        EditorGUILayout.LabelField("H:", GUILayout.Width(15));
        height.floatValue = EditorGUILayout.FloatField(height.floatValue, GUILayout.Width(35));
        
        EditorGUILayout.LabelField("M:", GUILayout.Width(15));
        metallic.floatValue = EditorGUILayout.Slider(metallic.floatValue, 0f, 2f, GUILayout.Width(60));
        
        EditorGUILayout.LabelField("S:", GUILayout.Width(15));
        smoothness.floatValue = EditorGUILayout.Slider(smoothness.floatValue, 0f, 2f, GUILayout.Width(60));
        
        EditorGUILayout.EndHorizontal();
    }

    private void DrawStandardGUI(MaterialEditor materialEditor, MaterialProperty[] properties, Material material)
    {
        // 纹理设置
        bool textureFoldout = SessionState.GetBool(TEXTURE_FOLDOUT_KEY, true);
        textureFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(textureFoldout, "Texture Settings");
        SessionState.SetBool(TEXTURE_FOLDOUT_KEY, textureFoldout);
        
        if (textureFoldout)
        {
            EditorGUI.indentLevel++;
            DrawTextureProperties(materialEditor, properties);
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.EndFoldoutHeaderGroup();

        EditorGUILayout.Space();

        // Multi-Splat 和混合权重
        var multiSplat = FindProperty("_Multi_Splat", properties);
        var blendWeight = FindProperty("_Weight", properties);
        
        materialEditor.ShaderProperty(multiSplat, new GUIContent("Enable 8 Layers"));
        materialEditor.ShaderProperty(blendWeight, new GUIContent("Blend Weight"));

        EditorGUILayout.Space();

        // 层级设置
        bool useEightLayers = material.IsKeywordEnabled("_MULTI_SPLAT_ON");
        int layerCount = useEightLayers ? 8 : 4;

        EditorGUILayout.LabelField("Layer Settings", EditorStyles.boldLabel);
        
        for (int i = 0; i < layerCount; i++)
        {
            DrawLayerProperties(materialEditor, properties, i);
        }

        // 高级设置
        EditorGUILayout.Space();
        bool advancedFoldout = SessionState.GetBool(ADVANCED_FOLDOUT_KEY, false);
        advancedFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(advancedFoldout, "Advanced Settings");
        SessionState.SetBool(ADVANCED_FOLDOUT_KEY, advancedFoldout);
        
        if (advancedFoldout)
        {
            EditorGUI.indentLevel++;
            materialEditor.EnableInstancingField();
            materialEditor.RenderQueueField();
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    private void DrawTextureProperties(MaterialEditor editor, MaterialProperty[] props)
    {
        var controlTex = FindProperty("_ControlTex", props);
        var splatArray = FindProperty("_Splat", props);
        var normalArray = FindProperty("_Splat_NMP", props);
        var maskArray = FindProperty("_Splat_Mask", props);

        editor.TexturePropertySingleLine(new GUIContent("Control Texture"), controlTex);
        EditorGUILayout.Space();
        editor.TexturePropertySingleLine(new GUIContent("Albedo Array"), splatArray);
        editor.TexturePropertySingleLine(new GUIContent("Normal Array"), normalArray);
        editor.TexturePropertySingleLine(new GUIContent("Mask Array"), maskArray);
    }

    private void DrawLayerProperties(MaterialEditor editor, MaterialProperty[] props, int index)
    {
        int layerNum = index + 1;
        string foldoutKey = LAYER_FOLDOUT_KEY + index;
        
        var color = FindProperty($"_Lay{layerNum}Color", props);
        
        EditorGUILayout.BeginVertical("Box");
        
        EditorGUILayout.BeginHorizontal();
        bool foldout = SessionState.GetBool(foldoutKey, false);
        foldout = EditorGUILayout.Foldout(foldout, $"Layer {layerNum}", true);
        SessionState.SetBool(foldoutKey, foldout);
        
        EditorGUILayout.ColorField(GUIContent.none, color.colorValue, false, false, false, 
            GUILayout.Width(40), GUILayout.Height(18));
        EditorGUILayout.EndHorizontal();

        if (foldout)
        {
            EditorGUI.indentLevel++;
            
            // 使用垂直布局，每个属性单独一行
            editor.ShaderProperty(color, new GUIContent("Color"));
            editor.ShaderProperty(FindProperty($"_Lay{layerNum}Tilling", props), new GUIContent("Tiling"));
            editor.ShaderProperty(FindProperty($"_Lay{layerNum}NMPScale", props), new GUIContent("Normal Scale"));
            editor.ShaderProperty(FindProperty($"_Splat{layerNum}_Height", props), new GUIContent("Height"));
            
            EditorGUILayout.Space(5);
            
            editor.ShaderProperty(FindProperty($"_Lay{layerNum}Metallic", props), new GUIContent("Metallic"));
            editor.ShaderProperty(FindProperty($"_Lay{layerNum}Smoothness", props), new GUIContent("Smoothness"));
            editor.ShaderProperty(FindProperty($"_Lay{layerNum}AO", props), new GUIContent("Ambient Occlusion"));
            
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.EndVertical();
    }

    private void UpdateKeywords(Material material)
    {
        if (material.GetFloat("_Multi_Splat") > 0.5f)
        {
            material.EnableKeyword("_MULTI_SPLAT_ON");
        }
        else
        {
            material.DisableKeyword("_MULTI_SPLAT_ON");
        }
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);
        UpdateKeywords(material);
    }
}