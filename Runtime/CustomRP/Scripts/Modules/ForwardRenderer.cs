using System;
using System.Collections;
using System.Collections.Generic;
using CustomRP;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Profiling;
using UnityEngine.Rendering;

[System.Serializable,
 CreateAssetMenu(fileName = "Forward Module", menuName = "Custom RP/RP Forward Module", order = 0)]
public class ForwardRenderer : RPModule
{
    protected override bool culls()
    {
        return true;
    }

    protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
    {
        var tempForwardTarget =
            RenderTexture.GetTemporary(camera.pixelWidth, camera.pixelHeight, 16, RenderTextureFormat.DefaultHDR);


        RenderTargetIdentifier id = CameraRendererUtility.frameBufferId;


        CoreUtils.SetRenderTarget(buffer, tempForwardTarget);
        CoreUtils.ClearRenderTarget(buffer, ClearFlag.All, Color.clear);
        ExecuteBuffer(context, buffer);
        

        //copy color buffer
       
        buffer.SetGlobalTexture("ScreenColor",tempForwardTarget);
        ExecuteBuffer(context, buffer);
        CoreUtils.SetRenderTarget(buffer,CameraRendererUtility.frameBufferId);
      
        //ExecuteBuffer(context, buffer);
        context.SetupCameraProperties(camera);
        ExecuteBuffer(context, buffer);

        Profiler.BeginSample("Forward Opaque");
       


        var sortingSettings = new SortingSettings(camera)
        {
            criteria = SortingCriteria.CommonOpaque
        };
        var drawingSettings = new DrawingSettings(CameraRenderer.ForwardShaderTagID, sortingSettings);
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        context.DrawRenderers(
            _cullingResults, ref drawingSettings, ref filteringSettings
        );


        Profiler.EndSample();
        Profiler.BeginSample("Forward Transparent");
        buffer.Blit(CameraRendererUtility.frameBufferId, tempForwardTarget.colorBuffer);
        CoreUtils.SetRenderTarget(buffer,CameraRendererUtility.frameBufferId);

        ExecuteBuffer(context, buffer);

        sortingSettings = new SortingSettings(camera)
        {
            criteria = SortingCriteria.CommonTransparent
        };
        drawingSettings = new DrawingSettings(CameraRenderer.ForwardShaderTagID, sortingSettings);
        filteringSettings = new FilteringSettings(RenderQueueRange.transparent);
        context.DrawRenderers(
            _cullingResults, ref drawingSettings, ref filteringSettings
        );
        Profiler.EndSample();
        ExecuteBuffer(context, buffer);
     
        RenderTexture.ReleaseTemporary(tempForwardTarget);
        CoreUtils.SetRenderTarget(buffer, CameraRendererUtility.frameBufferId);
    }
}