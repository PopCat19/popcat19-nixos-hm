// Set high precision for floating-point calculations
precision highp float;

// Input texture coordinates
varying vec2 v_texcoord;

// Input texture and time uniform
uniform sampler2D tex;
uniform float time;

// [Debug Toggles]
#define DEBUG_CA       1       // Toggle chromatic aberration effect
#define DEBUG_BLOOM    1       // Toggle bloom effect
#define DEBUG_VIGNETTE 0       // Toggle vignette effect
#define DEBUG_PIXEL   0       // Toggle pixelation effect
#define COLOR_DEPTH_ENABLED 0  // Enable color depth reduction
#define DEBUG_SCANLINE 0       // Toggle scanline effect
#define DEBUG_VHS_OVERLAY 1    // Toggle VHS double overlay effect
#define DEBUG_GLITCH   1       // Toggle glitch effect
#define DEBUG_DRIFT    1       // Toggle drifting effect
#define DEBUG_COLOR_TEMP 1     // Toggle color temperature adjustment
#define DEBUG_VIBRATION 1      // Toggle vertical vibration effect
#define DEBUG_BITRATE   0       // Toggle bitrate compression artifacts

// [Effect Parameters]
// Bloom Parameters
#define BLOOM_INTENSITY       0.5     // Overall strength of bloom effect (0.0-1.0)
#define BLOOM_RADIUS          0.006    // Spread radius of bloom effect in texture coordinates
#define BLOOM_SAMPLES         64    // Number of sampling points (quality vs performance)
#define BLOOM_TINT           vec3(1.1, 0.9, 0.9) // RGB color multiplier for bloom
#define BLOOM_THRESHOLD       0.0     // Minimum brightness to trigger bloom (linear color space)
#define BLOOM_SOFT_THRESHOLD  1.0     // Smooth transition range for threshold (knee width)
#define BLOOM_FALLOFF_CURVE   32.0     // Controls bloom spread intensity (higher = faster falloff)

// Glitch Parameters
#define GLITCH_STRENGTH        0.1    // Intensity of glitch displacement
#define GLITCH_PROBABILITY     0.1    // Chance of occurring per interval (0.0-1.0)
#define GLITCH_X_VIBRATION_PROBABILITY 0.6 // Separate probability for X vibration
#define GLITCH_INTERVAL        3.0    // Time between glitch attempts (seconds)
#define GLITCH_DURATION        0.1    // Duration of each glitch burst (seconds)
#define GLITCH_BLOCK_SIZE      8.0    // Size of glitch blocks in pixels
#define GLITCH_DISPLACEMENT    0.01   // Maximum horizontal displacement
#define GLITCH_COLOR_SHIFT     0.0    // RGB channel separation strength
#define GLITCH_BLOCK_PROBABILITY 0.3  // Chance for individual blocks to glitch
#define GLITCH_X_VIBRATION_AMPLITUDE 0.006 // Strength of X-axis vibration during glitch

// Vignette Parameters
#define VIGNETTE_STRENGTH      0.4    // Darkness intensity at edges (0.0-1.0)
#define VIGNETTE_RADIUS        1.6    // Starting position from center (higher = smaller vignette)
#define VIGNETTE_SMOOTHNESS    0.8    // Edge transition smoothness (0.0-1.0)
#define VIGNETTE_ASPECT       vec2(1.0, 1.0) // Aspect ratio correction (affects vignette shape & pixelation grid)
#define VIGNETTE_COLOR        vec3(0.0, 0.0, 0.0) // Custom color for tint mode (RGB)
#define VIGNETTE_OFFSET       vec2(0.0, 0.0) // Center position offset (uv coordinates)
#define VIGNETTE_EXPONENT     1.0     // Non-linear falloff curve (1.0 = linear)
#define VIGNETTE_MODE         0       // 0 = Darkness only, 1 = Color tint + Darkness

// Chromatic Aberration Parameters
#define CA_RED_STRENGTH     0.001 // Red channel displacement strength
#define CA_BLUE_STRENGTH    0.001 // Blue channel displacement strength
#define CA_FALLOFF          1.0   // Global displacement scale multiplier
#define CA_ANGLE            0.0   // Displacement direction in radians
#define CA_FALLOFF_EXPONENT 1.0   // Edge effect curvature (higher = sharper transition)
#define CA_CENTER_STRENGTH  3.0   // Base effect strength at center (0.0-1.0+)

// Scanline Parameters
#define SCANLINE_OPACITY     0.2    // Opacity of black lines (0.0 transparent - 1.0 fully black)
#define SCANLINE_FREQUENCY   1.0    // Number of scanlines
#define SCANLINE_SPEED       -1.0   // Animation speed
#define SCANLINE_THICKNESS   0.2    // Line thickness control

// Drifting Effect Parameters
#define DRIFT_MODE 1           // Drift mode: 0 = Radial, 1 = Radial2, 2 = Linear
#define DRIFT_SPEED -1.6        // Speed of the drifting effect
#define DRIFT_RADIUS 0.002     // Radius of the circular drift (for radial mode)
#define DRIFT_AMPLITUDE 0.002  // Amplitude of the radial2 drift (for radial2 mode)
#define DRIFT_FREQUENCY 1.2    // Frequency of the radial2 drift (for radial2 mode)
#define DRIFT_DIRECTION vec2(1.0, 0.5) // Direction of the linear drift (for linear mode)

// Vibration Parameters
#define VIBRATION_AMPLITUDE 0.0004 // Strength of vertical vibration
#define VIBRATION_FREQUENCY 80.0  // Speed of vibration

// Color Settings
#define COLOR_DEPTH 16         // Bit depth reducation: 8, 16, or 24
const float COLOR_TEMPERATURE = 3200.0; // White balance in Kelvin (1000-40000)
const float COLOR_TEMPERATURE_STRENGTH = 1.0; // Color temperature mix strength (0.0-1.0)

// Pixelation Effect
#define PIXEL_GRID_SIZE 960.0   // Vertical resolution in pixels (higher = finer details, set aspect ratio via VIGNETTE_ASPECT)

// VHS Overlay Parameters
#define VHS_OVERLAY_INTENSITY  0.3    // Strength of overlay effect (0.0-1.0)
#define VHS_OVERLAY_OFFSET     vec2(0.005, -0.003) // Base displacement vector
#define VHS_OVERLAY_SPEED      0.3    // Animation speed for displacement
#define VHS_OVERLAY_TINT_RGB   vec3(1.5, 0.8, 1.2) // Color tint for overlay
#define VHS_OVERLAY_NOISE_SCALE 512.0  // Noise pattern scale
#define VHS_OVERLAY_FREQ       0.3    // Wave frequency for pulsation effect
#define VHS_OVERLAY_DISPLACEMENT_SCALE 0.333 // Scaling factor for displacement
#define VHS_OVERLAY_WAVE_AMPLITUDE 0.1 // Amplitude of the pulsation wave

// Bitrate Compression Artifact Parameters
#define BITRATE_BLOCK_SIZE    256.0    // Size of compression blocks in pixels
#define BITRATE_STRENGTH       1.0    // Strength of compression artifacts (0.0-1.0)
#define BITRATE_NOISE_AMOUNT   0.1    // Amount of block edge noise (0.0-1.0)

const float PI = 3.14159265359;

// --- Utility Functions ---
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// --- Color Depth Reduction ---
vec3 applyColorDepthReduction(vec3 color) {
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
    return floor(color * maxValues + 0.5) / maxValues;
#else
    return color;
#endif
}

// --- Pixelation Effect ---
vec2 pixelate(vec2 uv) {
#if DEBUG_PIXEL
    // Correct aspect ratio adjustment using VIGNETTE_ASPECT
    vec2 grid = vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE * (VIGNETTE_ASPECT.y / VIGNETTE_ASPECT.x));
    vec2 pixelUV = floor(uv * grid) / grid;
    return pixelUV;
#else
    return uv;
#endif
}

vec3 applyPixelGrid(vec2 uv, vec3 color) {
#if DEBUG_PIXEL
    // Match grid calculation with pixelate function for consistent aspect ratio
    vec2 grid = vec2(PIXEL_GRID_SIZE, PIXEL_GRID_SIZE * (VIGNETTE_ASPECT.y / VIGNETTE_ASPECT.x));
    vec2 pixelCoord = uv * grid;
    vec2 gridLine = smoothstep(0.95, 0.99, fract(pixelCoord));
    float gridMask = 1.0 - max(gridLine.x, gridLine.y);
    return color * mix(vec3(0.2), vec3(1.0), gridMask);
#else
    return color;
#endif
}

// --- Bitrate Compression Artifacts ---
vec3 applyBitrateCompression(vec2 uv, vec3 color) {
#if DEBUG_BITRATE
    // Calculate block position
    vec2 blockUV = floor(uv * BITRATE_BLOCK_SIZE) / BITRATE_BLOCK_SIZE;
    
    // Calculate average color for the block
    vec3 avgColor = vec3(0.0);
    for(float x = 0.0; x < 1.0; x += 0.25) {
        for(float y = 0.0; y < 1.0; y += 0.25) {
            vec2 sampleUV = blockUV + vec2(x, y) / BITRATE_BLOCK_SIZE;
            avgColor += texture2D(tex, sampleUV).rgb;
        }
    }
    avgColor /= 16.0;
    
    // Add noise to block edges
    float noise = random(blockUV * BITRATE_BLOCK_SIZE) * BITRATE_NOISE_AMOUNT;
    avgColor *= 1.0 + noise * BITRATE_STRENGTH;
    
    return mix(color, avgColor, BITRATE_STRENGTH);
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
    
    alpha = texture2D(tex, uv).a;
    return vec3(
        texture2D(tex, uv + dir * strength_r).r,
        texture2D(tex, uv).g,
        texture2D(tex, uv - dir * strength_b).b
    );
}

// --- Optimized Bloom Function ---
vec3 calculateBloom(vec2 uv) {
    vec3 color = vec3(0.0);
    float total = 0.0;
    const float goldenAngle = 2.39996; // 137.508° for optimal distribution
    float currentAngle = 0.0;
    
    for(int i = 0; i < BLOOM_SAMPLES; i++) {
        // Spiral distribution with golden angle
        float ratio = sqrt(float(i)/float(BLOOM_SAMPLES)); // Square root for area distribution
        float radius = ratio * BLOOM_RADIUS;
        currentAngle += goldenAngle;
        
        // Calculate sample direction
        vec2 dir = vec2(cos(currentAngle), sin(currentAngle)) * radius;
        
        // Get sample color
        vec2 sampleUV = uv + dir;
        vec3 sampleColor = texture2D(tex, sampleUV).rgb;
        
        // Calculate luminance threshold
        float luminance = dot(sampleColor, vec3(0.299, 0.587, 0.114));
        float softThreshold = smoothstep(
            BLOOM_THRESHOLD - BLOOM_SOFT_THRESHOLD,
            BLOOM_THRESHOLD + BLOOM_SOFT_THRESHOLD,
            luminance
        );
        
        // Gaussian-style weight calculation
        float weight = exp(-(radius * radius) * BLOOM_FALLOFF_CURVE) * softThreshold;
        
        color += sampleColor * weight;
        total += weight;
    }
    
    return (color / max(total, 0.001)) * BLOOM_INTENSITY * BLOOM_TINT;
}

// --- Scanline Effect ---
float applyScanlines(vec2 uv, float time) {
    float scan = sin(uv.y * SCANLINE_FREQUENCY * PI + time * SCANLINE_SPEED);
    scan = smoothstep(1.0 - SCANLINE_THICKNESS, 1.0, scan);
    return 1.0 - scan * SCANLINE_OPACITY;
}

// --- VHS Double Overlay Effect ---
vec3 applyVHSOverlay(vec2 uv, float time, vec3 originalColor) {
    vec2 displacement = VHS_OVERLAY_OFFSET * VHS_OVERLAY_DISPLACEMENT_SCALE *
        (1.0 + random(uv * VHS_OVERLAY_NOISE_SCALE + time) * 0.5);

    vec3 overlay = texture2D(tex, uv + displacement).rgb;
    overlay.r = texture2D(tex, uv + displacement * 1.2).r;
    overlay.b = texture2D(tex, uv - displacement * 0.8).b;

    return mix(
        originalColor,
        overlay * VHS_OVERLAY_TINT_RGB * (1.0 + sin(time * VHS_OVERLAY_FREQ) * VHS_OVERLAY_WAVE_AMPLITUDE),
        VHS_OVERLAY_INTENSITY * (0.8 + random(uv + time) * 0.2)
    );
}

// --- Drifting Effect ---
vec2 applyDrift(vec2 uv, float time) {
    vec2 driftOffset = vec2(0.0);

    #if DRIFT_MODE == 0
        // Radial (circular) drift
        float driftAngle = time * DRIFT_SPEED;
        driftOffset = vec2(cos(driftAngle), sin(driftAngle)) * DRIFT_RADIUS;
    #elif DRIFT_MODE == 1
        // Radial2 drift (formerly zigzag)
        driftOffset.x = sin(time * DRIFT_SPEED * DRIFT_FREQUENCY) * DRIFT_AMPLITUDE;
        driftOffset.y = cos(time * DRIFT_SPEED * DRIFT_FREQUENCY) * DRIFT_AMPLITUDE;
    #elif DRIFT_MODE == 2
        // Linear drift
        driftOffset = DRIFT_DIRECTION * (time * DRIFT_SPEED);
    #endif

    return uv + driftOffset;
}

// --- Glitch Effect ---
vec3 applyGlitch(vec2 uv, float time, vec3 color, float isActive) {
    // Random RGB shift
    vec2 shift = vec2(
        GLITCH_COLOR_SHIFT * (random(vec2(time)) - 0.5),
        GLITCH_COLOR_SHIFT * (random(vec2(time + 1.0)) - 0.5)
    );
    vec3 distorted = vec3(
        texture2D(tex, uv + shift).r,
        texture2D(tex, uv).g,
        texture2D(tex, uv - shift).b
    );

    // Block displacement
    float currentInterval = floor(time / GLITCH_INTERVAL);
    float blockY = floor(uv.y * GLITCH_BLOCK_SIZE);
    float blockGlitch = step(random(vec2(blockY, currentInterval)), GLITCH_BLOCK_PROBABILITY);
    float displacement = (random(vec2(blockY, time)) - 0.5) * GLITCH_DISPLACEMENT;
    vec2 displacedUV = uv + vec2(displacement * isActive * blockGlitch, 0.0);

    // Mix effects
    vec3 finalColor = mix(color, distorted, isActive * GLITCH_STRENGTH);
    finalColor = mix(finalColor, texture2D(tex, displacedUV).rgb, isActive * blockGlitch);
    
    return finalColor;
}

// --- Main Shader ---
void main() {
    float alpha;
    vec3 color;
    vec2 processedUV = v_texcoord;

    // Calculate activation states
    float currentInterval = floor(time / GLITCH_INTERVAL);
    float tInInterval = fract(time / GLITCH_INTERVAL);
    
    // Main glitch activation
    float seedGlitch = random(vec2(currentInterval));
    float intervalActive = step(seedGlitch, GLITCH_PROBABILITY);
    float isActiveGlitch = intervalActive * step(tInInterval, GLITCH_DURATION);
    
    // X vibration activation (separate probability)
    float seedXVib = random(vec2(currentInterval + 100.0)); // Different seed
    float xVibActive = step(seedXVib, GLITCH_X_VIBRATION_PROBABILITY) * intervalActive;
    float isActiveXVibration = xVibActive * step(tInInterval, GLITCH_DURATION);

    // Apply drifting effect
    #if DEBUG_DRIFT
        processedUV = applyDrift(processedUV, time);
    #endif

    // Apply vertical vibration
    #if DEBUG_VIBRATION
        processedUV.y += sin(time * VIBRATION_FREQUENCY) * VIBRATION_AMPLITUDE;
    #endif

    // Apply X-axis vibration with separate probability
    #if DEBUG_GLITCH
        float xVib = (random(vec2(time, currentInterval)) - 0.5) * 
                    GLITCH_X_VIBRATION_AMPLITUDE * 
                    isActiveXVibration;
        processedUV.x += xVib;
    #endif

    // Apply pixelation
    processedUV = pixelate(processedUV);

    // Chromatic aberration
    #if DEBUG_CA
        color = applyChromaticAberration(processedUV, alpha);
    #else
        vec4 base = texture2D(tex, processedUV);
        color = base.rgb;
        alpha = base.a;
    #endif

    // Apply glitch effect
    #if DEBUG_GLITCH
        color = applyGlitch(processedUV, time, color, isActiveGlitch);
    #endif

    // Apply pixel grid overlay
    color = applyPixelGrid(processedUV, color);

    // Add bloom effect
    #if DEBUG_BLOOM
        color += calculateBloom(processedUV);
    #endif

    // Apply bitrate compression artifacts
    #if DEBUG_BITRATE
        color = applyBitrateCompression(processedUV, color);
    #endif

    // Color temperature adjustment
    #if DEBUG_COLOR_TEMP
        color = mix(color, color * colorTemperatureToRGB(COLOR_TEMPERATURE), COLOR_TEMPERATURE_STRENGTH);
    #endif
    
    // Color depth quantization
    color = applyColorDepthReduction(color);

    // Apply scanlines
    #if DEBUG_SCANLINE
        color *= applyScanlines(v_texcoord, time);
    #endif

    // Vignette application
    #if DEBUG_VIGNETTE
        float vig = computeVignette(processedUV);
        #if VIGNETTE_MODE == 0
            color *= mix(1.0 - VIGNETTE_STRENGTH, 1.0, vig);
        #else
            color = mix(color * VIGNETTE_COLOR, color, vig);
            color *= mix(1.0 - VIGNETTE_STRENGTH/2.0, 1.0, vig);
        #endif
    #endif

    // Apply VHS overlay effect
    #if DEBUG_VHS_OVERLAY
        color = applyVHSOverlay(processedUV, time, color);
    #endif

    // Final output
    gl_FragColor = vec4(color, alpha);
}
