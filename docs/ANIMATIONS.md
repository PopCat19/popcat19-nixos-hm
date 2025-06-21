# Animation Configuration

## Current Status

The animations directory has been **removed** as it was not being used. Animation configuration is now handled directly in the main `hyprland.conf` file.

## Animation Configuration Location

Animations are configured in `hypr_config/hyprland.conf` in the `animations` block:

```conf
animations {
    enabled = true

    # Bezier curves
    bezier = easeOutQuint, 0.23, 1, 0.32, 1
    bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
    bezier = linear, 0, 0, 1, 1
    bezier = almostLinear, 0.5, 0.5, 0.75, 1.0
    bezier = quick, 0.15, 0, 0.1, 1

    # Animation definitions
    animation = global, 1, 10, default
    animation = border, 1, 5.39, easeOutQuint
    animation = windows, 1, 4.79, easeOutQuint
    animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
    animation = windowsOut, 1, 1.49, linear, popin 87%
    animation = fadeIn, 1, 1.73, almostLinear
    animation = fadeOut, 1, 1.46, almostLinear
    animation = fade, 1, 3.03, quick
    animation = layers, 1, 3.81, easeOutQuint
    animation = layersIn, 1, 4, easeOutQuint, fade
    animation = layersOut, 1, 1.5, linear, fade
    animation = fadeLayersIn, 1, 1.79, almostLinear
    animation = fadeLayersOut, 1, 1.39, almostLinear
    animation = workspaces, 1, 1.94, almostLinear, fade
    animation = workspacesIn, 1, 1.21, almostLinear, fade
    animation = workspacesOut, 1, 1.94, almostLinear, fade
}
```

## Customization

To modify animations, edit the `animations` block in `hypr_config/hyprland.conf`:

### Performance Tweaks
- **Disable all animations**: Set `enabled = false`
- **Faster animations**: Reduce duration values (second parameter)
- **Simpler animations**: Remove or comment out complex animations

### Key Parameters
- **Duration**: Second parameter (1-10, lower = faster)
- **Bezier curves**: Define animation easing
- **Animation types**: windows, fade, layers, workspaces, etc.

### Performance Recommendations
- **Low-end hardware**: Set `enabled = false`
- **Better performance**: Reduce duration values to 1-3
- **Smooth experience**: Keep current values (balanced)

## Reference

For detailed animation configuration, see:
- [Hyprland Animation Documentation](https://wiki.hyprland.org/Configuring/Animations/)
- Current configuration in `hypr_config/hyprland.conf`