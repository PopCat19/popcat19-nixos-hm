#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform float time;

// ============================================================================
// PASS 1: CHROMATIC ABERRATION & GLITCH PARAMETERS
// ============================================================================
#define CA_RED_STRENGTH     0.001
#define CA_BLUE_STRENGTH    0.001
#define CA_FALLOFF          1.0
#define CA_ANGLE            0.0
#define CA_FALLOFF_EXPONENT 1.0
#define CA_CENTER_STRENGTH  3.0

#define GLITCH_STRENGTH        1.0
#define GLITCH_PROBABILITY     0.20
#define GLITCH_INTERVAL        3.0
#define GLITCH_DURATION        0.12
#define GLITCH_SPEED           64.0

// ============================================================================
// PASS 2: BLOOM PARAMETERS (TRUE MULTIPASS VERSION)
// ============================================================================
#define BLOOM_INTENSITY       0.24
#define BLOOM_RADIUS          0.0016
#define BLOOM_RADIAL_SAMPLES  24
#define BLOOM_TINT            vec3(1.1, 0.9, 0.85)
#define BLOOM_THRESHOLD       0.96
#define BLOOM_SOFT_THRESHOLD  0.3
#define BLOOM_PASSES          6

// ============================================================================
// PASS 3: FINAL COMPOSITE PARAMETERS
// ============================================================================
#define VIGNETTE_STRENGTH      0.4
#define VIGNETTE_RADIUS        1.6
#define VIGNETTE_SMOOTHNESS    0.8
#define VIGNETTE_EXPONENT      1.0
#define VIGNETTE_MODE          0
#define GRAIN_INTENSITY 0.08
#define GRAIN_SIZE 800.0
#define GRAIN_SPEED 0.5
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

// ============================================================================
// PASS 1 FUNCTIONS: CHROMATIC ABERRATION & GLITCH
// ============================================================================

vec3 samplePass1(vec2 uv, out float alpha) {
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

    vec3 color = vec3(
            texture(tex, uv + dir * strength_r).r,
            texture(tex, uv).g,
            texture(tex, uv - dir * strength_b).b
        );

    // Apply glitch
    float currentInterval = floor(time / GLITCH_INTERVAL);
    float tInInterval = fract(time / GLITCH_INTERVAL);
    float seedGlitch = random(vec2(currentInterval));
    float intervalActive = step(seedGlitch, GLITCH_PROBABILITY);
    float isActiveGlitch = intervalActive * step(tInInterval, GLITCH_DURATION);

    if (isActiveGlitch > 0.5) {
        float bounce = sin(tInInterval * GLITCH_SPEED * PI);
        float strength = GLITCH_STRENGTH * bounce;
        float line = floor(uv.y * 480.0);
        float lineNoise = random(vec2(line, time));
        float tearStrength = step(0.985, lineNoise) * 0.02 * strength;
        vec2 glitchUV = uv;
        glitchUV.x += tearStrength * (random(vec2(lineNoise, time)) - 0.5);
        float wave = sin(uv.y * 40.0 + time * 6.0) * 0.002 * strength;
        glitchUV.x += wave;
        float shift = 0.0015 * sin(time * 2.0 + uv.y * 10.0) * strength;
        vec3 analogColor = vec3(
                texture(tex, glitchUV + vec2(shift, 0.0)).r,
                texture(tex, glitchUV).g,
                texture(tex, glitchUV - vec2(shift, 0.0)).b
            );
        color = mix(color, analogColor, strength);
    }

    return color;
}

// ============================================================================
// PASS 2 FUNCTIONS: TRUE MULTIPASS BLOOM
// ============================================================================

vec3 samplePass1ForBloom(vec2 uv) {
    float dummyAlpha;
    return samplePass1(uv, dummyAlpha);
}

vec3 calculateBloomPass(vec2 uv, float blurSize) {
    vec3 bloomAccum = vec3(0.0);
    float totalWeight = 0.0;

    float dither = interleavedGradientNoise(uv * vec2(1920.0, 1080.0)) * 2.0 - 1.0;
    float ditherAmount = 0.015;

    // Sample along 8 directions with HIGH sample count
    for (int dir = 0; dir < 8; dir++) {
        float angle = float(dir) * 0.785398;
        vec2 direction = vec2(cos(angle), sin(angle));

        for (int s = 1; s <= BLOOM_RADIAL_SAMPLES; s++) {
            float t = float(s) / float(BLOOM_RADIAL_SAMPLES);
            float jitter = dither * ditherAmount * (1.0 / float(BLOOM_RADIAL_SAMPLES));
            float radius = blurSize * (t + jitter);

            vec2 sampleUV = uv + direction * radius;
            vec3 sampleColor = samplePass1ForBloom(sampleUV);
            float sampleLum = dot(sampleColor, vec3(0.299, 0.587, 0.114));
            float sampleMask = smoothstep(
                    BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                    BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                    sampleLum
                );

            float tentWeight = pow(1.0 - t, 1.2);
            float sigma = blurSize * 0.9;
            float gaussianWeight = exp(-(radius * radius) / (2.0 * sigma * sigma));
            float weight = smoothstep(0.0, 1.0, tentWeight * gaussianWeight) * sampleMask;

            bloomAccum += sampleColor * weight;
            totalWeight += weight;
        }
    }

    // Center sample
    vec3 centerColor = samplePass1ForBloom(uv);
    float centerLum = dot(centerColor, vec3(0.299, 0.587, 0.114));
    float centerMask = smoothstep(
            BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
            BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
            centerLum
        );
    float centerWeight = 2.0 * centerMask;
    bloomAccum += centerColor * centerWeight;
    totalWeight += centerWeight;

    if (totalWeight > 0.0) {
        bloomAccum /= totalWeight;
    }

    return bloomAccum;
}

vec3 calculateMultipassBloom(vec2 uv) {
    vec3 bloomAccumulated = vec3(0.0);

    float blurSizes[6];
    blurSizes[0] = BLOOM_RADIUS * 0.3;
    blurSizes[1] = BLOOM_RADIUS * 0.7;
    blurSizes[2] = BLOOM_RADIUS * 1.3;
    blurSizes[3] = BLOOM_RADIUS * 2.2;
    blurSizes[4] = BLOOM_RADIUS * 3.8;
    blurSizes[5] = BLOOM_RADIUS * 5.5;

    // Accumulate multiple bloom passes with different blur sizes
    for (int pass = 0; pass < BLOOM_PASSES; pass++) {
        float blurSize = blurSizes[pass];
        vec3 bloomPass = calculateBloomPass(uv, blurSize);
        float passContribution = exp(-float(pass) * 0.4);
        bloomAccumulated += bloomPass * passContribution;
    }

    return bloomAccumulated * BLOOM_INTENSITY * BLOOM_TINT;
}

// ============================================================================
// PASS 3 FUNCTIONS: FINAL COMPOSITE
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

vec3 applyVHSEffect(vec2 uv, float time, vec3 color) {
    float jitter = (random(vec2(time, uv.y)) - 0.5) * VHS_JITTER_STRENGTH;
    vec2 vhsUV = uv;
    vhsUV.x += jitter;
    vhsUV.y += sin(uv.x * VHS_WAVE_FREQ + time * 1.5) * VHS_WAVE_AMPLITUDE;

    float dummyAlpha;
    vec3 vhsColor = vec3(
            samplePass1(vhsUV + vec2(VHS_COLOR_SHIFT, 0.0), dummyAlpha).r,
            samplePass1(vhsUV, dummyAlpha).g,
            samplePass1(vhsUV - vec2(VHS_COLOR_SHIFT, 0.0), dummyAlpha).b
        );

    float bandNoise = step(1.0 - VHS_NOISE_BAND_FREQ, random(vec2(time, floor(uv.y * 480.0))));
    if (bandNoise > 0.5) {
        float noise = (random(uv * time) - 0.5) * VHS_NOISE_BAND_STRENGTH;
        vhsColor += vec3(noise);
    }

    return mix(color, vhsColor, VHS_INTENSITY);
}

// ============================================================================
// MAIN: 3-PASS PIPELINE
// ============================================================================

void main() {
    vec2 uv = v_texcoord;
    float alpha;

    // PASS 1: Chromatic Aberration & Glitch
    vec3 pass1Color = samplePass1(uv, alpha);

    // PASS 2: TRUE Multipass Bloom (6 accumulated blur passes)
    vec3 bloomColor = calculateMultipassBloom(uv);

    // PASS 3: Final Composite (bloom + grain + VHS + vignette)
    vec3 finalColor = pass1Color + bloomColor;
    finalColor = applyGrain(uv, finalColor, time);
    finalColor = applyVHSEffect(uv, time, finalColor);

    float vig = computeVignette(uv);
    #if VIGNETTE_MODE == 0
    finalColor *= mix(1.0 - VIGNETTE_STRENGTH, 1.0, vig);
    #else
    finalColor = mix(finalColor * vec3(0.0), finalColor, vig);
    finalColor *= mix(1.0 - VIGNETTE_STRENGTH / 2.0, 1.0, vig);
    #endif

    fragColor = vec4(finalColor, alpha);
}
