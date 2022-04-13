using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP.Scripts.Modules
{
    [System.Serializable,
     CreateAssetMenu(fileName = "Deferred Module", menuName = "Custom RP/RP Deferred Populate GBuffers Module",
         order = 0)]
    public class DeferredModule : RPModule
    {
        [SerializeField] private Material GBufferPopulateMaterial;

        [SerializeField] private bool DrawColorBuffer, DrawNormalsBuffer, DrawMADS, DrawAdditionalData;


        [SerializeField] private BufferContainer bufferContainer;

        protected override bool culls()
        {
            return true;
        }

        protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
        {
            _camera = camera;
            _context = context;
            this.buffer = buffer;

            SetupGBuffer();
            DrawDeferredVisibleGeometry();


            ReleaseGBuffers();
        }

        ScriptableRenderContext _context;
        Camera _camera;
        private CommandBuffer buffer;

        private CommandBuffer shadowsBuffer;
        private RenderTexture shadowMap;

        void DrawDeferredVisibleGeometry()
        {
            CoreUtils.SetRenderTarget(buffer, bufferContainer.colors, bufferContainer.depth);
            _context.SetupCameraProperties(_camera);
            ClearFlag flag;
            switch (_camera.clearFlags)
            {
                case CameraClearFlags.Skybox:
                    flag = ClearFlag.All;
                    break;
                case CameraClearFlags.Color:
                    flag = ClearFlag.All;
                    break;
                case CameraClearFlags.Depth:
                    flag = ClearFlag.Depth;
                    break;
                case CameraClearFlags.Nothing:
                    flag = ClearFlag.None;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            var color = _camera.backgroundColor;
            CoreUtils.ClearRenderTarget(buffer, flag, color);
            ExecuteBuffer(_context, buffer);

            var sortingSettings = new SortingSettings(_camera)
            {
                criteria = SortingCriteria.CommonOpaque
            };
            var drawingSettings = new DrawingSettings(CameraRenderer.DeferredShaderTagID, sortingSettings);
            var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
            _context.DrawRenderers(
                _cullingResults, ref drawingSettings, ref filteringSettings
            );
        }


        private int gbufferSize = 4;

        void SetupGBuffer()
        {
            bufferContainer.SetupBuffers(gbufferSize, _camera, buffer);
            SetKeyword("TARGET_BUFFER_0", DrawColorBuffer);
            SetKeyword("TARGET_BUFFER_1", DrawNormalsBuffer);
            SetKeyword("TARGET_BUFFER_2", DrawMADS);
            SetKeyword("TARGET_BUFFER_3", DrawAdditionalData);
        }

        void ReleaseGBuffers()
        {
            bufferContainer.ReleaseBuffers();

            // ExecuteBuffer();
        }


        void SetKeyword(string name, bool value)
        {
            if (value)
                Shader.EnableKeyword(name);
            else
            {
                Shader.DisableKeyword(name);
            }
        }
    }
}