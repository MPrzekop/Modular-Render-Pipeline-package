
using System.Collections.Generic;

using UnityEngine;

using UnityEngine.Rendering;

namespace CustomRP
{
    [System.Serializable]
    public class CameraRenderer
    {
        const string BufferName = "Render Camera";
        static ShaderTagId unlitShaderTagId;

        [SerializeField] public List<RPModule> modules;
        [SerializeField] ScriptableRenderContext _context;
        Camera _camera;
        CullingResults _cullingResults;
        static int frameBufferId = Shader.PropertyToID("_CameraFrameBuffer");

        CommandBuffer buffer = new CommandBuffer
        {
            name = BufferName
        };

        public static ShaderTagId DeferredShaderTagID
        {
            get
            {
                unlitShaderTagId = new ShaderTagId("CustomDeferred");
                return unlitShaderTagId;
            }
        }

        public static ShaderTagId ForwardShaderTagID
        {
            get
            {
                unlitShaderTagId = new ShaderTagId("CustomForward");
                return unlitShaderTagId;
            }
        }


        public void Render(ScriptableRenderContext context, Camera camera)
        {
            _context = context;
            _camera = camera;
            if (buffer == null)
            {
                buffer = new CommandBuffer()
                {
                    name = BufferName
                };
            }

            CameraRendererUtility.PrepareBufferProfiling(buffer, camera);
            CameraRendererUtility.PrepareForSceneWindow(camera, context);

            if (!Cull())
            {
                return;
            }

            Setup();


            foreach (var module in modules)
            {
                module.Render(context, camera, buffer);
            }


            //

            CameraRendererUtility.RenderGizmos(camera, context);
            buffer.Blit(CameraRendererUtility.frameBufferId, BuiltinRenderTextureType.CameraTarget);
            ExecuteBuffer();
            Submit();
        }

        void Setup()
        {
            _context.SetupCameraProperties(_camera);
            CameraClearFlags flags = _camera.clearFlags;
            buffer.GetTemporaryRT(
                CameraRendererUtility.frameBufferId, _camera.pixelWidth, _camera.pixelHeight,
                32, FilterMode.Bilinear,
                RenderTextureFormat.DefaultHDR
            );
            CameraRendererUtility.StartSample(buffer);
            ExecuteBuffer();
        }


        bool Cull()
        {
            //ScriptableCullingParameters p
            if (_camera.TryGetCullingParameters(out ScriptableCullingParameters p))
            {
                _cullingResults = _context.Cull(ref p);
                return true;
            }

            return false;
        }


        void ExecuteBuffer()
        {
            _context.ExecuteCommandBuffer(buffer);
            buffer.Clear();
        }

        void Submit()
        {
            CameraRendererUtility.EndSample(buffer);
            ExecuteBuffer();
            _context.Submit();
            buffer.Release();
            buffer = null;
        }
    }
}