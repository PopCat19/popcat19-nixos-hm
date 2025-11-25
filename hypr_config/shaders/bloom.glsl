#version 320 es
precision highp float;

// Input texture coordinates
in vec2 v_texcoord;

// Output fragment color
out vec4 fragColor;

// Input texture and time uniform
uniform sampler2D tex;
uniform float time;

// Bloom Parameters
#define BLOOM_INTENSITY         0.16      // Increase for more visible bloom (try 0.30-0.50)
#define BLOOM_RADIUS            0.004     // Increase for wider spread (try 0.025-0.040)
#define BLOOM_RADIAL_SAMPLES    8         // Samples per axis direction (try 10-16 for smoother blur)
#define DIRECTIONS              32        // Number of directions for bloom blur sampling (try 16-64)
#define BLOOM_TINT              vec3(1.1, 0.9, 0.85)
#define BLOOM_THRESHOLD         0.96      // Only bright areas create bloom (try 0.4-0.7)
#define BLOOM_SOFT_THRESHOLD    0.4       // Softer threshold transition
#define BLOOM_PASSES            6         // Number of blur passes (more = smoother, slower)
#define BLOOM_SIGMA_SCALE       0.9       // Gaussian spread factor (higher = softer blur)
#define BLOOM_PASS_FALLOFF      0.4       // How quickly blur passes fade (higher = more even blending)
#define BLOOM_CENTER_WEIGHT     2.0       // Weight of center sample (higher = preserves more detail)
#define BLOOM_LUM_R_WEIGHT      0.299     // Luminance R channel weight
#define BLOOM_LUM_G_WEIGHT      0.587     // Luminance G channel weight
#define BLOOM_LUM_B_WEIGHT      0.114     // Luminance B channel weight

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

// --- Pure Gaussian Blur ---
vec3 calculateBloom(vec2 uv) {
    vec3 bloomAccum = vec3(0.0);
    float totalWeight = 0.0;

    const int BLUR_PASSES = BLOOM_PASSES;
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
                float sampleLum = dot(sampleColor, vec3(BLOOM_LUM_R_WEIGHT, BLOOM_LUM_G_WEIGHT, BLOOM_LUM_B_WEIGHT));
                float sampleMask = smoothstep(
                        BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                        BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                        sampleLum
                    );

                // Gaussian falloff calculation
                float sigma = blurSize * BLOOM_SIGMA_SCALE;
                float gaussianWeight = exp(-(radius * radius) / (2.0 * sigma * sigma));

                // Weight is pure Gaussian multiplied by sample mask
                float weight = gaussianWeight * sampleMask;

                passBlur += sampleColor * weight;
                passWeight += weight;
            }
        }

        // Add center sample with high weight to preserve some detail
        vec3 centerColor = texture(tex, uv).rgb;
        float centerLum = dot(centerColor, vec3(BLOOM_LUM_R_WEIGHT, BLOOM_LUM_G_WEIGHT, BLOOM_LUM_B_WEIGHT));
        float centerMask = smoothstep(
                BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
                BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
                centerLum
            );
        float centerWeight = BLOOM_CENTER_WEIGHT * centerMask;
        passBlur += centerColor * centerWeight;
        passWeight += centerWeight;

        if (passWeight > 0.0) {
            passBlur /= passWeight;
        }

        // Smoother pass contribution curve to reduce stepping between passes
        float passContribution = exp(-float(pass) * BLOOM_PASS_FALLOFF);
        bloomAccum += passBlur * passContribution;
        totalWeight += passContribution;
    }

    if (totalWeight > 0.0) {
        bloomAccum /= totalWeight;
    }

    return bloomAccum * BLOOM_INTENSITY * BLOOM_TINT;
}

// --- Main ---
void main() {
    vec2 uv = v_texcoord;

    // Sample original color
    vec4 base = texture(tex, uv);
    vec3 color = base.rgb;
    float alpha = base.a;

    // Apply bloom
    color += calculateBloom(uv);

    fragColor = vec4(color, alpha);
}
