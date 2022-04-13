using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP
{
    [CreateAssetMenu, Serializable]
    public class CustomRenderPipelineAsset : RenderPipelineAsset
    {
        [SerializeField] public List<RPModule> modules;


        protected override RenderPipeline CreatePipeline()
        {
            return new CustomRenderPipeline(this);
        }
    }
}