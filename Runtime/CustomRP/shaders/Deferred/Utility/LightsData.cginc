#include "Light.cginc"

#pragma multi_compile _ _SOFTSHADOWS
StructuredBuffer<Light> LIGHT_BUFFER;
int LIGHT_COUNT;
sampler2D _ShadowMap;
float4 _ShadowMap_TexelSize;
float4x4 _WorldToShadowMatrix;

static const int kernelSampleCount = 16;
static const float2 kernel[kernelSampleCount] = {
    float2(0, 0),
    float2(0.54545456, 0),
    float2(0.16855472, 0.5187581),
    float2(-0.44128203, 0.3206101),
    float2(-0.44128197, -0.3206102),
    float2(0.1685548, -0.5187581),
    float2(1, 0),
    float2(0.809017, 0.58778524),
    float2(0.30901697, 0.95105654),
    float2(-0.30901703, 0.9510565),
    float2(-0.80901706, 0.5877852),
    float2(-1, 0),
    float2(-0.80901694, -0.58778536),
    float2(-0.30901664, -0.9510566),
    float2(0.30901712, -0.9510565),
    float2(0.80901694, -0.5877853),
};


float3 GetDirectionalLightDirection(Light ctx)
{
    return -normalize(mul(ctx.localToWorldMatrix, float4(0, 0, 1, 0)));
}

float GetDirectionalLight(Light ctx, float3 worldNormals)
{
    // return float4(-forward,1);
    //  return float4(worldNormals, 0);
    return 1;
}

float3 GetPointLightDirection(Light ctx, float3 position)
{
    float3 lightPos = mul(ctx.localToWorldMatrix, float4(0, 0, 0, 1));
    float3 delta = lightPos - position;
    float3 dir = normalize(delta);
    return dir;
}

float dot2(float3 a)
{
    return dot(a, a);
}

float udTriangle(float3 p, float3 a, float3 b, float3 c)
{
    float3 ba = b - a;
    float3 pa = p - a;
    float3 cb = c - b;
    float3 pb = p - b;
    float3 ac = a - c;
    float3 pc = p - c;
    float3 nor = cross(ba, ac);
    return sqrt(
        (sign(dot(cross(ba, nor), pa)) +
            sign(dot(cross(cb, nor), pb)) +
            sign(dot(cross(ac, nor), pc)) < 2.0)
            ? min(min(
                      dot2(ba * clamp(dot(ba, pa) / dot2(ba), 0.0, 1.0) - pa),
                      dot2(cb * clamp(dot(cb, pb) / dot2(cb), 0.0, 1.0) - pb)),
                  dot2(ac * clamp(dot(ac, pc) / dot2(ac), 0.0, 1.0) - pc))
            : dot(nor, pa) * dot(nor, pa) / dot2(nor));
}

bool pointInTriangle(float3 p, float3 a, float3 b, float3 c)
{
    a -= p;
    b -= p;
    c -= p;


    float3 u = cross(b, c);
    float3 v = cross(c, a);
    float3 w = cross(a, b);


    if (dot(u, v) < 0)
    {
        return false;
    }
    if (dot(u, w) < 0.0f)
    {
        return false;
    }


    return true;
}

float3 ClosestPointOnLine(float3 pointIn, float3 a, float3 b)
{
    // Break ab appart into components a and b


    // Project c onto ab, computing the 
    // paramaterized position d(t) = a + t * (b - a)
    float t = dot(pointIn - a, b - a) / dot2(b - a);

    // Clamp T to a 0-1 range. If t was < 0 or > 1
    // then the closest point was outside the line!
    t = clamp(t, 0, 1);

    // Compute the projected position from the clamped t
    float3 d = (a + t * (b - a));

    // Return result
    return d;
}

float3 GetClosestPointInTriangleOnPlane(float3 pointIn, float3 a, float3 b, float3 c, out int hit)
{
    if (pointInTriangle(pointIn, a, b, c))
    {
        hit = 1;
        return pointIn;
    }
    float3x3 points;
    float3 c1 = ClosestPointOnLine(pointIn, a, b);
    float3 c2 = ClosestPointOnLine(pointIn, b, c);
    float3 c3 = ClosestPointOnLine(pointIn, c, a);
    points[0] = c1;
    points[1] = c2;
    points[2] = c3;
    float3 distances;
    int closest = 0;
    for (int i = 0; i < 3; i++)
    {
        distances[i] = length(pointIn - points[i]);
        if (distances[i] < distances[closest])
        {
            closest = i;
        }
    }
    hit = 0;
    return points[closest];
}

float3 GetClosestPointInTriangle(float3 pointIn, float3 a, float3 b, float3 c, out int hit)
{
    float3 planeNormal = normalize(cross(b - a, c - a));
    float distance = dot(planeNormal, a);
    float3 closestPointOnPlane = pointIn - (dot(planeNormal, pointIn) - distance) * planeNormal;
    if (pointInTriangle(closestPointOnPlane, a, b, c))
    {
        hit = 1;
        return closestPointOnPlane;
    }
    float3x3 points;
    float3 c1 = ClosestPointOnLine(closestPointOnPlane, a, b);
    float3 c2 = ClosestPointOnLine(closestPointOnPlane, b, c);
    float3 c3 = ClosestPointOnLine(closestPointOnPlane, c, a);
    points[0] = c1;
    points[1] = c2;
    points[2] = c3;
    float3 distances;
    int closest = 0;
    for (int i = 0; i < 3; i++)
    {
        distances[i] = length(closestPointOnPlane - points[i]);
        if (distances[i] < distances[closest])
        {
            closest = i;
        }
    }
    hit = 0;
    return points[closest];
}

float3x3 constructTransitionMatrix(float3 forwardDir, float3 upDir)
{
    float3 rightDir = cross(forwardDir, upDir);
    float3x3 result = {rightDir, upDir, forwardDir};
    return result;
}

float intersectPlane(float3 lineOrigin, float3 lineDir, float3 shapeOrigin, float3 shapeUpDir)
{
    // Transform line origin and direction from world space to the shape space
    float3x3 transitionMatrix = constructTransitionMatrix(float3(0, 0, 0), shapeUpDir);
    float3 lO = mul(transitionMatrix, lineOrigin - shapeOrigin);
    float3 lD = mul(transitionMatrix, lineDir);

    float denominator = lD.y;
    float numerator = lO.y;

    return - numerator / denominator;
}


float3 GetAreaLightDirection(Light ctx, float3 position)
{
    float3 lightLowRight = mul(ctx.localToWorldMatrix, float4(0.5, -0.5, 0, 1));
    float3 lightHighRight = mul(ctx.localToWorldMatrix, float4(0.5, 0.5, 0, 1));
    float3 lightLowLeft = mul(ctx.localToWorldMatrix, float4(-0.5, -0.5, 0, 1));
    float3 lightHighLeft = mul(ctx.localToWorldMatrix, float4(-0.5, 0.5, 0, 1));

    bool hit;
    float3 closestA = GetClosestPointInTriangle(position, lightHighLeft, lightLowLeft, lightHighRight, hit);
    float3 closestB = GetClosestPointInTriangle(position, lightLowRight, lightLowLeft, lightHighRight, hit);
    //return  normalize(closestB-position);
    return normalize((length(closestA - position) > length(closestB - position) ? closestB : closestA) - position);
}

float3 GetAreaLightSpecularDirection(Light ctx, float3 position, float3 normal, float3 viewDir)
{
    float3 lightLowRight = mul(ctx.localToWorldMatrix, float4(0.5, -0.5, 0, 1));
    float3 lightHighRight = mul(ctx.localToWorldMatrix, float4(0.5, 0.5, 0, 1));
    float3 lightLowLeft = mul(ctx.localToWorldMatrix, float4(-0.5, -0.5, 0, 1));
    float3 lightHighLeft = mul(ctx.localToWorldMatrix, float4(-0.5, 0.5, 0, 1));
    float3 ref = reflect(viewDir, normal);
    float3 pos = position + ref * intersectPlane(position, ref, lightLowRight,
                                                 normalize(cross(lightLowRight - lightHighRight,
                                                                 lightLowLeft - lightHighRight)));

    bool hit = false;
    float3 closestA = GetClosestPointInTriangleOnPlane(pos, lightHighLeft, lightLowLeft, lightHighRight, hit);
    if (hit)
    {
        normalize(closestA - position);
    }

    float3 closestB = GetClosestPointInTriangleOnPlane(pos, lightLowRight, lightLowLeft, lightHighRight, hit);
    if (hit)
    {
        normalize(closestB - position);
    }
    //closestA = GetClosestPointInTriangle(position, lightHighLeft, lightLowLeft, lightHighRight,hit);
    //closestB = GetClosestPointInTriangle(position, lightLowRight, lightLowLeft, lightHighRight,hit);
    //return  normalize(closestB-position);
    //return closestA;
    // return normalize(closestA-position);
    // return length(closestA - position)-length(closestB - position);
    return normalize((length(closestA - pos) > length(closestB - pos) ? closestB : closestA) - position);
}


float GetAreaLightAtten(Light ctx, float3 worldNormlas, float3 position)
{
    //return 1;
    float3 lightLowRight = mul(ctx.localToWorldMatrix, float4(1, -1, 0, 1));
    float3 lightHighRight = mul(ctx.localToWorldMatrix, float4(1, 1, 0, 1));
    float3 lightLowLeft = mul(ctx.localToWorldMatrix, float4(-1, -1, 0, 1));
    float3 lightHighLeft = mul(ctx.localToWorldMatrix, float4(-1, 1, 0, 1));
    float distance = min(udTriangle(position, lightLowRight, lightHighRight, lightLowLeft),
                         udTriangle(position, lightHighLeft, lightHighRight, lightLowLeft));
    float delta2 = distance * distance;
    float rangeFade = max(delta2 * (1.0 / (ctx.range * ctx.range)), 0.00001);
    rangeFade = saturate(1.0 - rangeFade * rangeFade);
    rangeFade *= rangeFade;
    float distanceSqr = max(delta2, 0.00001);
    return (rangeFade / distanceSqr);
}

float GetPointLight(Light ctx, float3 worldNormals, float3 position)
{
    float3 lightPos = mul(ctx.localToWorldMatrix, float4(0, 0, 0, 1));
    float3 delta = position - lightPos;

    float rangeFade = max(dot(delta, delta) * (1.0 / (ctx.range * ctx.range)), 0.00001);
    rangeFade = saturate(1.0 - rangeFade * rangeFade);
    rangeFade *= rangeFade;
    float distanceSqr = max(dot(delta, delta), 0.00001);

    return (rangeFade / distanceSqr);
}

float3 GetSpotLightDirection(Light ctx, float3 position)
{
    float3 lightPos = mul(ctx.localToWorldMatrix, float4(0, 0, 0, 1));
    float3 delta = lightPos - position;
    return normalize(delta);
}

float GetSpotLight(Light ctx, float3 normals, float3 position)
{
    float3 forward = (mul(ctx.localToWorldMatrix, float4(0, 0, 1, 0)));
    float3 lightPos = mul(ctx.localToWorldMatrix, float4(0, 0, 0, 1));
    float3 delta = position - lightPos;
    float outerRad = radians(ctx.spotAngle * 0.5);
    float outerCos = cos(outerRad);
    float outerTan = tan(outerRad);
    float innerCos = cos(atan(((64.0 - 18.0) / 64) * outerTan));
    float angleRange = max(innerCos - outerCos, 0.001);
    float rangeFade = max(dot(delta, delta) * (1.0 / (ctx.range * ctx.range)), 0.00001);
    rangeFade = saturate(1.0 - rangeFade * rangeFade);
    rangeFade *= rangeFade;
    float spotFade = dot(normalize(delta), forward);
    spotFade = saturate(spotFade * (1.0 / angleRange) + -outerCos * 1.0 / angleRange);
    spotFade *= spotFade;

    float distanceSqr = max(dot(delta, delta), 0.00001);
    float3 dir = normalize(delta);
    return (spotFade * rangeFade / distanceSqr);
}

float blur13(float2 uv, float kernelMult)
{
    float color = 0;
    for (int k = 0; k < kernelSampleCount; k++)
    {
        float2 o = kernel[k] * kernelMult;
        o *= _ShadowMap_TexelSize.xy * 8;
        color += tex2D(_ShadowMap, uv + o).r;
    }
    color *= 1.0 / kernelSampleCount;
    return color;
}

float SampleShadowMap(float2 uv)
{
    float4 o = _ShadowMap_TexelSize.xyxy * float2(-2, 2).xxyy;
    half4 s =
        tex2D(_ShadowMap, uv + o.xy).r +
        tex2D(_ShadowMap, uv + o.zy).r +
        tex2D(_ShadowMap, uv + o.xw).r +
        tex2D(_ShadowMap, uv + o.zw).r;
    return s * 0.25;
}

float InShadow(float3 position)
{
    float4 shadowPos = mul(_WorldToShadowMatrix, float4(position, 1));
    shadowPos.xyz /= shadowPos.w;
    float shadowVal = tex2D(_ShadowMap, shadowPos.xy).r;
    float distance = shadowVal - shadowPos.z;
    //float blurredShadowMap = blur13(shadowPos.xy, 1) - shadowPos.z;
    // return blurredShadowMap;
    if (distance <= 0.001f)
        return 1;
    return distance;
    // return shadowVal-shadowPos.z;
    // 
    //  return 1 - (lerp((shadowVal), softshadowVal, (shadowPos.z + 0.01f) - (shadowVal)) - (shadowPos.z + 0.01f));
}


float4 GetLighting(float4 albedo, float3 worldNormals, float4 MADS, float3 worldPosition)
{
    float4 returnVal = 0;
    for (int i = 0; i < LIGHT_COUNT; i++)
    {
        const Light currentLight = LIGHT_BUFFER[i];
        switch (currentLight.lightType)
        {
        case 0:
            returnVal += GetSpotLight(currentLight, worldNormals, worldPosition);
            break;
        case 1:
            returnVal += GetDirectionalLight(currentLight, worldNormals);
            break;
        case 2:
            returnVal += GetPointLight(currentLight, worldNormals, worldPosition);
            break;
        case 3:
            returnVal += GetAreaLightAtten(currentLight, worldNormals, worldPosition);
            break;
        default: break;;
        }
        if (currentLight.shadows == 1)
        {
            returnVal *= InShadow(worldPosition);
        }
        returnVal.a = 1;
        // returnVal += currentLight.color;
    }
    return returnVal;
}

float GetLightAtten(float3 worldNormals, float3 worldPosition, int id, float2 uv)
{
    float retVal = 0;
    const Light currentLight = LIGHT_BUFFER[id];
    switch (currentLight.lightType)
    {
    case 0:
        retVal += GetSpotLight(currentLight, worldNormals, worldPosition);
        break;
    case 1:
        retVal += GetDirectionalLight(currentLight, worldNormals);
        break;
    case 2:
        retVal += GetPointLight(currentLight, worldNormals, worldPosition);
        break;
    case 3:
        retVal += GetAreaLightAtten(currentLight, worldNormals, worldPosition);
        break;
    default: break;;
    }
    if (currentLight.shadows == 1)
    {
        retVal *= tex2D(_ShadowMap, uv);
    }
    return retVal;
}

float4 GetLightColor(int id)
{
    const Light currentLight = LIGHT_BUFFER[id];
    return currentLight.color;
}

float3 GetLightDirection(float3 worldPosition, int id)
{
    float3 returnVal = 0;

    const Light currentLight = LIGHT_BUFFER[id];
    switch (currentLight.lightType)
    {
    case 0:
        returnVal = GetSpotLightDirection(currentLight, worldPosition);
        break;
    case 1:
        returnVal = GetDirectionalLightDirection(currentLight);
        break;
    case 2:
        returnVal = GetPointLightDirection(currentLight, worldPosition);
        break;
    case 3:
        returnVal = GetAreaLightDirection(currentLight, worldPosition);
        break;
    default: break;;
    }
    return returnVal;
}

float3 GetSpecularLightDirection(float3 worldPos, float3 worldNormal, float3 viewDir, int id)
{
    float3 returnVal = 0;

    const Light currentLight = LIGHT_BUFFER[id];
    switch (currentLight.lightType)
    {
    case 0:
        returnVal = GetLightDirection(worldPos, id);
        break;
    case 1:
        returnVal = GetLightDirection(worldPos, id);
        break;
    case 2:
        returnVal = GetLightDirection(worldPos, id);
        break;
    case 3:
        returnVal = GetAreaLightSpecularDirection(currentLight, worldPos, worldNormal, viewDir);
        break;
    default: break;;
    }
    return returnVal;
}
