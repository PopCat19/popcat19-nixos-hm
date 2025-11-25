#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform float time;

// Dither Parameters
#define DITHER_MODE 3
#define DITHER_STRENGTH 0.2
#define DITHER_COLORS 16
#define DITHER_SCALE 1.0
#define DITHER_BIAS 0.6
#define DITHER_TEMPORAL 0
#define DITHER_COLORED 1
#define DITHER_GAMMA 2.2
#define DITHER_PRE_QUANTIZE 1
#define DITHER_PRE_STRENGTH 4.0
#define PIXEL_GRID_SIZE 960.0

// PC-98 Palette
const int PC98_PALETTE_SIZE = 68;
const vec3 PC98_PALETTE[68] = vec3[68](
        vec3(0x00, 0x00, 0x00) / 255.0, vec3(0xff, 0xff, 0xff) / 255.0, vec3(0xff, 0xee, 0xcc) / 255.0, vec3(0xee, 0xbb, 0xaa) / 255.0,
        vec3(0xff, 0x44, 0x44) / 255.0, vec3(0x88, 0x00, 0x00) / 255.0, vec3(0xff, 0xff, 0x55) / 255.0, vec3(0xaa, 0xaa, 0x44) / 255.0,
        vec3(0x22, 0xaa, 0x22) / 255.0, vec3(0x00, 0x66, 0x00) / 255.0, vec3(0xaa, 0xaa, 0xff) / 255.0, vec3(0x00, 0x00, 0xff) / 255.0,
        vec3(0xcc, 0x55, 0xcc) / 255.0, vec3(0x77, 0x00, 0x77) / 255.0, vec3(0xff, 0xaa, 0xbb) / 255.0, vec3(0xee, 0xaa, 0xbb) / 255.0,
        vec3(0x66, 0x66, 0x66) / 255.0, vec3(0xfe, 0x45, 0x45) / 255.0, vec3(0xff, 0x00, 0x00) / 255.0, vec3(0x89, 0x01, 0x01) / 255.0,
        vec3(0x55, 0x00, 0x00) / 255.0, vec3(0x99, 0x55, 0x44) / 255.0, vec3(0xbb, 0x55, 0x00) / 255.0, vec3(0xff, 0x99, 0x00) / 255.0,
        vec3(0x55, 0x88, 0x11) / 255.0, vec3(0x23, 0xab, 0x23) / 255.0, vec3(0x01, 0x67, 0x01) / 255.0, vec3(0x11, 0x88, 0xff) / 255.0,
        vec3(0x00, 0x00, 0x77) / 255.0, vec3(0xbb, 0x55, 0xbb) / 255.0, vec3(0x88, 0x00, 0x88) / 255.0, vec3(0x66, 0x00, 0x55) / 255.0,
        vec3(0xcc, 0x22, 0x22) / 255.0, vec3(0xaa, 0x00, 0x00) / 255.0, vec3(0x99, 0x00, 0x00) / 255.0, vec3(0x66, 0x33, 0x22) / 255.0,
        vec3(0xaa, 0x66, 0x22) / 255.0, vec3(0x99, 0x55, 0x00) / 255.0, vec3(0x88, 0x66, 0x00) / 255.0, vec3(0xdd, 0xcc, 0x44) / 255.0,
        vec3(0xff, 0xff, 0x00) / 255.0, vec3(0x44, 0xbb, 0x33) / 255.0, vec3(0x22, 0x66, 0x22) / 255.0, vec3(0x88, 0x88, 0x55) / 255.0,
        vec3(0x99, 0x99, 0x99) / 255.0, vec3(0xcc, 0xbb, 0xcc) / 255.0, vec3(0xbb, 0xbb, 0xff) / 255.0, vec3(0xaa, 0xdd, 0xff) / 255.0,
        vec3(0x00, 0x99, 0xaa) / 255.0, vec3(0x00, 0x77, 0x88) / 255.0, vec3(0x00, 0x33, 0xaa) / 255.0, vec3(0x11, 0x11, 0x66) / 255.0,
        vec3(0x66, 0x33, 0x88) / 255.0, vec3(0x55, 0x44, 0x99) / 255.0, vec3(0x66, 0x55, 0xbb) / 255.0, vec3(0xaa, 0x99, 0xdd) / 255.0,
        vec3(0xdd, 0xdd, 0xff) / 255.0, vec3(0xcc, 0x33, 0xaa) / 255.0, vec3(0x88, 0x00, 0x66) / 255.0, vec3(0x44, 0x22, 0x44) / 255.0,
        vec3(0xcc, 0x88, 0x99) / 255.0, vec3(0x99, 0x44, 0x55) / 255.0, vec3(0x88, 0x33, 0x22) / 255.0, vec3(0xbb, 0x55, 0x33) / 255.0,
        vec3(0xdd, 0x99, 0x77) / 255.0, vec3(0xff, 0xdd, 0xdd) / 255.0, vec3(0xff, 0xcc, 0xaa) / 255.0, vec3(0x99, 0x99, 0x66) / 255.0
    );

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float interleavedGradientNoise(vec2 pixel) {
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(pixel, magic.xy)));
}

vec3 toLinear(vec3 color) {
    return pow(color, vec3(DITHER_GAMMA));
}

vec3 toGamma(vec3 color) {
    return pow(color, vec3(1.0 / DITHER_GAMMA));
}

float getDitherThreshold(vec2 screenPos, int mode, float time) {
    vec2 scaledPos = screenPos * DITHER_SCALE;
    float threshold = interleavedGradientNoise(scaledPos + time * float(DITHER_TEMPORAL));
    threshold = threshold - 0.5 + DITHER_BIAS;
    return clamp(threshold, 0.0, 1.0);
}

vec3 getColoredDitherThreshold(vec2 screenPos, int mode, float time) {
    if (DITHER_COLORED == 0) {
        float t = getDitherThreshold(screenPos, mode, time);
        return vec3(t);
    }
    vec3 thresholds;
    thresholds.r = getDitherThreshold(screenPos, mode, time);
    thresholds.g = getDitherThreshold(screenPos + vec2(0.3333, 0.0), mode, time);
    thresholds.b = getDitherThreshold(screenPos + vec2(0.6666, 0.0), mode, time);
    return thresholds;
}

vec3 applyPreQuantizationDither(vec3 color, vec2 screenPos, float time) {
    vec3 ditherThreshold = getColoredDitherThreshold(screenPos, DITHER_MODE, time);
    vec3 ditherNoise = (ditherThreshold - 0.5) * DITHER_PRE_STRENGTH;
    color = color + ditherNoise / 64.0;
    return clamp(color, 0.0, 1.0);
}

vec3 applyPC98PaletteWithDither(vec3 color, vec2 screenPos, float time) {
    color = applyPreQuantizationDither(color, screenPos, time);
    color = toLinear(color);

    float minDist1 = 999999.0;
    float minDist2 = 999999.0;
    vec3 closest1 = color;
    vec3 closest2 = color;

    for (int i = 0; i < PC98_PALETTE_SIZE; i++) {
        vec3 paletteColor = toLinear(PC98_PALETTE[i]);
        vec3 diff = color - paletteColor;
        float dist = dot(diff, diff);

        if (dist < minDist1) {
            minDist2 = minDist1;
            closest2 = closest1;
            minDist1 = dist;
            closest1 = paletteColor;
        } else if (dist < minDist2) {
            minDist2 = dist;
            closest2 = paletteColor;
        }
    }

    vec3 ditherThreshold = getColoredDitherThreshold(screenPos, DITHER_MODE, time);
    float totalDist = minDist1 + minDist2;
    float normalizedDist = (totalDist > 0.0) ? sqrt(minDist1) / (sqrt(minDist1) + sqrt(minDist2)) : 0.0;

    vec3 result;
    if (DITHER_COLORED == 1) {
        result = vec3(
                (normalizedDist > ditherThreshold.r) ? closest2.r : closest1.r,
                (normalizedDist > ditherThreshold.g) ? closest2.g : closest1.g,
                (normalizedDist > ditherThreshold.b) ? closest2.b : closest1.b
            );
    } else {
        float threshold = ditherThreshold.r;
        result = (normalizedDist * DITHER_STRENGTH > threshold * DITHER_STRENGTH) ? closest2 : closest1;
    }

    result = toGamma(result);
    return result;
}

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec2 screenPos = v_texcoord * vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE);

    color.rgb = applyPC98PaletteWithDither(color.rgb, screenPos, time);

    fragColor = color;
}
