using System.Collections;
using System.Collections.Generic;
using CustomRP;
using UnityEngine;
using UnityEngine.Rendering;
[CreateAssetMenu(fileName = "Deferred Cleanup Module", menuName = "Custom RP/RP Deferred Cleanup Module", order = 0)]

public class DeferredCleanupModule : RPModule
{
    [SerializeField] private BufferContainer _bufferContainer;
    protected override bool culls()
    {
        return false;
    }

    protected override void RenderInternal(ScriptableRenderContext context, Camera camera, CommandBuffer buffer)
    {
       _bufferContainer.ReleaseBuffers();
    }
}
