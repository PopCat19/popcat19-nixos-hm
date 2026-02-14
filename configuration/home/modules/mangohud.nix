# mangohud.nix
#
# Purpose: Configure MangoHUD gaming performance overlay with Rose Pine theming
#
# This module:
# - Installs MangoHUD and related gaming tools
# - Configures performance monitoring overlay settings
{ pkgs, userConfig, ... }:
{
  home.file.".config/MangoHud/MangoHud.conf" = {
    text = ''
      legacy_layout=false

      background_alpha=0.0
      round_corners=0
      font_file=
      font_size=14
      position=middle-left
      toggle_hud=Shift_R+F12
      hud_compact
      pci_dev=0:12:00.0
      table_columns=2

      gpu_text=
      gpu_stats
      gpu_load_change
      gpu_load_value=50,90
      gpu_voltage
      gpu_core_clock
      gpu_temp
      gpu_mem_temp
      gpu_junction_temp
      gpu_fan
      gpu_power

      cpu_text=
      cpu_stats
      cpu_load_change
      cpu_load_value=50,90
      cpu_mhz
      cpu_temp

      vram
      ram
      battery

      fps
      fps_metrics=avg,0.01
      frame_timing
      throttling_status_graph
      fps_limit_method=early
      toggle_fps_limit=none
      fps_limit=0
      fps_color_change
      fps_value=60,90

      af=8
      output_folder=${userConfig.directories.home}
      log_duration=30
      autostart_log=0
      log_interval=100
      toggle_logging=Shift_L+F2
    '';
  };

  home.packages = with pkgs; [
    goverlay
    gpu-viewer
    mangohud
    obs-studio-plugins.obs-vkcapture
    vkbasalt
  ];
}
