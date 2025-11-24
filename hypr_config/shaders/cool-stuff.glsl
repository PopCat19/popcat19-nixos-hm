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
#define DEBUG_CA       0       // Toggle chromatic aberration effect
#define DEBUG_BLOOM    0       // Toggle bloom effect
#define DEBUG_VIGNETTE 0       // Toggle vignette effect
#define DEBUG_PIXEL    1       // Toggle pixelation effect
#define COLOR_DEPTH_ENABLED 0  // Enable color depth reduction
#define DEBUG_SCANLINE 0       // Toggle scanline effect
#define DEBUG_VHS_OVERLAY 0    // Toggle VHS effect
#define DEBUG_GLITCH   0       // Toggle glitch effect
#define DEBUG_DRIFT    0       // Toggle drifting effect
#define DEBUG_COLOR_TEMP 0     // Toggle color temperature adjustment
#define DEBUG_VIBRATION 0      // Toggle CRT buzz vibration effect
#define DEBUG_GRAIN     0      // Toggle cinematic grain effect
#define DEBUG_PC98      1      // Toggle PC-98 color palette mode
#define DEBUG_DITHER    1      // Toggle dithering effect

// [Effect Parameters]
// Bloom Parameters
#define BLOOM_INTENSITY       0.16
#define BLOOM_RADIUS          0.008
#define BLOOM_SAMPLES         64
#define BLOOM_TINT            vec3(1.1, 0.9, 0.9)
#define BLOOM_THRESHOLD       0.0
#define BLOOM_SOFT_THRESHOLD  1.0
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
#define SCANLINE_OPACITY     0.2
#define SCANLINE_FREQUENCY   1.0
#define SCANLINE_SPEED       -1.0
#define SCANLINE_THICKNESS   0.2

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
#define DITHER_MODE 0          // 0=Bayer8x8, 1=Ordered2x2, 2=Blue Noise, 3=Random
#define DITHER_STRENGTH 1.0    // Overall dithering intensity (0.0-1.0)
#define DITHER_COLORS 16       // Number of color levels per channel (2-256)

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
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// --- Grain Effect ---
vec3 applyGrain(vec2 uv, vec3 color, float time) {
#if DEBUG_GRAIN
    float noise = random(uv * GRAIN_SIZE + time * GRAIN_SPEED);
    float grain = (noise - 0.5) * 2.0;
    return mix(color, color + grain * GRAIN_INTENSITY, 0.5);
#else
    return color;
#endif
}

// --- INDEX-PAINTING + PC-98 Color Quantization ---
// This implements "index painting dithering": for each input color we find the
// nearest and second-nearest palette entries and use an ordered/blue-noise
// threshold to choose which index to paint. This preserves palette indexing
// and produces pleasing dither patterns across edges.

float safeDistanceSq(vec3 a, vec3 b) {
    vec3 d = a - b;
    return dot(d, d);
}

// --- Dithering Module ---
// Bayer 8x8 matrix for ordered dithering
const float BAYER_MATRIX_8x8[64] = float[64](
     0.0/64.0, 32.0/64.0,  8.0/64.0, 40.0/64.0,  2.0/64.0, 34.0/64.0, 10.0/64.0, 42.0/64.0,
    48.0/64.0, 16.0/64.0, 56.0/64.0, 24.0/64.0, 50.0/64.0, 18.0/64.0, 58.0/64.0, 26.0/64.0,
    12.0/64.0, 44.0/64.0,  4.0/64.0, 36.0/64.0, 14.0/64.0, 46.0/64.0,  6.0/64.0, 38.0/64.0,
    60.0/64.0, 28.0/64.0, 52.0/64.0, 20.0/64.0, 62.0/64.0, 30.0/64.0, 54.0/64.0, 22.0/64.0,
     3.0/64.0, 35.0/64.0, 11.0/64.0, 43.0/64.0,  1.0/64.0, 33.0/64.0,  9.0/64.0, 41.0/64.0,
    51.0/64.0, 19.0/64.0, 59.0/64.0, 27.0/64.0, 49.0/64.0, 17.0/64.0, 57.0/64.0, 25.0/64.0,
    15.0/64.0, 47.0/64.0,  7.0/64.0, 39.0/64.0, 13.0/64.0, 45.0/64.0,  5.0/64.0, 37.0/64.0,
    63.0/64.0, 31.0/64.0, 55.0/64.0, 23.0/64.0, 61.0/64.0, 29.0/64.0, 53.0/64.0, 21.0/64.0
);

// Ordered 2x2 matrix (simpler pattern)
const float ORDERED_MATRIX_2x2[4] = float[4](
    0.0/4.0, 2.0/4.0,
    3.0/4.0, 1.0/4.0
);

// Get Bayer matrix threshold value
float getBayerThreshold(vec2 screenPos) {
    // mod with 8.0, ensure positive indices
    ivec2 pos = ivec2(int(mod(screenPos.x, 8.0)), int(mod(screenPos.y, 8.0)));
    // ensure indices in [0..7]
    pos = ivec2((pos.x + 8) % 8, (pos.y + 8) % 8);
    int index = pos.y * 8 + pos.x;
    return BAYER_MATRIX_8x8[index];
}

// Get ordered 2x2 threshold value
float getOrderedThreshold(vec2 screenPos) {
    ivec2 pos = ivec2(int(mod(screenPos.x, 2.0)), int(mod(screenPos.y, 2.0)));
    pos = ivec2((pos.x + 2) % 2, (pos.y + 2) % 2);
    int index = pos.y * 2 + pos.x;
    return ORDERED_MATRIX_2x2[index];
}

// Blue noise approximation using hash function
float blueNoise(vec2 coord) {
    vec2 p = floor(coord);
    float n = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    vec2 f = fract(coord);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(n, fract(sin(dot(p + vec2(1.0, 0.0), vec2(12.9898, 78.233))) * 43758.5453), f.x),
        mix(fract(sin(dot(p + vec2(0.0, 1.0), vec2(12.9898, 78.233))) * 43758.5453),
            fract(sin(dot(p + vec2(1.0, 1.0), vec2(12.9898, 78.233))) * 43758.5453), f.x),
        f.y
    );
}

// Get threshold depending on chosen DITHER_MODE
float getDitherThreshold(vec2 screenPos, float t) {
    #if DITHER_MODE == 0
        return getBayerThreshold(screenPos);
    #elif DITHER_MODE == 1
        return getOrderedThreshold(screenPos);
    #elif DITHER_MODE == 2
        return blueNoise(screenPos * 0.5 + t);
    #else
        return random(screenPos + t);
    #endif
}

// Apply index-painting dithering using the PC98 palette
vec3 applyIndexPaintingDither(vec3 color, vec2 screenPos, float t) {
    // Find nearest and second-nearest palette colors (by squared distance)
    int idxNearest = 0;
    int idxSecond = 0;
    float best = 1e20;
    float second = 1e20;
    for (int i = 0; i < PC98_PALETTE_SIZE; ++i) {
        float d = safeDistanceSq(color, PC98_PALETTE[i]);
        if (d < best) {
            second = best;
            idxSecond = idxNearest;
            best = d;
            idxNearest = i;
        } else if (d < second) {
            second = d;
            idxSecond = i;
        }
    }

    // If colors are identical (rare), just return the nearest
    if (second <= 0.0) {
        return PC98_PALETTE[idxNearest];
    }

    // Compute a normalized closeness factor: w in [0,1]
    // smaller w -> color much closer to nearest; larger w -> closer to second
    float w = best / (best + second); // in [0,1], small => strongly nearest

    // Get spatial threshold
    float threshold = getDitherThreshold(screenPos, t);
    // Apply strength and remap threshold so 0.5 is neutral
    threshold = (threshold - 0.5) * DITHER_STRENGTH + 0.5;

    // If closeness (w) is larger than threshold -> pick second, else pick nearest.
    // This produces a pattern where pixels near the boundary choose the alternate index
    // depending on the ordered/blue-noise pattern.
    if (w > threshold) {
        return PC98_PALETTE[idxSecond];
    } else {
        return PC98_PALETTE[idxNearest];
    }
}

// --- Dither-compatible PC-98 palette application ---
// Replaces the simpler nearest-color mapping with index-painting when dithering enabled.
vec3 applyPC98Palette(vec3 color, vec2 screenPos, float t) {
#if DEBUG_PC98 && DEBUG_DITHER
    return applyIndexPaintingDither(color, screenPos, t);
#elif DEBUG_PC98
    // Fallback: nearest-color quantization (no index painting)
    float minDistance = 999999.0;
    vec3 closestColor = color;
    for (int i = 0; i < PC98_PALETTE_SIZE; i++) {
        vec3 paletteColor = PC98_PALETTE[i];
        vec3 diff = color - paletteColor;
        float distance = dot(diff, diff);
        if (distance < minDistance) {
            minDistance = distance;
            closestColor = paletteColor;
        }
    }
    return closestColor;
#else
    return color;
#endif
}

// --- Apply dithering to color (channel-wise fallback) ---
vec3 applyDither(vec2 uv, vec3 color, float time) {
#if DEBUG_DITHER
    // Calculate screen position for dither pattern
    vec2 screenPos = uv * vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE * (VIGNETTE_ASPECT.y / VIGNETTE_ASPECT.x));
    
    // Adjust threshold by dither strength: handled inside getDitherThreshold / painting function
    
    // Quantize colors with dithering per-channel (fallback path if not using palette index painting)
    float threshold = getDitherThreshold(screenPos, time);
    threshold = (threshold - 0.5) * DITHER_STRENGTH + 0.5;
    
    float levels = float(DITHER_COLORS);
    vec3 quantized = floor(color * levels) / levels;
    vec3 nextLevel = ceil(color * levels) / levels;
    
    vec3 dithered;
    dithered.r = (fract(color.r * levels) > threshold) ? nextLevel.r : quantized.r;
    dithered.g = (fract(color.g * levels) > threshold) ? nextLevel.g : quantized.g;
    dithered.b = (fract(color.b * levels) > threshold) ? nextLevel.b : quantized.b;
    
    return dithered;
#else
    return color;
#endif
}

// --- Color Depth Reduction ---
vec3 applyColorDepthReduction(vec3 color) {
#if COLOR_DEPTH_ENABLED
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
    vec3 maxValues = pow(vec3(2.0), vec3(bits)) - 1.0;
    return floor(color * maxValues + 0.5) / maxValues;
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

// --- Bloom ---
vec3 calculateBloom(vec2 uv) {
    vec3 color = vec3(0.0);
    float total = 0.0;
    const float goldenAngle = 2.39996;
    float currentAngle = 0.0;

    const int SCALES = 3;
    float scaleRadius[SCALES];
    scaleRadius[0] = BLOOM_RADIUS * 0.5;
    scaleRadius[1] = BLOOM_RADIUS * 1.5;
    scaleRadius[2] = BLOOM_RADIUS * 3.0;

    for (int s = 0; s < SCALES; s++) {
        for (int i = 0; i < BLOOM_SAMPLES / SCALES; i++) {
            float ratio = sqrt(float(i) / float(BLOOM_SAMPLES / SCALES));
            float radius = ratio * scaleRadius[s];
            currentAngle += goldenAngle;
            vec2 dir = vec2(cos(currentAngle), sin(currentAngle)) * radius;
            vec2 sampleUV = uv + dir;

            vec3 sampleColor = texture(tex, sampleUV).rgb;
            float luminance = dot(sampleColor, vec3(0.299, 0.587, 0.114));

            float softThreshold = smoothstep(
                BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                luminance
            );

            float weight = exp(-(radius * radius) * BLOOM_FALLOFF_CURVE) * softThreshold;
            color += sampleColor * weight;
            total += weight;
        }
    }

    return (color / max(total, 0.001)) * BLOOM_INTENSITY * BLOOM_TINT;
}

// --- Scanline Effect ---
float applyScanlines(vec2 uv, float time) {
    float scan = sin(uv.y * SCANLINE_FREQUENCY * PI + time * SCANLINE_SPEED);
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
        texture(tex, uv + vec2( VHS_COLOR_SHIFT, 0.0)).r,
        texture(tex, uv).g,
        texture(tex, uv - vec2( VHS_COLOR_SHIFT, 0.0)).b
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
    float noise = (random(vec2(line, time * VIBRATION_NOISE_FREQ)) - 0.5) 
                  * VIBRATION_AMPLITUDE * VIBRATION_NOISE_STRENGTH;
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
        texture(tex, uv + vec2( shift, 0.0)).r,
        texture(tex, uv).g,
        texture(tex, uv - vec2( shift, 0.0)).b
    );
    return mix(color, analogColor, strength);
}

// --- Main ---
void main() {
    float alpha;
    vec3 color;
    vec2 processedUV = v_texcoord;

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

    processedUV = pixelate(processedUV);

    #if DEBUG_CA
        color = applyChromaticAberration(processedUV, alpha);
    #else
        vec4 base = texture(tex, processedUV);
        color = base.rgb;
        alpha = base.a;
    #endif

    #if DEBUG_GLITCH
        color = applyAnalogGlitch(processedUV, time, color, isActiveGlitch, tInInterval);
    #endif

    color = applyPixelGrid(processedUV, color);

    #if DEBUG_BLOOM
        color += calculateBloom(processedUV);
    #endif

    #if DEBUG_COLOR_TEMP
        color = mix(color, color * colorTemperatureToRGB(COLOR_TEMPERATURE), COLOR_TEMPERATURE_STRENGTH);
    #endif

    color = applyColorDepthReduction(color);

    #if DEBUG_SCANLINE
        color *= applyScanlines(v_texcoord, time);
    #endif

    #if DEBUG_VIGNETTE
        float vig = computeVignette(processedUV);
        #if VIGNETTE_MODE == 0
            color *= mix(1.0 - VIGNETTE_STRENGTH, 1.0, vig);
        #else
            color = mix(color * VIGNETTE_COLOR, color, vig);
            color *= mix(1.0 - VIGNETTE_STRENGTH/2.0, 1.0, vig);
        #endif
    #endif

    #if DEBUG_VHS_OVERLAY
        color = applyVHSEffect(processedUV, time, color);
    #endif

    #if DEBUG_GRAIN
        color = applyGrain(processedUV, color, time);
    #endif

    // Apply channel-wise dithering if not using palette-index painting,
    // but if PC98 palette + dithering are enabled, apply index-painting
    #if DEBUG_PC98
        // For index-painting we need a consistent "screen position" for thresholding.
        vec2 screenPos = processedUV * vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE * (VIGNETTE_ASPECT.y / VIGNETTE_ASPECT.x));
        color = applyPC98Palette(color, screenPos, time);
    #else
        #if DEBUG_DITHER
            color = applyDither(processedUV, color, time);
        #endif
    #endif

    fragColor = vec4(color, alpha);
}
