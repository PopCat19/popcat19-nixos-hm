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
#define DEBUG_VHS_OVERLAY 1    // Toggle VHS effect
#define DEBUG_GLITCH   1       // Toggle glitch effect
#define DEBUG_DRIFT    0       // Toggle drifting effect
#define DEBUG_COLOR_TEMP 0     // Toggle color temperature adjustment
#define DEBUG_VIBRATION 1      // Toggle CRT buzz vibration effect
#define DEBUG_GRAIN     0      // Toggle cinematic grain effect

// [Effect Parameters]
// Bloom Parameters
#define BLOOM_INTENSITY       0.16      // Increase for more visible bloom (try 0.30-0.50)
#define BLOOM_RADIUS          0.004     // Increase for wider spread (try 0.025-0.040)
#define BLOOM_RADIAL_SAMPLES  8        // Samples per axis direction (try 10-16 for smoother blur)
#define DIRECTIONS            32        // Number of directions for bloom blur sampling
#define BLOOM_TINT            vec3(1.1, 0.9, 0.85)
#define BLOOM_THRESHOLD       0.96       // Only bright areas create bloom (try 0.4-0.7)
#define BLOOM_SOFT_THRESHOLD  0.4       // Softer threshold transition

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

const float PI = 3.14159265359;

// --- Utility Functions ---
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
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

        // Sample along configurable number of directions
        for (int dir = 0; dir < DIRECTIONS; dir++) {
            float angle = float(dir) * (2.0 * 3.14159265359 / float(DIRECTIONS)); // Evenly distributed angles
            vec2 direction = vec2(cos(angle), sin(angle));

            // Multiple samples along each direction (tent blur)
            for (int s = 1; s <= samplesPerAxis; s++) {
                float t = float(s) / float(samplesPerAxis);

                float radius = blurSize * t;

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

// --- Vignette Effect ---
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

    color = applyPixelGrid(pixelatedUV, color);

    #if DEBUG_BLOOM
    color += calculateBloom(pixelatedUV);
    #endif

    #if DEBUG_COLOR_TEMP
    color = mix(color, color * colorTemperatureToRGB(COLOR_TEMPERATURE), COLOR_TEMPERATURE_STRENGTH);
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

    fragColor = vec4(color, alpha);
}
