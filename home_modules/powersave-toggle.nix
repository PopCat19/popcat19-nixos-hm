# Hyprland Powersave Toggle Module
# ================================
# This module provides a script to toggle power-saving settings in Hyprland
# and sets up the necessary keybind (mod+alt+P) to activate it.

{ config, pkgs, ... }:

{
  # Add Python and required packages
  home.packages = with pkgs; [
    python3
    libnotify                          # Desktop notifications (notify-send)
  ];

  # Create the powersave toggle Python script
  home.file.".local/bin/powersave-toggle" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      Hyprland Powersave Toggle Script
      Toggles blur, shadow, and VFR settings for power saving
      """
      
      import subprocess
      import sys
      import os
      
      def run_command(cmd):
          """Run a shell command and return the output"""
          try:
              result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
              return result.stdout.strip(), result.returncode
          except Exception as e:
              return str(e), 1
      
      def send_notification(title, message, icon=None):
          """Send a desktop notification if notify-send is available"""
          try:
              cmd = ["notify-send", title, message]
              if icon:
                  cmd.extend(["-i", icon])
              subprocess.run(cmd, check=False, capture_output=True)
          except FileNotFoundError:
              # notify-send not available, ignore
              pass
      
      def main():
          """Main function to toggle powersave mode"""
          # Check current blur state to determine if we're in powersave mode
          blur_output, return_code = run_command("hyprctl getoption decoration:blur:enabled")
          
          if return_code != 0:
              print(f"Error getting blur state: {blur_output}")
              sys.exit(1)
          
          # Parse the output to get the blur enabled state
          try:
              # The output format is typically: "option: decoration:blur:enabled -> int: 1"
              blur_enabled = blur_output.split()[-1]
              if blur_enabled == "1":
                  # Currently in normal mode, switch to powersave
                  print("Enabling powersave mode...")
                  
                  # Execute hyprctl commands to enable powersave mode
                  commands = [
                      "keyword decoration:blur:enabled false",
                      "keyword decoration:shadow:enabled false",
                      "keyword misc:vfr false"  # Disable VFR for power saving
                  ]
                  
                  for cmd in commands:
                      output, code = run_command(f"hyprctl {cmd}")
                      if code != 0:
                          print(f"Error executing command '{cmd}': {output}")
                  
                  send_notification("Hyprland", "Powersave mode enabled", "battery-low")
              else:
                  # Currently in powersave mode, switch to normal
                  print("Disabling powersave mode...")
                  
                  # Execute hyprctl commands to disable powersave mode
                  commands = [
                      "keyword decoration:blur:enabled true",
                      "keyword decoration:shadow:enabled true",
                      "keyword misc:vfr true"  # Enable VFR for normal mode
                  ]
                  
                  for cmd in commands:
                      output, code = run_command(f"hyprctl {cmd}")
                      if code != 0:
                          print(f"Error executing command '{cmd}': {output}")
                  
                  send_notification("Hyprland", "Powersave mode disabled", "battery-full")
                  
          except (IndexError, ValueError) as e:
              print(f"Error parsing blur state: {e}")
              sys.exit(1)
      
      if __name__ == "__main__":
          main()
    '';
  };
}