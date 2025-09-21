# Hyprlock minimal Rosé Pine theme
{
  home.file.".config/hypr/hyprlock.conf".text = ''
    # Rosé Pine palette
    $base = 0x191724ff
    $surface = 0x1f1d2eff
    $overlay = 0x26233aff
    $muted = 0x6e6a86ff
    $subtle = 0x908caaff
    $text = 0xe0def4ff
    $love = 0xeb6f92ff
    $gold = 0xf6c177ff
    $rose = 0xebbcbaff
    $pine = 0x31748fff
    $foam = 0x9ccfd8ff
    $iris = 0xc4a7e7ff

    general {
      hide_cursor = true
      grace = 1
      disable_loading_bar = true
    }

    background {
      color = $base
      blur_passes = 0
    }

    # Clock (HH:MM)
    label {
      text = cmd[update:1000] date +"%H:%M"
      color = $text
      font_size = 120
      font_family = "JetBrainsMono Nerd Font, Inter, DejaVu Sans"
      position = 0, -120
      halign = center
      valign = center
    }

    # Date (weekday, month day)
    label {
      text = cmd[update:1000] date +"%A, %B %d"
      color = $muted
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

      inner_color = $overlay
      outer_color = $iris
      font_color = $text

      placeholder_text = <i>password</i>
      fail_color = $love
      check_color = $iris
      capslock_color = $gold

      dots_size = 0.2
      dots_spacing = 0.25
    }
  '';
}