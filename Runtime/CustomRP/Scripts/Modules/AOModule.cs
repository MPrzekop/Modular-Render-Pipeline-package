using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP.Scripts.Modules
{
    [CreateAssetMenu(fileName = "AO module",
        menuName = "Custom RP/AO module", order = 0)]
    public class AOModule : RPModule
    {
        [SerializeField]
        private Material AOMaterial;

        [SerializeField] private RenderTexture AOTexture;
        protected override bool culls()
        {
            return false;
        }

        protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
        {

            
            if (AOMaterial == null) return;
            AOTexture = RenderTexture.GetTemporary(camera.pixelWidth, camera.pixelHeight, 24,
                RenderTextureFormat.DefaultHDR);
            buffer.Blit(CameraRendererUtility.frameBufferId,AOTexture,AOMaterial);
            ExecuteBuffer(context,buffer);
            RenderTexture.ReleaseTemporary(AOTexture);
        }
    }
}