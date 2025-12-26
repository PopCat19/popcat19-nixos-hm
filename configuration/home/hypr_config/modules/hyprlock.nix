# Hyprlock minimal Rosé Pine theme
{
  home.file.".config/hypr/hyprlock.conf".text = ''
    # Hyprlock theme configuration
    # Manual color definitions removed - let stylix handle theming
    # Colors will be automatically applied by stylix to hyprlock
    
    # To manually configure colors, uncomment and set desired values:
    # $base = 0xff<color>
    # $surface = 0xff<color>
    # $text = 0xff<color>
    # ... other color variables ...
    
    general {
      hide_cursor = true
      grace = 1
      disable_loading_bar = true
    }

    background {
      # color removed - let stylix handle background theming
      blur_passes = 3
      # To use an image background instead of solid color, uncomment and set a path:
      # path = /nix/store/.../kasane_teto_utau_drawn_by_yananami_numata220.jpg
      # tip: keep color set as a fallback; blur applies over the image if supported
    }

    # Clock (HH:MM)
    label {
      text = cmd[update:1000] date +"%H:%M"
      # color removed - let stylix handle theming
      font_size = 120
      font_family = "JetBrainsMono Nerd Font, Inter, DejaVu Sans"
      position = 0, -120
      halign = center
      valign = center
    }

    # Date (weekday, month day)
    label {
      text = cmd[update:1000] date +"%A, %B %d"
      # color removed - let stylix handle theming
      font_size = 22
      font_family = "Inter, JetBrainsMono Nerd Font, DejaVu Sans"
      position = 0, -30
      halign = center
      valign = center
    }

    # Password field (centered)
    input-field {
      monitor =
      size = 300, 44
      position = 0, 160
      halign = center
      valign = center

      rounding = 12
      outline_thickness = 2

      # inner_color removed - let stylix handle theming
      # outer_color removed - let stylix handle theming
      # font_color removed - let stylix handle theming

      placeholder_text = <i>password</i>
      # fail_color removed - let stylix handle theming
      # check_color removed - let stylix handle theming
      # capslock_color removed - let stylix handle theming

      dots_size = 0.2
      dots_spacing = 0.25
    }
    # Hint
    label {
      text = "Type password to unlock"
      # color removed - let stylix handle theming
      font_size = 14
      font_family = "Inter, JetBrainsMono Nerd Font, DejaVu Sans"
      position = 0, 210
      halign = center
      valign = center
    }
  '';
}
