// vim: set ft=glsl:

precision highp float;
varying highp vec2 v_texcoord;
uniform sampler2D tex;

#define STRENGTH 0.0028
#define CENTER_TRANSITION_SIZE 0.1  // Size of the transition around the center

const float temperature = 2800.0;
const float temperatureStrength = 1.0;

#define WithQuickAndDirtyLuminancePreservation
const float LuminancePreservationFactor = 1.0;

// function from https://www.shadertoy.com/view/4sc3D7
// valid from 1000 to 40000 K (and additionally 0 for pure full white)
vec3 colorTemperatureToRGB(const in float temperature) {
    mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                                            vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                                            vec3(1.0, 1.3302673723350029, 1.8993753891711275))
                                     : mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                                            vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                                            vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));
    return mix(clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)),
               vec3(1.0), smoothstep(1000.0, 0.0, temperature));
}

void main() {
    // First apply chromatic aberration
    vec2 center = vec2(0.5, 0.5);
    vec2 offset = (v_texcoord - center) * STRENGTH;

    float rSquared = dot(offset, offset);
    float distortion = 1.0 + 1.0 * rSquared;
    vec2 distortedOffset = offset * distortion;

    // Apply transition size to limit distortion
    float transitionFactor = smoothstep(CENTER_TRANSITION_SIZE - 0.1, CENTER_TRANSITION_SIZE, length(v_texcoord - center));
    vec2 redOffset = vec2(distortedOffset.x, distortedOffset.y) * transitionFactor;
    vec2 blueOffset = vec2(distortedOffset.x, distortedOffset.y) * transitionFactor;

    vec4 redColor = texture2D(tex, v_texcoord + redOffset);
    vec4 blueColor = texture2D(tex, v_texcoord + blueOffset);
    vec4 greenColor = texture2D(tex, v_texcoord);

    vec3 color = vec3(redColor.r, greenColor.g, blueColor.b);

    // Then apply color temperature
#ifdef WithQuickAndDirtyLuminancePreservation
    color *= mix(1.0, dot(color, vec3(0.2126, 0.7152, 0.0722)) / max(dot(color, vec3(0.2126, 0.7152, 0.0722)), 1e-5),
                 LuminancePreservationFactor);
#endif

    color = mix(color, color * colorTemperatureToRGB(temperature), temperatureStrength);

    gl_FragColor = vec4(color, 1.0);
}
