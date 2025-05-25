// Set high precision for floating-point calculations
precision highp float;

// Input texture coordinates
varying vec2 v_texcoord;

// Input texture
uniform sampler2D tex;

// Effect parameters
const float BLOOM_INTENSITY = 0.8;          // Strength of bloom effect
const float BLOOM_RADIUS = 0.006;           // Size of bloom sampling area
const int BLOOM_SAMPLES = 12;                // Number of bloom samples
const float BF_TEMPERATURE = 3200.0;        // Color temperature in Kelvin
const float BF_STRENGTH = 1.0;              // Strength of temperature effect

// Standard luminance conversion weights
const vec3 LUMINANCE_FACTORS = vec3(0.2126, 0.7152, 0.0722);

// Convert color temperature (Kelvin) to RGB color
vec3 colorTemperatureToRGB(float temperature) {
    // Matrix coefficients for temperature conversion
    mat3 m = (temperature <= 6500.0) ? 
        mat3(0.0, -2902.1955373783176, -8257.7997278925690,
             0.0, 1669.5803561666639, 2575.2827530017594,
             1.0, 1.3302673723350029, 1.8993753891711275)
        : mat3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690,
               -2666.3474220535695, -2173.1012343082230, 2575.2827530017594,
               0.55995389139931482, 0.70381203140554553, 1.8993753891711275);
    
    // Calculate and clamp RGB values
    vec3 result = clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0));
    return mix(result, vec3(1.0), smoothstep(1000.0, 0.0, temperature));
}

// Sample texture in a circular pattern to create bloom effect
vec3 sampleBloom(vec2 uv, float radius) {
    vec3 color = vec3(0.0);
    float total = 0.0;
    
    // Sample in circular pattern
    for (int i = 0; i < BLOOM_SAMPLES; i++) {
        float angle = float(i) * 3.14159265359 / float(BLOOM_SAMPLES);
        vec2 dir = vec2(cos(angle), sin(angle)) * radius;
        
        // Sample along radius with decreasing weight
        for (float d = 1.0 / float(BLOOM_SAMPLES); d <= 1.0; d += 2.0 / float(BLOOM_SAMPLES)) {
            float weight = 1.0 - d;
            weight *= weight;  // Quadratic falloff
            vec2 offset = dir * d;
            
            // Sample symmetrically around center point
            color += (texture2D(tex, uv + offset).rgb + texture2D(tex, uv - offset).rgb) * weight;
            total += 2.0 * weight;
        }
    }
    
    return color / total;  // Normalize by total weight
}

void main() {
    // Sample original color
    vec3 color = texture2D(tex, v_texcoord).rgb;

    // Apply bloom effect
    vec3 bloomColor = sampleBloom(v_texcoord, BLOOM_RADIUS);
    bloomColor = mix(bloomColor, bloomColor * vec3(1.1, 0.9, 0.9), 0.3);  // Tint bloom slightly
    color += bloomColor * BLOOM_INTENSITY;

    // Preserve luminance
    float luminance = dot(color, LUMINANCE_FACTORS);
    color *= mix(1.0, luminance / max(luminance, 1e-5), 1.0);

    // Apply color temperature
    color = mix(color, color * colorTemperatureToRGB(BF_TEMPERATURE), BF_STRENGTH);

    // Output final color
    gl_FragColor = vec4(color, 1.0);
}


