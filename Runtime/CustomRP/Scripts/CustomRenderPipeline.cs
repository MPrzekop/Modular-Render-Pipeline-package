using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP
{
    [Serializable]
    public class CustomRenderPipeline : RenderPipeline
    {
        public CameraRenderer renderer = new CameraRenderer();

        public CustomRenderPipeline(CustomRenderPipelineAsset context)
        {
            GraphicsSettings.lightsUseLinearIntensity = true;
            renderer.modules = context.modules;
        }


        protected override void Render(ScriptableRenderContext context, Camera[] cameras)
        {
            foreach (var c in cameras)
            {
                renderer.Render(context, c);
            }
        }
    }
}