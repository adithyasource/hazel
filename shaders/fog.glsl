#define FOG_START 0.6 // [0.1 0.2 0.3 0.4 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 1.0 1.2 1.5 2.0]
#define FOG_END 0.7 // [0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 1.0 1.2 1.5 2.0 3.0 5.0]
#define FOG_DENSITY 0.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.25 1.5 1.75 2.0 2.5 3.0 4.0 5.0 8.0 10.0]
#define FOG_CURVE 0 // [0 1 2 3 4 5] Linear, Fast Start, Slow Start, S-Curve, Exponential, Inverse

// Compute fog curve
float applyFogCurve(float t) {
    #if FOG_CURVE == 0
        return t;
    #elif FOG_CURVE == 1
        return 1.0 - pow(1.0 - t, 4.0);
    #elif FOG_CURVE == 2
        return t * t;
    #elif FOG_CURVE == 3
        return t * t * (3.0 - 2.0 * t);
    #elif FOG_CURVE == 4
        return 1.0 - exp(-4.0 * t);
    #elif FOG_CURVE == 5
        return (exp(2.0 * t) - 1.0) / (exp(2.0) - 1.0);
    #endif
    return t;
}

float getFogStrength(int shape, float fogStart, float fogEnd) {
    vec4 fragPos = vec4((gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0 - 1.0, gl_FragCoord.z * 2.0 - 1.0, 1.0);
    fragPos = gbufferProjectionInverse * fragPos;
    fragPos /= fragPos.w;
    float dist;
    if (shape == 1 /* CYLINDER */) {
        vec4 worldPos = gbufferModelViewInverse * fragPos;
        dist = max(length(worldPos.xz), abs(worldPos.y));
    } else {
        dist = length(fragPos.xyz);
    }
    float customFogStart = fogStart * FOG_START * (1.0 / FOG_DENSITY);
    float customFogEnd = fogEnd * FOG_END * (1.0 / FOG_DENSITY);
    if (dist >= customFogEnd) {
        return 1.0; // FULL fog past fogEnd
    }
    float linearFog = smoothstep(customFogStart, customFogEnd, dist);
    float finalFog = applyFogCurve(linearFog);
    return clamp(finalFog, 0.0, 1.0);
}

// New function to get sky-colored fog instead of default fog color
vec3 getSkyFogColor() {
    return SKY_FOG_COLOR;
}
