using CustomRP.Scripts.CustomRPLights;
using UnityEngine;
using UnityEngine.Rendering;

namespace CustomRP.Scripts.CullingUtilities
{
    [CreateAssetMenu]
    public class LightsCuller : CustomCuller
    {
        // Start is called before the first frame update

        public override object Cull(ScriptableRenderContext context)
        {
            return FindObjectsOfType<CustomLight>();
        }
    }
}