using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

[CreateAssetMenu]
public class BufferContainer : ScriptableObject
{
    [SerializeField] public RenderTargetIdentifier[] colors;
    [SerializeField] public RenderTargetIdentifier depth;
    [SerializeField] public RenderTexture[] buffers;
    [SerializeField] public RenderTexture dBuffer;
    [SerializeField]
    private string TargetDepthBufferGlobalName = "depth";

   [SerializeField]
    private string TargetColorBufferGlobalName = "albedo";
    [SerializeField]
    private string TargetNormalBufferGlobalName = "normals";
    [SerializeField]
    private string TargetMADSBufferGlobalName = "MADS";

    [SerializeField]
    private string TargetPositionBufferGlobalName = "additionalData";

   
    public void SetupBuffers(int GBufferCount, Camera _camera, CommandBuffer buffer)
    {
        if (colors == null || colors.Length != GBufferCount)
        {
            colors = new RenderTargetIdentifier[GBufferCount];
            buffers = new RenderTexture[GBufferCount];
        }

        for (int i = 0; i < GBufferCount; i++)
        {
            var rt = RenderTexture.GetTemporary(_camera.pixelWidth, _camera.pixelHeight, 0,
                GraphicsFormat.R32G32B32A32_SFloat);
            rt.filterMode = FilterMode.Point;
            //rt.Create();
            buffers[i] = rt;
            colors[i] = new RenderTargetIdentifier(rt);
        }

        dBuffer = RenderTexture.GetTemporary(_camera.pixelWidth, _camera.pixelHeight, 32,
            RenderTextureFormat.Depth);
        dBuffer.filterMode = FilterMode.Point;
        //dBuffer.Create();
        depth = new RenderTargetIdentifier(dBuffer.colorBuffer);
        
        buffer.SetGlobalTexture(TargetColorBufferGlobalName, colors[0]);
        buffer.SetGlobalTexture(TargetNormalBufferGlobalName, colors[1]);
        buffer.SetGlobalTexture(TargetMADSBufferGlobalName, colors[2]);
        buffer.SetGlobalTexture(TargetPositionBufferGlobalName, colors[3]);
        buffer.SetGlobalTexture(TargetDepthBufferGlobalName, depth);
    }

    public void ReleaseBuffers()
    {
        for (int i = 0; i < colors.Length; i++)
        {
            RenderTexture.ReleaseTemporary(buffers[i]);
        }

        RenderTexture.ReleaseTemporary(dBuffer);
    }
}