# Multipass Shader System for Hyprland

A modular, high-performance shader pipeline featuring chromatic aberration, analog glitch effects, bloom, CRT simulation, PC-98 palette quantization, and vintage post-processing effects.

## 📁 File Structure

```
multipass/
├── pass1_base.glsl       # Chromatic aberration + glitch effects
├── pass2_bloom.glsl      # Multi-pass bloom with 6 iterations
├── pass3_crt.glsl        # CRT curvature, shadow mask, scanlines
├── pass4_color.glsl      # PC-98 palette + dithering
├── pass5_final.glsl      # Bloom composite, grain, VHS, vignette
└── README.md             # This file
```

## 🎯 Render Pipeline

```
Original Texture
      ↓
┌─────────────────────────┐
│ Pass 1: Base Effects    │ → Framebuffer A (RGBA8/RGBA16F)
│ - Chromatic Aberration  │
│ - Analog Glitch         │
└─────────────────────────┘
      ↓
┌─────────────────────────┐
│ Pass 2: Bloom × 6       │ → Framebuffer B (RGBA16F, Additive)
│ - Multiple blur sizes   │
│ - Threshold-based glow  │
└─────────────────────────┘
      ↓
┌─────────────────────────┐
│ Pass 3: CRT Effects     │ → Framebuffer C (RGBA8)
│ - Screen curvature      │
│ - Shadow mask           │
│ - Scanlines             │
└─────────────────────────┘
      ↓
┌─────────────────────────┐
│ Pass 4: Color Grading   │ → Framebuffer D (RGBA8)
│ - PC-98 palette         │
│ - Dithering             │
└─────────────────────────┘
      ↓
┌─────────────────────────┐
│ Pass 5: Final Composite │ → Screen Output
│ - Bloom addition        │
│ - Film grain            │
│ - VHS artifacts         │
│ - Vignette              │
└─────────────────────────┘
```

## 🚀 Implementation Guide

### Hyprland Configuration

Since Hyprland uses a single-pass shader system, you'll need to create a wrapper that implements the multi-pass pipeline. Here's the recommended approach:

#### Option 1: Merge Passes (Simplified)

For Hyprland compatibility, merge all passes into a single shader:

```glsl
#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform float time;

// Include all functions from pass1_base.glsl
// ... (chromatic aberration, glitch functions)

// Include simplified bloom (single-pass approximation)
// ... (bloom functions with reduced samples)

// Include all functions from pass3_crt.glsl
// ... (CRT curvature, shadow mask, scanlines)

// Include all functions from pass4_color.glsl
// ... (PC-98 palette, dithering)

// Include all functions from pass5_final.glsl
// ... (grain, VHS, vignette)

void main() {
    // Execute all passes in sequence
    vec2 uv = v_texcoord;
    
    // Pass 1: Base effects
    float alpha;
    vec3 color = applyChromaticAberration(uv, alpha);
    // ... apply glitch
    
    // Pass 2: Simplified bloom (approximated)
    vec3 bloom = approximateBloom(uv, color);
    
    // Pass 3: CRT effects
    uv = applyCRTCurvature(uv);
    // ... apply shadow mask, scanlines
    
    // Pass 4: Color grading
    color = applyPC98PaletteWithDither(color, v_texcoord * 960.0, time);
    
    // Pass 5: Final composite
    color += bloom;
    color = applyGrain(v_texcoord, color, time);
    color = applyVHSEffect(v_texcoord, time, color);
    float vig = computeVignette(v_texcoord);
    color *= mix(0.6, 1.0, vig);
    
    fragColor = vec4(color, alpha);
}
```

#### Option 2: External Compositor

For true multi-pass rendering with Hyprland, you would need:

1. **Custom Hyprland Fork**: Modify Hyprland to support multi-pass shaders
2. **External Post-Processor**: Use tools like `picom` or a custom compositor wrapper
3. **OBS Studio**: Capture desktop and apply shaders as filters

### OpenGL/WebGL Implementation

For standalone applications or game engines:

```c
// Pseudocode for OpenGL 3.2+ / ES 3.2

// 1. Initialize framebuffers
Framebuffer fboA, fboB, fboC, fboD;
Texture texA, texB, texC, texD;

// Create textures
texA = createTexture(width, height, GL_RGBA8);
texB = createTexture(width/2, height/2, GL_RGBA16F); // Half-res for bloom
texC = createTexture(width, height, GL_RGBA8);
texD = createTexture(width, height, GL_RGBA8);

// Attach to framebuffers
fboA.attachTexture(texA);
fboB.attachTexture(texB);
fboC.attachTexture(texC);
fboD.attachTexture(texD);

// 2. Load shaders
ShaderProgram pass1 = loadShader("pass1_base.glsl");
ShaderProgram pass2 = loadShader("pass2_bloom.glsl");
ShaderProgram pass3 = loadShader("pass3_crt.glsl");
ShaderProgram pass4 = loadShader("pass4_color.glsl");
ShaderProgram pass5 = loadShader("pass5_final.glsl");

// 3. Render loop
void render(float time) {
    // Pass 1: Base effects
    fboA.bind();
    pass1.use();
    pass1.setUniform("tex", originalTexture);
    pass1.setUniform("time", time);
    drawFullscreenQuad();
    
    // Pass 2: Bloom (6 iterations, additive)
    fboB.bind();
    glClear(GL_COLOR_BUFFER_BIT);
    pass2.use();
    pass2.setUniform("tex", texA);
    pass2.setUniform("time", time);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    
    for (int i = 0; i < 6; i++) {
        pass2.setUniform("blurPass", i);
        drawFullscreenQuad();
    }
    
    glDisable(GL_BLEND);
    
    // Pass 3: CRT effects
    fboC.bind();
    pass3.use();
    pass3.setUniform("tex", texA);
    pass3.setUniform("time", time);
    drawFullscreenQuad();
    
    // Pass 4: Color grading
    fboD.bind();
    pass4.use();
    pass4.setUniform("tex", texC);
    pass4.setUniform("time", time);
    drawFullscreenQuad();
    
    // Pass 5: Final composite
    glBindFramebuffer(GL_FRAMEBUFFER, 0); // Screen
    pass5.use();
    pass5.setUniform("tex", texD);
    pass5.setUniform("bloomTex", texB);
    pass5.setUniform("time", time);
    drawFullscreenQuad();
}
```

### WebGL 2.0 Implementation

```javascript
// Initialize WebGL 2.0 context
const gl = canvas.getContext('webgl2');

// Helper: Create framebuffer with texture
function createFramebuffer(width, height, internalFormat) {
    const texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, width, height, 0, 
                  gl.RGBA, gl.FLOAT, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    
    const fbo = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, 
                           gl.TEXTURE_2D, texture, 0);
    
    return { fbo, texture };
}

// Setup
const fboA = createFramebuffer(1920, 1080, gl.RGBA8);
const fboB = createFramebuffer(960, 540, gl.RGBA16F);
const fboC = createFramebuffer(1920, 1080, gl.RGBA8);
const fboD = createFramebuffer(1920, 1080, gl.RGBA8);

// Load shaders (async)
const programs = await Promise.all([
    loadShaderProgram(gl, 'pass1_base.glsl'),
    loadShaderProgram(gl, 'pass2_bloom.glsl'),
    loadShaderProgram(gl, 'pass3_crt.glsl'),
    loadShaderProgram(gl, 'pass4_color.glsl'),
    loadShaderProgram(gl, 'pass5_final.glsl')
]);

// Render function
function render(time) {
    // Pass 1
    gl.bindFramebuffer(gl.FRAMEBUFFER, fboA.fbo);
    gl.useProgram(programs[0]);
    gl.uniform1f(gl.getUniformLocation(programs[0], 'time'), time);
    drawQuad();
    
    // Pass 2: Bloom
    gl.bindFramebuffer(gl.FRAMEBUFFER, fboB.fbo);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.useProgram(programs[1]);
    gl.bindTexture(gl.TEXTURE_2D, fboA.texture);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.ONE, gl.ONE);
    
    for (let i = 0; i < 6; i++) {
        gl.uniform1i(gl.getUniformLocation(programs[1], 'blurPass'), i);
        drawQuad();
    }
    
    gl.disable(gl.BLEND);
    
    // Pass 3
    gl.bindFramebuffer(gl.FRAMEBUFFER, fboC.fbo);
    gl.useProgram(programs[2]);
    gl.bindTexture(gl.TEXTURE_2D, fboA.texture);
    drawQuad();
    
    // Pass 4
    gl.bindFramebuffer(gl.FRAMEBUFFER, fboD.fbo);
    gl.useProgram(programs[3]);
    gl.bindTexture(gl.TEXTURE_2D, fboC.texture);
    drawQuad();
    
    // Pass 5
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.useProgram(programs[4]);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, fboD.texture);
    gl.activeTexture(gl.TEXTURE1);
    gl.bindTexture(gl.TEXTURE_2D, fboB.texture);
    gl.uniform1i(gl.getUniformLocation(programs[4], 'tex'), 0);
    gl.uniform1i(gl.getUniformLocation(programs[4], 'bloomTex'), 1);
    drawQuad();
    
    requestAnimationFrame(render);
}

requestAnimationFrame(render);
```

## ⚙️ Configuration & Tweaking

### Pass 1: Chromatic Aberration & Glitch

```glsl
// Chromatic Aberration
#define CA_RED_STRENGTH     0.001   // Red channel offset
#define CA_BLUE_STRENGTH    0.001   // Blue channel offset
#define CA_FALLOFF_EXPONENT 1.0     // Edge vs center distribution
#define CA_CENTER_STRENGTH  3.0     // Center emphasis multiplier

// Glitch
#define GLITCH_STRENGTH     1.0     // Overall intensity
#define GLITCH_PROBABILITY  0.20    // 20% chance per interval
#define GLITCH_INTERVAL     3.0     // Seconds between checks
#define GLITCH_DURATION     0.12    // Glitch duration in seconds
#define GLITCH_SPEED        64.0    // Animation speed
```

### Pass 2: Bloom

```glsl
#define BLOOM_INTENSITY       0.24    // Overall bloom strength
#define BLOOM_RADIUS          0.0016  // Blur spread
#define BLOOM_RADIAL_SAMPLES  24      // Samples per direction (8 dirs)
#define BLOOM_THRESHOLD       0.96    // Brightness threshold
#define BLOOM_SOFT_THRESHOLD  0.3     // Threshold smoothness
#define BLOOM_TINT            vec3(1.1, 0.9, 0.85) // Color tint
```

**Performance tip**: Reduce `BLOOM_RADIAL_SAMPLES` to 16 or 12 for faster rendering.

### Pass 3: CRT Effects

```glsl
// Curvature
#define CRT_CURVE_STRENGTH 0.15     // Screen bend amount
#define CRT_CORNER_RADIUS  0.05     // Corner rounding
#define CRT_EDGE_FADE      0.02     // Edge darkening width

// Shadow Mask (phosphor pattern)
#define SHADOW_MASK_TYPE 0          // 0=Aperture, 1=Slot, 2=Dot
#define SHADOW_MASK_STRENGTH 0.3    // Mask visibility
#define SHADOW_MASK_SIZE 2.0        // Pattern scale

// Scanlines
#define SCANLINE_OPACITY    0.25    // Line darkness
#define SCANLINE_FREQUENCY  1.0     // Line density
#define SCANLINE_SPEED      -1.0    // Scroll speed (negative = up)
#define SCANLINE_THICKNESS  0.2     // Line width
```

### Pass 4: Color Grading

```glsl
#define DITHER_MODE 3               // Dithering algorithm
#define DITHER_STRENGTH 0.2         // Dither intensity
#define DITHER_BIAS 0.6             // Threshold offset
#define DITHER_COLORED 1            // Per-channel dithering
#define DITHER_GAMMA 2.2            // Gamma correction
#define DITHER_PRE_STRENGTH 4.0     // Pre-quantization noise
```

**Color palettes**: Edit the `PC98_PALETTE` array to use custom color schemes.

### Pass 5: Final Composite

```glsl
// Grain
#define GRAIN_INTENSITY 0.08        // Film grain strength
#define GRAIN_SIZE 800.0            // Grain detail
#define GRAIN_SPEED 0.5             // Animation speed

// VHS
#define VHS_INTENSITY        0.16   // Overall VHS effect strength
#define VHS_JITTER_STRENGTH  0.004  // Horizontal jitter
#define VHS_WAVE_FREQ        2.0    // Wave distortion frequency
#define VHS_COLOR_SHIFT      0.0015 // Chromatic shift

// Vignette
#define VIGNETTE_STRENGTH    0.4    // Edge darkening
#define VIGNETTE_RADIUS      1.6    // Vignette size
#define VIGNETTE_SMOOTHNESS  0.8    // Edge softness
```

## 🎨 Effect Presets

### Subtle (Performance Focused)

```glsl
// Pass 1
CA_RED_STRENGTH = 0.0005
GLITCH_PROBABILITY = 0.1

// Pass 2
BLOOM_RADIAL_SAMPLES = 12
BLOOM_INTENSITY = 0.15

// Pass 3
SCANLINE_OPACITY = 0.15
SHADOW_MASK_STRENGTH = 0.2

// Pass 4
DITHER_STRENGTH = 0.1

// Pass 5
GRAIN_INTENSITY = 0.04
VHS_INTENSITY = 0.08
```

### Intense (Vintage Heavy)

```glsl
// Pass 1
CA_RED_STRENGTH = 0.002
GLITCH_PROBABILITY = 0.35

// Pass 2
BLOOM_INTENSITY = 0.35
BLOOM_RADIUS = 0.0024

// Pass 3
SCANLINE_OPACITY = 0.35
SHADOW_MASK_STRENGTH = 0.5
CRT_CURVE_STRENGTH = 0.25

// Pass 4
DITHER_STRENGTH = 0.35

// Pass 5
GRAIN_INTENSITY = 0.12
VHS_INTENSITY = 0.25
VIGNETTE_STRENGTH = 0.6
```

### Clean CRT (No Glitch/VHS)

```glsl
// Pass 1
GLITCH_PROBABILITY = 0.0

// Pass 2
BLOOM_INTENSITY = 0.20

// Pass 3
SCANLINE_OPACITY = 0.20
SHADOW_MASK_STRENGTH = 0.25

// Pass 4
DITHER_STRENGTH = 0.15

// Pass 5
VHS_INTENSITY = 0.0
GRAIN_INTENSITY = 0.05
```

## 🔧 Performance Optimization

### 1. Reduce Bloom Quality

```glsl
// In pass2_bloom.glsl
#define BLOOM_RADIAL_SAMPLES 12  // Default: 24
```

Reduce iterations:
```c
// Render only 4 bloom passes instead of 6
for (int i = 0; i < 4; i++) {
    pass2.setUniform("blurPass", i);
    drawFullscreenQuad();
}
```

### 2. Lower Bloom Resolution

```c
// Render bloom at 1/4 resolution instead of 1/2
texB = createTexture(width/4, height/4, GL_RGBA16F);
```

### 3. Disable Expensive Effects

```glsl
// Pass 1: Disable glitch
#define GLITCH_PROBABILITY 0.0

// Pass 3: Disable shadow mask
#define SHADOW_MASK_STRENGTH 0.0

// Pass 4: Disable dithering (use direct palette)
#define DITHER_PRE_QUANTIZE 0

// Pass 5: Disable VHS
#define VHS_INTENSITY 0.0
```

### 4. Use Lower Precision

```glsl
// Change from highp to mediump in mobile/low-end devices
precision mediump float;
```

### 5. Merge Passes

Combine Pass 3 and Pass 4 into a single shader to reduce texture reads.

## 📊 Framebuffer Requirements

| Buffer | Resolution | Format    | Purpose              |
|--------|-----------|-----------|----------------------|
| A      | Full      | RGBA8     | Base effects         |
| B      | Half/Full | RGBA16F   | Bloom accumulation   |
| C      | Full      | RGBA8     | CRT processed        |
| D      | Full      | RGBA8     | Color graded         |

**Memory usage** (1920×1080):
- Full resolution RGBA8: ~8.3 MB
- Full resolution RGBA16F: ~16.6 MB
- Half resolution RGBA16F: ~4.2 MB

**Total**: ~37 MB (with half-res bloom) or ~49 MB (full-res bloom)

## 🐛 Troubleshooting

### Black screen output

1. Check framebuffer completeness:
```c
if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    printf("Framebuffer incomplete!\n");
}
```

2. Verify texture formats are supported (RGBA16F requires extensions)

3. Check shader compilation errors

### Bloom not visible

1. Ensure additive blending is enabled:
```c
glEnable(GL_BLEND);
glBlendFunc(GL_ONE, GL_ONE);
```

2. Verify `bloomTex` uniform is bound to correct texture unit

3. Increase `BLOOM_INTENSITY` or decrease `BLOOM_THRESHOLD`

### Performance issues

1. Profile each pass individually
2. Reduce bloom samples and passes
3. Lower bloom framebuffer resolution
4. Disable heavy effects (glitch, VHS, dithering)

### Color banding

1. Use RGBA16F for intermediate buffers
2. Increase `DITHER_PRE_STRENGTH`
3. Enable gamma-correct rendering

## 📝 Notes

- **GLSL ES 320**: Required for WebGL 2.0 compatibility
- **Alpha channel**: Preserved through all passes
- **Time uniform**: Must be in seconds (float)
- **UV coordinates**: Standard 0-1 range
- **Texture filtering**: Use bilinear (GL_LINEAR) for all framebuffers

## 🔗 Integration Examples

### Godot Engine

```gdscript
# Add as a custom shader material
var shader_material = ShaderMaterial.new()
shader_material.shader = load("res://shaders/multipass/pass1_base.glsl")

# For full multipass, use Viewport nodes with BackBufferCopy
```

### Unity

```csharp
// Attach to Camera as ImageEffect
using UnityEngine;

[ExecuteInEditMode]
public class MultipassShader : MonoBehaviour {
    public Material[] passes;
    
    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        RenderTexture buffer1 = RenderTexture.GetTemporary(...);
        RenderTexture buffer2 = RenderTexture.GetTemporary(...);
        
        // Execute passes
        Graphics.Blit(src, buffer1, passes[0]);
        // ... etc
        
        RenderTexture.ReleaseTemporary(buffer1);
        RenderTexture.ReleaseTemporary(buffer2);
    }
}
```

## 📚 References

- Original shader: `cool-stuff.glsl`
- GLSL ES 3.2 Specification: https://www.khronos.org/registry/OpenGL/specs/es/3.2/
- Bloom implementation based on dual-filtering techniques
- PC-98 palette sourced from NEC PC-9801 hardware specifications

## 📜 License

Same as parent project. Modify and distribute freely.

---

**Created**: 2024  
**Version**: 1.0.0  
**Compatibility**: OpenGL ES 3.2, WebGL 2.0, OpenGL 3.2+