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
#define BLOOM_INTENSITY       0.16      // Increase for more visible bloom (try 0.30-0.50)
#define BLOOM_RADIUS          0.004     // Increase for wider spread (try 0.025-0.040)
#define BLOOM_RADIAL_SAMPLES  8        // Samples per axis direction (try 10-16 for smoother blur)
#define DIRECTIONS            32        // Number of directions for bloom blur sampling
#define BLOOM_TINT            vec3(1.1, 0.9, 0.85)
#define BLOOM_THRESHOLD       0.96       // Only bright areas create bloom (try 0.4-0.7)
#define BLOOM_SOFT_THRESHOLD  0.4       // Softer threshold transition

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
