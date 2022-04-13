using System;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using CustomRP;
using CustomRP.Scripts.CustomRPLights;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName = "Deferred Render To Screen Module",
    menuName = "Custom RP/RP Deferred Render To Screen Module", order = 0)]
public class DeferredRenderToScreenModule : RPModule
{
    [SerializeField] private Material LightingMaterial;
    [SerializeField] private BufferContainer _bufferContainer;
    [SerializeField] private bool renderShadows;
    [SerializeField] private ComputeShader shadowsBlur;

    private CommandBuffer shadowsBuffer;


    protected override bool culls()
    {
        return true;
    }

    protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
    {
        RenderToScreen(context, camera, buffer);
    }

    private Material shadowmaskMaterial;
    private RenderTexture shadowmaskBuffer1, shadowmaskBuffer2;

    void RenderToScreen(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
    {
        //render to screen with depth copy
        
        if (shadowmaskMaterial == null)
        {
            shadowmaskMaterial = new Material(Shader.Find("Unlit/RenderScreenSpaceShadows"));
        }

        if (shadowmaskBuffer1 == null)
        {
            shadowmaskBuffer1 = new RenderTexture(camera.pixelWidth, camera.pixelHeight, 24,
                RenderTextureFormat.DefaultHDR);
            shadowmaskBuffer1.enableRandomWrite = true;
            shadowmaskBuffer1.Create();
        }

        if (shadowmaskBuffer2 == null)
        {
            shadowmaskBuffer2 = new RenderTexture(camera.pixelWidth, camera.pixelHeight, 24,
                RenderTextureFormat.DefaultHDR);
            shadowmaskBuffer2.enableRandomWrite = true;
            shadowmaskBuffer2.Create();
        }
        CustomLight[] Nlights = (CustomLight[]) customCuller.Cull(context);
        if (lightsData == null || lightsData.Length != maxLightsCount)
        {
            lightsData = new BlittableLight[maxLightsCount];
        }
        if (maxLightsCount == 0) return;
        if (lightsBuffer == null || lightsBuffer.count != maxLightsCount)
        {
            lightsBuffer?.Release();
            lightsBuffer = new ComputeBuffer(maxLightsCount, UnsafeUtility.SizeOf<BlittableLight>());
        }

        for (int i = 0; i < Mathf.Min(maxLightsCount, Nlights.Length); i++)
        {
            lightsData[i] = new BlittableLight(Nlights[i]);
        }

        lightsBuffer.SetData(lightsData);
        Shader.SetGlobalBuffer(lightBufferName, lightsBuffer);
        Shader.SetGlobalInt(lightCountPropertyName, Mathf.Min(maxLightsCount, Nlights.Length));
        
        if (lightingData && maxLightsCount > 0 && Nlights.Length > 0)
        {
            var tempRenderTexture = new RenderTexture[]
            {
                RenderTexture.GetTemporary(camera.pixelWidth, camera.pixelHeight, 24,
                    RenderTextureFormat.DefaultHDR),
                RenderTexture.GetTemporary(camera.pixelWidth, camera.pixelHeight, 24,
                    RenderTextureFormat.DefaultHDR)
            };

            CoreUtils.SetRenderTarget(buffer, tempRenderTexture[0]);


            CoreUtils.ClearRenderTarget(buffer, ClearFlag.All, Color.black);
            ExecuteBuffer(context, buffer);
            int lastIndex = 0;
           
            for (int i = 0; i < Mathf.Min(maxLightsCount, Nlights.Length); i++)
            {
                buffer.SetGlobalInt("LIGHT_ID", i);
                ExecuteBuffer(context, buffer);

                if (renderShadows)
                {
                    //ShadowMapRenderer.RenderShadows(context, lights[i], shadowsBuffer, _cullingResults, i);


                    buffer.Blit(tempRenderTexture[i % 2], shadowmaskBuffer1, shadowmaskMaterial);
                    buffer.Blit(tempRenderTexture[i % 2], shadowmaskBuffer2, shadowmaskMaterial);
                    ExecuteBuffer(context, buffer);

                    if (shadowsBlur != null)
                    {
                        for (int j = 0; j < 6; j++)
                        {
                            buffer.SetComputeTextureParam(shadowsBlur, 0, "target", shadowmaskBuffer2);

                            buffer.SetComputeTextureParam(shadowsBlur, 0, "ShadowMap", shadowmaskBuffer1);

                            ExecuteBuffer(context, buffer);
                            buffer.DispatchCompute(shadowsBlur, 0, camera.pixelWidth / 16, camera.pixelHeight / 16, 1);
                        }

                        buffer.SetGlobalTexture(CameraRendererUtility.shadowMapId, shadowmaskBuffer1);
                        ExecuteBuffer(context, buffer);
                    }
                }


                buffer.Blit(tempRenderTexture[i % 2], tempRenderTexture[(i + 1) % 2],
                    LightingMaterial);
                ExecuteBuffer(context, buffer);


                lastIndex = (i + 1) % 2;
            }


            context.SetupCameraProperties(camera);
            ExecuteBuffer(context, buffer);
            CoreUtils.SetRenderTarget(buffer, CameraRendererUtility.frameBufferId);
            buffer.Blit(tempRenderTexture[lastIndex], CameraRendererUtility.frameBufferId);
            ExecuteBuffer(context, buffer);
            foreach (var t in tempRenderTexture)
            {
                RenderTexture.ReleaseTemporary(t);
            }
        }
        else
        {
            buffer.Blit(_bufferContainer.colors[0], CameraRendererUtility.frameBufferId,
                LightingMaterial);
        }

        CoreUtils.SetRenderTarget(buffer, CameraRendererUtility.frameBufferId);

        ExecuteBuffer(context, buffer);
    }
}