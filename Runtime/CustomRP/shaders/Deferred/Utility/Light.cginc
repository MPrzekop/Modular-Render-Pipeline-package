
struct Light
{
    int lightType;
    float4 color;
    float4x4 localToWorldMatrix;
    float range;
    float spotAngle;
    int shadows;
};