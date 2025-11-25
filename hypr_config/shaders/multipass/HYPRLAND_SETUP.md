# Hyprland Shader Setup Guide

## Quick Start

### Single-Pass Merged Shader (Recommended for Hyprland)

Hyprland's current shader system supports single-pass fragment shaders. Use the merged version:

```bash
# Copy the merged shader
cp multipass/hyprland_merged.glsl ~/.config/hypr/shaders/retro-effects.glsl

# Edit your hyprland.conf
nano ~/.config/hypr/hyprland.conf
```

Add to your `hyprland.conf`:

```conf
decoration {
    screen_shader = ~/.config/hypr/shaders/retro-effects.glsl
}
```

Reload Hyprland:
```bash
hyprctl reload
```

## Available Shaders

### 1. Full Effects (hyprland_merged.glsl)
Complete pipeline with all effects combined:
- ✅ Chromatic aberration
- ✅ Analog glitch effects
- ✅ Bloom (simplified for single-pass)
- ✅ CRT curvature & scanlines
- ✅ Shadow mask (phosphor grid)
- ✅ PC-98 palette quantization
- ✅ Dithering
- ✅ Film grain
- ✅ VHS artifacts
- ✅ Vignette

**Performance**: Medium (optimized bloom)
**Visual Impact**: Very High

### 2. Individual Passes
The `pass1_base.glsl` through `pass5_final.glsl` files are reference implementations for multi-pass systems. They won't work directly with Hyprland but can be used in:
- Custom Hyprland forks
- OBS Studio shader filters
- Game engines
- Video editing tools

## Customizing Effects

Edit the `#define` values at the top of `hyprland_merged.glsl`:

### Quick Tweaks

```glsl
// Reduce glitch frequency
#define GLITCH_PROBABILITY     0.10    // Default: 0.20

// Increase bloom glow
#define BLOOM_INTENSITY       0.35     // Default: 0.24

// Stronger CRT curvature
#define CRT_CURVE_STRENGTH 0.25        // Default: 0.15

// More aggressive color quantization
#define DITHER_STRENGTH 0.35           // Default: 0.2

// Heavier vignette
#define VIGNETTE_STRENGTH      0.6     // Default: 0.4
```

### Disable Individual Effects

```glsl
// Disable chromatic aberration
#define CA_RED_STRENGTH     0.0
#define CA_BLUE_STRENGTH    0.0

// Disable glitch
#define GLITCH_PROBABILITY     0.0

// Disable bloom
#define BLOOM_INTENSITY       0.0

// Disable CRT curvature (keep scanlines)
#define CRT_CURVE_STRENGTH 0.0

// Disable scanlines
#define SCANLINE_OPACITY     0.0

// Disable shadow mask
#define SHADOW_MASK_STRENGTH 0.0

// Disable dithering (keep palette)
#define DITHER_STRENGTH 0.0

// Disable VHS
#define VHS_INTENSITY        0.0

// Disable grain
#define GRAIN_INTENSITY 0.0

// Disable vignette
#define VIGNETTE_STRENGTH      0.0
```

## Performance Presets

### Lightweight (60+ FPS)
```glsl
#define BLOOM_SAMPLES         8        // Default: 12
#define GLITCH_PROBABILITY    0.0      // Disable
#define SHADOW_MASK_STRENGTH  0.0      // Disable
#define DITHER_PRE_QUANTIZE   0        // Disable
#define VHS_INTENSITY         0.0      // Disable
```

### Balanced (30-60 FPS)
```glsl
#define BLOOM_SAMPLES         12       // Default
#define GLITCH_PROBABILITY    0.10     // Reduced
#define SHADOW_MASK_STRENGTH  0.2      // Reduced
```

### Maximum Quality (GPU dependent)
```glsl
#define BLOOM_SAMPLES         24       // Doubled
#define BLOOM_RADIUS          0.0024   // Increased
#define SHADOW_MASK_STRENGTH  0.5      // Increased
#define SCANLINE_OPACITY      0.35     // Stronger
```

## Effect Presets

### Clean Retro (Minimal Artifacts)
```glsl
#define GLITCH_PROBABILITY     0.0
#define VHS_INTENSITY          0.0
#define GRAIN_INTENSITY        0.03
#define BLOOM_INTENSITY        0.18
#define SCANLINE_OPACITY       0.20
#define SHADOW_MASK_STRENGTH   0.25
```

### Heavy Vintage (Maximum Nostalgia)
```glsl
#define GLITCH_PROBABILITY     0.35
#define VHS_INTENSITY          0.25
#define GRAIN_INTENSITY        0.12
#define BLOOM_INTENSITY        0.35
#define SCANLINE_OPACITY       0.35
#define SHADOW_MASK_STRENGTH   0.5
#define CRT_CURVE_STRENGTH     0.25
```

### Cyberpunk (Futuristic Glitch)
```glsl
#define CA_RED_STRENGTH        0.002
#define CA_BLUE_STRENGTH       0.002
#define GLITCH_PROBABILITY     0.25
#define BLOOM_INTENSITY        0.4
#define BLOOM_TINT             vec3(1.2, 0.8, 1.3)
#define SCANLINE_OPACITY       0.15
#define SHADOW_MASK_STRENGTH   0.0
#define VHS_INTENSITY          0.0
```

### Arcade Monitor
```glsl
#define CRT_CURVE_STRENGTH     0.20
#define SCANLINE_OPACITY       0.30
#define SHADOW_MASK_TYPE       0      // Aperture grille
#define SHADOW_MASK_STRENGTH   0.4
#define BLOOM_INTENSITY        0.25
#define GLITCH_PROBABILITY     0.0
#define VHS_INTENSITY          0.0
```

## Shadow Mask Types

```glsl
#define SHADOW_MASK_TYPE 0    // Aperture Grille (vertical lines)
#define SHADOW_MASK_TYPE 1    // Slot Mask (triads)
#define SHADOW_MASK_TYPE 2    // Dot Mask (circular phosphors)
```

## Troubleshooting

### Shader not loading
```bash
# Check Hyprland logs
hyprctl logs

# Verify shader syntax
# Look for compilation errors
```

### Black screen
1. Check that the file path is correct
2. Verify GLSL ES 320 support:
   ```bash
   glxinfo | grep "OpenGL"
   ```
3. Try disabling effects one by one to isolate the issue

### Performance issues
1. Reduce `BLOOM_SAMPLES` to 8 or 6
2. Disable heavy effects (glitch, VHS, dithering)
3. Lower shadow mask strength
4. Use `precision mediump float;` instead of `highp`

### Colors look wrong
1. Check your monitor's color profile
2. Adjust `DITHER_GAMMA` (try 1.8 or 2.4)
3. Reduce `DITHER_STRENGTH`
4. Disable bloom tinting:
   ```glsl
   #define BLOOM_TINT vec3(1.0, 1.0, 1.0)
   ```

### Glitches too frequent/intense
```glsl
#define GLITCH_PROBABILITY  0.10    // Reduce frequency
#define GLITCH_STRENGTH     0.5     // Reduce intensity
#define GLITCH_DURATION     0.08    // Shorten duration
```

## Hot-Reloading Shaders

Make shader changes instant:

```bash
# Edit the shader
nano ~/.config/hypr/shaders/retro-effects.glsl

# Reload Hyprland to apply changes
hyprctl reload

# Or toggle the shader off and on
hyprctl keyword decoration:screen_shader ""
hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/retro-effects.glsl
```

## Custom Color Palettes

Replace the PC-98 palette in `hyprland_merged.glsl`:

```glsl
// Example: Gameboy palette (4 colors)
const int PALETTE_SIZE = 4;
const vec3 PALETTE[4] = vec3[4](
    vec3(0x0f, 0x38, 0x0f) / 255.0,  // Dark green
    vec3(0x30, 0x62, 0x30) / 255.0,  // Medium green
    vec3(0x8b, 0xac, 0x0f) / 255.0,  // Light green
    vec3(0x9b, 0xbc, 0x0f) / 255.0   // Pale green
);

// Update the loop in applyPC98PaletteWithDither:
for (int i = 0; i < PALETTE_SIZE; i++) {
    vec3 paletteColor = toLinear(PALETTE[i]);
    // ... rest of the code
}
```

Popular palettes:
- **CGA**: 16 colors (1981 IBM PC)
- **EGA**: 64 colors (1984 enhanced CGA)
- **VGA**: 256 colors (1987 standard)
- **Commodore 64**: 16 colors
- **NES**: 56 colors
- **Amstrad CPC**: 27 colors

## Advanced: Multi-Pass with Custom Hyprland Fork

If you compile Hyprland from source, you can modify the compositor to support multi-pass shaders:

1. Fork Hyprland repository
2. Modify `src/render/OpenGL.cpp` to support framebuffers
3. Implement pass chaining in the render loop
4. Use the individual `pass1_base.glsl` through `pass5_final.glsl` files

This requires C++ knowledge and maintaining a custom fork.

## Alternative: OBS Studio Integration

Use these shaders with OBS for screen recording/streaming:

1. Add a "Display Capture" source
2. Right-click → Filters → Add "Shader" filter
3. Load `hyprland_merged.glsl`
4. Adjust uniforms in the OBS shader editor

## Script: Quick Effect Toggle

Create `~/.config/hypr/scripts/toggle-shader.sh`:

```bash
#!/bin/bash

SHADER_PATH="$HOME/.config/hypr/shaders/retro-effects.glsl"
CURRENT=$(hyprctl getoption decoration:screen_shader | grep "str:" | awk '{print $2}')

if [ "$CURRENT" = "[[EMPTY]]" ] || [ -z "$CURRENT" ]; then
    hyprctl keyword decoration:screen_shader "$SHADER_PATH"
    notify-send "Shader" "Retro effects enabled"
else
    hyprctl keyword decoration:screen_shader ""
    notify-send "Shader" "Retro effects disabled"
fi
```

Make executable:
```bash
chmod +x ~/.config/hypr/scripts/toggle-shader.sh
```

Bind to a key in `hyprland.conf`:
```conf
bind = $mainMod SHIFT, S, exec, ~/.config/hypr/scripts/toggle-shader.sh
```

## Performance Monitoring

Check shader performance:

```bash
# Monitor FPS
watch -n 1 "hyprctl monitors | grep -A 10 Monitor"

# Check GPU usage
nvidia-smi  # NVIDIA
radeontop   # AMD
intel_gpu_top  # Intel
```

## Resources

- [Hyprland Wiki - Screen Shaders](https://wiki.hyprland.org/Configuring/Shaders/)
- [GLSL ES 3.2 Specification](https://www.khronos.org/registry/OpenGL/specs/es/3.2/)
- [Shader Toy](https://www.shadertoy.com/) - Test shader code
- PC-98 Palette Reference: NEC PC-9801 Technical Manual

## Credits

Based on the original `cool-stuff.glsl` shader, refactored into a modular pipeline for better maintainability and performance.

---

**Version**: 1.0.0  
**Compatibility**: Hyprland 0.30+, OpenGL ES 3.2+  
**License**: Same as parent project