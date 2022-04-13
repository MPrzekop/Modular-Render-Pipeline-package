struct Surface
{
    float roughness;
    float metallic;
    float specular;
    float sheen;
    float anisotropy;
    float clearcoat;
    float clearcoatGloss;
    float subsurface;
    float4 baseColor;
    float4 sheenTint;
    float4 specularTint;
    float3 normal;
};


#define MEDIUMP_FLT_MAX    65504.0
#define saturateMediump(x) min(x, MEDIUMP_FLT_MAX)

static const float PI = 3.14159265358979323846;

float sqr(float x) { return x * x; }

float SchlickFresnel(float u)
{
    float m = clamp(1 - u, 0, 1);
    float m2 = m * m;
    return m2 * m2 * m; // pow(m,5)
}

float GTR1(float NdotH, float a)
{
    if (a >= 1) return 1 / PI;
    float a2 = a * a;
    float t = 1 + (a2 - 1) * NdotH * NdotH;
    return (a2 - 1) / (PI * log(a2) * t);
}

float GTR2(float NdotH, float a)
{
    float a2 = a * a;
    float t = 1 + (a2 - 1) * NdotH * NdotH;
    return a2 / (PI * t * t);
}

float GTR2_aniso(float NdotH, float HdotX, float HdotY, float ax, float ay)
{
    return 1 / (PI * ax * ay * sqr(sqr(HdotX / ax) + sqr(HdotY / ay) + NdotH * NdotH));
}

float smithG_GGX(float NdotV, float alphaG)
{
    float a = alphaG * alphaG;
    float b = NdotV * NdotV;
    return 1 / (NdotV + sqrt(a + b - a * b));
}

float smithG_GGX_aniso(float NdotV, float VdotX, float VdotY, float ax, float ay)
{
    return 1 / (NdotV + sqrt(sqr(VdotX * ax) + sqr(VdotY * ay) + sqr(NdotV)));
}

float3 mon2lin(float3 x)
{
    return float3(pow(x[0], 2.2), pow(x[1], 2.2), pow(x[2], 2.2));
}

float3 Lighting(Surface surface, float3 lightDir, float3 viewDir,float4x4 worldToScreen,float3 specularLightDir)
{
    float NdotL = max(dot(surface.normal, lightDir), 0.0);
    float specNdotL = max(dot(surface.normal, specularLightDir), 0.0);
    float NdotV = max(dot(surface.normal, viewDir), 0.0);
   
    float3 H = normalize(lightDir + viewDir);
    float3 specH = normalize(specularLightDir + viewDir);
    float NdotH = max(dot(surface.normal, H), 0.0);
    float specNdotH = max(dot(surface.normal, specH), 0.0);
    float LdotH = max(dot(lightDir, H), 0.0);
    float specLdotH = max(dot(specularLightDir, specH), 0.0);

    float3 Cdlin = mon2lin(surface.baseColor);
    float Cdlum = .3 * Cdlin[0] + .6 * Cdlin[1] + .1 * Cdlin[2]; // luminance approx.

    float3 Ctint = Cdlum > 0 ? Cdlin / Cdlum : float3(1, 1, 1); // normalize lum. to isolate hue+sat
    float3 Cspec0 = lerp(surface.specular * .08 * lerp(float3(1, 1, 1), Ctint, surface.specularTint), Cdlin,
                         surface.metallic);
    float3 Csheen = lerp(float3(1, 1, 1), Ctint, surface.sheenTint);
    float3 screenNormal = mul(worldToScreen,float3(1, 0, 0));
    float3 X = cross(surface.normal, screenNormal);
    float3 Y = cross(surface.normal,  X);
    // Diffuse fresnel - go from 1 at normal incidence to .5 at grazing
    // and lerp in diffuse retro-reflection based on roughness
    float FL = SchlickFresnel(NdotL), FV = SchlickFresnel(NdotV);
    float Fd90 = 0.5 + 2 * LdotH * LdotH * surface.roughness;
    float Fd = lerp(1.0, Fd90, FL) * lerp(1.0, Fd90, FV)*NdotL;
    float Fss90 = LdotH * LdotH * surface.roughness;
    float Fss = lerp(1.0, Fss90, FL) * lerp(1.0, Fss90, FV);
    float ss = 1.25 * (Fss * (1 / (NdotL + NdotV) - .5) + .5);
   //return specularLightDir;
    float aspect = sqrt(1 - surface.anisotropy * .9);
    float ax = max(.001, sqr(surface.roughness) / aspect);
    float ay = max(.001, sqr(surface.roughness) * aspect);
    float Ds = GTR2_aniso(specNdotH, dot(specH, X), dot(specH, Y), ax, ay);
    float FH = SchlickFresnel(specLdotH);
    
    float3 Fs = lerp(Cspec0, float3(1, 1, 1), FH);
    
    float Gs = smithG_GGX_aniso(specNdotL, dot(specularLightDir, X), dot(specularLightDir, Y), ax, ay);
    //return float4(lightDir,1);
    Gs *= smithG_GGX_aniso(NdotV, dot(viewDir, X), dot(viewDir, Y), ax, ay);
    // sheen
    float3 Fsheen = FH * surface.sheen * Csheen*NdotL;
  

    // clearcoat (ior = 1.5 -> F0 = 0.04)
    float Dr = GTR1(specNdotH, lerp(.1, .001, surface.clearcoatGloss));
    float Fr = lerp(.04, 1.0, FH);
    float Gr = smithG_GGX(NdotL, .25) * smithG_GGX(NdotV, .25);
    //return FH;
    //return  Fs;
   // return Ds; 
    return max((((1 / PI) * lerp(Fd, ss, surface.subsurface) * Cdlin + Fsheen) * (1 - surface.metallic) + Gs * Fs * Ds*specNdotL + .25
        * surface.clearcoat * Gr * Fr * Dr*specNdotL),0);
    return saturate(surface.baseColor * (Fd));
}
