#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;
uniform sampler2D u_texture;
uniform vec2 u_resolution;
uniform float u_time;

void main() {
    // Curvature parameters
    vec2 curvature = vec2(4.0, 4.0);
    vec2 scanlineIntensity = vec2(0.5, 0.5);
    float screenTint = 0.3;
    
    // Normalized pixel coordinates
    vec2 uv = v_texCoord;
    
    // Screen curvature effect
    vec2 curvedUV = uv - 0.5;
    curvedUV *= 1.0 + pow(length(curvedUV), 3.0) * 0.1;
    curvedUV += 0.5;
    
    // Chromatic aberration
    float chromaOffset = 0.002;
    vec3 color;
    color.r = texture2D(u_texture, curvedUV + vec2(chromaOffset, 0.0)).r;
    color.g = texture2D(u_texture, curvedUV).g;
    color.b = texture2D(u_texture, curvedUV - vec2(chromaOffset, 0.0)).b;
    
    // Scanlines
    float scanline = sin(curvedUV.y * u_resolution.y * 3.1415) * 0.5 + 0.5;
    scanline = pow(scanline, 8.0) * scanlineIntensity.x + (1.0 - scanlineIntensity.y);
    color *= scanline;
    
    // Phosphor grid
    vec2 grid = fract(curvedUV * u_resolution / 4.0);
    float gridMask = (1.0 - max(grid.x, grid.y)) * 0.1;
    color += gridMask;
    
    // Vignette
    vec2 uvVignette = uv * (1.0 - uv);
    float vignette = uvVignette.x * uvVignette.y * 25.0;
    vignette = pow(vignette, 0.25);
    color *= vignette;
    
    // Color tint
    color *= vec3(0.7, 1.0, 0.7) * (1.0 - screenTint) + vec3(1.0) * screenTint;
    
    // CRT gamma
    color = pow(color, vec3(1.0/2.2));
    
    gl_FragColor = vec4(color, 1.0);
}
