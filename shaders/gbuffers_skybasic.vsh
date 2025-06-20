#version 120

varying vec4 color;

void main() {
    color = gl_Color; // supplied by Minecraft, time-of-day adjusted sky color

    gl_Position = ftransform();
}

