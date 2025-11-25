#version 320 es
precision highp float;

// Input texture coordinates
in vec2 v_texcoord;

// Output fragment color
out vec4 fragColor;

// Input texture and time uniform
uniform sampler2D tex;
uniform float time;

// [Debug Toggles]
#define DEBUG_CA       1       // Toggle chromatic aberration effect
#define DEBUG_BLOOM    1       // Toggle bloom effect
#define DEBUG_VIGNETTE 0       // Toggle vignette effect
#define DEBUG_PIXEL    0       // Toggle pixelation effect
#define COLOR_DEPTH_ENABLED 0  // Enable color depth reduction
#define DEBUG_SCANLINE 0       // Toggle scanline effect
#define DEBUG_VHS_OVERLAY 0    // Toggle VHS effect
#define DEBUG_GLITCH   1       // Toggle glitch effect
#define DEBUG_DRIFT    0       // Toggle drifting effect
#define DEBUG_COLOR_TEMP 0     // Toggle color temperature adjustment
#define DEBUG_VIBRATION 0      // Toggle CRT buzz vibration effect
#define DEBUG_GRAIN     0      // Toggle cinematic grain effect
#define DEBUG_PC98      0      // Toggle PC-98 color palette mode
#define DEBUG_DITHER    0      // Toggle dithering effects (all dithering on/off)
#define DEBUG_CRT_CURVE 0      // Toggle CRT curvature effect
#define DEBUG_PHOSPHOR  0      // Toggle phosphor glow effect
#define DEBUG_SHADOW_MASK 0    // Toggle shadow mask (aperture grille)
#define DEBUG_HALATION  0      // Toggle halation (backlight glow)

// [Effect Parameters]
// Bloom Parameters
#define BLOOM_INTENSITY       0.24      // Increase for more visible bloom (try 0.30-0.50)
#define BLOOM_RADIUS          0.0016     // Increase for wider spread (try 0.025-0.040)
#define BLOOM_SAMPLES         128       // Not used in tent blur (kept for compatibility)
#define BLOOM_RADIAL_SAMPLES  24        // Samples per axis direction (try 10-16 for smoother blur)
#define BLOOM_DENSITY_CURVE   1.6       // Not used in tent blur (kept for compatibility)
#define BLOOM_TINT            vec3(1.1, 0.9, 0.85)
#define BLOOM_THRESHOLD       0.96       // Only bright areas create bloom (try 0.4-0.7)
#define BLOOM_SOFT_THRESHOLD  0.3       // Softer threshold transition
#define BLOOM_FALLOFF_CURVE   32.0

// Glitch Parameters
#define GLITCH_STRENGTH        1.0
#define GLITCH_PROBABILITY     0.20
#define GLITCH_INTERVAL        3.0
#define GLITCH_DURATION        0.12   // at least 120ms
#define GLITCH_SPEED           64.0   // configurable bounce speed

// Vignette Parameters
#define VIGNETTE_STRENGTH      0.4
#define VIGNETTE_RADIUS        1.6
#define VIGNETTE_SMOOTHNESS    0.8
#define VIGNETTE_ASPECT        vec2(1.0, 1.0)
#define VIGNETTE_COLOR         vec3(0.0, 0.0, 0.0)
#define VIGNETTE_OFFSET        vec2(0.0, 0.0)
#define VIGNETTE_EXPONENT      1.0
#define VIGNETTE_MODE          0

// Chromatic Aberration Parameters
#define CA_RED_STRENGTH     0.001
#define CA_BLUE_STRENGTH    0.001
#define CA_FALLOFF          1.0
#define CA_ANGLE            0.0
#define CA_FALLOFF_EXPONENT 1.0
#define CA_CENTER_STRENGTH  3.0

// Scanline Parameters
#define SCANLINE_OPACITY     0.25
#define SCANLINE_FREQUENCY   1.0
#define SCANLINE_SPEED       -1.0
#define SCANLINE_THICKNESS   0.2
#define SCANLINE_SHARPNESS   0.5

// Drifting Effect Parameters
#define DRIFT_MODE 1
#define DRIFT_SPEED -1.6
#define DRIFT_RADIUS 0.002
#define DRIFT_AMPLITUDE 0.002
#define DRIFT_FREQUENCY 1.2
#define DRIFT_DIRECTION vec2(1.0, 0.5)

// CRT Buzz Vibration Parameters
#define VIBRATION_AMPLITUDE 0.0004
#define VIBRATION_BASE_FREQ 75.0
#define VIBRATION_NOISE_FREQ 120.0
#define VIBRATION_NOISE_STRENGTH 0.4

// Color Settings
#define COLOR_DEPTH 16
const float COLOR_TEMPERATURE = 4000.0;
const float COLOR_TEMPERATURE_STRENGTH = 1.0;

// Pixelation Effect
#define PIXEL_GRID_SIZE 960.0

// VHS Overlay Parameters
#define VHS_INTENSITY        0.16
#define VHS_JITTER_STRENGTH  0.004
#define VHS_WAVE_FREQ        2.0
#define VHS_WAVE_AMPLITUDE   0.003
#define VHS_COLOR_SHIFT      0.0015
#define VHS_NOISE_BAND_FREQ  0.8
#define VHS_NOISE_BAND_STRENGTH 0.25

// Grain Parameters
#define GRAIN_INTENSITY 0.08
#define GRAIN_SIZE 800.0
#define GRAIN_SPEED 0.5

// Dither Parameters
#define DITHER_MODE 3          // 0=Bayer8x8, 1=Bayer4x4, 2=Bayer2x2, 3=IGN, 4=Triangular, 5=White Noise, 6=Blue Noise, 7=Void-Cluster, 8=Random, 9=Halftone
#define DITHER_STRENGTH 0.2    // Overall dithering intensity (0.0-1.0)
#define DITHER_COLORS 16       // Number of color levels per channel (2-256)
#define DITHER_SCALE 1.0       // Scale/size of dither pattern (0.5-4.0)
#define DITHER_BIAS 0.6        // Threshold bias (0.0-1.0, 0.5=centered)
#define DITHER_TEMPORAL 0      // Enable temporal dithering (animated)
#define DITHER_COLORED 1       // Enable colored/chromatic dithering
#define DITHER_SERPENTINE 0    // Enable serpentine/error diffusion mode
#define DITHER_GAMMA 2.2       // Gamma correction for dithering (1.0-3.0)
#define DITHER_PRE_QUANTIZE 1  // Enable pre-quantization dithering to break source gradients (0/1)
#define DITHER_PRE_STRENGTH 4.0 // Pre-quantization dither strength (0.5-3.0, higher = more gradient smoothing)

// CRT Curvature Parameters
#define CRT_CURVE_STRENGTH 0.15
#define CRT_CORNER_RADIUS 0.05
#define CRT_EDGE_FADE 0.02

// Phosphor Glow Parameters
#define PHOSPHOR_DECAY 0.85
#define PHOSPHOR_STRENGTH 0.3
#define PHOSPHOR_SAMPLES 5

// Shadow Mask Parameters
#define SHADOW_MASK_TYPE 0     // 0=Aperture Grille, 1=Slot Mask, 2=Dot Mask
#define SHADOW_MASK_STRENGTH 0.3
#define SHADOW_MASK_SIZE 2.0

// Halation Parameters
#define HALATION_STRENGTH 0.2
#define HALATION_RADIUS 0.015
#define HALATION_SAMPLES 16

const float PI = 3.14159265359;

// PC-98 Touhou Color Palette (68 colors)
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

// --- Utility Functions ---
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Bayer 8x8 matrix for ordered dithering
float bayer8x8(ivec2 pixel) {
    const int bayer[64] = int[64](
            0, 32, 8, 40, 2, 34, 10, 42,
            48, 16, 56, 24, 50, 18, 58, 26,
            12, 44, 4, 36, 14, 46, 6, 38,
            60, 28, 52, 20, 62, 30, 54, 22,
            3, 35, 11, 43, 1, 33, 9, 41,
            51, 19, 59, 27, 49, 17, 57, 25,
            15, 47, 7, 39, 13, 45, 5, 37,
            63, 31, 55, 23, 61, 29, 53, 21
        );
    int idx = (pixel.y % 8) * 8 + (pixel.x % 8);
    return float(bayer[idx]) / 64.0;
}

// Bayer 4x4 matrix
float bayer4x4(ivec2 pixel) {
    const int bayer[16] = int[16](
            0, 8, 2, 10,
            12, 4, 14, 6,
            3, 11, 1, 9,
            15, 7, 13, 5
        );
    int idx = (pixel.y % 4) * 4 + (pixel.x % 4);
    return float(bayer[idx]) / 16.0;
}

// Bayer 2x2 matrix
float bayer2x2(ivec2 pixel) {
    const int bayer[4] = int[4](0, 2, 3, 1);
    int idx = (pixel.y % 2) * 2 + (pixel.x % 2);
    return float(bayer[idx]) / 4.0;
}

// Interleaved Gradient Noise (fast, high quality)
float interleavedGradientNoise(vec2 pixel) {
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(pixel, magic.xy)));
}

// Triangular dithering (probabilistic)
float triangularDither(vec2 pixel, float time) {
    float r1 = hash12(pixel + time * float(DITHER_TEMPORAL));
    float r2 = hash12(pixel * 1.337 + time * float(DITHER_TEMPORAL) * 0.5);
    return (r1 + r2) * 0.5;
}

// White noise dithering
float whiteNoise(vec2 pixel, float time) {
    return hash12(pixel + time * float(DITHER_TEMPORAL) * 0.1);
}

// Blue noise approximation (using golden ratio)
float blueNoise(vec2 pixel, float time) {
    const float PHI = 1.61803398875;
    vec2 coord = pixel * 0.1 + time * float(DITHER_TEMPORAL) * 0.01;
    return fract(hash12(floor(coord)) + length(fract(coord)) * PHI);
}

// Void-and-cluster approximation
float voidCluster(vec2 pixel) {
    vec2 coord = pixel * 0.125;
    float a = hash12(floor(coord));
    float b = hash12(floor(coord) + vec2(1.0, 0.0));
    float c = hash12(floor(coord) + vec2(0.0, 1.0));
    float d = hash12(floor(coord) + vec2(1.0, 1.0));
    vec2 f = smoothstep(0.0, 1.0, fract(coord));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Halftone pattern
float halftone(vec2 pixel) {
    vec2 coord = pixel * 0.1;
    vec2 center = floor(coord) + 0.5;
    float dist = length(fract(coord) - 0.5);
    float intensity = hash12(center);
    return smoothstep(intensity * 0.5, intensity * 0.5 + 0.1, dist);
}

// Apply gamma correction
vec3 toLinear(vec3 color) {
    return pow(color, vec3(DITHER_GAMMA));
}

vec3 toGamma(vec3 color) {
    return pow(color, vec3(1.0 / DITHER_GAMMA));
}

// --- Grain Effect ---
vec3 applyGrain(vec2 uv, vec3 color, float time) {
    #if DEBUG_GRAIN
    float noise = hash12(uv * GRAIN_SIZE + time * GRAIN_SPEED);
    float grain = (noise - 0.5) * 2.0;
    return color + grain * GRAIN_INTENSITY;
    #else
    return color;
    #endif
}

// --- CRT Curvature ---
vec2 applyCRTCurvature(vec2 uv) {
    #if DEBUG_CRT_CURVE
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(CRT_CURVE_STRENGTH, CRT_CURVE_STRENGTH);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    #endif
    return uv;
}

// Check if UV is within valid bounds after curvature
bool isValidUV(vec2 uv) {
    #if DEBUG_CRT_CURVE
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return false;
    }
    // Corner fade
    vec2 edge = smoothstep(vec2(0.0), vec2(CRT_CORNER_RADIUS), uv) *
            smoothstep(vec2(0.0), vec2(CRT_CORNER_RADIUS), vec2(1.0) - uv);
    if (edge.x * edge.y < 0.1) {
        return false;
    }
    #endif
    return true;
}

// --- Shadow Mask (Aperture Grille) ---
vec3 applyShadowMask(vec2 screenPos, vec3 color) {
    #if DEBUG_SHADOW_MASK
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
    #else
    return color;
    #endif
}

// --- Phosphor Glow ---
vec3 calculatePhosphorGlow(vec2 uv, vec3 baseColor) {
    #if DEBUG_PHOSPHOR
    vec3 glow = vec3(0.0);
    float totalWeight = 0.0;

    for (int x = -PHOSPHOR_SAMPLES; x <= PHOSPHOR_SAMPLES; x++) {
        for (int y = -PHOSPHOR_SAMPLES; y <= PHOSPHOR_SAMPLES; y++) {
            if (x == 0 && y == 0) continue;

            vec2 offset = vec2(float(x), float(y)) / vec2(PIXEL_GRID_SIZE);
            vec2 sampleUV = uv + offset;

            vec3 sampleColor = texture(tex, sampleUV).rgb;
            float dist = length(vec2(x, y));
            float weight = exp(-dist * 0.5) * PHOSPHOR_DECAY;

            glow += sampleColor * weight;
            totalWeight += weight;
        }
    }

    if (totalWeight > 0.0) {
        glow /= totalWeight;
    }

    return mix(baseColor, baseColor + glow * PHOSPHOR_STRENGTH, 0.5);
    #else
    return baseColor;
    #endif
}

// --- Halation (Backlight Glow) ---
vec3 calculateHalation(vec2 uv) {
    #if DEBUG_HALATION
    vec3 halation = vec3(0.0);
    const float goldenAngle = 2.39996;
    float currentAngle = 0.0;

    for (int i = 0; i < HALATION_SAMPLES; i++) {
        float ratio = float(i) / float(HALATION_SAMPLES);
        float radius = ratio * HALATION_RADIUS;
        currentAngle += goldenAngle;

        vec2 dir = vec2(cos(currentAngle), sin(currentAngle)) * radius;
        vec2 sampleUV = uv + dir;

        vec3 sampleColor = texture(tex, sampleUV).rgb;
        float weight = exp(-ratio * 3.0);

        halation += sampleColor * weight;
    }

    return halation / float(HALATION_SAMPLES) * HALATION_STRENGTH;
    #else
    return vec3(0.0);
    #endif
}

// --- Advanced Dithering System ---
float getDitherThreshold(vec2 screenPos, int mode, float time) {
    vec2 scaledPos = screenPos * DITHER_SCALE;
    ivec2 pixel = ivec2(scaledPos);
    float threshold = 0.5;

    if (mode == 0) {
        // Bayer 8x8
        threshold = bayer8x8(pixel);
    } else if (mode == 1) {
        // Bayer 4x4
        threshold = bayer4x4(pixel);
    } else if (mode == 2) {
        // Bayer 2x2
        threshold = bayer2x2(pixel);
    } else if (mode == 3) {
        // Interleaved Gradient Noise
        threshold = interleavedGradientNoise(scaledPos + time * float(DITHER_TEMPORAL));
    } else if (mode == 4) {
        // Triangular
        threshold = triangularDither(scaledPos, time);
    } else if (mode == 5) {
        // White Noise
        threshold = whiteNoise(scaledPos, time);
    } else if (mode == 6) {
        // Blue Noise
        threshold = blueNoise(scaledPos, time);
    } else if (mode == 7) {
        // Void-and-Cluster
        threshold = voidCluster(scaledPos);
    } else if (mode == 8) {
        // Random
        threshold = random(scaledPos + time * float(DITHER_TEMPORAL));
    } else if (mode == 9) {
        // Halftone
        threshold = halftone(scaledPos);
    }

    // Apply bias
    threshold = threshold - 0.5 + DITHER_BIAS;

    return clamp(threshold, 0.0, 1.0);
}

// Colored dithering (different patterns per channel)
vec3 getColoredDitherThreshold(vec2 screenPos, int mode, float time) {
    if (DITHER_COLORED == 0) {
        float t = getDitherThreshold(screenPos, mode, time);
        return vec3(t);
    }

    // Offset each channel slightly for colored dithering
    vec3 thresholds;
    thresholds.r = getDitherThreshold(screenPos, mode, time);
    thresholds.g = getDitherThreshold(screenPos + vec2(0.3333, 0.0), mode, time);
    thresholds.b = getDitherThreshold(screenPos + vec2(0.6666, 0.0), mode, time);

    return thresholds;
}

// --- Pre-quantization dithering to break up source gradients ---
// This is the KEY to smooth gradients: we add noise BEFORE finding palette colors
// This breaks up color steps in the source image so they dither smoothly
vec3 applyPreQuantizationDither(vec3 color, vec2 screenPos, float time) {
    #if DEBUG_DITHER && DITHER_PRE_QUANTIZE
    // Get dither threshold pattern
    vec3 ditherThreshold = getColoredDitherThreshold(screenPos, DITHER_MODE, time);

    // Convert threshold from [0,1] to [-0.5, 0.5] range for noise
    vec3 ditherNoise = (ditherThreshold - 0.5) * DITHER_PRE_STRENGTH;

    // Add dithering noise to break up banding in source gradient
    // This happens BEFORE palette quantization to disperse color steps
    // Scale factor: /64.0 makes noise visible enough to break bands
    // Higher DITHER_PRE_STRENGTH = more aggressive gradient smoothing
    color = color + ditherNoise / 64.0;

    return clamp(color, 0.0, 1.0);
    #else
    return color;
    #endif
}

// --- PC-98 palette with advanced dithering ---
vec3 applyPC98PaletteWithDither(vec3 color, vec2 screenPos, float time) {
    #if DEBUG_PC98
    // Apply pre-quantization dithering to break up source gradient banding
    #if DEBUG_DITHER
    color = applyPreQuantizationDither(color, screenPos, time);
    #endif

    // Apply gamma correction for better dithering
    color = toLinear(color);

    // Find two nearest colors in linear space
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

    // Two-stage dithering approach for smooth gradients:
    // 1. Pre-quantization dither already broke up source gradient steps (above)
    // 2. Now dither between the two nearest palette colors for smooth transitions

    #if DEBUG_DITHER
    vec3 ditherThreshold = getColoredDitherThreshold(screenPos, DITHER_MODE, time);

    // Calculate normalized distance: 0.0 = closest to color1, 1.0 = closest to color2
    // Using sqrt for perceptually linear distance
    float totalDist = minDist1 + minDist2;
    float normalizedDist = (totalDist > 0.0) ? sqrt(minDist1) / (sqrt(minDist1) + sqrt(minDist2)) : 0.0;

    // Per-channel dithering if colored mode is enabled
    vec3 result;
    if (DITHER_COLORED == 1) {
        // Per-channel comparison with dither threshold
        // Each RGB channel dithers independently for chromatic effect
        result = vec3(
                (normalizedDist > ditherThreshold.r) ? closest2.r : closest1.r,
                (normalizedDist > ditherThreshold.g) ? closest2.g : closest1.g,
                (normalizedDist > ditherThreshold.b) ? closest2.b : closest1.b
            );
    } else {
        // Single comparison - choose between two colors based on dither pattern
        // Multiply by strength to control dithering visibility
        float threshold = ditherThreshold.r;
        result = (normalizedDist * DITHER_STRENGTH > threshold * DITHER_STRENGTH) ? closest2 : closest1;
    }
    #else
    // Dithering disabled - just use closest color
    vec3 result = closest1;
    #endif

    // Convert back to gamma space
    result = toGamma(result);
    return result;
    #else
    return color;
    #endif
}

// --- Color Depth Reduction with Advanced Dithering ---
vec3 applyColorDepthReduction(vec3 color, vec2 screenPos, float time) {
    #if COLOR_DEPTH_ENABLED && DEBUG_DITHER
    ivec3 bits;
    if (COLOR_DEPTH == 8) {
        bits = ivec3(3, 3, 2);
    } else if (COLOR_DEPTH == 16) {
        bits = ivec3(5, 6, 5);
    } else if (COLOR_DEPTH == 24) {
        bits = ivec3(8, 8, 8);
    } else {
        return color;
    }

    // Apply gamma correction
    color = toLinear(color);

    vec3 maxValues = pow(vec3(2.0), vec3(bits)) - 1.0;
    vec3 dither = getColoredDitherThreshold(screenPos, DITHER_MODE, time) - 0.5;

    vec3 ditheredColor = color + dither / maxValues * DITHER_STRENGTH;
    vec3 quantized = floor(ditheredColor * maxValues + 0.5) / maxValues;

    // Convert back to gamma space
    return toGamma(quantized);
    #else
    return color;
    #endif
}

// --- Pixelation Effect ---
vec2 pixelate(vec2 uv) {
    #if DEBUG_PIXEL
    vec2 grid = vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE * (VIGNETTE_ASPECT.y / VIGNETTE_ASPECT.x));
    vec2 pixelUV = floor(uv * grid) / grid;
    return pixelUV;
    #else
    return uv;
    #endif
}

vec3 applyPixelGrid(vec2 uv, vec3 color) {
    #if DEBUG_PIXEL
    vec2 grid = vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE * (VIGNETTE_ASPECT.y / VIGNETTE_ASPECT.x));
    vec2 pixelCoord = uv * grid;
    vec2 gridLine = smoothstep(0.95, 0.99, fract(pixelCoord));
    float gridMask = 1.0 - max(gridLine.x, gridLine.y);
    return color * mix(vec3(0.2), vec3(1.0), gridMask);
    #else
    return color;
    #endif
}

// --- Core Functions ---
vec3 colorTemperatureToRGB(float temperature) {
    mat3 m = (temperature <= 6500.0) ? mat3(
            0.0, -2902.1955373783176, -8257.7997278925690,
            0.0, 1669.5803561666639, 2575.2827530017594,
            1.0, 1.3302673723350029, 1.8993753891711275
        ) : mat3(
            1745.0425298314172, 1216.6168361476490, -8257.7997278925690,
            -2666.3474220535695, -2173.1012343082230, 2575.2827530017594,
            0.55995389139931482, 0.70381203140554553, 1.8993753891711275
        );
    vec3 result = clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0));
    return mix(result, vec3(1.0), smoothstep(1000.0, 0.0, temperature));
}

// --- Post-Processing Effects ---
float computeVignette(vec2 uv) {
    vec2 coord = (uv - 0.5 - VIGNETTE_OFFSET) * 2.0 * VIGNETTE_ASPECT;
    float dist = length(coord);
    dist = pow(dist, VIGNETTE_EXPONENT);
    return smoothstep(VIGNETTE_RADIUS, VIGNETTE_RADIUS - VIGNETTE_SMOOTHNESS, dist);
}

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

// --- Dual-Axis Tent Blur (mimics separable gaussian) ---
vec3 calculateBloom(vec2 uv) {
    vec3 bloomAccum = vec3(0.0);
    float totalWeight = 0.0;

    // Spatial dithering to break up banding
    float dither = interleavedGradientNoise(uv * vec2(1920.0, 1080.0)) * 2.0 - 1.0;
    float ditherAmount = 0.015; // Subtle dithering

    const int BLUR_PASSES = 6; // More passes with closer spacing
    float blurSizes[BLUR_PASSES];
    blurSizes[0] = BLOOM_RADIUS * 0.3;
    blurSizes[1] = BLOOM_RADIUS * 0.7;
    blurSizes[2] = BLOOM_RADIUS * 1.3;
    blurSizes[3] = BLOOM_RADIUS * 2.2;
    blurSizes[4] = BLOOM_RADIUS * 3.8;
    blurSizes[5] = BLOOM_RADIUS * 5.5;

    for (int pass = 0; pass < BLUR_PASSES; pass++) {
        vec3 passBlur = vec3(0.0);
        float passWeight = 0.0;
        float blurSize = blurSizes[pass];

        // Tent/box blur pattern: sample along axes and diagonals
        // This mimics separable gaussian blur to eliminate shape artifacts
        int samplesPerAxis = BLOOM_RADIAL_SAMPLES;

        // Sample along 8 cardinal/diagonal directions
        for (int dir = 0; dir < 8; dir++) {
            float angle = float(dir) * 0.785398; // 45 degrees each
            vec2 direction = vec2(cos(angle), sin(angle));

            // Multiple samples along each direction (tent blur)
            for (int s = 1; s <= samplesPerAxis; s++) {
                float t = float(s) / float(samplesPerAxis);

                // Apply dithering to sample position to break up banding
                float jitter = dither * ditherAmount * (1.0 / float(samplesPerAxis));
                float radius = blurSize * (t + jitter);

                vec2 sampleUV = uv + direction * radius;
                vec3 sampleColor = texture(tex, sampleUV).rgb;
                float sampleLum = dot(sampleColor, vec3(0.299, 0.587, 0.114));
                float sampleMask = smoothstep(
                        BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                        BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                        sampleLum
                    );

                // Smooth tent filter with power curve to reduce banding
                float tentWeight = pow(1.0 - t, 1.2); // Slightly curved falloff

                // Gaussian falloff for smoother blend
                float sigma = blurSize * 0.9;
                float gaussianWeight = exp(-(radius * radius) / (2.0 * sigma * sigma));

                // Combine weights with smoothstep for band reduction
                float weight = smoothstep(0.0, 1.0, tentWeight * gaussianWeight) * sampleMask;

                passBlur += sampleColor * weight;
                passWeight += weight;
            }
        }

        // Add center sample with high weight to preserve some detail
        vec3 centerColor = texture(tex, uv).rgb;
        float centerLum = dot(centerColor, vec3(0.299, 0.587, 0.114));
        float centerMask = smoothstep(
                BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                centerLum
            );
        float centerWeight = 2.0 * centerMask;
        passBlur += centerColor * centerWeight;
        passWeight += centerWeight;

        if (passWeight > 0.0) {
            passBlur /= passWeight;
        }

        // Smoother pass contribution curve to reduce stepping between passes
        float passContribution = exp(-float(pass) * 0.4);
        bloomAccum += passBlur * passContribution;
        totalWeight += passContribution;
    }

    if (totalWeight > 0.0) {
        bloomAccum /= totalWeight;
    }

    return bloomAccum * BLOOM_INTENSITY * BLOOM_TINT;
}

// --- Enhanced Scanline Effect ---
float applyScanlines(vec2 uv, float time) {
    float scanY = uv.y * SCANLINE_FREQUENCY * 1000.0 + time * SCANLINE_SPEED * 10.0;
    float scan = sin(scanY * PI);

    // Add sharp scanlines
    scan = mix(scan, pow(abs(scan), SCANLINE_SHARPNESS), 0.5);
    scan = smoothstep(1.0 - SCANLINE_THICKNESS, 1.0, scan);

    return 1.0 - scan * SCANLINE_OPACITY;
}

// --- VHS Effect ---
vec3 applyVHSEffect(vec2 uv, float time, vec3 originalColor) {
    #if DEBUG_VHS_OVERLAY
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
    #else
    return originalColor;
    #endif
}

// --- Drift ---
vec2 applyDrift(vec2 uv, float time) {
    vec2 driftOffset = vec2(0.0);
    #if DRIFT_MODE == 0
    float driftAngle = time * DRIFT_SPEED;
    driftOffset = vec2(cos(driftAngle), sin(driftAngle)) * DRIFT_RADIUS;
    #elif DRIFT_MODE == 1
    driftOffset.x = sin(time * DRIFT_SPEED * DRIFT_FREQUENCY) * DRIFT_AMPLITUDE;
    driftOffset.y = cos(time * DRIFT_SPEED * DRIFT_FREQUENCY) * DRIFT_AMPLITUDE;
    #elif DRIFT_MODE == 2
    driftOffset = DRIFT_DIRECTION * (time * DRIFT_SPEED);
    #endif
    return uv + driftOffset;
}

// --- CRT Buzz ---
vec2 applyCRTVibration(vec2 uv, float time) {
    #if DEBUG_VIBRATION
    float buzz = sin(time * VIBRATION_BASE_FREQ) * VIBRATION_AMPLITUDE;
    float line = floor(uv.y * 480.0);
    float noise = (random(vec2(line, time * VIBRATION_NOISE_FREQ)) - 0.5) * VIBRATION_AMPLITUDE * VIBRATION_NOISE_STRENGTH;
    uv.y += buzz + noise;
    #endif
    return uv;
}

// --- Glitch ---
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

// --- Main ---
void main() {
    vec2 originalUV = v_texcoord;
    vec2 processedUV = originalUV;

    // Apply CRT curvature first
    #if DEBUG_CRT_CURVE
    processedUV = applyCRTCurvature(processedUV);
    if (!isValidUV(processedUV)) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    #endif

    // Glitch calculation
    float currentInterval = floor(time / GLITCH_INTERVAL);
    float tInInterval = fract(time / GLITCH_INTERVAL);
    float seedGlitch = random(vec2(currentInterval));
    float intervalActive = step(seedGlitch, GLITCH_PROBABILITY);
    float isActiveGlitch = intervalActive * step(tInInterval, GLITCH_DURATION);

    #if DEBUG_DRIFT
    processedUV = applyDrift(processedUV, time);
    #endif

    #if DEBUG_VIBRATION
    processedUV = applyCRTVibration(processedUV, time);
    #endif

    vec2 pixelatedUV = pixelate(processedUV);

    // Sample color
    float alpha;
    vec3 color;
    #if DEBUG_CA
    color = applyChromaticAberration(pixelatedUV, alpha);
    #else
    vec4 base = texture(tex, pixelatedUV);
    color = base.rgb;
    alpha = base.a;
    #endif

    #if DEBUG_GLITCH
    color = applyAnalogGlitch(pixelatedUV, time, color, isActiveGlitch, tInInterval);
    #endif

    // Calculate screen position for effects
    vec2 screenPos = pixelatedUV * vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE * (VIGNETTE_ASPECT.y / VIGNETTE_ASPECT.x));

    // Apply phosphor glow
    #if DEBUG_PHOSPHOR
    color = calculatePhosphorGlow(pixelatedUV, color);
    #endif

    // Apply halation
    #if DEBUG_HALATION
    color += calculateHalation(pixelatedUV);
    #endif

    color = applyPixelGrid(pixelatedUV, color);

    #if DEBUG_BLOOM
    color += calculateBloom(pixelatedUV);
    #endif

    #if DEBUG_COLOR_TEMP
    color = mix(color, color * colorTemperatureToRGB(COLOR_TEMPERATURE), COLOR_TEMPERATURE_STRENGTH);
    #endif

    // Apply color depth reduction with dithering
    color = applyColorDepthReduction(color, screenPos, time);

    #if DEBUG_SCANLINE
    color *= applyScanlines(originalUV, time);
    #endif

    // Apply shadow mask
    #if DEBUG_SHADOW_MASK
    color = applyShadowMask(screenPos, color);
    #endif

    #if DEBUG_VIGNETTE
    float vig = computeVignette(processedUV);
    #if VIGNETTE_MODE == 0
    color *= mix(1.0 - VIGNETTE_STRENGTH, 1.0, vig);
    #else
    color = mix(color * VIGNETTE_COLOR, color, vig);
    color *= mix(1.0 - VIGNETTE_STRENGTH / 2.0, 1.0, vig);
    #endif
    #endif

    #if DEBUG_VHS_OVERLAY
    color = applyVHSEffect(pixelatedUV, time, color);
    #endif

    #if DEBUG_GRAIN
    color = applyGrain(pixelatedUV, color, time);
    #endif

    // Apply PC-98 palette with advanced dithering if enabled
    #if DEBUG_PC98
    color = applyPC98PaletteWithDither(color, screenPos, time);
    #else
    // Even without PC-98, apply pre-quantization dither to break source gradients
    #if DEBUG_DITHER && DITHER_PRE_QUANTIZE
    color = applyPreQuantizationDither(color, screenPos, time);
    #endif
    #endif

    // Edge fade for CRT
    #if DEBUG_CRT_CURVE
    vec2 edge = smoothstep(vec2(0.0), vec2(CRT_EDGE_FADE), processedUV) * smoothstep(vec2(0.0), vec2(CRT_EDGE_FADE), vec2(1.0) - processedUV);
    float edgeFade = edge.x * edge.y;
    color *= edgeFade;
    #endif

    fragColor = vec4(color, alpha);
}
