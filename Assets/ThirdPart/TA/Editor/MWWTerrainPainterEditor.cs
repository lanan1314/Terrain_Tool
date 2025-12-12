using UnityEngine;
using UnityEditor;
using System.IO;

[CustomEditor(typeof(MWWTerrainPainter))]
public class MWWTerrainPainterEditor : Editor
{
    MWWTerrainPainter script;
    private Texture2D[] splatPreviews;
    
    // --- 预览网格相关变量 ---
    private Mesh previewMesh;
    private Material previewMaterial;
    private const int GRID_SIZE = 30; // 网格密度，越大越贴合，但消耗越高。30x30=900次射线，性能OK。
    private Vector3[] vertices;
    private Vector2[] uvs;
    private int[] triangles;

    private void OnEnable()
    {
        script = (MWWTerrainPainter)target;
        UpdateSplatPreviews();
        
        // 初始化预览网格
        InitPreviewMesh();
        
        // 初始化预览材质
        Shader s = Shader.Find("Hidden/MWW_BrushPreview");
        if (s == null) Debug.LogWarning("找不到 'Hidden/MWW_BrushPreview' Shader，请创建它！");
        else previewMaterial = new Material(s);
    }
    
    private void OnDisable()
    {
        // 清理内存
        if (previewMesh != null) DestroyImmediate(previewMesh);
        if (previewMaterial != null) DestroyImmediate(previewMaterial);
    }
    
    // --- 预览网格初始化 ---
    // 这里生成一个平面的 Grid 网格，后续会在 OnSceneGUI 中根据地形高度修改其顶点
    void InitPreviewMesh()
    {
        previewMesh = new Mesh();
        previewMesh.MarkDynamic(); // 标记为动态，优化频繁更新
        
        int vertCount = (GRID_SIZE + 1) * (GRID_SIZE + 1);
        vertices = new Vector3[vertCount];
        uvs = new Vector2[vertCount];
        triangles = new int[GRID_SIZE * GRID_SIZE * 6];

        // 预计算 UV 和 三角面索引
        int tIndex = 0;
        for (int z = 0; z <= GRID_SIZE; z++)
        {
            for (int x = 0; x <= GRID_SIZE; x++)
            {
                int vIndex = z * (GRID_SIZE + 1) + x;
                uvs[vIndex] = new Vector2((float)x / GRID_SIZE, (float)z / GRID_SIZE);

                if (x < GRID_SIZE && z < GRID_SIZE)
                {
                    triangles[tIndex++] = vIndex;
                    triangles[tIndex++] = vIndex + GRID_SIZE + 1;
                    triangles[tIndex++] = vIndex + 1;
                    triangles[tIndex++] = vIndex + 1;
                    triangles[tIndex++] = vIndex + GRID_SIZE + 1;
                    triangles[tIndex++] = vIndex + GRID_SIZE + 2;
                }
            }
        }
        
        previewMesh.vertices = vertices; // 先赋个初始值
        previewMesh.uv = uvs;
        previewMesh.triangles = triangles;
        previewMesh.RecalculateNormals();
    }

    void UpdateSplatPreviews()
    {
        if (script.targetMaterial == null) return;
        Texture2DArray splatArray = script.targetMaterial.GetTexture("_Splat") as Texture2DArray;
        if (splatArray == null) return;

        int layers = splatArray.depth;
        splatPreviews = new Texture2D[layers];
        
        Shader s = Shader.Find("Hidden/ArrayPreview"); 
        if(s == null) { Debug.LogWarning("找不到 Hidden/ArrayPreview Shader"); return; }
        
        Material previewMat = new Material(s);
        RenderTexture tempRT = RenderTexture.GetTemporary(128, 128, 0, RenderTextureFormat.ARGB32);

        for (int i = 0; i < layers; i++)
        {
            previewMat.SetTexture("_MainTex", splatArray);
            previewMat.SetInt("_Slice", i);
            Graphics.Blit(null, tempRT, previewMat);
            
            Texture2D tex = new Texture2D(128, 128, TextureFormat.ARGB32, false);
            RenderTexture.active = tempRT;
            tex.ReadPixels(new Rect(0, 0, 128, 128), 0, 0);
            tex.Apply();
            splatPreviews[i] = tex;
        }
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(tempRT);
        DestroyImmediate(previewMat);
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.Space();
        GUIStyle toggleStyle = new GUIStyle(GUI.skin.button);
        toggleStyle.fontSize = 14;
        toggleStyle.fontStyle = FontStyle.Bold;
        toggleStyle.padding = new RectOffset(10, 10, 10, 10);
        
        Color originalColor = GUI.backgroundColor;
        
        if (script.isEditMode)
        {
            GUI.backgroundColor = new Color(1f, 0.5f, 0.5f); 
            if (GUILayout.Button("退出编辑模式 (Exit Paint Mode)", toggleStyle))
            {
                // --- 优化：只有在有未保存修改时才弹窗 ---
                if (!script.hasUnsavedChanges)
                {
                    // 没有修改，或者已经保存过了 -> 直接退出，不烦人
                    script.ExitEditMode();
                    EditorUtility.SetDirty(script);
                }
                else
                {
                    // 有修改未保存 -> 弹窗提示
                    int option = EditorUtility.DisplayDialogComplex(
                        "退出编辑", "检测到未保存的修改，是否保存？\n'保存'：覆盖并退出\n'不保存'：丢弃并退出",
                        "保存 (Save)", "取消 (Cancel)", "不保存 (Don't Save)"
                    );

                    switch (option)
                    {
                        case 0: // Save
                            if (SaveTexture()) script.ExitEditMode();
                            break;
                        case 1: // Cancel
                            break;
                        case 2: // Don't Save
                            script.ExitEditMode();
                            Debug.Log("已丢弃修改。");
                            break;
                    }
                }
            }
        }
        else
        {
            GUI.backgroundColor = new Color(0.5f, 1f, 0.5f); 
            if (GUILayout.Button("开始绘制 (Start Painting)", toggleStyle))
            {
                script.EnterEditMode();
                UpdateSplatPreviews();
            }
        }
        
        GUI.backgroundColor = originalColor;
        EditorGUILayout.Space();

        if (!script.isEditMode)
        {
            EditorGUILayout.HelpBox("点击上方按钮进入绘制模式。", MessageType.Info);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("targetMaterial"));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("terrainCollider"));
            serializedObject.ApplyModifiedProperties();
            return;
        }

        DrawDefaultInspector();

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Layer Palette", EditorStyles.boldLabel);
        
        if (splatPreviews != null && splatPreviews.Length > 0)
        {
            int columns = 4;
            int rows = Mathf.CeilToInt(splatPreviews.Length / (float)columns);
            float size = (EditorGUIUtility.currentViewWidth - 40) / columns;

            for (int r = 0; r < rows; r++)
            {
                EditorGUILayout.BeginHorizontal();
                for (int c = 0; c < columns; c++)
                {
                    int index = r * columns + c;
                    if (index >= splatPreviews.Length) break;

                    GUIStyle style = new GUIStyle(GUI.skin.button);
                    if (script.selectedLayerIndex == index)
                    {
                        style.normal.background = Texture2D.whiteTexture; 
                        GUI.backgroundColor = Color.green;
                    }
                    else GUI.backgroundColor = Color.white;

                    if (GUILayout.Button(splatPreviews[index], style, GUILayout.Width(size), GUILayout.Height(size)))
                    {
                        script.selectedLayerIndex = index;
                    }
                    GUI.backgroundColor = Color.white; 
                }
                EditorGUILayout.EndHorizontal();
            }
        }
        else
        {
            if (GUILayout.Button("Refresh Previews")) UpdateSplatPreviews();
        }

        EditorGUILayout.Space();
        if (GUILayout.Button("手动保存 (Save Now)", GUILayout.Height(30)))
        {
            SaveTexture();
        }

        serializedObject.ApplyModifiedProperties();
    }

    // --- 场景交互核心 ---
    // 在 OnSceneGUI 中修改射线检测和 Paint 调用的逻辑
    private void OnSceneGUI()
    {
        if (!script.isEditMode) return;
        if (script.targetMaterial == null || script.terrainCollider == null) return;

        Event e = Event.current;
        bool isEraser = script.isEraserMode; 

        if (e.type == EventType.KeyDown && e.control)
        {
            if (e.keyCode == KeyCode.Z) { script.PerformUndo(); e.Use(); return; }
            if (e.keyCode == KeyCode.Y) { script.PerformRedo(); e.Use(); return; }
        }

        // 1. 主射线检测
        Ray ray = HandleUtility.GUIPointToWorldRay(e.mousePosition);
        RaycastHit hit;

        if (script.terrainCollider.Raycast(ray, out hit, 1000f))
        {
            DrawConformingPreview(hit.point, script.brushSize, isEraser);

            // ---  核心算法：实时测量 UV 密度 ---
            // 这一步会发射额外的射线来探测地形 UV 的拉伸情况
            Vector2 accurateUVRadius = CalculateAccurateUVRadius(hit, script.brushSize);

            if (e.type == EventType.MouseDown && e.button == 0 && !e.alt)
            {
                script.RegisterUndo();
            }
            
            if ((e.type == EventType.MouseDrag || e.type == EventType.MouseDown) && e.button == 0 && !e.alt)
            {
                // [修改] 传入计算好的精确 UV 半径
                script.Paint(hit.textureCoord, accurateUVRadius, isEraser);
                e.Use();
            }
        }
        
        if (e.type == EventType.MouseMove || e.type == EventType.MouseDrag) SceneView.RepaintAll();
    }

    // ---  辅助方法：通过偏移射线计算 UV 缩放 ---
    Vector2 CalculateAccurateUVRadius(RaycastHit centerHit, float worldRadius)
    {
        // 探测步长：取一个很小的距离（例如 0.5 米）
        // 只要这个距离在地形上，我们就能算出比例
        float step = 0.5f; 

        // 准备探测射线的起点：在击中点上方高处
        Vector3 centerPos = centerHit.point;
        float rayHeight = centerPos.y + 100f; // 抬高足够高，防止地形起伏遮挡

        // 1. 测量 X 轴方向的 UV 变化 (World X)
        Vector3 probePosX = centerPos + Vector3.right * step;
        Ray rayX = new Ray(new Vector3(probePosX.x, rayHeight, probePosX.z), Vector3.down);
        RaycastHit hitX;
        
        float uvScaleX = 0f;
        // 如果向右探测成功
        if (script.terrainCollider.Raycast(rayX, out hitX, 200f))
        {
            // 公式：UV差值 / 世界距离 = 每米对应的UV长度
            float uvDist = Vector2.Distance(centerHit.textureCoord, hitX.textureCoord);
            uvScaleX = uvDist / step;
        }
        else
        {
            // 如果向右没探测到（比如在地图边缘），我们就假设比例和之前一样（或者给个保底值）
            // 这里为了简单，如果边缘探测失败，可以尝试反向探测（向左）
            // 但为了代码简洁，如果失败通常意味着 brush 已经出界了，给个默认值即可
            float boundsSize = script.terrainCollider.bounds.size.x;
            uvScaleX = (boundsSize > 0) ? (1.0f / boundsSize) : 0.01f;
        }

        // 2. 测量 Z 轴方向的 UV 变化 (World Z)
        Vector3 probePosZ = centerPos + Vector3.forward * step;
        Ray rayZ = new Ray(new Vector3(probePosZ.x, rayHeight, probePosZ.z), Vector3.down);
        RaycastHit hitZ;
        
        float uvScaleZ = 0f;
        if (script.terrainCollider.Raycast(rayZ, out hitZ, 200f))
        {
            float uvDist = Vector2.Distance(centerHit.textureCoord, hitZ.textureCoord);
            uvScaleZ = uvDist / step;
        }
        else
        {
            float boundsSize = script.terrainCollider.bounds.size.z;
            uvScaleZ = (boundsSize > 0) ? (1.0f / boundsSize) : 0.01f;
        }

        // 最终计算：
        // 世界半径 * (每米UV长度) = 该笔刷大小对应的 UV 半径
        return new Vector2(worldRadius * uvScaleX, worldRadius * uvScaleZ);
    }
    
    // --- 更新网格顶点并绘制 ---
    void DrawConformingPreview(Vector3 center, float radius, bool isEraser)
    {
        if (previewMesh == null) InitPreviewMesh();
        if (previewMaterial == null) return;

        // 设置材质参数
        // 颜色：擦除红，绘制绿，稍微带点透明
        Color c = isEraser ? new Color(1, 0.1f, 0.1f, 0.8f) : new Color(1f, 1, 1f, 0.8f);
        previewMaterial.SetColor("_Color", c);

        // 贴图：如果有自定义笔刷，就传进去；否则传个默认（shader里处理）
        if (script.customBrushTexture != null)
        {
            previewMaterial.SetTexture("_MainTex", script.customBrushTexture);
            previewMaterial.SetFloat("_IsCustom", 1.0f);
        }
        else
        {
            previewMaterial.SetFloat("_IsCustom", 0.0f);
        }

        // 核心：顶点吸附算法
        // 逻辑：生成一个以鼠标为中心的 2D 网格，然后对网格每个点向下发射射线，
        // 将顶点移动到射线击中地形的位置
        float step = (radius * 2) / GRID_SIZE;
        Vector3 startPos = center - new Vector3(radius, 0, radius);
        
        // 射线起始高度，要比地形高，防止漏检测
        float rayHeight = center.y + 50f; 

        for (int z = 0; z <= GRID_SIZE; z++)
        {
            for (int x = 0; x <= GRID_SIZE; x++)
            {
                // 计算当前顶点的 XZ 世界坐标
                float worldX = startPos.x + x * step;
                float worldZ = startPos.z + z * step;
                
                Vector3 rayOrigin = new Vector3(worldX, rayHeight, worldZ);
                Ray r = new Ray(rayOrigin, Vector3.down);
                RaycastHit meshHit;

                // 这里的 100f 是射线长度，确保够长
                if (script.terrainCollider.Raycast(r, out meshHit, 200f))
                {
                    // 吸附到击中点，并稍微抬高一点点防止穿插 (0.05f)
                    vertices[z * (GRID_SIZE + 1) + x] = meshHit.point + meshHit.normal * 0.05f;
                }
                else
                {
                    // 如果没扫到地形（比如边缘），就让它跟中心点y一样高，或者隐藏
                    vertices[z * (GRID_SIZE + 1) + x] = new Vector3(worldX, center.y, worldZ);
                }
            }
        }
        
        // 应用顶点
        previewMesh.vertices = vertices;
        previewMesh.RecalculateBounds();
        // RecalculateNormals 这里不是必须的，因为我们用 Unlit 渲染，不消耗法线

        // 绘制
        // 注意：Graphics.DrawMeshNow 必须在 Repaint 事件中调用才能显示
        if (Event.current.type == EventType.Repaint)
        {
            previewMaterial.SetPass(0);
            Graphics.DrawMeshNow(previewMesh, Matrix4x4.identity);
        }
    }

    bool SaveTexture()
    {
        if (script.controlRT == null || script.originalControlTex == null) 
        {
             Debug.LogWarning("无法保存：数据丢失");
             return false;
        }

        string path = AssetDatabase.GetAssetPath(script.originalControlTex);
        if (string.IsNullOrEmpty(path)) return false;

        int width = script.controlRT.width;
        int height = script.controlRT.height;

        Texture2DArray finalCompressedArray = new Texture2DArray(width, height, 2, TextureFormat.DXT5, false);
        
        RenderTexture tempRT = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);

        for (int i = 0; i < 2; i++)
        {
            // 1. 从 Array 中拷贝 Slice i 到 2D RT
            Graphics.CopyTexture(script.controlRT, i, tempRT, 0);
            
            // 2. 从 RT 读像素到 CPU 端的 Texture2D
            RenderTexture.active = tempRT;
            Texture2D sliceTex = new Texture2D(width, height, TextureFormat.RGBA32, false);
            sliceTex.ReadPixels(new Rect(0, 0, width, height), 0, 0);
            sliceTex.Apply();
            
            // 3. CPU 端压缩 (耗时操作，但在保存时可接受)
            EditorUtility.CompressTexture(sliceTex, TextureFormat.DXT5, TextureCompressionQuality.Best);
            
            // 4. 将压缩后的数据拷入最终 Array
            Graphics.CopyTexture(sliceTex, 0, finalCompressedArray, i);
            DestroyImmediate(sliceTex);
        }
        
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(tempRT);
        finalCompressedArray.Apply();

        Texture2DArray existingAsset = AssetDatabase.LoadAssetAtPath<Texture2DArray>(path);
        if (existingAsset != null)
        {
            EditorUtility.CopySerialized(finalCompressedArray, existingAsset);
            AssetDatabase.SaveAssets();
            script.originalControlTex = existingAsset; 
        }
        else
        {
            AssetDatabase.CreateAsset(finalCompressedArray, path);
        }
        
        AssetDatabase.Refresh();
        
        // 手动保存后，强制将材质贴图指回 RT
        if (script.isEditMode && script.targetMaterial != null)
        {
            script.targetMaterial.SetTexture("_ControlTex", script.controlRT);
        }

        // --- 保存成功后，重置脏标记 ---
        script.hasUnsavedChanges = false;
        
        Debug.Log($"已保存并压缩: {path}");
        return true;
    }
}