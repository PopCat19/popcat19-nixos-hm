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

#define ENABLE_CA           1
#define ENABLE_BLOOM        1
#define ENABLE_PIXEL        1
#define ENABLE_SCANLINE     1
#define ENABLE_VHS          1
#define ENABLE_GLITCH       1
#define ENABLE_COLOR_TEMP   0
#define ENABLE_VIBRATION    1
#define ENABLE_INTERLACE    1

// =============================================================================
// Constants
// =============================================================================

const float PI = 3.14159265359;
const float GOLDEN_ANGLE = 2.39996;
const vec3 LUMA_WEIGHTS = vec3(0.299, 0.587, 0.114);

// =============================================================================
// Effect Parameters
// Purpose: Centralized tuning knobs grouped by effect.
// Rationale: Easier iteration; avoids hunting for magic numbers.
// =============================================================================

// --- Bloom ---
const float  BLOOM_INTENSITY      = 0.16;
const float  BLOOM_RADIUS         = 0.008;
const int    BLOOM_SAMPLES        = 64;
const vec3   BLOOM_TINT           = vec3(1.1, 0.9, 0.9);
const float  BLOOM_THRESHOLD      = 0.0;
const float  BLOOM_SOFT_THRESHOLD = 1.0;
const float  BLOOM_FALLOFF        = 32.0;
const int    BLOOM_SCALES         = 3;

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
const float SCANLINE_OPACITY    = 0.02;
const float SCANLINE_FREQUENCY  = 0.8;
const float SCANLINE_SPEED      = 1.0;
const float SCANLINE_THICKNESS  = 0.02;

// --- CRT Vibration ---
const float VIBRATION_AMPLITUDE      = 0.0004;
const float VIBRATION_BASE_FREQ      = 75.0;
const float VIBRATION_NOISE_FREQ     = 8.0;
const float VIBRATION_NOISE_STRENGTH = 0.4;

// --- Color ---
const float COLOR_TEMPERATURE        = 4000.0;
const float COLOR_TEMPERATURE_MIX    = 1.0;

// --- Pixelation ---
const float PIXEL_GRID_SIZE = 960.0;

// --- VHS ---
const float VHS_INTENSITY           = 0.16;
const float VHS_JITTER_STRENGTH     = 0.004;
const float VHS_WAVE_FREQ           = 2.0;
const float VHS_WAVE_AMPLITUDE      = 0.003;
const float VHS_COLOR_SHIFT         = 0.0015;
const float VHS_NOISE_BAND_FREQ     = 0.8;
const float VHS_NOISE_BAND_STRENGTH = 0.25;

// --- Interlace ---
const float INTERLACE_STRENGTH = 0.15;
const float INTERLACE_LINES    = 480.0;

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

float luminance(vec3 c) {
    return dot(c, LUMA_WEIGHTS);
}

vec3 sampleTex(vec2 uv) {
    return texture(tex, uv).rgb;
}

vec4 sampleTexA(vec2 uv) {
    return texture(tex, uv);
}

// Separated channel sampling for color fringing effects
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

// =============================================================================
// UV Transformation Effects
// Purpose: Modify UV coordinates before sampling.
// Rationale: Applied first in pipeline to affect all subsequent reads.
// =============================================================================

vec2 applyCRTVibration(vec2 uv, float t) {
#if ENABLE_VIBRATION
    float buzz = sin(t * VIBRATION_BASE_FREQ) * VIBRATION_AMPLITUDE;
    float line = floor(uv.y * INTERLACE_LINES);
    float noise = (hash(vec2(line, t * VIBRATION_NOISE_FREQ)) - 0.5)
                  * VIBRATION_AMPLITUDE * VIBRATION_NOISE_STRENGTH;
    return uv + vec2(0.0, buzz + noise);
#else
    return uv;
#endif
}

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

    alpha = texture(tex, uv).a;
    return sampleSeparated(uv + dir * rStr, uv, uv - dir * bStr);
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

    // --- Compute glitch state once ---
    GlitchState glitch = computeGlitchState(time);

    // --- UV Transform Stage ---
    uv = applyCRTVibration(uv, time);
    uv = applyPixelate(uv);

    // --- Sampling Stage ---
    vec3 color = applyChromaticAberration(uv, alpha);

    // --- Distortion Effects ---
    color = applyAnalogGlitch(uv, time, color, glitch);

    // --- Overlay Effects ---
    color = applyPixelGrid(uv, color);
    color += calculateBloom(uv);

    // --- Color Processing ---
    color = applyColorTemperature(color);

    // --- Screen Effects ---
    color *= applyScanlines(v_texcoord, time);
    color *= applyInterlace(v_texcoord, time);

    // --- Noise & Degradation ---
    color = applyVHSEffect(uv, time, color);

    fragColor = vec4(color, alpha);
}
