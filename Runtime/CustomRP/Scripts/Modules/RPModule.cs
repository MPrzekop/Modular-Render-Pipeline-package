using System;
using System.Collections.Generic;
using CustomRP.Scripts.CullingUtilities;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP
{
    [System.Serializable]
    public abstract class RPModule : ScriptableObject
    {
        public string moduleName;
        public bool enabled;


        public LayerMask LayerMask;

        public bool lightingData;

        [Range(0, 128)] public int maxLightsCount;

        public string lightBufferName = "LIGHT_BUFFER";
        public string lightCountPropertyName = "LIGHT_COUNT";

        [SerializeField] public bool customCulling;
        [SerializeField] public CustomCuller customCuller;

        public void Render(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
        {
            if (!enabled) return;
            if (culls())
            {
                if (!Cull(camera, context, out _cullingResults)) return;
                RenderInternal(context, camera, buffer);
            }

            else
            {
                RenderInternal(context, camera, buffer);
            }
        }


        protected abstract bool culls();
        protected CullingResults _cullingResults;

        protected NativeArray<VisibleLight> lights;
        protected BlittableLight[] lightsData;
        protected ComputeBuffer lightsBuffer;

        protected bool Cull(Camera camera, ScriptableRenderContext context, out CullingResults cullingResults)
        {
            if (customCulling)
            {
                cullingResults = default(CullingResults);
                return true;
            }

            //ScriptableCullingParameters p
            if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
            {
                if (!lightingData)
                    p.maximumVisibleLights = 0;
                else
                {
                    // if (lights == null || lights.Length != maxLightsCount)
                    // {
                    //     lights = new NativeArray<VisibleLight>();
                    // }
                    if (lightsData == null || lightsData.Length != maxLightsCount)
                    {
                        lightsData = new BlittableLight[maxLightsCount];
                    }

                    p.maximumVisibleLights = maxLightsCount;
                }

                p.shadowDistance = 10;
                p.cullingMask = (uint) LayerMask.value;

                cullingResults = context.Cull(ref p);
                if (lightingData)
                {
                    lights = cullingResults.visibleLights;
                    PopulateLightsBuffer();
                }

                return true;
            }

            cullingResults = default(CullingResults);
            return false;
        }

        private void PopulateLightsBuffer()
        {
            if (maxLightsCount == 0) return;
            if (lightsBuffer == null || lightsBuffer.count != maxLightsCount)
            {
                lightsBuffer?.Release();
                lightsBuffer = new ComputeBuffer(maxLightsCount, UnsafeUtility.SizeOf<BlittableLight>());
            }

            for (int i = 0; i < Mathf.Min(maxLightsCount, lights.Length); i++)
            {
                lightsData[i] = new BlittableLight(lights[i]);
            }

            lightsBuffer.SetData(lightsData);
            Shader.SetGlobalBuffer(lightBufferName, lightsBuffer);
            Shader.SetGlobalInt(lightCountPropertyName, Mathf.Min(maxLightsCount, lights.Length));
        }

        protected abstract void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer);

        protected void ExecuteBuffer(ScriptableRenderContext context, CommandBuffer buffer)
        {
            context.ExecuteCommandBuffer(buffer);
            buffer.Clear();
        }
    }

    [System.Serializable]
    public abstract class SerializedList<T> : List<T>, ISerializationCallbackReceiver
    {
        [SerializeField, HideInInspector] private List<T> valueData = new List<T>();

        public void OnBeforeSerialize()
        {
            this.valueData.Clear();
            for (int i = 0; i < this.Count; i++)
            {
                valueData.Add(this[i]);
            }
        }

        public void OnAfterDeserialize()
        {
            this.Clear();
            for (int i = 0; i < this.valueData.Count; i++)
            {
                this.Add(this.valueData[i]);
            }
        }
    }

    [System.Serializable]
    public class RPModulesList : SerializedList<RPModule>
    {
    }
}