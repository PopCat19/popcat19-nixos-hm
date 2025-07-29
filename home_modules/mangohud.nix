# Home Manager MangoHUD Configuration
# This file contains MangoHUD gaming performance overlay configuration and packages
# Imported by home.nix

{ config, pkgs, userConfig, ... }:

{
  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎮 MANGOHUD GAMING PERFORMANCE OVERLAY SYSTEM
  # ═══════════════════════════════════════════════════════════════════════════════
  #
  # MangoHUD provides real-time performance monitoring overlay for games and applications.
  # This configuration includes Rose Pine theming and comprehensive performance metrics
  # for gaming optimization and system monitoring.
  #
  # FEATURES:
  # • Real-time GPU/CPU performance monitoring
  # • Memory usage tracking (VRAM/RAM)
  # • Frame timing and FPS metrics
  # • Temperature and power consumption monitoring
  # • Rose Pine color scheme integration
  # • Customizable overlay position and layout
  # • Logging capabilities for performance analysis
  #
  # USAGE:
  # • Automatically loads with compatible games
  # • Toggle overlay: Shift+F12
  # • Toggle logging: Shift+F2
  # • Configure via goverlay GUI tool
  #
  # DEPENDENCIES:
  # • Vulkan/OpenGL compatible graphics drivers
  # • Compatible games/applications
  # ═══════════════════════════════════════════════════════════════════════════════

  home.packages = with pkgs; [
    # ─── CORE MANGOHUD PACKAGES ───
    mangohud # Gaming performance overlay with system metrics
    goverlay # MangoHUD configuration GUI for easy setup

    # Note: MangoHUD automatically integrates with Steam and most gaming platforms
    # Additional gaming tools can be found in home-packages.nix under gaming section
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # 📊 MANGOHUD CONFIGURATION - ROSE PINE THEMED PERFORMANCE OVERLAY
  # ═══════════════════════════════════════════════════════════════════════════════
  # Comprehensive MangoHUD configuration with Rose Pine color scheme integration.
  # Displays essential gaming metrics in an unobtrusive overlay format.
  #
  # COLOR SCHEME (Rose Pine):
  # • Background: 191724 (base)
  # • Text: e0def4 (text)
  # • GPU metrics: 9ccfd8 (foam)
  # • CPU metrics: 31748f (pine)
  # • Memory: c4a7e7 (iris)
  # • Frame timing: ebbcba (rose)
  # • Temperature warnings: f6c177 (gold) / eb6f92 (love)

  home.file.".config/MangoHud/MangoHud.conf" = {
    text = ''
      ################### Declarative MangoHud Configuration ###################
      # Modern layout with Rose Pine theming - matches desktop color scheme
      legacy_layout=false

      # ─── OVERLAY APPEARANCE ───
      background_alpha=0.0              # Transparent background for clean look
      round_corners=0                   # Sharp corners matching system theme
      background_color=191724           # Rose Pine base color
      font_file=                        # Use system default font
      font_size=14                      # Readable font size
      text_color=e0def4                 # Rose Pine text color
      position=middle-left              # Unobtrusive overlay position
      toggle_hud=Shift_R+F12           # Toggle overlay visibility
      hud_compact                       # Compact layout for minimal distraction
      pci_dev=0:12:00.0                # GPU PCI device identifier
      table_columns=2                   # Two-column layout for organized display

      # ─── GPU MONITORING ───
      gpu_text=                         # No GPU label text (clean appearance)
      gpu_stats                         # Enable GPU statistics display
      gpu_load_change                   # Show GPU load changes
      gpu_load_value=50,90             # GPU load warning thresholds (50%, 90%)
      gpu_load_color=e0def4,f6c177,eb6f92  # Colors: normal, warning, critical
      gpu_voltage                       # Display GPU voltage
      gpu_core_clock                    # Show GPU core clock speed
      gpu_temp                          # GPU temperature monitoring
      gpu_mem_temp                      # GPU memory temperature
      gpu_junction_temp                 # GPU junction temperature
      gpu_fan                           # GPU fan speed display
      gpu_power                         # GPU power consumption
      gpu_color=9ccfd8                  # Rose Pine foam color for GPU metrics

      # ─── CPU MONITORING ───
      cpu_text=                         # No CPU label text
      cpu_stats                         # Enable CPU statistics
      cpu_load_change                   # Show CPU load changes
      cpu_load_value=50,90             # CPU load warning thresholds
      cpu_load_color=e0def4,f6c177,eb6f92  # CPU load colors
      cpu_mhz                           # CPU frequency display
      cpu_temp                          # CPU temperature monitoring
      cpu_color=31748f                  # Rose Pine pine color for CPU metrics

      # ─── MEMORY MONITORING ───
      vram                              # GPU memory (VRAM) usage
      vram_color=c4a7e7                # Rose Pine iris color for VRAM
      ram                               # System RAM usage
      ram_color=c4a7e7                 # Rose Pine iris color for RAM
      battery                           # Battery status (for laptops)
      battery_color=9ccfd8             # Rose Pine foam color for battery

      # ─── PERFORMANCE METRICS ───
      fps                               # Frames per second display
      fps_metrics=avg,0.01             # FPS average and 0.01% low metrics
      frame_timing                      # Frame timing graph
      frametime_color=ebbcba           # Rose Pine rose color for frame timing
      throttling_status_graph           # GPU/CPU throttling indicators
      fps_limit_method=early           # Early FPS limiting method
      toggle_fps_limit=none            # No FPS limit toggle key
      fps_limit=0                      # No FPS limit (0 = unlimited)
      fps_color_change                 # Dynamic FPS color based on performance
      fps_color=eb6f92,f6c177,9ccfd8   # FPS colors: low, medium, high
      fps_value=60,90                  # FPS thresholds for color changes

      # ─── ADVANCED SETTINGS ───
      af=8                             # Anisotropic filtering level
      output_folder=${userConfig.directories.home}     # Log output directory
      log_duration=30                  # Logging duration in seconds
      autostart_log=0                  # Don't auto-start logging
      log_interval=100                 # Log interval in milliseconds
      toggle_logging=Shift_L+F2        # Toggle performance logging
    '';
  };
}
