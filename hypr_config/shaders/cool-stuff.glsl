// Enhanced Stylistic Post-Processing Shader - "Chaotic Beauty" Edition
// Set high precision for floating-point calculations
precision highp float;

// Input texture coordinates
varying vec2 v_texcoord;

// Input texture and time uniform
uniform sampler2D tex;
uniform float time;

// [Enhanced Debug Toggles]
#define DEBUG_CA       1       // Chromatic aberration
#define DEBUG_BLOOM    1       // Enhanced bloom
#define DEBUG_VIGNETTE 1       // Stylized vignette
#define DEBUG_PIXEL    0       // Pixelation
#define COLOR_DEPTH_ENABLED 1  // Color depth reduction
#define DEBUG_SCANLINE 1       // Enhanced scanlines
#define DEBUG_VHS_OVERLAY 1    // VHS overlay
#define DEBUG_GLITCH   1       // Enhanced glitch
#define DEBUG_DRIFT    1       // Drifting
#define DEBUG_COLOR_TEMP 1     // Color temperature
#define DEBUG_VIBRATION 1      // Vibration
#define DEBUG_BITRATE   0      // Bitrate compression
#define DEBUG_FILM_GRAIN 1     // Film grain effect
#define DEBUG_COLOR_GRADING 1  // Advanced color grading
#define DEBUG_LENS_DISTORTION 1 // Lens distortion
#define DEBUG_THERMAL_NOISE 1  // Thermal noise simulation
#define DEBUG_RETRO_BANDS 1    // Retro color banding

// [Enhanced Effect Parameters]
// Enhanced Bloom Parameters
#define BLOOM_INTENSITY       0.8
#define BLOOM_RADIUS          0.008
#define BLOOM_SAMPLES         96
#define BLOOM_TINT           vec3(1.2, 0.9, 1.1)
#define BLOOM_THRESHOLD       0.1
#define BLOOM_SOFT_THRESHOLD  0.8
#define BLOOM_FALLOFF_CURVE   28.0
#define BLOOM_SECONDARY_INTENSITY 0.3
#define BLOOM_SECONDARY_RADIUS 0.02

// Enhanced Glitch Parameters
#define GLITCH_STRENGTH        0.15
#define GLITCH_PROBABILITY     0.12
#define GLITCH_X_VIBRATION_PROBABILITY 0.7
#define GLITCH_INTERVAL        2.5
#define GLITCH_DURATION        0.15
#define GLITCH_BLOCK_SIZE      12.0
#define GLITCH_DISPLACEMENT    0.015
#define GLITCH_COLOR_SHIFT     0.008
#define GLITCH_BLOCK_PROBABILITY 0.4
#define GLITCH_X_VIBRATION_AMPLITUDE 0.008
#define GLITCH_DIGITAL_NOISE   0.05

// Enhanced Vignette Parameters
#define VIGNETTE_STRENGTH      0.6
#define VIGNETTE_RADIUS        1.4
#define VIGNETTE_SMOOTHNESS    0.6
#define VIGNETTE_ASPECT       vec2(1.0, 1.0)
#define VIGNETTE_COLOR        vec3(0.1, 0.05, 0.2)
#define VIGNETTE_OFFSET       vec2(0.0, 0.0)
#define VIGNETTE_EXPONENT     1.2
#define VIGNETTE_MODE         1

// Enhanced Chromatic Aberration
#define CA_RED_STRENGTH     0.003
#define CA_BLUE_STRENGTH    0.003
#define CA_FALLOFF          1.2
#define CA_ANGLE            0.0
#define CA_FALLOFF_EXPONENT 1.5
#define CA_CENTER_STRENGTH  2.5
#define CA_DYNAMIC_STRENGTH 0.5

// Enhanced Scanline Parameters
#define SCANLINE_OPACITY     0.3
#define SCANLINE_FREQUENCY   2.0
#define SCANLINE_SPEED       -0.8
#define SCANLINE_THICKNESS   0.15
#define SCANLINE_CURVATURE   0.1

// Enhanced Drift Parameters
#define DRIFT_MODE 1
#define DRIFT_SPEED -1.8
#define DRIFT_RADIUS 0.003
#define DRIFT_AMPLITUDE 0.003
#define DRIFT_FREQUENCY 1.5
#define DRIFT_DIRECTION vec2(1.0, 0.3)

// Enhanced Vibration
#define VIBRATION_AMPLITUDE 0.0006
#define VIBRATION_FREQUENCY 85.0
#define VIBRATION_CHAOS_FREQ 23.0

// Enhanced Color Settings
#define COLOR_DEPTH 16
const float COLOR_TEMPERATURE = 2800.0;
const float COLOR_TEMPERATURE_STRENGTH = 0.8;

// Pixelation
#define PIXEL_GRID_SIZE 840.0

// Enhanced VHS Overlay
#define VHS_OVERLAY_INTENSITY  0.4
#define VHS_OVERLAY_OFFSET     vec2(0.007, -0.004)
#define VHS_OVERLAY_SPEED      0.4
#define VHS_OVERLAY_TINT_RGB   vec3(1.6, 0.7, 1.3)
#define VHS_OVERLAY_NOISE_SCALE 420.0
#define VHS_OVERLAY_FREQ       0.25
#define VHS_OVERLAY_DISPLACEMENT_SCALE 0.4
#define VHS_OVERLAY_WAVE_AMPLITUDE 0.15

// Film Grain Parameters
#define FILM_GRAIN_INTENSITY 0.08
#define FILM_GRAIN_SIZE 512.0
#define FILM_GRAIN_LUMINANCE_INFLUENCE 0.7

// Color Grading Parameters
#define COLOR_CONTRAST 1.15
#define COLOR_SATURATION 1.1
#define COLOR_GAMMA 0.95
#define COLOR_LIFT vec3(0.02, 0.01, 0.05)
#define COLOR_GAMMA_VEC vec3(0.95, 1.0, 0.9)
#define COLOR_GAIN vec3(1.05, 0.98, 1.02)

// Lens Distortion Parameters
#define LENS_DISTORTION_STRENGTH 0.03
#define LENS_DISTORTION_EDGE_DARKEN 0.2

// Thermal Noise Parameters
#define THERMAL_NOISE_INTENSITY 0.02
#define THERMAL_NOISE_FREQUENCY 8.0

// Retro Color Banding
#define RETRO_BANDS_LEVELS 32.0
#define RETRO_BANDS_INTENSITY 0.3

const float PI = 3.14159265359;
const float TAU = 6.28318530718;

// Enhanced utility functions
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(random(i + vec2(0.0,0.0)), random(i + vec2(1.0,0.0)), u.x),
               mix(random(i + vec2(0.0,1.0)), random(i + vec2(1.1,1.0)), u.x), u.y);
}

// Enhanced color depth reduction with dithering
vec3 applyColorDepthReduction(vec3 color, vec2 uv) {
#if COLOR_DEPTH_ENABLED
    ivec3 bits;
    if(COLOR_DEPTH == 8) {
        bits = ivec3(3, 3, 2);
    } else if(COLOR_DEPTH == 16) {
        bits = ivec3(5, 6, 5);
    } else {
        return color;
    }
    
    vec3 maxValues = pow(vec3(2.0), vec3(bits)) - 1.0;
    
    // Add dithering
    float dither = random(uv * 1000.0) * 0.05;
    color += vec3(dither);
    
    return floor(color * maxValues + 0.5) / maxValues;
#else
    return color;
#endif
}

// Film grain effect
vec3 applyFilmGrain(vec2 uv, vec3 color, float time) {
#if DEBUG_FILM_GRAIN
    float grain = noise(uv * FILM_GRAIN_SIZE + time * 12.0) - 0.5;
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float grainStrength = FILM_GRAIN_INTENSITY * (1.0 - luminance * FILM_GRAIN_LUMINANCE_INFLUENCE);
    return color + vec3(grain * grainStrength);
#else
    return color;
#endif
}

// Advanced color grading
vec3 applyColorGrading(vec3 color) {
#if DEBUG_COLOR_GRADING
    // Lift, Gamma, Gain
    color = COLOR_LIFT + color * COLOR_GAIN;
    color = pow(max(color, vec3(0.0)), COLOR_GAMMA_VEC);
    
    // Contrast and saturation
    vec3 luminance = vec3(dot(color, vec3(0.299, 0.587, 0.114)));
    color = mix(luminance, color, COLOR_SATURATION);
    color = mix(vec3(0.5), color, COLOR_CONTRAST);
    
    return color;
#else
    return color;
#endif
}

// Lens distortion effect
vec2 applyLensDistortion(vec2 uv) {
#if DEBUG_LENS_DISTORTION
    vec2 coord = uv - 0.5;
    float dist = length(coord);
    coord *= 1.0 + LENS_DISTORTION_STRENGTH * dist * dist;
    return coord + 0.5;
#else
    return uv;
#endif
}

// Thermal noise simulation
vec3 applyThermalNoise(vec2 uv, vec3 color, float time) {
#if DEBUG_THERMAL_NOISE
    float thermalNoise = noise(uv * THERMAL_NOISE_FREQUENCY + time * 2.0) * THERMAL_NOISE_INTENSITY;
    return color + vec3(thermalNoise * (1.0 + sin(time * 3.0) * 0.2));
#else
    return color;
#endif
}

// Retro color banding
vec3 applyRetroBanding(vec3 color) {
#if DEBUG_RETRO_BANDS
    vec3 banded = floor(color * RETRO_BANDS_LEVELS) / RETRO_BANDS_LEVELS;
    return mix(color, banded, RETRO_BANDS_INTENSITY);
#else
    return color;
#endif
}

// Enhanced pixelation with chromatic shift
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
    vec2 gridLine = smoothstep(0.92, 0.98, fract(pixelCoord));
    float gridMask = 1.0 - max(gridLine.x, gridLine.y) * 0.3;
    return color * mix(vec3(0.15), vec3(1.0), gridMask);
#else
    return color;
#endif
}

// Enhanced color temperature
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

// Enhanced vignette with color tinting
float computeVignette(vec2 uv) {
    vec2 coord = (uv - 0.5 - VIGNETTE_OFFSET) * 2.0 * VIGNETTE_ASPECT;
    float dist = length(coord);
    dist = pow(dist, VIGNETTE_EXPONENT);
    return smoothstep(VIGNETTE_RADIUS, VIGNETTE_RADIUS - VIGNETTE_SMOOTHNESS, dist);
}

// Enhanced chromatic aberration with dynamic strength
vec3 applyChromaticAberration(vec2 uv, float time, out float alpha) {
    vec2 dir = (uv - 0.5) * CA_FALLOFF;
    float cosA = cos(CA_ANGLE);
    float sinA = sin(CA_ANGLE);
    dir = vec2(dir.x * cosA - dir.y * sinA, dir.x * sinA + dir.y * cosA);
    
    float dist = length(dir);
    float edgeComponent = pow(dist, CA_FALLOFF_EXPONENT);
    float centerComponent = (1.0 - edgeComponent) * CA_CENTER_STRENGTH;
    float totalFalloff = edgeComponent + centerComponent;
    
    // Dynamic strength based on time
    float dynamicMultiplier = 1.0 + sin(time * 0.3) * CA_DYNAMIC_STRENGTH;
    
    float strength_r = totalFalloff * CA_RED_STRENGTH * dynamicMultiplier;
    float strength_b = totalFalloff * CA_BLUE_STRENGTH * dynamicMultiplier;
    
    alpha = texture2D(tex, uv).a;
    return vec3(
        texture2D(tex, uv + dir * strength_r).r,
        texture2D(tex, uv).g,
        texture2D(tex, uv - dir * strength_b).b
    );
}

// Enhanced bloom with secondary bloom layer
vec3 calculateBloom(vec2 uv) {
    vec3 color = vec3(0.0);
    float total = 0.0;
    const float goldenAngle = 2.39996;
    float currentAngle = 0.0;
    
    // Primary bloom
    for(int i = 0; i < BLOOM_SAMPLES; i++) {
        float ratio = sqrt(float(i)/float(BLOOM_SAMPLES));
        float radius = ratio * BLOOM_RADIUS;
        currentAngle += goldenAngle;
        
        vec2 dir = vec2(cos(currentAngle), sin(currentAngle)) * radius;
        vec2 sampleUV = uv + dir;
        vec3 sampleColor = texture2D(tex, sampleUV).rgb;
        
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
    
    vec3 primaryBloom = (color / max(total, 0.001)) * BLOOM_INTENSITY * BLOOM_TINT;
    
    // Secondary bloom (wider, softer)
    vec3 secondaryBloom = vec3(0.0);
    float secondaryTotal = 0.0;
    currentAngle = 0.0;
    
    for(int i = 0; i < BLOOM_SAMPLES/2; i++) {
        float ratio = sqrt(float(i)/float(BLOOM_SAMPLES/2));
        float radius = ratio * BLOOM_SECONDARY_RADIUS;
        currentAngle += goldenAngle;
        
        vec2 dir = vec2(cos(currentAngle), sin(currentAngle)) * radius;
        vec2 sampleUV = uv + dir;
        vec3 sampleColor = texture2D(tex, sampleUV).rgb;
        
        float weight = exp(-(radius * radius) * 8.0);
        secondaryBloom += sampleColor * weight;
        secondaryTotal += weight;
    }
    
    secondaryBloom = (secondaryBloom / max(secondaryTotal, 0.001)) * BLOOM_SECONDARY_INTENSITY;
    
    return primaryBloom + secondaryBloom;
}

// Enhanced scanlines with curvature
float applyScanlines(vec2 uv, float time) {
    float curved = uv.y + sin(uv.x * PI * 4.0) * SCANLINE_CURVATURE;
    float scan = sin(curved * SCANLINE_FREQUENCY * PI + time * SCANLINE_SPEED);
    scan = smoothstep(1.0 - SCANLINE_THICKNESS, 1.0, scan);
    return 1.0 - scan * SCANLINE_OPACITY;
}

// Enhanced VHS overlay with more distortion
vec3 applyVHSOverlay(vec2 uv, float time, vec3 originalColor) {
    vec2 displacement = VHS_OVERLAY_OFFSET * VHS_OVERLAY_DISPLACEMENT_SCALE *
        (1.0 + noise(uv * VHS_OVERLAY_NOISE_SCALE + time) * 0.6);

    vec3 overlay = texture2D(tex, uv + displacement).rgb;
    overlay.r = texture2D(tex, uv + displacement * 1.3).r;
    overlay.b = texture2D(tex, uv - displacement * 0.7).b;

    float wave = sin(time * VHS_OVERLAY_FREQ) * VHS_OVERLAY_WAVE_AMPLITUDE;
    float tracking = sin(uv.y * 20.0 + time * 2.0) * 0.02;
    
    return mix(
        originalColor,
        overlay * VHS_OVERLAY_TINT_RGB * (1.0 + wave + tracking),
        VHS_OVERLAY_INTENSITY * (0.7 + noise(uv + time) * 0.3)
    );
}

// Enhanced drift with multiple modes
vec2 applyDrift(vec2 uv, float time) {
    vec2 driftOffset = vec2(0.0);

    #if DRIFT_MODE == 0
        float driftAngle = time * DRIFT_SPEED;
        driftOffset = vec2(cos(driftAngle), sin(driftAngle)) * DRIFT_RADIUS;
    #elif DRIFT_MODE == 1
        driftOffset.x = sin(time * DRIFT_SPEED * DRIFT_FREQUENCY) * DRIFT_AMPLITUDE;
        driftOffset.y = cos(time * DRIFT_SPEED * DRIFT_FREQUENCY * 0.7) * DRIFT_AMPLITUDE;
    #elif DRIFT_MODE == 2
        driftOffset = DRIFT_DIRECTION * (time * DRIFT_SPEED);
    #endif

    return uv + driftOffset;
}

// Enhanced glitch with digital noise
vec3 applyGlitch(vec2 uv, float time, vec3 color, float isActive) {
    vec2 shift = vec2(
        GLITCH_COLOR_SHIFT * (random(vec2(time)) - 0.5),
        GLITCH_COLOR_SHIFT * (random(vec2(time + 1.0)) - 0.5)
    );
    
    vec3 distorted = vec3(
        texture2D(tex, uv + shift).r,
        texture2D(tex, uv).g,
        texture2D(tex, uv - shift).b
    );

    float currentInterval = floor(time / GLITCH_INTERVAL);
    float blockY = floor(uv.y * GLITCH_BLOCK_SIZE);
    float blockGlitch = step(random(vec2(blockY, currentInterval)), GLITCH_BLOCK_PROBABILITY);
    float displacement = (random(vec2(blockY, time)) - 0.5) * GLITCH_DISPLACEMENT;
    vec2 displacedUV = uv + vec2(displacement * isActive * blockGlitch, 0.0);

    // Digital noise
    float digitalNoise = (random(uv * 100.0 + time) - 0.5) * GLITCH_DIGITAL_NOISE * isActive;
    
    vec3 finalColor = mix(color, distorted, isActive * GLITCH_STRENGTH);
    finalColor = mix(finalColor, texture2D(tex, displacedUV).rgb, isActive * blockGlitch);
    finalColor += vec3(digitalNoise);
    
    return finalColor;
}

// Main shader
void main() {
    float alpha;
    vec3 color;
    vec2 processedUV = v_texcoord;

    // Apply lens distortion first
    processedUV = applyLensDistortion(processedUV);

    // Calculate glitch states
    float currentInterval = floor(time / GLITCH_INTERVAL);
    float tInInterval = fract(time / GLITCH_INTERVAL);
    
    float seedGlitch = random(vec2(currentInterval));
    float intervalActive = step(seedGlitch, GLITCH_PROBABILITY);
    float isActiveGlitch = intervalActive * step(tInInterval, GLITCH_DURATION);
    
    float seedXVib = random(vec2(currentInterval + 100.0));
    float xVibActive = step(seedXVib, GLITCH_X_VIBRATION_PROBABILITY) * intervalActive;
    float isActiveXVibration = xVibActive * step(tInInterval, GLITCH_DURATION);

    // Apply effects in order
    #if DEBUG_DRIFT
        processedUV = applyDrift(processedUV, time);
    #endif

    #if DEBUG_VIBRATION
        float vibration = sin(time * VIBRATION_FREQUENCY) * VIBRATION_AMPLITUDE;
        vibration += sin(time * VIBRATION_CHAOS_FREQ) * VIBRATION_AMPLITUDE * 0.3;
        processedUV.y += vibration;
    #endif

    #if DEBUG_GLITCH
        float xVib = (random(vec2(time, currentInterval)) - 0.5) * 
                    GLITCH_X_VIBRATION_AMPLITUDE * 
                    isActiveXVibration;
        processedUV.x += xVib;
    #endif

    processedUV = pixelate(processedUV);

    #if DEBUG_CA
        color = applyChromaticAberration(processedUV, time, alpha);
    #else
        vec4 base = texture2D(tex, processedUV);
        color = base.rgb;
        alpha = base.a;
    #endif

    #if DEBUG_GLITCH
        color = applyGlitch(processedUV, time, color, isActiveGlitch);
    #endif

    // Apply stylistic effects
    color = applyPixelGrid(processedUV, color);
    color = applyThermalNoise(processedUV, color, time);
    color = applyFilmGrain(processedUV, color, time);

    #if DEBUG_BLOOM
        color += calculateBloom(processedUV);
    #endif

    #if DEBUG_COLOR_TEMP
        color = mix(color, color * colorTemperatureToRGB(COLOR_TEMPERATURE), COLOR_TEMPERATURE_STRENGTH);
    #endif
    
    color = applyColorGrading(color);
    color = applyRetroBanding(color);
    color = applyColorDepthReduction(color, processedUV);

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
        color = applyVHSOverlay(processedUV, time, color);
    #endif

    gl_FragColor = vec4(clamp(color, 0.0, 1.0), alpha);
}
