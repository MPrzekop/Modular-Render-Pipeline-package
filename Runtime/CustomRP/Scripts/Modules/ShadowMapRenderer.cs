using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ShadowMapRenderer : MonoBehaviour
{
    private static void RenderSpotShadows(CullingResults _cullingResults, int lightIndex, Matrix4x4 viewMatrix,
        Matrix4x4 projectionMatrix, ShadowSplitData splitData, CommandBuffer shadowsBuffer,
        ScriptableRenderContext context, RenderTargetIdentifier shadowMap)
    {
        _cullingResults.ComputeSpotShadowMatricesAndCullingPrimitives(
            lightIndex, out viewMatrix, out projectionMatrix, out splitData
        );
        shadowsBuffer.SetViewProjectionMatrices(viewMatrix, projectionMatrix);
        context.ExecuteCommandBuffer(shadowsBuffer);
        shadowsBuffer.Clear();
        var shadowSettings = new ShadowDrawingSettings(_cullingResults, lightIndex);
        shadowSettings.splitData = splitData;
        context.DrawShadows(ref shadowSettings);
        if (SystemInfo.usesReversedZBuffer)
        {
            projectionMatrix.m20 = -projectionMatrix.m20;
            projectionMatrix.m21 = -projectionMatrix.m21;
            projectionMatrix.m22 = -projectionMatrix.m22;
            projectionMatrix.m23 = -projectionMatrix.m23;
        }

        var scaleOffset = Matrix4x4.identity;
        scaleOffset.m00 = scaleOffset.m11 = scaleOffset.m22 = 0.5f;
        scaleOffset.m03 = scaleOffset.m13 = scaleOffset.m23 = 0.5f;
        Matrix4x4 worldToShadowMatrix =
            scaleOffset * (projectionMatrix * viewMatrix);
        shadowsBuffer.SetGlobalMatrix(CameraRendererUtility.worldToShadowMatrixId, worldToShadowMatrix);

        shadowsBuffer.SetGlobalTexture(CameraRendererUtility.shadowMapId, shadowMap);
    }

    private static void RenderPointShadows(CullingResults _cullingResults, int lightIndex, Matrix4x4 viewMatrix,
        Matrix4x4 projectionMatrix, ShadowSplitData splitData, CommandBuffer shadowsBuffer,
        ScriptableRenderContext context, RenderTargetIdentifier shadowMap)
    {
        for (int i = 0; i < 6; i++)
        {
            _cullingResults.ComputePointShadowMatricesAndCullingPrimitives(lightIndex, (CubemapFace) i, 0f,
                out viewMatrix, out projectionMatrix, out splitData);
        }
    }

    private static void RenderDirectionalShadows(CullingResults _cullingResults, int lightIndex, Matrix4x4 viewMatrix,
        Matrix4x4 m, ShadowSplitData splitData, CommandBuffer shadowsBuffer,
        ScriptableRenderContext context, RenderTargetIdentifier shadowMap)
    {
        ShadowDrawingSettings settings = new ShadowDrawingSettings(_cullingResults, lightIndex);

        _cullingResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(lightIndex, 0, 1, Vector3.zero, 4096, 0,
            out viewMatrix, out m, out splitData);
        settings.splitData = splitData;
        shadowsBuffer.SetViewProjectionMatrices(viewMatrix, m);
        context.ExecuteCommandBuffer(shadowsBuffer);
        shadowsBuffer.Clear();
        context.DrawShadows(ref settings);
        if (SystemInfo.usesReversedZBuffer)
        {
            m.m20 = -m.m20;
            m.m21 = -m.m21;
            m.m22 = -m.m22;
            m.m23 = -m.m23;
        }

        float scale = 1f / 1;
        m.m00 = (0.5f * (m.m00 + m.m30)) * scale;
        m.m01 = (0.5f * (m.m01 + m.m31)) * scale;
        m.m02 = (0.5f * (m.m02 + m.m32)) * scale;
        m.m03 = (0.5f * (m.m03 + m.m33)) * scale;
        m.m10 = (0.5f * (m.m10 + m.m30)) * scale;
        m.m11 = (0.5f * (m.m11 + m.m31)) * scale;
        m.m12 = (0.5f * (m.m12 + m.m32)) * scale;
        m.m13 = (0.5f * (m.m13 + m.m33)) * scale;
        m.m20 = 0.5f * (m.m20 + m.m30);
        m.m21 = 0.5f * (m.m21 + m.m31);
        m.m22 = 0.5f * (m.m22 + m.m32);
        m.m23 = 0.5f * (m.m23 + m.m33);
        context.ExecuteCommandBuffer(shadowsBuffer);
        shadowsBuffer.Clear();
        Matrix4x4 worldToShadowMatrix =
            (m * viewMatrix);
        shadowsBuffer.SetGlobalMatrix(CameraRendererUtility.worldToShadowMatrixId, worldToShadowMatrix);
        shadowsBuffer.SetGlobalTexture(CameraRendererUtility.shadowMapId, shadowMap);
    }

    public static void RenderShadows(ScriptableRenderContext context, VisibleLight light, CommandBuffer shadowsBuffer,
        CullingResults _cullingResults, int lightIndex)
    {
        if (light.light.shadows == LightShadows.None) return;

        //return;
        if (shadowsBuffer == null)
        {
            shadowsBuffer = new CommandBuffer()
            {
                name = "Shadow buffer"
            };
        }

        var shadowMap = RenderTexture.GetTemporary(4096, 4096, 24, RenderTextureFormat.Depth);
        shadowMap.filterMode = FilterMode.Point;
        shadowMap.wrapMode = TextureWrapMode.Clamp;
        CoreUtils.SetRenderTarget(shadowsBuffer, shadowMap,
            RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store,
            ClearFlag.Depth);
        context.ExecuteCommandBuffer(shadowsBuffer);
        shadowsBuffer.Clear();
       
        if (light.light.shadows == LightShadows.Soft)
        {
            shadowsBuffer.EnableShaderKeyword("_SOFTSHADOWS");
        }
        else
        {
            shadowsBuffer.DisableShaderKeyword("_SOFTSHADOWS");
        }

        Matrix4x4 viewMatrix = new Matrix4x4(), projectionMatrix = new Matrix4x4();
        ShadowSplitData splitData = default;
        switch (light.lightType)
        {
            case LightType.Spot:
                RenderSpotShadows(_cullingResults, lightIndex, viewMatrix, projectionMatrix, splitData, shadowsBuffer,
                    context, shadowMap);
                break;
            case LightType.Directional:
                RenderDirectionalShadows(_cullingResults, lightIndex, viewMatrix, projectionMatrix, splitData,
                    shadowsBuffer,
                    context, shadowMap);
                break;
            case LightType.Point:
                RenderPointShadows(_cullingResults, lightIndex, viewMatrix, projectionMatrix, splitData, shadowsBuffer,
                    context, shadowMap);
                break;
            case LightType.Area:
                break;
            case LightType.Disc:
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }

        context.ExecuteCommandBuffer(shadowsBuffer);
        shadowsBuffer.Clear();
       
        

        context.ExecuteCommandBuffer(shadowsBuffer);
        shadowsBuffer.Clear();
        RenderTexture.ReleaseTemporary(shadowMap);
    }
}