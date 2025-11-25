#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform float time;
uniform int blurPass; // 0-5 for different blur sizes

// Bloom Parameters
#define BLOOM_INTENSITY       0.24
#define BLOOM_RADIUS          0.0016
#define BLOOM_RADIAL_SAMPLES  24
#define BLOOM_TINT            vec3(1.1, 0.9, 0.85)
#define BLOOM_THRESHOLD       0.96
#define BLOOM_SOFT_THRESHOLD  0.3

const float PI = 3.14159265359;

float interleavedGradientNoise(vec2 pixel) {
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(pixel, magic.xy)));
}

vec3 calculateBloomPass(vec2 uv, float blurSize) {
    vec3 bloomAccum = vec3(0.0);
    float totalWeight = 0.0;

    // Spatial dithering
    float dither = interleavedGradientNoise(uv * vec2(1920.0, 1080.0)) * 2.0 - 1.0;
    float ditherAmount = 0.015;

    int samplesPerAxis = BLOOM_RADIAL_SAMPLES;

    // Sample along 8 directions
    for (int dir = 0; dir < 8; dir++) {
        float angle = float(dir) * 0.785398;
        vec2 direction = vec2(cos(angle), sin(angle));

        for (int s = 1; s <= samplesPerAxis; s++) {
            float t = float(s) / float(samplesPerAxis);
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

            float tentWeight = pow(1.0 - t, 1.2);
            float sigma = blurSize * 0.9;
            float gaussianWeight = exp(-(radius * radius) / (2.0 * sigma * sigma));
            float weight = smoothstep(0.0, 1.0, tentWeight * gaussianWeight) * sampleMask;

            bloomAccum += sampleColor * weight;
            totalWeight += weight;
        }
    }

    // Center sample
    vec3 centerColor = texture(tex, uv).rgb;
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

void main() {
    // Different blur sizes for each pass
    float blurSizes[6];
    blurSizes[0] = BLOOM_RADIUS * 0.3;
    blurSizes[1] = BLOOM_RADIUS * 0.7;
    blurSizes[2] = BLOOM_RADIUS * 1.3;
    blurSizes[3] = BLOOM_RADIUS * 2.2;
    blurSizes[4] = BLOOM_RADIUS * 3.8;
    blurSizes[5] = BLOOM_RADIUS * 5.5;

    float blurSize = blurSizes[clamp(blurPass, 0, 5)];
    vec3 bloom = calculateBloomPass(v_texcoord, blurSize);

    // Pass contribution for accumulation
    float passContribution = exp(-float(blurPass) * 0.4);

    fragColor = vec4(bloom * passContribution * BLOOM_INTENSITY * BLOOM_TINT, 1.0);
}
