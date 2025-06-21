#version 120

uniform sampler2D texture;

uniform float viewWidth;
uniform float viewHeight;

uniform int fogShape;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

varying vec2 texcoord;
varying vec4 color;

#include "fog.glsl"

void main() {
    vec4 col = color;

    float width = gl_Fog.end - gl_Fog.start;
    float newWidth = width * 4.0f;

    col.a *= 1.0f - getFogStrength(0, gl_Fog.start, gl_Fog.start + newWidth);
    col.rgb = mix(col.rgb, gl_Fog.color.rgb, 0.3f);

    gl_FragData[0] = texture2D(texture, texcoord) * col;
}
