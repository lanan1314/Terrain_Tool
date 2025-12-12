using System;
using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
public class MWWTerrainPainter : MonoBehaviour
{
    [Header("Switch")]
    [NonSerialized]
    public bool isEditMode = false;
    
    // 脏标记：用于提示用户保存，避免数据丢失
    [HideInInspector] public bool hasUnsavedChanges = false;

    [Header("Configuration")]
    public Material targetMaterial;
    public Collider terrainCollider;

    [Header("Brush Settings")]
    [Range(0.01f, 50f)] public float brushSize = 5f;
    [Range(0.01f, 1f)] public float brushStrength = 0.5f;
    
    [Tooltip("勾选进入擦除模式 (Erase Mode)")]
    public bool isEraserMode = false; 
    
    public Texture2D customBrushTexture; 

    [Header("State")]
    public int selectedLayerIndex = 0;
    
    // 运行时使用的动态纹理，替代原始的 Asset
    [NonSerialized] public RenderTexture controlRT;
    // 原始资产引用，用于退出时恢复或保存时覆盖
    [NonSerialized] public Texture2DArray originalControlTex;
    
    // --- 新增：撤销/重做 历史栈 ---
    private Stack<RenderTexture> undoStack = new Stack<RenderTexture>();
    private Stack<RenderTexture> redoStack = new Stack<RenderTexture>();
    private const int MAX_HISTORY = 20; // 最大撤销步数，防止显存爆炸

    private Material paintMaterial;

    private void OnEnable()
    {
        if (targetMaterial == null)
        {
            Renderer r = GetComponent<Renderer>();
            if (r != null) targetMaterial = r.sharedMaterial;
        }
        if (terrainCollider == null) terrainCollider = GetComponent<Collider>();
        
        if (isEditMode) InitPaintSystem();
    }
    
    private void OnDisable()
    {
        CleanupPaintSystem();
    }
    
    // [新增] 每一帧都检查材质引用
    private void Update()
    {
        // 仅在编辑模式且资源都存在时运行
        if (isEditMode && targetMaterial != null && controlRT != null && controlRT.IsCreated())
        {
            // 如果材质当前的贴图 不是 我们的绘制RT（说明刚刚可能发生了Save，引用被重置了）
            if (targetMaterial.GetTexture("_ControlTex") != controlRT)
            {
                // 强制指回来！
                targetMaterial.SetTexture("_ControlTex", controlRT);
            }
        }
    }
    
    public void EnterEditMode()
    {
        isEditMode = true;
        InitPaintSystem();
    }

    public void ExitEditMode()
    {
        isEditMode = false;
        CleanupPaintSystem();
    }

    // 初始化绘制系统：核心是将静态贴图转换为动态 RT
    private void InitPaintSystem()
    {
        if (targetMaterial == null) return;

        hasUnsavedChanges = false;
        isEraserMode = false;
        customBrushTexture = null;
        ClearHistory(); // 初始化时清空历史

        Texture currentTex = targetMaterial.GetTexture("_ControlTex");
        // 防止重复初始化
        if (currentTex is RenderTexture) return; 
        
        originalControlTex = currentTex as Texture2DArray;

        if (originalControlTex == null)
        {
            Debug.LogError("材质缺少 _ControlTex 或不是 Texture2DArray。");
            isEditMode = false;
            return;
        }

        // 确保 RT 存在且尺寸匹配
        if (controlRT == null || controlRT.width != originalControlTex.width || controlRT.height != originalControlTex.height)
        {
            CreateControlRT(); // 封装创建逻辑，因为Undo可能也需要用
            
            // 初始化内容
            Shader copyShader = Shader.Find("Hidden/MWW_ArrayCopy");
            if (copyShader == null) { Debug.LogError("找不到 'Hidden/MWW_ArrayCopy'"); return; }
            Material copyMat = new Material(copyShader);
            RenderTexture tempSlice = RenderTexture.GetTemporary(controlRT.width, controlRT.height, 0, RenderTextureFormat.ARGB32);

            for (int i = 0; i < 2; i++)
            {
                copyMat.SetTexture("_MainTex", originalControlTex);
                copyMat.SetFloat("_SliceIndex", i);
                Graphics.Blit(null, tempSlice, copyMat); 
                Graphics.CopyTexture(tempSlice, 0, controlRT, i); 
            }
            RenderTexture.ReleaseTemporary(tempSlice);
            if (Application.isEditor) DestroyImmediate(copyMat); else Destroy(copyMat);
        }

        // 将材质的贴图指向动态 RT，实现实时反馈
        targetMaterial.SetTexture("_ControlTex", controlRT);
        
        if (paintMaterial == null)
        {
            Shader s = Shader.Find("Hidden/MWW_Internal_Paint");
            if (s != null) paintMaterial = new Material(s);
        }
    }

    private void CreateControlRT()
    {
        if (controlRT != null) controlRT.Release();
        // 格式必须包含 Alpha 通道 (ARGB32)，因为我们需要 4 个通道存储权重
        controlRT = new RenderTexture(originalControlTex.width, originalControlTex.height, 0, RenderTextureFormat.ARGB32);
        controlRT.dimension = UnityEngine.Rendering.TextureDimension.Tex2DArray;
        controlRT.volumeDepth = 2; // 2 个 Slice * 4 通道 = 8 层权重
        controlRT.enableRandomWrite = true; // 允许计算着色器或特殊写入
        controlRT.useMipMap = false; // 绘制时不需要 MipMap，保存时会自动生成
        
        // HideFlags.DontSave 意味着：这个 RT 是临时的，切换场景或保存场景时不要理它，也不要销毁它（由我们手动管理）
        controlRT.hideFlags = HideFlags.DontSave;
        controlRT.Create();
    }

    private void CleanupPaintSystem()
    {
        if (targetMaterial != null && originalControlTex != null)
        {
            targetMaterial.SetTexture("_ControlTex", originalControlTex);
        }
        if (controlRT != null)
        {
            controlRT.Release();
            controlRT = null;
        }
        hasUnsavedChanges = false;
        ClearHistory(); // 退出时清理显存
    }

    // --- 历史记录相关方法 ---
    // 1. 记录快照 (在绘制前调用)
    public void RegisterUndo()
    {
        if (controlRT == null) return;

        // 如果栈满了，这其实不太好处理(Stack只能弹栈顶)，为了简单，我们暂不处理底部移除
        // 但建议实际项目中改用 LinkedList 或 CircularBuffer。
        // 这里仅做简单的 Count 限制：如果超了，就不存了或者清空（比较暴力）
        if (undoStack.Count >= MAX_HISTORY)
        {
            // 移除栈底元素（最旧的历史）以释放显存
            // 由于 Stack 没有 RemoveLast，通常做法是转存到一个 List 或使用 LinkedList
            // 或者简单粗暴地：
            var temp = undoStack.ToArray();
            // 释放最旧的一个
            temp[temp.Length - 1].Release(); 
            // 重建栈 (性能稍差但作为一个几十次操作才触发一次的逻辑可以接受)
            undoStack = new Stack<RenderTexture>(new ArraySegment<RenderTexture>(temp, 0, temp.Length - 1));
        }

        // 创建当前状态的副本
        RenderTexture snapshot = new RenderTexture(controlRT.descriptor);
        snapshot.Create();
        
        // 既然 controlRT 是 Array，我们必须逐层 Copy
        for (int i = 0; i < 2; i++) Graphics.CopyTexture(controlRT, i, snapshot, i);
        
        undoStack.Push(snapshot);
        
        // 一旦有新操作，Redo 栈就失效了，必须清空并释放显存
        while (redoStack.Count > 0)
        {
            RenderTexture rt = redoStack.Pop();
            rt.Release();
        }
    }

    // 2. 执行撤销
    public void PerformUndo()
    {
        if (undoStack.Count == 0) return;

        // A. 把当前状态存入 Redo 栈
        RenderTexture currentToRedo = new RenderTexture(controlRT.descriptor);
        currentToRedo.Create();
        for (int i = 0; i < 2; i++) Graphics.CopyTexture(controlRT, i, currentToRedo, i);
        redoStack.Push(currentToRedo);

        // B. 从 Undo 栈取出上一步状态
        RenderTexture prev = undoStack.Pop();
        
        // C. 恢复到 controlRT
        for (int i = 0; i < 2; i++) Graphics.CopyTexture(prev, i, controlRT, i);
        
        // D. 释放取出的快照（因为它已经复制进 controlRT 了，或者我们可以选择保留引用，但那样逻辑更绕）
        // 为了逻辑清晰：栈里存的是独占的备份。一旦应用，这个备份本身就可以扔了（因为Redo里存了反向备份）
        prev.Release();
        
        Debug.Log($"撤销成功。剩余步数: {undoStack.Count}");
    }

    // 3. 执行重做
    public void PerformRedo()
    {
        if (redoStack.Count == 0) return;

        // A. 把当前状态存入 Undo 栈 (再次备份，以便再次撤销)
        RenderTexture currentToUndo = new RenderTexture(controlRT.descriptor);
        currentToUndo.Create();
        for (int i = 0; i < 2; i++) Graphics.CopyTexture(controlRT, i, currentToUndo, i);
        undoStack.Push(currentToUndo);

        // B. 从 Redo 栈取出未来状态
        RenderTexture next = redoStack.Pop();

        // C. 恢复
        for (int i = 0; i < 2; i++) Graphics.CopyTexture(next, i, controlRT, i);
        
        // D. 释放
        next.Release();
        
        Debug.Log($"重做成功。");
    }

    private void ClearHistory()
    {
        while (undoStack.Count > 0) undoStack.Pop().Release();
        while (redoStack.Count > 0) redoStack.Pop().Release();
    }

    public void Paint(Vector2 centerUV, Vector2 uvRadius, bool isEraser = false)
    {
        if (controlRT == null || paintMaterial == null) InitPaintSystem();
        
        hasUnsavedChanges = true;

        // 1. 准备快照 (保持不变)
        RenderTexture snapshotRT = RenderTexture.GetTemporary(controlRT.width, controlRT.height, 0, controlRT.graphicsFormat);
        snapshotRT.dimension = UnityEngine.Rendering.TextureDimension.Tex2DArray;
        snapshotRT.volumeDepth = 2;
        snapshotRT.useMipMap = false;
        snapshotRT.Create();
        for (int i = 0; i < 2; i++) Graphics.CopyTexture(controlRT, i, snapshotRT, i);


        // 2. 设置材质参数
        paintMaterial.SetTexture("_MainTex", snapshotRT);
        paintMaterial.SetVector("_PaintUV", centerUV);
        
        // [关键] 直接传入外部计算好的精确 UV 半径
        // Shader 中需要 Vector4 (x, y, 0, 0)
        paintMaterial.SetVector("_BrushUVRadius", new Vector4(uvRadius.x, uvRadius.y, 0, 0));

        paintMaterial.SetFloat("_BrushStrength", brushStrength * 0.1f);
        paintMaterial.SetInt("_TargetLayerIndex", selectedLayerIndex);
        paintMaterial.SetInt("_IsEraser", isEraser ? 1 : 0);

        // 3. 绘制 (保持不变)
        paintMaterial.SetInt("_RenderSlice", 0);
        Graphics.SetRenderTarget(controlRT, 0, CubemapFace.Unknown, 0);
        Graphics.Blit(null, paintMaterial, 0);

        paintMaterial.SetInt("_RenderSlice", 1);
        Graphics.SetRenderTarget(controlRT, 0, CubemapFace.Unknown, 1);
        Graphics.Blit(null, paintMaterial, 0);

        RenderTexture.ReleaseTemporary(snapshotRT);
    }
}