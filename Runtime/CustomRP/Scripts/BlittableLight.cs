using System;
using System.Collections;
using System.Collections.Generic;
using CustomRP.Scripts.CustomRPLights;
using UnityEngine;
using UnityEngine.Rendering;

public struct BlittableLight
{
    int lightType;
    Vector4 color;
    Matrix4x4 localToWorldMatrix;
    float range;
    float spotAngle;
    int shadows;

    public BlittableLight(VisibleLight light)
    {
        lightType = (int) light.lightType;
        color = light.finalColor;
        localToWorldMatrix = light.localToWorldMatrix;
        range = light.range;
        spotAngle = light.spotAngle;
        shadows = light.light.shadows != LightShadows.None ? 1 : 0;
    }

    public BlittableLight(CustomLight light)
    {
        lightType = (int) light.type;
        color = light.lightColor * light.intensity;
        localToWorldMatrix = light.transform.localToWorldMatrix;
        range = light.range;
        spotAngle = light.spotAngle;
        shadows = (int) light.shadowType;
    }
}