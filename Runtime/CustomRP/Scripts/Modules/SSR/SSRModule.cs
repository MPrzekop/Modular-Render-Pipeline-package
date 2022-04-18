using System;
using System.Collections;
using System.Collections.Generic;
using CustomRP;
using Unity.Plastic.Antlr3.Runtime.Tree;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

[CreateAssetMenu]
public class SSRModule : RPModule
{
    enum textureQuality
    {
        full,
        half,
        quarter
    }

    [SerializeField] private ComputeShader SSRCompute;

    [SerializeField] private BufferContainer container;
    [SerializeField] private RenderTexture reflectionBuffer, blurBuffer, result;
    [SerializeField,Range(1,128)] private int maxIterations;
    [Range(0, 1)] [SerializeField] private float screenFade;
    [Range(0, 100)] [SerializeField] private float reflectionDistance;
    [Range(0, 1)] [SerializeField] private float objectThickness;

    [SerializeField] private bool randomizeStartingPoint;
    [SerializeField] private textureQuality quality;

    protected override bool culls()
    {
        return false;
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

    protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
    {
        int texPixelWidth = camera.pixelWidth;
        int texPixelHeight = camera.pixelHeight;
        CameraRendererUtility.SetupCameraMatrices(camera,buffer,context);
        switch (quality)
        {
            case textureQuality.full:
                break;
            case textureQuality.half:
                texPixelHeight /= 2;
                texPixelWidth /= 2;


                break;
            case textureQuality.quarter:
                texPixelHeight /= 4;
                texPixelWidth /= 4;
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }

        SetKeyword("HALF_RES_SAMPLE", quality == textureQuality.half);
        SetKeyword("QUARTER_RES_SAMPLE", quality == textureQuality.quarter);

        if (reflectionBuffer == null || reflectionBuffer.width != texPixelWidth ||
            reflectionBuffer.height != texPixelHeight)
        {
            if (reflectionBuffer != null)
            {
                reflectionBuffer.Release();
            }

            if (blurBuffer != null)
            {
                blurBuffer.Release();
            }

            if (result != null)
            {
                result.Release();
            }


            reflectionBuffer = new RenderTexture(texPixelWidth, texPixelHeight, 24, RenderTextureFormat.DefaultHDR);
            reflectionBuffer.filterMode = FilterMode.Bilinear;
            reflectionBuffer.enableRandomWrite = true;
            reflectionBuffer.Create();
            blurBuffer = new RenderTexture(reflectionBuffer);
            result = new RenderTexture(camera.pixelWidth, camera.pixelHeight, 24, DefaultFormat.HDR);
            result.enableRandomWrite = true;
            result.filterMode = FilterMode.Point;
            result.Create();
        }

        buffer.SetComputeFloatParam(SSRCompute, "maxIterations", maxIterations);
        buffer.SetComputeFloatParam(SSRCompute, "screenEdgeFade", screenFade);
        buffer.SetComputeFloatParam(SSRCompute, "reflectionDistance", reflectionDistance);
        buffer.SetComputeFloatParam(SSRCompute, "objectThickness", objectThickness);

        SetKeyword("RANDOM_STARTING_POINT", randomizeStartingPoint);


        buffer.SetComputeIntParam(SSRCompute, "screenWidth", camera.pixelWidth);
        buffer.SetComputeIntParam(SSRCompute, "screenHeight", camera.pixelHeight);


        buffer.SetComputeTextureParam(SSRCompute, 0, "MADS", container.buffers[2]);
        buffer.SetComputeTextureParam(SSRCompute, 0, "color", CameraRendererUtility.frameBufferId);
        buffer.SetComputeTextureParam(SSRCompute, 0, "normals", container.buffers[1]);
        buffer.SetComputeTextureParam(SSRCompute, 0, "position", container.buffers[3]);
        buffer.SetComputeTextureParam(SSRCompute, 0, "depth", container.depth);

        buffer.SetComputeTextureParam(SSRCompute, 0, "Result", reflectionBuffer);
        buffer.DispatchCompute(SSRCompute, 0, texPixelWidth / 8, texPixelHeight / 8, 1);
        //buffer.Blit(reflectionBuffer, CameraRendererUtility.frameBufferId);

        //ExecuteBuffer(context, buffer);

        //buffer.Blit(reflectionBuffer, blurBuffer);
   
        
        //ExecuteBuffer(context, buffer);
        // buffer.SetComputeTextureParam(SSRCompute, 1, "color", blurBuffer);
        //
        // buffer.SetComputeTextureParam(SSRCompute, 1, "MADS", container.buffers[2]);
        // buffer.SetComputeTextureParam(SSRCompute, 1, "Result", reflectionBuffer);
        // buffer.DispatchCompute(SSRCompute, 1, texPixelWidth / 8, texPixelHeight / 8, 1);
        //

        //ExecuteBuffer(context, buffer);

        buffer.SetComputeTextureParam(SSRCompute, 2, "color", CameraRendererUtility.frameBufferId);
        buffer.SetComputeTextureParam(SSRCompute, 2, "MADS", container.buffers[2]);
        buffer.SetComputeTextureParam(SSRCompute, 2, "reflections", reflectionBuffer);
        buffer.SetComputeTextureParam(SSRCompute, 2, "Result", result);
        buffer.SetComputeTextureParam(SSRCompute, 2, "depth", container.depth);

        buffer.DispatchCompute(SSRCompute, 2, camera.pixelWidth / 8, camera.pixelHeight / 8, 1);
        buffer.Blit(result, CameraRendererUtility.frameBufferId);
        ExecuteBuffer(context, buffer);

        // camera.worldToCameraMatrix;
    }
}