#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform sampler2D bloomTex; // Accumulated bloom from pass 2
uniform float time;

// Vignette Parameters
#define VIGNETTE_STRENGTH      0.4
#define VIGNETTE_RADIUS        1.6
#define VIGNETTE_SMOOTHNESS    0.8
#define VIGNETTE_ASPECT        vec2(1.0, 1.0)
#define VIGNETTE_COLOR         vec3(0.0, 0.0, 0.0)
#define VIGNETTE_OFFSET        vec2(0.0, 0.0)
#define VIGNETTE_EXPONENT      1.0
#define VIGNETTE_MODE          0

// Grain Parameters
#define GRAIN_INTENSITY 0.08
#define GRAIN_SIZE 800.0
#define GRAIN_SPEED 0.5

// VHS Parameters
#define VHS_INTENSITY        0.16
#define VHS_JITTER_STRENGTH  0.004
#define VHS_WAVE_FREQ        2.0
#define VHS_WAVE_AMPLITUDE   0.003
#define VHS_COLOR_SHIFT      0.0015
#define VHS_NOISE_BAND_FREQ  0.8
#define VHS_NOISE_BAND_STRENGTH 0.25

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float computeVignette(vec2 uv) {
    vec2 coord = (uv - 0.5 - VIGNETTE_OFFSET) * 2.0 * VIGNETTE_ASPECT;
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

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec4 bloom = texture(bloomTex, v_texcoord);

    // Add bloom
    color.rgb += bloom.rgb;

    // Apply grain
    color.rgb = applyGrain(v_texcoord, color.rgb, time);

    // Apply VHS
    color.rgb = applyVHSEffect(v_texcoord, time, color.rgb);

    // Apply vignette
    float vig = computeVignette(v_texcoord);
    #if VIGNETTE_MODE == 0
    color.rgb *= mix(1.0 - VIGNETTE_STRENGTH, 1.0, vig);
    #else
    color.rgb = mix(color.rgb * VIGNETTE_COLOR, color.rgb, vig);
    color.rgb *= mix(1.0 - VIGNETTE_STRENGTH / 2.0, 1.0, vig);
    #endif

    fragColor = color;
}
