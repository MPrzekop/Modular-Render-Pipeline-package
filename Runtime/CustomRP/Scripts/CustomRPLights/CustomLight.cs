using UnityEngine;

namespace CustomRP.Scripts.CustomRPLights
{
    public class CustomLight : MonoBehaviour
    {
        public enum LightType
        {
            Spot=0,
            Directional=1,
            Point=2,
            Area=3,
            Tube
        }

        public enum ShadowType
        {
            None,
            Hard,
            Soft
        }

        public LightType type;
        public float intensity=1;
        public Color lightColor= Color.white;
        [Range(0,1000)]
        public float range;
        [Range(0,180)]
        public float spotAngle;
        public ShadowType shadowType;

        public BlittableLight blittableLight
        {
            get { return new BlittableLight(this); }
        }
    }
}