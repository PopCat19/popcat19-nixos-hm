#version 320 es
precision highp float;

// =============================================================================
// CRT Post-Processing Fragment Shader
//
// Purpose: Apply retro CRT/VHS aesthetics with configurable post-processing.
// Rationale: Modular effect pipeline enables mix-and-match visual styles.
// Related: Vertex shader providing v_texcoord
//
// Note: Requires ES 3.2+; bloom is expensive at high sample counts.
// =============================================================================

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform float time;

// =============================================================================
// Toggles
// Purpose: Enable/disable individual effects.
// =============================================================================

#define ENABLE_CA              1
#define ENABLE_BLOOM           1
#define ENABLE_PIXEL           0
#define ENABLE_SCANLINE        1
#define ENABLE_VHS             0
#define ENABLE_GLITCH          1
#define ENABLE_COLOR_TEMP      0
#define ENABLE_VIBRATION       1
#define ENABLE_INTERLACE       1
#define ENABLE_VIGNETTE        0
#define ENABLE_FILM_GRAIN      1
#define ENABLE_CRT_MASK        1
#define ENABLE_COLOR_BLEED     1
#define ENABLE_PHOSPHOR_DECAY  1
#define ENABLE_DITHER          1
#define ENABLE_SHARPEN         1
#define ENABLE_COLOR_GRADING   1
#define ENABLE_FLICKER         1
#define ENABLE_TAPE_CREASE     1

// =============================================================================
// Constants
// =============================================================================

const float PI = 3.14159265359;
const float TAU = 6.28318530718;
const float GOLDEN_ANGLE = 2.39996;
const vec3 LUMA_WEIGHTS = vec3(0.299, 0.587, 0.114);
const vec3 LUMA_WEIGHTS_REC709 = vec3(0.2126, 0.7152, 0.0722);

// =============================================================================
// Effect Parameters
// Purpose: Centralized tuning knobs grouped by effect.
// Rationale: Easier iteration; avoids hunting for magic numbers.
// =============================================================================

// --- Bloom ---
const float BLOOM_INTENSITY      = 0.16;
const float BLOOM_RADIUS         = 0.008;
const int   BLOOM_SAMPLES        = 64;
const vec3  BLOOM_TINT           = vec3(1.1, 0.9, 0.9);
const float BLOOM_THRESHOLD      = 0.0;
const float BLOOM_SOFT_THRESHOLD = 1.0;
const float BLOOM_FALLOFF        = 32.0;
const int   BLOOM_SCALES         = 3;

// --- Glitch ---
const float GLITCH_STRENGTH    = 1.0;
const float GLITCH_PROBABILITY = 0.20;
const float GLITCH_INTERVAL    = 3.0;
const float GLITCH_DURATION    = 0.12;
const float GLITCH_SPEED       = 64.0;

// --- Chromatic Aberration ---
const float CA_RED_STRENGTH     = 0.001;
const float CA_BLUE_STRENGTH    = 0.001;
const float CA_FALLOFF          = 1.0;
const float CA_ANGLE            = 0.0;
const float CA_FALLOFF_EXPONENT = 1.0;
const float CA_CENTER_STRENGTH  = 3.0;

// --- Scanlines ---
const float SCANLINE_OPACITY   = 0.02;
const float SCANLINE_FREQUENCY = 0.8;
const float SCANLINE_SPEED     = 1.0;
const float SCANLINE_THICKNESS = 0.02;

// --- CRT Vibration ---
const float VIBRATION_AMPLITUDE      = 0.0004;
const float VIBRATION_BASE_FREQ      = 75.0;
const float VIBRATION_NOISE_FREQ     = 8.0;
const float VIBRATION_NOISE_STRENGTH = 0.4;

// --- Color ---
const float COLOR_TEMPERATURE     = 4000.0;
const float COLOR_TEMPERATURE_MIX = 1.0;

// --- Pixelation ---
const float PIXEL_GRID_SIZE = 960.0;

// --- VHS ---
const float VHS_INTENSITY           = 0.16;
const float VHS_JITTER_STRENGTH     = 0.004;
const float VHS_WAVE_FREQ           = 2.0;
const float VHS_WAVE_AMPLITUDE      = 0.003;
const float VHS_COLOR_SHIFT         = 0.0015;
const float VHS_NOISE_BAND_FREQ     = 0.0;//.8;
const float VHS_NOISE_BAND_STRENGTH = 0.0;//.25;

// --- Interlace ---
const float INTERLACE_STRENGTH = 0.1;
const float INTERLACE_LINES    = 480.0;

// --- Vignette ---
const float VIGNETTE_INTENSITY  = 0.1;
const float VIGNETTE_RADIUS     = 0.75;
const float VIGNETTE_SOFTNESS   = 0.45;
const vec3  VIGNETTE_COLOR      = vec3(0.0, 0.0, 0.0);
const float VIGNETTE_ROUNDNESS  = 1.0;

// --- Film Grain ---
const float GRAIN_INTENSITY     = 0.08;
const float GRAIN_SIZE          = 1.6;
const float GRAIN_SPEED         = 15.0;
const float GRAIN_LUMA_AMOUNT   = 0.7;
const float GRAIN_CHROMA_AMOUNT = 0.3;

// --- CRT Mask ---
const int   MASK_TYPE          = 1;
const float MASK_STRENGTH      = 0.12;
const float MASK_SIZE          = 1.0;
const vec3  MASK_COLOR_R       = vec3(1.0, 0.0, 0.0);
const vec3  MASK_COLOR_G       = vec3(0.0, 1.0, 0.0);
const vec3  MASK_COLOR_B       = vec3(0.0, 0.0, 1.0);

// --- Color Bleeding ---
const float BLEED_STRENGTH     = 0.4;
const float BLEED_DISTANCE     = 0.003;
const int   BLEED_SAMPLES      = 8;

// --- Phosphor Decay ---
const float PHOSPHOR_PERSISTENCE = 0.88;
const vec3  PHOSPHOR_COLOR       = vec3(0.4, 1.0, 0.4);

// --- Dither ---
const float DITHER_STRENGTH    = 0.1;
const float DITHER_LEVELS      = 16.0;

// --- Sharpen ---
const float SHARPEN_STRENGTH   = 1.0;

// --- Color Grading ---
const float GRADE_CONTRAST     = 1.0;
const float GRADE_BRIGHTNESS   = 0.0;
const float GRADE_SATURATION   = 1.12;
const float GRADE_GAMMA        = 1.0;
const vec3  GRADE_LIFT         = vec3(0.0, 0.0, 0.02);
const vec3  GRADE_GAIN         = vec3(1.0, 0.98, 0.96);
const vec3  GRADE_OFFSET       = vec3(0.0);

// --- Flicker ---
const float FLICKER_INTENSITY  = 0.02;
const float FLICKER_SPEED      = 16.0;

// --- Tape Crease ---
const float CREASE_PROBABILITY = 0.01;
const float CREASE_WIDTH       = 0.02;
const float CREASE_INTENSITY   = 0.4;

// =============================================================================
// Utility Functions
// Purpose: Shared primitives to reduce duplication.
// =============================================================================

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

float hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash3(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

// =============================================================================
// Improved Hash Function
// Purpose: Higher quality randomness to prevent tiling patterns.
// =============================================================================
float hash31(vec3 p3) {
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float luminance(vec3 c) {
    return dot(c, LUMA_WEIGHTS);
}

float luminanceRec709(vec3 c) {
    return dot(c, LUMA_WEIGHTS_REC709);
}

vec3 sampleTex(vec2 uv) {
    return texture(tex, uv).rgb;
}

vec4 sampleTexA(vec2 uv) {
    return texture(tex, uv);
}

vec3 sampleSeparated(vec2 uvR, vec2 uvG, vec2 uvB) {
    return vec3(
        texture(tex, uvR).r,
        texture(tex, uvG).g,
        texture(tex, uvB).b
    );
}

vec2 computeGridSize() {
    return vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE);
}

// Attempt to infer resolution from derivatives (approximation)
vec2 getResolution() {
    vec2 dx = dFdx(v_texcoord);
    vec2 dy = dFdy(v_texcoord);
    return 1.0 / vec2(length(dx), length(dy));
}

float smootherstep(float edge0, float edge1, float x) {
    x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Attempt at perlin-ish noise
float valueNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; i++) {
        value += amplitude * valueNoise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

// =============================================================================
// UV Transformation Effects
// Purpose: Modify UV coordinates before sampling.
// Rationale: Applied first in pipeline to affect all subsequent reads.
// =============================================================================

vec2 applyPixelate(vec2 uv) {
#if ENABLE_PIXEL
    vec2 grid = computeGridSize();
    return floor(uv * grid) / grid;
#else
    return uv;
#endif
}

// =============================================================================
// Color Manipulation Effects
// Purpose: Transform color values post-sampling.
// =============================================================================

vec3 colorTemperatureToRGB(float temp) {
    mat3 m = (temp <= 6500.0) ? mat3(
        0.0, -2902.1955373783176, -8257.7997278925690,
        0.0, 1669.5803561666639, 2575.2827530017594,
        1.0, 1.3302673723350029, 1.8993753891711275
    ) : mat3(
        1745.0425298314172, 1216.6168361476490, -8257.7997278925690,
        -2666.3474220535695, -2173.1012343082230, 2575.2827530017594,
        0.55995389139931482, 0.70381203140554553, 1.8993753891711275
    );

    float clamped = clamp(temp, 1000.0, 40000.0);
    vec3 result = clamp(m[0] / (vec3(clamped) + m[1]) + m[2], 0.0, 1.0);
    return mix(result, vec3(1.0), smoothstep(1000.0, 0.0, temp));
}

vec3 applyColorTemperature(vec3 color) {
#if ENABLE_COLOR_TEMP
    return mix(color, color * colorTemperatureToRGB(COLOR_TEMPERATURE), COLOR_TEMPERATURE_MIX);
#else
    return color;
#endif
}

vec3 applyColorGrading(vec3 color) {
#if ENABLE_COLOR_GRADING
    // Lift/Gamma/Gain
    color = pow(max(color, 0.0), vec3(1.0 / GRADE_GAMMA));
    color = color * GRADE_GAIN + GRADE_LIFT;
    color = color + GRADE_OFFSET;

    // Contrast around midpoint
    color = (color - 0.5) * GRADE_CONTRAST + 0.5;

    // Brightness
    color += GRADE_BRIGHTNESS;

    // Saturation
    float lum = luminance(color);
    color = mix(vec3(lum), color, GRADE_SATURATION);

    return clamp(color, 0.0, 1.0);
#else
    return color;
#endif
}

// =============================================================================
// Chromatic Aberration
// Purpose: Simulate lens color fringing for analog feel.
// Rationale: Radial falloff mimics real lens behavior.
// =============================================================================

vec3 applyChromaticAberration(vec2 uv, out float alpha) {
#if ENABLE_CA
    vec2 dir = (uv - 0.5) * CA_FALLOFF;

    float cosA = cos(CA_ANGLE);
    float sinA = sin(CA_ANGLE);
    dir = vec2(dir.x * cosA - dir.y * sinA, dir.x * sinA + dir.y * cosA);

    float dist = length(dir);
    float edge = pow(dist, CA_FALLOFF_EXPONENT);
    float center = (1.0 - edge) * CA_CENTER_STRENGTH;
    float falloff = edge + center;

    float rStr = falloff * CA_RED_STRENGTH;
    float bStr = falloff * CA_BLUE_STRENGTH;

    vec2 uvR = uv + dir * rStr;
    vec2 uvG = uv;
    vec2 uvB = uv - dir * bStr;

    alpha = texture(tex, uv).a;
    return sampleSeparated(uvR, uvG, uvB);
#else
    vec4 s = sampleTexA(uv);
    alpha = s.a;
    return s.rgb;
#endif
}

// =============================================================================
// Bloom Effect
// Purpose: Add soft glow around bright areas.
// Rationale: Multi-scale sampling creates natural light diffusion.
// =============================================================================

vec3 calculateBloom(vec2 uv) {
#if ENABLE_BLOOM
    vec3 result = vec3(0.0);
    float totalWeight = 0.0;
    float angle = 0.0;

    float radii[3];
    radii[0] = BLOOM_RADIUS * 0.5;
    radii[1] = BLOOM_RADIUS * 1.5;
    radii[2] = BLOOM_RADIUS * 3.0;

    int samplesPerScale = BLOOM_SAMPLES / BLOOM_SCALES;

    for (int s = 0; s < BLOOM_SCALES; s++) {
        for (int i = 0; i < samplesPerScale; i++) {
            float ratio = sqrt(float(i) / float(samplesPerScale));
            float r = ratio * radii[s];
            angle += GOLDEN_ANGLE;

            vec2 offset = vec2(cos(angle), sin(angle)) * r;
            vec3 sample_ = sampleTex(uv + offset);

            float lum = luminance(sample_);
            float threshold = smoothstep(
                BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                lum
            );

            float weight = exp(-r * r * BLOOM_FALLOFF) * threshold;
            result += sample_ * weight;
            totalWeight += weight;
        }
    }

    return (result / max(totalWeight, 0.001)) * BLOOM_INTENSITY * BLOOM_TINT;
#else
    return vec3(0.0);
#endif
}

// =============================================================================
// Scanline & Interlace Effects
// Purpose: Simulate CRT display artifacts.
// =============================================================================

float applyScanlines(vec2 uv, float t) {
#if ENABLE_SCANLINE
    float scan = sin(uv.y * SCANLINE_FREQUENCY * PI - t * SCANLINE_SPEED);
    scan = smoothstep(1.0 - SCANLINE_THICKNESS, 1.0, scan);
    return 1.0 - scan * SCANLINE_OPACITY;
#else
    return 1.0;
#endif
}

float applyInterlace(vec2 uv, float t) {
#if ENABLE_INTERLACE
    float line = floor(uv.y * INTERLACE_LINES);
    float frame = floor(t * 60.0);
    float odd = mod(line + frame, 2.0);
    return 1.0 - odd * INTERLACE_STRENGTH;
#else
    return 1.0;
#endif
}

// =============================================================================
// CRT Mask Effect
// Purpose: Simulate CRT shadow mask or aperture grille.
// Rationale: Real CRTs have RGB phosphor patterns visible at close range.
// =============================================================================

vec3 applyCRTMask(vec2 uv, vec3 color) {
#if ENABLE_CRT_MASK
    vec2 res = getResolution();
    vec2 pixelCoord = uv * res / MASK_SIZE;

    vec3 mask;

    if (MASK_TYPE == 0) {
        // Shadow mask (triad pattern)
        float phase = mod(floor(pixelCoord.x) + floor(pixelCoord.y) * 0.5, 3.0);
        if (phase < 1.0) mask = vec3(1.0, 0.0, 0.0);
        else if (phase < 2.0) mask = vec3(0.0, 1.0, 0.0);
        else mask = vec3(0.0, 0.0, 1.0);
    } else if (MASK_TYPE == 1) {
        // Aperture grille (vertical stripes)
        float phase = mod(floor(pixelCoord.x), 3.0);
        if (phase < 1.0) mask = MASK_COLOR_R;
        else if (phase < 2.0) mask = MASK_COLOR_G;
        else mask = MASK_COLOR_B;
    } else {
        // Slot mask
        vec2 slot = mod(pixelCoord, vec2(3.0, 2.0));
        float phase = mod(floor(slot.x) + floor(slot.y), 3.0);
        if (phase < 1.0) mask = vec3(1.0, 0.0, 0.0);
        else if (phase < 2.0) mask = vec3(0.0, 1.0, 0.0);
        else mask = vec3(0.0, 0.0, 1.0);
    }

    mask = mix(vec3(1.0), mask, MASK_STRENGTH);
    return color * mask;
#else
    return color;
#endif
}

// =============================================================================
// Pixel Grid Overlay
// Purpose: Draw visible pixel boundaries for retro look.
// =============================================================================

vec3 applyPixelGrid(vec2 uv, vec3 color) {
#if ENABLE_PIXEL
    vec2 grid = computeGridSize();
    vec2 pixelCoord = uv * grid;
    vec2 gridLine = smoothstep(0.95, 0.99, fract(pixelCoord));
    float gridMask = 1.0 - max(gridLine.x, gridLine.y);
    return color * mix(vec3(0.2), vec3(1.0), gridMask);
#else
    return color;
#endif
}

// =============================================================================
// Vignette Effect
// Purpose: Darken screen edges to simulate camera/CRT falloff.
// Rationale: Real displays and cameras have natural edge darkening.
// =============================================================================

vec3 applyVignette(vec2 uv, vec3 color) {
#if ENABLE_VIGNETTE
    vec2 centered = (uv - 0.5) * 2.0;

    // Adjust for roundness
    float dist;
    if (VIGNETTE_ROUNDNESS >= 1.0) {
        dist = length(centered);
    } else {
        vec2 adjusted = pow(abs(centered), vec2(2.0 / max(VIGNETTE_ROUNDNESS, 0.01)));
        dist = pow(adjusted.x + adjusted.y, 0.5);
    }

    float vignette = smoothstep(VIGNETTE_RADIUS, VIGNETTE_RADIUS - VIGNETTE_SOFTNESS, dist);
    vignette = 1.0 - (1.0 - vignette) * VIGNETTE_INTENSITY;

    return mix(VIGNETTE_COLOR, color, vignette);
#else
    return color;
#endif
}

// =============================================================================
// Film Grain Effect
// Purpose: Add organic film-like noise texture without visible tiling.
// =============================================================================

vec3 applyFilmGrain(vec2 uv, float t, vec3 color) {
#if ENABLE_FILM_GRAIN
    vec2 res = getResolution();

    // Use a wrapped time for the frame seed
    float frameTime = floor(mod(t, 1000.0) * GRAIN_SPEED);

    // Generate a large random offset per frame
    // This moves the "grain grid" so the eye can't see the tiling
    vec2 jitter = hash22(vec2(frameTime)) * 100.0;

    // Scale by resolution to keep grain size consistent regardless of aspect ratio
    vec2 grainUV = (uv * res) / max(GRAIN_SIZE, 0.1) + jitter;

    // Sample luminance grain using the improved hash
    float grain = hash31(vec3(grainUV, frameTime));

    // Calculate chroma noise (optional, but adds to the look)
    vec3 chromaGrain = vec3(
        hash31(vec3(grainUV + 0.1, frameTime)),
        hash31(vec3(grainUV + 0.2, frameTime)),
        hash31(vec3(grainUV + 0.3, frameTime))
    );

    // Natural Response: Apply less grain in very bright areas (film highlights)
    float lum = luminance(color);
    float grainResponse = 1.0 - pow(lum, 2.0);

    // Apply luma grain
    color += (grain - 0.5) * GRAIN_INTENSITY * GRAIN_LUMA_AMOUNT * grainResponse;

    // Apply chroma grain
    color += (chromaGrain - 0.5) * GRAIN_INTENSITY * GRAIN_CHROMA_AMOUNT * grainResponse;

    return clamp(color, 0.0, 1.0);
#else
    return color;
#endif
}

// =============================================================================
// Color Bleeding Effect
// Purpose: Simulate chroma bleeding from analog signal limitations.
// Rationale: Composite video has limited color bandwidth causing bleed.
// =============================================================================

vec3 applyColorBleed(vec2 uv, vec3 color) {
#if ENABLE_COLOR_BLEED
    vec3 bleed = vec3(0.0);

    for (int i = 1; i <= BLEED_SAMPLES; i++) {
        float offset = float(i) * BLEED_DISTANCE / float(BLEED_SAMPLES);
        bleed += sampleTex(uv - vec2(offset, 0.0));
    }
    bleed /= float(BLEED_SAMPLES);

    // Only bleed chroma, preserve luma
    float originalLuma = luminance(color);
    vec3 bleedChroma = bleed - vec3(luminance(bleed));
    vec3 originalChroma = color - vec3(originalLuma);

    vec3 mixedChroma = mix(originalChroma, bleedChroma, BLEED_STRENGTH);
    return vec3(originalLuma) + mixedChroma;
#else
    return color;
#endif
}

// =============================================================================
// Phosphor Decay Effect
// Purpose: Simulate the characteristic green phosphor glow of old monitors.
// Rationale: Monochrome CRTs often had P1 or P31 green phosphors.
// =============================================================================

vec3 applyPhosphorDecay(vec3 color) {
#if ENABLE_PHOSPHOR_DECAY
    float lum = luminance(color);
    vec3 phosphor = PHOSPHOR_COLOR * lum;
    return mix(color, phosphor, 1.0 - PHOSPHOR_PERSISTENCE);
#else
    return color;
#endif
}

// =============================================================================
// Dithering Effect
// Purpose: Apply ordered dithering for retro low-color look.
// Rationale: Old displays used dithering to simulate more colors.
// =============================================================================

vec3 applyDithering(vec2 uv, vec3 color) {
#if ENABLE_DITHER
    vec2 res = getResolution();
    vec2 pixel = floor(uv * res);

    // 4x4 Bayer matrix
    int x = int(mod(pixel.x, 4.0));
    int y = int(mod(pixel.y, 4.0));

    float bayer[16];
    bayer[0] = 0.0; bayer[1] = 8.0; bayer[2] = 2.0; bayer[3] = 10.0;
    bayer[4] = 12.0; bayer[5] = 4.0; bayer[6] = 14.0; bayer[7] = 6.0;
    bayer[8] = 3.0; bayer[9] = 11.0; bayer[10] = 1.0; bayer[11] = 9.0;
    bayer[12] = 15.0; bayer[13] = 7.0; bayer[14] = 13.0; bayer[15] = 5.0;

    float threshold = (bayer[y * 4 + x] / 16.0 - 0.5) * DITHER_STRENGTH;

    color += threshold;
    color = floor(color * DITHER_LEVELS + 0.5) / DITHER_LEVELS;

    return clamp(color, 0.0, 1.0);
#else
    return color;
#endif
}

// =============================================================================
// Sharpen Effect
// Purpose: Enhance edge definition for crisper image.
// Rationale: Counter softness from other effects or low-res sources.
// =============================================================================

vec3 applySharpen(vec2 uv, vec3 color) {
#if ENABLE_SHARPEN
    vec2 texelSize = 1.0 / getResolution();

    vec3 blur = sampleTex(uv + vec2(-texelSize.x, 0.0)) +
                sampleTex(uv + vec2(texelSize.x, 0.0)) +
                sampleTex(uv + vec2(0.0, -texelSize.y)) +
                sampleTex(uv + vec2(0.0, texelSize.y));
    blur *= 0.25;

    vec3 sharpened = color + (color - blur) * SHARPEN_STRENGTH;
    return clamp(sharpened, 0.0, 1.0);
#else
    return color;
#endif
}

// =============================================================================
// Flicker Effect
// Purpose: Simulate CRT brightness fluctuation.
// Rationale: Old CRTs had visible flicker, especially at low refresh rates.
// =============================================================================

vec3 applyFlicker(float t, vec3 color) {
#if ENABLE_FLICKER
    float flicker = 1.0 - FLICKER_INTENSITY * 0.5 +
                    sin(t * FLICKER_SPEED * TAU) * FLICKER_INTENSITY * 0.5;
    flicker += (hash(vec2(t * 100.0, 0.0)) - 0.5) * FLICKER_INTENSITY * 0.3;
    return color * flicker;
#else
    return color;
#endif
}

// =============================================================================
// Tape Crease Effect
// Purpose: Simulate horizontal distortion from damaged VHS tape.
// Rationale: Physical tape damage causes horizontal line artifacts.
// =============================================================================

vec3 applyTapeCrease(vec2 uv, float t, vec3 color, out vec2 distortedUV) {
#if ENABLE_TAPE_CREASE
    distortedUV = uv;
    float creaseCheck = hash(vec2(floor(t * 10.0), 0.0));

    if (creaseCheck < CREASE_PROBABILITY) {
        float creaseY = hash(vec2(floor(t * 5.0), 1.0));
        float dist = abs(uv.y - creaseY);

        if (dist < CREASE_WIDTH) {
            float creaseFactor = 1.0 - dist / CREASE_WIDTH;
            creaseFactor = pow(creaseFactor, 2.0);

            distortedUV.x += creaseFactor * 0.1 * sin(t * 100.0);
            color = mix(color, vec3(1.0), creaseFactor * CREASE_INTENSITY);
        }
    }
    return color;
#else
    distortedUV = uv;
    return color;
#endif
}

// =============================================================================
// VHS Effect
// Purpose: Simulate magnetic tape playback artifacts.
// Rationale: Combines jitter, wave distortion, and horizontal noise bands.
// =============================================================================

vec3 applyVHSEffect(vec2 uv, float t, vec3 original) {
#if ENABLE_VHS
    // Horizontal jitter
    float jitter = (hash(vec2(t, uv.y)) - 0.5) * VHS_JITTER_STRENGTH;
    vec2 distorted = uv + vec2(jitter, 0.0);

    // Wave distortion
    distorted.y += sin(distorted.x * VHS_WAVE_FREQ + t * 1.5) * VHS_WAVE_AMPLITUDE;

    // Color separation
    vec3 vhsColor = sampleSeparated(
        distorted + vec2(VHS_COLOR_SHIFT, 0.0),
        distorted,
        distorted - vec2(VHS_COLOR_SHIFT, 0.0)
    );

    // Horizontal noise bands
    float bandNoise = step(1.0 - VHS_NOISE_BAND_FREQ, hash(vec2(t, floor(uv.y * 480.0))));
    if (bandNoise > 0.5) {
        float noise = (hash(uv * t) - 0.5) * VHS_NOISE_BAND_STRENGTH;
        vhsColor += noise;
    }

    return mix(original, vhsColor, VHS_INTENSITY);
#else
    return original;
#endif
}

// =============================================================================
// Glitch Effect
// Purpose: Create periodic analog distortion bursts.
// Rationale: Probability-based triggering with bounce envelope.
// =============================================================================

struct GlitchState {
    float isActive;
    float tInInterval;
};

GlitchState computeGlitchState(float t) {
    float interval = floor(t / GLITCH_INTERVAL);
    float tIn = fract(t / GLITCH_INTERVAL);
    float seed = hash(vec2(interval, 0.0));
    float intervalActive = step(seed, GLITCH_PROBABILITY);

    GlitchState state;
    state.isActive = intervalActive * step(tIn, GLITCH_DURATION);
    state.tInInterval = tIn;
    return state;
}

vec3 applyAnalogGlitch(vec2 uv, float t, vec3 color, GlitchState state) {
#if ENABLE_GLITCH
    if (state.isActive < 0.5) return color;

    float bounce = sin(state.tInInterval * GLITCH_SPEED * PI);
    float strength = GLITCH_STRENGTH * bounce;

    // Horizontal tear lines
    float line = floor(uv.y * 480.0);
    float lineNoise = hash(vec2(line, t));
    float tearStrength = step(0.985, lineNoise) * 0.02 * strength;
    vec2 glitchUV = uv;
    glitchUV.x += tearStrength * (hash(vec2(lineNoise, t)) - 0.5);

    // Wave distortion
    float wave = sin(uv.y * 40.0 + t * 6.0) * 0.002 * strength;
    glitchUV.x += wave;

    // Color channel separation
    float shift = 0.0015 * sin(t * 2.0 + uv.y * 10.0) * strength;
    vec3 glitchColor = sampleSeparated(
        glitchUV + vec2(shift, 0.0),
        glitchUV,
        glitchUV - vec2(shift, 0.0)
    );

    // RGB shift blocks
    float blockY = floor(uv.y * 20.0);
    float blockNoise = hash(vec2(blockY, floor(t * 10.0)));
    if (blockNoise > 0.95) {
        float blockShift = (hash(vec2(blockY, t)) - 0.5) * 0.05 * strength;
        glitchColor = sampleSeparated(
            glitchUV + vec2(blockShift, 0.0),
            glitchUV,
            glitchUV - vec2(blockShift, 0.0)
        );
    }

    return mix(color, glitchColor, strength);
#else
    return color;
#endif
}

// =============================================================================
// Main Pipeline
// Purpose: Orchestrate effect application order.
// Rationale: UV transforms first, then sampling, then color ops.
// =============================================================================

void main() {
    float alpha;
    vec2 uv = v_texcoord;

    // Wrap time to prevent precision loss in hash functions
    float t = mod(time, 1000.0);

    // --- Compute glitch state once ---
    GlitchState glitch = computeGlitchState(t);

    // --- UV Transform Stage ---
    uv = applyPixelate(uv);

    // --- Tape Crease (can modify UV) ---
    vec2 creaseUV;
    vec3 preCrease = vec3(0.0);
#if ENABLE_TAPE_CREASE
    preCrease = applyTapeCrease(uv, t, preCrease, creaseUV);
    uv = creaseUV;
#endif

    // --- Sampling Stage ---
    vec3 color = applyChromaticAberration(uv, alpha);

    // --- Early Color Effects ---
    color = applySharpen(uv, color);
    color = applyColorBleed(uv, color);

    // --- Distortion Effects ---
    color = applyAnalogGlitch(uv, t, color, glitch);

    // --- Overlay Effects ---
    color = applyPixelGrid(uv, color);
    color = applyCRTMask(uv, color);
    color += calculateBloom(uv);

    // --- Color Processing ---
    color = applyColorTemperature(color);
    color = applyColorGrading(color);
    color = applyPhosphorDecay(color);

    // --- Screen Effects ---
    color *= applyScanlines(v_texcoord, t);
    color *= applyInterlace(v_texcoord, t);
    color = applyFlicker(t, color);

    // --- Noise & Degradation ---
    color = applyVHSEffect(uv, t, color);
    color = applyFilmGrain(uv, t, color);

    // --- Final Processing ---
    color = applyDithering(uv, color);
    color = applyVignette(v_texcoord, color);

    fragColor = vec4(color, alpha);
}
