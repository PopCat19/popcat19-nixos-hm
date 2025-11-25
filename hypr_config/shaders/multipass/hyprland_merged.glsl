#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform float time;

// ============================================================================
// CHROMATIC ABERRATION PARAMETERS
// ============================================================================
#define CA_RED_STRENGTH     0.001
#define CA_BLUE_STRENGTH    0.001
#define CA_FALLOFF          1.0
#define CA_ANGLE            0.0
#define CA_FALLOFF_EXPONENT 1.0
#define CA_CENTER_STRENGTH  3.0

// ============================================================================
// GLITCH PARAMETERS
// ============================================================================
#define GLITCH_STRENGTH        1.0
#define GLITCH_PROBABILITY     0.20
#define GLITCH_INTERVAL        3.0
#define GLITCH_DURATION        0.12
#define GLITCH_SPEED           64.0

// ============================================================================
// BLOOM PARAMETERS (SIMPLIFIED FOR SINGLE-PASS)
// ============================================================================
#define BLOOM_INTENSITY       0.24
#define BLOOM_RADIUS          0.0016
#define BLOOM_SAMPLES         12
#define BLOOM_TINT            vec3(1.1, 0.9, 0.85)
#define BLOOM_THRESHOLD       0.96
#define BLOOM_SOFT_THRESHOLD  0.3

// ============================================================================
// CRT CURVATURE PARAMETERS (DISABLED - BORKED)
// ============================================================================
#define CRT_CURVE_STRENGTH 0.0
#define CRT_CORNER_RADIUS 0.0
#define CRT_EDGE_FADE 0.0

// ============================================================================
// SHADOW MASK PARAMETERS (DISABLED)
// ============================================================================
#define SHADOW_MASK_TYPE 0
#define SHADOW_MASK_STRENGTH 0.0
#define SHADOW_MASK_SIZE 2.0

// ============================================================================
// SCANLINE PARAMETERS (DISABLED)
// ============================================================================
#define SCANLINE_OPACITY     0.0
#define SCANLINE_FREQUENCY   1.0
#define SCANLINE_SPEED       -1.0
#define SCANLINE_THICKNESS   0.2
#define SCANLINE_SHARPNESS   0.5

// ============================================================================
// DITHER PARAMETERS (DISABLED - INCOMPLETE)
// ============================================================================
#define DITHER_MODE 3
#define DITHER_STRENGTH 0.0
#define DITHER_BIAS 0.6
#define DITHER_TEMPORAL 0
#define DITHER_COLORED 1
#define DITHER_GAMMA 2.2
#define DITHER_PRE_QUANTIZE 0
#define DITHER_PRE_STRENGTH 0.0

// ============================================================================
// VIGNETTE PARAMETERS
// ============================================================================
#define VIGNETTE_STRENGTH      0.4
#define VIGNETTE_RADIUS        1.6
#define VIGNETTE_SMOOTHNESS    0.8
#define VIGNETTE_EXPONENT      1.0
#define VIGNETTE_MODE          0

// ============================================================================
// GRAIN PARAMETERS
// ============================================================================
#define GRAIN_INTENSITY 0.08
#define GRAIN_SIZE 800.0
#define GRAIN_SPEED 0.5

// ============================================================================
// VHS PARAMETERS
// ============================================================================
#define VHS_INTENSITY        0.16
#define VHS_JITTER_STRENGTH  0.004
#define VHS_WAVE_FREQ        2.0
#define VHS_WAVE_AMPLITUDE   0.003
#define VHS_COLOR_SHIFT      0.0015
#define VHS_NOISE_BAND_FREQ  0.8
#define VHS_NOISE_BAND_STRENGTH 0.25

// ============================================================================
// CONSTANTS
// ============================================================================
const float PI = 3.14159265359;
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

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

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

// ============================================================================
// PASS 1: CHROMATIC ABERRATION & GLITCH
// ============================================================================

vec3 applyChromaticAberration(vec2 uv, out float alpha) {
    vec2 dir = (uv - 0.5) * CA_FALLOFF;
    float cosA = cos(CA_ANGLE);
    float sinA = sin(CA_ANGLE);
    dir = vec2(dir.x * cosA - dir.y * sinA, dir.x * sinA + dir.y * cosA);
    float dist = length(dir);
    float edgeComponent = pow(dist, CA_FALLOFF_EXPONENT);
    float centerComponent = (1.0 - edgeComponent) * CA_CENTER_STRENGTH;
    float totalFalloff = edgeComponent + centerComponent;
    float strength_r = totalFalloff * CA_RED_STRENGTH;
    float strength_b = totalFalloff * CA_BLUE_STRENGTH;
    alpha = texture(tex, uv).a;
    return vec3(
        texture(tex, uv + dir * strength_r).r,
        texture(tex, uv).g,
        texture(tex, uv - dir * strength_b).b
    );
}

vec3 applyAnalogGlitch(vec2 uv, float time, vec3 color, float isActive, float tInInterval) {
    if (isActive < 0.5) return color;
    float bounce = sin(tInInterval * GLITCH_SPEED * PI);
    float strength = GLITCH_STRENGTH * bounce;
    float line = floor(uv.y * 480.0);
    float lineNoise = random(vec2(line, time));
    float tearStrength = step(0.985, lineNoise) * 0.02 * strength;
    uv.x += tearStrength * (random(vec2(lineNoise, time)) - 0.5);
    float wave = sin(uv.y * 40.0 + time * 6.0) * 0.002 * strength;
    uv.x += wave;
    float shift = 0.0015 * sin(time * 2.0 + uv.y * 10.0) * strength;
    vec3 analogColor = vec3(
            texture(tex, uv + vec2(shift, 0.0)).r,
            texture(tex, uv).g,
            texture(tex, uv - vec2(shift, 0.0)).b
        );
    return mix(color, analogColor, strength);
}

// ============================================================================
// PASS 2: BLOOM (SIMPLIFIED)
// ============================================================================

vec3 calculateSimplifiedBloom(vec2 uv) {
    vec3 bloomAccum = vec3(0.0);
    float totalWeight = 0.0;

    float dither = interleavedGradientNoise(uv * vec2(1920.0, 1080.0)) * 2.0 - 1.0;
    float ditherAmount = 0.015;

    // Sample in 8 directions with fewer samples
    for (int dir = 0; dir < 8; dir++) {
        float angle = float(dir) * 0.785398;
        vec2 direction = vec2(cos(angle), sin(angle));

        for (int s = 1; s <= BLOOM_SAMPLES; s++) {
            float t = float(s) / float(BLOOM_SAMPLES);
            float jitter = dither * ditherAmount * (1.0 / float(BLOOM_SAMPLES));
            float radius = BLOOM_RADIUS * 2.0 * (t + jitter);

            vec2 sampleUV = uv + direction * radius;
            vec3 sampleColor = texture(tex, sampleUV).rgb;
            float sampleLum = dot(sampleColor, vec3(0.299, 0.587, 0.114));
            float sampleMask = smoothstep(
                    BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                    BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                    sampleLum
                );

            float tentWeight = pow(1.0 - t, 1.2);
            float weight = tentWeight * sampleMask;

            bloomAccum += sampleColor * weight;
            totalWeight += weight;
        }
    }

    if (totalWeight > 0.0) {
        bloomAccum /= totalWeight;
    }

    return bloomAccum * BLOOM_INTENSITY * BLOOM_TINT;
}

// ============================================================================
// PASS 3: CRT EFFECTS
// ============================================================================

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

// ============================================================================
// PASS 4: COLOR GRADING & DITHERING
// ============================================================================

float getDitherThreshold(vec2 screenPos, int mode, float time) {
    vec2 scaledPos = screenPos * 1.0;
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

// ============================================================================
// PASS 5: FINAL COMPOSITE
// ============================================================================

float computeVignette(vec2 uv) {
    vec2 coord = (uv - 0.5) * 2.0;
    float dist = length(coord);
    dist = pow(dist, VIGNETTE_EXPONENT);
    return smoothstep(VIGNETTE_RADIUS, VIGNETTE_RADIUS - VIGNETTE_SMOOTHNESS, dist);
}

vec3 applyGrain(vec2 uv, vec3 color, float time) {
    float noise = hash12(uv * GRAIN_SIZE + time * GRAIN_SPEED);
    float grain = (noise - 0.5) * 2.0;
    return color + grain * GRAIN_INTENSITY;
}

vec3 applyVHSEffect(vec2 uv, float time, vec3 originalColor) {
    float jitter = (random(vec2(time, uv.y)) - 0.5) * VHS_JITTER_STRENGTH;
    uv.x += jitter;
    uv.y += sin(uv.x * VHS_WAVE_FREQ + time * 1.5) * VHS_WAVE_AMPLITUDE;

    vec3 vhsColor = vec3(
            texture(tex, uv + vec2(VHS_COLOR_SHIFT, 0.0)).r,
            texture(tex, uv).g,
            texture(tex, uv - vec2(VHS_COLOR_SHIFT, 0.0)).b
        );

    float bandNoise = step(1.0 - VHS_NOISE_BAND_FREQ, random(vec2(time, floor(uv.y * 480.0))));
    if (bandNoise > 0.5) {
        float noise = (random(uv * time) - 0.5) * VHS_NOISE_BAND_STRENGTH;
        vhsColor += vec3(noise);
    }

    return mix(originalColor, vhsColor, VHS_INTENSITY);
}

// ============================================================================
// MAIN
// ============================================================================

void main() {
    vec2 uv = v_texcoord;

    // ========================================================================
    // PASS 1: CHROMATIC ABERRATION & GLITCH
    // ========================================================================

    // Calculate glitch state
    float currentInterval = floor(time / GLITCH_INTERVAL);
    float tInInterval = fract(time / GLITCH_INTERVAL);
    float seedGlitch = random(vec2(currentInterval));
    float intervalActive = step(seedGlitch, GLITCH_PROBABILITY);
    float isActiveGlitch = intervalActive * step(tInInterval, GLITCH_DURATION);

    float alpha;
    vec3 color = applyChromaticAberration(uv, alpha);
    color = applyAnalogGlitch(uv, time, color, isActiveGlitch, tInInterval);

    // ========================================================================
    // PASS 2: BLOOM (SIMPLIFIED)
    // ========================================================================

    vec3 bloom = calculateSimplifiedBloom(uv);

    // ========================================================================
    // PASS 3: CRT EFFECTS (DISABLED)
    // ========================================================================

    // CRT effects disabled - using original UV
    vec2 screenPos = v_texcoord * vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE);

    // ========================================================================
    // PASS 4: COLOR GRADING (PC-98 DISABLED)
    // ========================================================================

    // PC-98 palette and dithering disabled - using original color

    // ========================================================================
    // PASS 5: FINAL COMPOSITE
    // ========================================================================

    // Add bloom
    color += bloom;

    // Apply grain
    color = applyGrain(v_texcoord, color, time);

    // Apply VHS
    color = applyVHSEffect(v_texcoord, time, color);

    // Apply vignette
    float vig = computeVignette(v_texcoord);
    #if VIGNETTE_MODE == 0
    color *= mix(1.0 - VIGNETTE_STRENGTH, 1.0, vig);
    #else
    color = mix(color * vec3(0.0), color, vig);
    color *= mix(1.0 - VIGNETTE_STRENGTH / 2.0, 1.0, vig);
    #endif

    fragColor = vec4(color, alpha);
}
