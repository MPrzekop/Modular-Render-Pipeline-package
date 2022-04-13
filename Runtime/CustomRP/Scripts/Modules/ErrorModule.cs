using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP.Scripts.Modules
{
    [CreateAssetMenu(menuName = "Custom RP/Create ErrorModule", fileName = "ErrorModule", order = 0)]
    public class ErrorModule : RPModule
    {
        protected override bool culls()
        {
            return true;
        }

        protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
        {
            if (Cull(camera, context, out var cullingResults))
            {  CoreUtils.SetRenderTarget(buffer, CameraRendererUtility.frameBufferId, RenderBufferLoadAction.DontCare,
                    RenderBufferStoreAction.Store, ClearFlag.None);
                CameraRendererUtility.DrawUnsupportedShaders(camera, context, cullingResults);
            }
        }
    }
}
