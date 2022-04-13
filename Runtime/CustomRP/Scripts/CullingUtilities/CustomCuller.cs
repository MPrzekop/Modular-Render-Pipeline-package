using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP.Scripts.CullingUtilities
{
    public abstract class CustomCuller : ScriptableObject
    {

        public abstract object Cull(ScriptableRenderContext context);
    }
}
