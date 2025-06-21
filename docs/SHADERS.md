# Hyprland Shader Configurations

This directory contains shader effects for Hyprland using hyprshade. Shaders provide visual effects that can enhance your desktop experience or serve practical purposes like blue light filtering.

## Available Shaders

### `blue-light-filter.glsl`
- **Purpose**: Reduces blue light emission from the screen
- **Effect**: Warmer color temperature
- **Use Case**: Evening use, eye strain reduction
- **Performance Impact**: Minimal

### `BLCA.glsl`
- **Purpose**: Blue Light Color Adjustment
- **Effect**: Advanced blue light filtering with color correction
- **Use Case**: Professional work, extended screen time
- **Performance Impact**: Low

### `crt.frag` / `crt.glsl`
- **Purpose**: CRT monitor simulation
- **Effect**: Retro CRT scanlines and curvature
- **Use Case**: Retro gaming, nostalgic aesthetics
- **Performance Impact**: Moderate

### `extradark.frag`
- **Purpose**: Extreme darkness filter
- **Effect**: Significantly reduces screen brightness
- **Use Case**: Very dark environments, night use
- **Performance Impact**: Minimal

### `invert.frag`
- **Purpose**: Color inversion
- **Effect**: Inverts all colors on screen
- **Use Case**: Accessibility, high contrast needs
- **Performance Impact**: Minimal

### `solarized.frag`
- **Purpose**: Solarized color scheme filter
- **Effect**: Applies solarized color palette
- **Use Case**: Consistent solarized theming
- **Performance Impact**: Low

## Usage with hyprshade

### Installation
Make sure hyprshade is installed and configured in your system.

### Manual Application
```bash
# Apply a shader
hyprshade on <shader-name>

# Remove current shader
hyprshade off

# Toggle shader
hyprshade toggle <shader-name>
```

### Automatic Scheduling
Configure automatic shader application in `~/.config/hypr/hyprshade.toml`:

```toml
[[schedule]]
start_time = "19:00:00"
end_time = "07:00:00" 
shader = "blue-light-filter"

[[schedule]]
start_time = "22:00:00"
end_time = "06:00:00"
shader = "extradark"
```

### Keybindings
Add these to your `hyprland.conf` for quick shader control:

```conf
# Shader controls
bind = $mainMod SHIFT, B, exec, hyprshade toggle blue-light-filter
bind = $mainMod SHIFT, D, exec, hyprshade toggle extradark
bind = $mainMod SHIFT, I, exec, hyprshade toggle invert
bind = $mainMod SHIFT, C, exec, hyprshade toggle crt
bind = $mainMod SHIFT, S, exec, hyprshade off
```

## Performance Considerations

- **Minimal Impact**: blue-light-filter, extradark, invert
- **Low Impact**: BLCA, solarized
- **Moderate Impact**: crt shaders

## Use Case Recommendations

### Daily Computing
- **Morning/Afternoon**: No shader or minimal filtering
- **Evening**: `blue-light-filter.glsl`
- **Night**: `extradark.frag` + `blue-light-filter.glsl`

### Gaming
- **Retro Games**: `crt.glsl` for authentic feel
- **Competitive Gaming**: No shaders for maximum performance
- **Casual Gaming**: Light filtering acceptable

### Accessibility
- **High Contrast Needs**: `invert.frag`
- **Light Sensitivity**: `extradark.frag`
- **Color Vision**: Custom shaders may be needed

## Custom Shader Development

To create custom shaders:

1. Copy an existing shader as a template
2. Modify the fragment shader code
3. Test with `hyprshade on <your-shader>`
4. Adjust parameters as needed

### Basic Shader Structure
```glsl
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    
    // Your shader modifications here
    
    gl_FragColor = pixColor;
}
```

## Troubleshooting

### Shader Not Loading
- Check shader file syntax
- Verify file permissions
- Ensure hyprshade is properly installed

### Performance Issues
- Disable shaders during intensive tasks
- Use simpler shaders on lower-end hardware
- Monitor GPU usage with shaders enabled

### Visual Artifacts
- Update graphics drivers
- Check shader compatibility with your GPU
- Try different shader variants

## External Resources

- [Hyprshade Documentation](https://github.com/loqusion/hyprshade)
- [GLSL Shader Reference](https://www.khronos.org/opengl/wiki/OpenGL_Shading_Language)
- [Hyprland Wiki - Shaders](https://wiki.hyprland.org/)