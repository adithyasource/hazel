#version 120

uniform sampler2D texture;
uniform int isEyeInWater;

varying vec2 texcoord;
varying vec4 color;

void main() {
    if (isEyeInWater != 0) {
        discard;
    }

    // Sample base sky texture
    vec4 texColor = texture2D(texture, texcoord);

    // Soften sharp gl_Color transitions by blending more toward texColor
    float blend = smoothstep(0.2, 0.8, texcoord.y); // horizon-to-top blend
    vec3 finalColor = mix(texColor.rgb, texColor.rgb * color.rgb, blend);

    gl_FragData[0] = vec4(finalColor, texColor.a * color.a);
}
