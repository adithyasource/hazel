#version 120
#include "fog.glsl"

uniform int isEyeInWater;
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

varying vec4 color; // time-of-day adjusted sky color

void main() {
    if (isEyeInWater != 0) {
        discard;
    }

    // Reconstruct world-space view direction
    vec2 screenUV = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    vec4 clipSpace = vec4(screenUV * 2.0 - 1.0, 1.0, 1.0); // Far plane
    vec4 viewSpace = gbufferProjectionInverse * clipSpace;
    viewSpace /= viewSpace.w;
    vec4 worldSpace = gbufferModelViewInverse * viewSpace;
    vec3 viewDir = normalize(worldSpace.xyz);

    // Clean blend from fog (bottom) to sky (top)
    float t = smoothstep(0.0, 0.6, viewDir.y);

    vec3 fogColor = gl_Fog.color.rgb;
    vec3 skyColor = color.rgb;

    // where gl_Fog.color is black/unset
    bool fogMissing = dot(fogColor, fogColor) < 0.001;
    if (fogMissing) {
        fogColor = skyColor;
    }

    vec3 finalColor = mix(fogColor, skyColor, t);

    gl_FragData[0] = vec4(finalColor, 1.0);
}
