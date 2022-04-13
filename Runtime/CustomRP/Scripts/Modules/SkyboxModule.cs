using System.Collections;
using System.Collections.Generic;
using CustomRP;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Custom RP/Create SkyboxModule", fileName = "SkyboxModule", order = 0)]
public class SkyboxModule : RPModule
{
    protected override bool culls()
    {
        return false;
    }

    protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
    {
        context.SetupCameraProperties(camera);
        CoreUtils.SetRenderTarget(buffer, CameraRendererUtility.frameBufferId, RenderBufferLoadAction.DontCare,RenderBufferStoreAction.Store,ClearFlag.None);
        ExecuteBuffer(context, buffer);
      
        context.DrawSkybox(camera);
        
    }
}