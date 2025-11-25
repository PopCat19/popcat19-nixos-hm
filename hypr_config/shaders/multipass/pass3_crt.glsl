#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform float time;

// CRT Curvature Parameters
#define CRT_CURVE_STRENGTH 0.15
#define CRT_CORNER_RADIUS 0.05
#define CRT_EDGE_FADE 0.02

// Shadow Mask Parameters
#define SHADOW_MASK_TYPE 0
#define SHADOW_MASK_STRENGTH 0.3
#define SHADOW_MASK_SIZE 2.0

// Scanline Parameters
#define SCANLINE_OPACITY     0.25
#define SCANLINE_FREQUENCY   1.0
#define SCANLINE_SPEED       -1.0
#define SCANLINE_THICKNESS   0.2
#define SCANLINE_SHARPNESS   0.5
#define PIXEL_GRID_SIZE 960.0

const float PI = 3.14159265359;

vec2 applyCRTCurvature(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(CRT_CURVE_STRENGTH, CRT_CURVE_STRENGTH);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

bool isValidUV(vec2 uv) {
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return false;
    }
    vec2 edge = smoothstep(vec2(0.0), vec2(CRT_CORNER_RADIUS), uv) *
            smoothstep(vec2(0.0), vec2(CRT_CORNER_RADIUS), vec2(1.0) - uv);
    if (edge.x * edge.y < 0.1) {
        return false;
    }
    return true;
}

vec3 applyShadowMask(vec2 screenPos, vec3 color) {
    vec2 maskCoord = screenPos * SHADOW_MASK_SIZE;
    vec3 mask = vec3(1.0);

    #if SHADOW_MASK_TYPE == 0  // Aperture Grille
    float line = fract(maskCoord.x);
    mask = mix(vec3(1.0, 0.7, 1.0), vec3(0.7, 1.0, 0.7), step(0.33, line) * step(line, 0.66));
    #elif SHADOW_MASK_TYPE == 1  // Slot Mask
    vec2 slot = fract(maskCoord);
    mask = vec3(
            step(slot.x, 0.33),
            step(0.33, slot.x) * step(slot.x, 0.66),
            step(0.66, slot.x)
        );
    mask = mix(vec3(0.5), vec3(1.0), mask);
    #elif SHADOW_MASK_TYPE == 2  // Dot Mask
    vec2 dot = fract(maskCoord);
    float dotPattern = step(length(dot - 0.5), 0.3);
    mask = mix(vec3(0.7), vec3(1.0), dotPattern);
    #endif

    return mix(color, color * mask, SHADOW_MASK_STRENGTH);
}

float applyScanlines(vec2 uv, float time) {
    float scanY = uv.y * SCANLINE_FREQUENCY * 1000.0 + time * SCANLINE_SPEED * 10.0;
    float scan = sin(scanY * PI);
    scan = mix(scan, pow(abs(scan), SCANLINE_SHARPNESS), 0.5);
    scan = smoothstep(1.0 - SCANLINE_THICKNESS, 1.0, scan);
    return 1.0 - scan * SCANLINE_OPACITY;
}

void main() {
    vec2 uv = applyCRTCurvature(v_texcoord);

    if (!isValidUV(uv)) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec4 color = texture(tex, uv);

    // Apply shadow mask
    vec2 screenPos = uv * vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE);
    color.rgb = applyShadowMask(screenPos, color.rgb);

    // Apply scanlines
    color.rgb *= applyScanlines(v_texcoord, time);

    // Edge fade
    vec2 edge = smoothstep(vec2(0.0), vec2(CRT_EDGE_FADE), uv) *
            smoothstep(vec2(0.0), vec2(CRT_EDGE_FADE), vec2(1.0) - uv);
    float edgeFade = edge.x * edge.y;
    color.rgb *= edgeFade;

    fragColor = color;
}
