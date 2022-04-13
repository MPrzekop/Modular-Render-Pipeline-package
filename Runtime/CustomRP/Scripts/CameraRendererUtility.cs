using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraRendererUtility
{
#if UNITY_EDITOR || DEVELOPMENT_BUILD
    static ShaderTagId[] legacyShaderTagIds =
    {
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM")
    };

    static Material errorMaterial;
    

    public static void DrawUnsupportedShaders(Camera camera, ScriptableRenderContext context,
        CullingResults cullingResults)
    {
        if (errorMaterial == null)
        {
            errorMaterial =
                new Material(Shader.Find("Hidden/InternalErrorShader"));
        }

        var drawingSettings = new DrawingSettings(
            legacyShaderTagIds[0], new SortingSettings(camera)
        )
        {
            overrideMaterial = errorMaterial
        };
        for (int i = 1; i < legacyShaderTagIds.Length; i++)
        {
            drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);
        }

        var filteringSettings = FilteringSettings.defaultValue;
        context.DrawRenderers(
            cullingResults, ref drawingSettings, ref filteringSettings
        );
    }

    public static void RenderGizmos(Camera camera, ScriptableRenderContext context)
    {
        if (Handles.ShouldRenderGizmos())
        {
            context.DrawGizmos(camera, GizmoSubset.PreImageEffects);
            context.DrawGizmos(camera, GizmoSubset.PostImageEffects);
        }
    }


    public static void PrepareForSceneWindow(Camera camera, ScriptableRenderContext context)
    {
        if (camera.cameraType == CameraType.SceneView)
        {
            ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
        }
    }

    public static void PrepareBufferProfiling(CommandBuffer buffer, Camera camera)
    {
        buffer.name = camera.name;
    }

    public static void StartSample(CommandBuffer buffer)
    {
        buffer.BeginSample(buffer.name);
    }

    public static void EndSample(CommandBuffer buffer)
    {
        buffer.EndSample(buffer.name);
    }

#else
           public static void DrawUnsupportedShaders(Camera camera, ScriptableRenderContext context,
        CullingResults cullingResults)
    {}
    public static void RenderGizmos(Camera camera, ScriptableRenderContext context)
    {}
    
     public static void PrepareForSceneWindow(Camera camera, ScriptableRenderContext context)
    {}

 public static void PrepareBufferProfiling(CommandBuffer buffer, Camera camera)
    {}

public static void StartSample(CommandBuffer buffer)
    {}
    public static void EndSample(CommandBuffer buffer)
    {}

#endif

    public static void ClearRenderTarget(CommandBuffer cmd, CameraClearFlags clearFlag, Color clearColor)
    {
        if (clearFlag != CameraClearFlags.Nothing)
            cmd.ClearRenderTarget((clearFlag & CameraClearFlags.Depth) != 0, (clearFlag & CameraClearFlags.Color) != 0,
                clearColor);
    }
    public static readonly int frameBufferId = Shader.PropertyToID("_CameraFrameBuffer");
    public static readonly int worldToShadowMatrixId =
        Shader.PropertyToID("_WorldToShadowMatrix");
    public static  readonly int shadowMapId = Shader.PropertyToID("_ShadowMap");
}

