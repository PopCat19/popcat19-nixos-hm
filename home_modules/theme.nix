{ pkgs, config, system, lib, inputs, ... }:

{
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
    GTK_THEME = "Rose-Pine-Main-BL";
    GDK_BACKEND = "wayland,x11,*";
    XCURSOR_THEME = "rose-pine-hyprcursor";
    XCURSOR_SIZE = "24";
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "rose-pine-hyprcursor";
      size = 24;
      package = inputs.rose-pine-hyprcursor.packages.${system}.default;
    };
    theme = {
      name = "Rose-Pine-Main-BL";
      package = pkgs.rose-pine-gtk-theme-full;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Rounded Mplus 1c Medium";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };
    gtk4.extraConfig = {
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };
    gtk3.extraCss = ''
      * {
        font-family: "Rounded Mplus 1c Medium";
      }
    '';
    gtk4.extraCss = ''
      * {
        font-family: "Rounded Mplus 1c Medium";
      }
    '';
  };

  qt = {
    enable = true;
    style = {
      name = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  home.file.".config/Kvantum/RosePine".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-rose";

  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=rose-pine-rose

    [Applications]
    dolphin=rose-pine-rose
    ark=rose-pine-rose
    gwenview=rose-pine-rose
    systemsettings=rose-pine-rose
    kate=rose-pine-rose
    kwrite=rose-pine-rose
  '';

  home.file.".config/kdeglobals" = {
    text = ''
      [ColorScheme]
      Name=Rose-Pine-Main-BL

      [Colors:Button]
      BackgroundAlternate=49,46,77
      BackgroundNormal=49,46,77
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Selection]
      BackgroundAlternate=82,79,103
      BackgroundNormal=64,61,82
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Tooltip]
      BackgroundAlternate=25,23,36
      BackgroundNormal=25,23,36
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:View]
      BackgroundAlternate=31,29,46
      BackgroundNormal=25,23,36
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Window]
      BackgroundAlternate=31,29,46
      BackgroundNormal=25,23,36
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Complementary]
      BackgroundAlternate=49,46,77
      BackgroundNormal=38,35,58
      DecorationFocus=235,188,186
      DecorationHover=235,188,186
      ForegroundActive=224,222,244
      ForegroundInactive=110,106,134
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [General]
      ColorScheme=Rose-Pine-Main-BL
      Name=Rose-Pine-Main-BL
      shadeSortColumn=true

      [Icons]
      Theme=Papirus-Dark

      [KDE]
      contrast=4
      widgetStyle=kvantum
    '';
    force = true;
  };

  home.file.".config/qt6ct/qt6ct.conf" = {
    text = ''
      [Appearance]
      color_scheme_path=
      custom_palette=false
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=kvantum

      [Fonts]
      fixed="JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0"
      general="Rounded Mplus 1c Medium,11,-1,5,50,0,0,0,0,0"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3

      [SettingsWindow]
      geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf\0\0\0\0\x2\0\0\0\n\0\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf)
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "rose-pine-hyprcursor";
      cursor-size = 24;
      gtk-theme = "Rose-Pine-Main-BL";
      icon-theme = "Papirus-Dark";
      font-name = "Rounded Mplus 1c Medium 11";
      document-font-name = "Rounded Mplus 1c Medium 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      theme = "Rose-Pine-Main-BL";
    };

    "org/gnome/desktop/thumbnailers" = {
      disable-all = false;
    };

    "org/gnome/nautilus/preferences" = {
      show-image-thumbnails = "always";
      thumbnail-limit = 10;
      show-directory-item-counts = "always";
    };

    "org/nemo/preferences" = {
      show-image-thumbnails = true;
      thumbnail-limit = 10;
      show-thumbnails = true;
    };

    "org/gnome/desktop/privacy" = {
      remember-recent-files = true;
      recent-files-max-age = 30;
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      WantedBy = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };



  programs.kitty.font = {
    name = "JetBrainsMono Nerd Font";
    size = 11;
  };

  programs.fuzzel.settings.main.font = "Rounded Mplus 1c Medium:size=14";

  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Rounded Mplus 1c Medium</family>
        </prefer>
      </alias>
      <alias>
        <family>Rounded Mplus 1c Medium</family>
        <default>
          <family>sans-serif</family>
        </default>
      </alias>
    </fontconfig>
  '';

  home.packages = with pkgs; [
    google-fonts
    vim
    firefox
    htop
    neofetch
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    nwg-look
    dconf-editor
    libsForQt5.qt5ct
    qt6ct
    themechanger
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    rose-pine-kvantum
    rose-pine-gtk-theme-full
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    catppuccin-gtk
    catppuccin-cursors
    papirus-icon-theme
    adwaita-icon-theme
    polkit_gnome
    gsettings-desktop-schemas
    (pkgs.writeShellScriptBin "check-rose-pine-theme" ''
      #!/usr/bin/env bash

      set -euo pipefail

      SCRIPT_VERSION="2.0.0"
      CONFIG_DIR="$HOME/.config"
      NIXOS_CONFIG_DIR="$HOME/nixos-config"
      VERBOSE=false
      SHOW_FIX_SUGGESTIONS=false

      readonly RED='\033[0;31m'
      readonly GREEN='\033[0;32m'
      readonly YELLOW='\033[1;33m'
      readonly BLUE='\033[0;34m'
      readonly PURPLE='\033[0;35m'
      readonly CYAN='\033[0;36m'
      readonly WHITE='\033[1;37m'
      readonly GRAY='\033[0;37m'
      readonly NC='\033[0m'

      readonly CHECK_MARK="✓"
      readonly CROSS_MARK="✗"
      readonly WARNING="⚠"
      readonly INFO="ℹ"

      TOTAL_CHECKS=0
      PASSED_CHECKS=0
      FAILED_CHECKS=0
      WARNING_CHECKS=0

      print_header() {
          local title="$1"
          echo ""
          echo -e "${PURPLE}🌹 ${title}${NC}"
          echo -e "${PURPLE}$(printf '═%.0s' $(seq 1 ${#title}))${NC}"
      }

      print_section() {
          local title="$1"
          echo ""
          echo -e "${BLUE}$title${NC}"
      }

      print_check() {
          local status="$1"
          local message="$2"
          local details="${3:-}"

          ((TOTAL_CHECKS++))

          case "$status" in
              "PASS")
                  echo -e "${GREEN}${CHECK_MARK} ${message}${NC}"
                  [ -n "$details" ] && echo -e "    ${GRAY}${details}${NC}"
                  ((PASSED_CHECKS++))
                  ;;
              "FAIL")
                  echo -e "${RED}${CROSS_MARK} ${message}${NC}"
                  [ -n "$details" ] && echo -e "    ${RED}${details}${NC}"
                  ((FAILED_CHECKS++))
                  ;;
              "WARN")
                  echo -e "${YELLOW}${WARNING} ${message}${NC}"
                  [ -n "$details" ] && echo -e "    ${YELLOW}${details}${NC}"
                  ((WARNING_CHECKS++))
                  ;;
              "INFO")
                  echo -e "${CYAN}${INFO} ${message}${NC}"
                  [ -n "$details" ] && echo -e "    ${CYAN}${details}${NC}"
                  ;;
          esac
      }

      check_environment_variables() {
          print_section "Environment Variables"

          if [[ "${QT_QPA_PLATFORMTHEME:-}" == "qt6ct" ]]; then
              print_check "PASS" "QT_QPA_PLATFORMTHEME correctly set" "qt6ct"
          else
              print_check "FAIL" "QT_QPA_PLATFORMTHEME incorrect" "Expected: qt6ct, Got: ${QT_QPA_PLATFORMTHEME:-unset}"
          fi

          if [[ "${QT_STYLE_OVERRIDE:-}" == "kvantum" ]]; then
              print_check "PASS" "QT_STYLE_OVERRIDE correctly set" "kvantum"
          else
              print_check "FAIL" "QT_STYLE_OVERRIDE incorrect" "Expected: kvantum, Got: ${QT_STYLE_OVERRIDE:-unset}"
          fi

          if [[ "${GTK_THEME:-}" == "Rose-Pine-Main-BL" ]]; then
              print_check "PASS" "GTK_THEME correctly set" "Rose-Pine-Main-BL"
          else
              print_check "WARN" "GTK_THEME incorrect" "Expected: Rose-Pine-Main-BL, Got: ${GTK_THEME:-unset}"
          fi

          if [[ "${XCURSOR_THEME:-}" == "rose-pine-hyprcursor" ]]; then
              print_check "PASS" "XCURSOR_THEME correctly set" "rose-pine-hyprcursor"
          else
              print_check "WARN" "XCURSOR_THEME incorrect" "Expected: rose-pine-hyprcursor, Got: ${XCURSOR_THEME:-unset}"
          fi
      }

      check_packages() {
          print_section "Package Availability"

          for pkg in kitty fuzzel micro dolphin qt6ct kvantummanager nwg-look; do
              if command -v "$pkg" &> /dev/null; then
                  print_check "PASS" "$pkg available"
              else
                  print_check "FAIL" "$pkg not found"
              fi
          done
      }

      check_theme_files() {
          print_section "Theme Files and Configuration"

          if [[ -d "$HOME/.config/Kvantum/RosePine" ]]; then
              print_check "PASS" "Kvantum Rose Pine theme directory found"
              if [[ -f "$HOME/.config/Kvantum/RosePine/rose-pine-rose.kvconfig" ]]; then
                  print_check "PASS" "Rose Pine Kvantum config found"
              else
                  print_check "WARN" "Rose Pine Kvantum config missing"
              fi
          else
              print_check "FAIL" "Kvantum Rose Pine theme directory missing" "$HOME/.config/Kvantum/RosePine"
          fi

          if [[ -f "$HOME/.config/kdeglobals" ]]; then
              if grep -q "ColorScheme=Rose-Pine-Main-BL" "$HOME/.config/kdeglobals" 2>/dev/null; then
                  print_check "PASS" "kdeglobals Rose Pine configured"
              else
                  print_check "WARN" "kdeglobals exists but may not be Rose Pine"
              fi
          else
              print_check "FAIL" "kdeglobals missing"
          fi

          if [[ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]]; then
              if grep -q "theme=rose-pine-rose" "$HOME/.config/Kvantum/kvantum.kvconfig" 2>/dev/null; then
                  print_check "PASS" "Kvantum Rose Pine theme configured"
              else
                  print_check "WARN" "Kvantum config exists but theme may not be Rose Pine"
              fi
          else
              print_check "FAIL" "Kvantum config missing"
          fi

          if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
              if grep -q "style=kvantum" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null; then
                  print_check "PASS" "Qt6ct Kvantum style configured"
              else
                  print_check "WARN" "Qt6ct exists but style may not be Kvantum"
              fi
          else
              print_check "FAIL" "Qt6ct config missing"
          fi
      }

      check_fonts() {
          print_section "Font Installation"

          if command -v fc-list &> /dev/null; then
              print_check "PASS" "fontconfig available" "$(fc-list | wc -l) fonts detected"

              if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
                  print_check "PASS" "JetBrainsMono Nerd Font installed"
              else
                  print_check "FAIL" "JetBrainsMono Nerd Font not found" "Required from nerd-fonts.jetbrains-mono package"
              fi

              if fc-list | grep -qi "Rounded Mplus 1c"; then
                  print_check "PASS" "Rounded Mplus 1c font installed"
              else
                  print_check "FAIL" "Rounded Mplus 1c font not found" "Required from pkgs.google-fonts (system-level dependency)"
              fi

              if fc-list | grep -qi "Noto Sans"; then
                  print_check "PASS" "Noto Sans fonts installed"
              else
                  print_check "FAIL" "Noto Sans fonts not found" "Required from noto-fonts packages"
              fi

              if fc-list | grep -qi "Font Awesome"; then
                  print_check "PASS" "Font Awesome icons installed"
              else
                  print_check "WARN" "Font Awesome icons not found" "May affect UI icon display"
              fi
          else
              print_check "FAIL" "fontconfig not available"
          fi
      }

      show_troubleshooting() {
          print_section "Troubleshooting Tips"

          echo -e "${YELLOW}If theming is not working:${NC}"
          echo "1. Run kvantummanager and select Rose Pine theme"
          echo "2. Restart KDE applications: pkill dolphin && dolphin &"
          echo "3. Logout and login to reload environment variables"
          echo "4. Check Home Manager rebuild: home-manager switch"
          echo ""
          echo -e "${YELLOW}Font troubleshooting:${NC}"
          echo "• TESTING: google-fonts moved to user-level (home-theme.nix)"
          echo "• JetBrainsMono requires nerd-fonts.jetbrains-mono in home-theme.nix"
          echo "• Run 'fc-list | grep -i \"mplus\"' to verify font installation"
          echo "• Check both home-theme.nix and /etc/nixos/configuration.nix for fonts"
          echo ""
          echo -e "${YELLOW}Manual theme tools:${NC}"
          echo " kvantummanager - Kvantum theme manager"
          echo " qt6ct - Qt6 configuration tool"
          echo " nwg-look - GTK theme manager"
          echo ""
      }

      print_summary() {
          print_header "Diagnostic Summary"

          local pass_percent=0
          if [[ $TOTAL_CHECKS -gt 0 ]]; then
              pass_percent=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
          fi

          echo -e "${WHITE}Total Checks: $TOTAL_CHECKS${NC}"
          echo -e "${GREEN}Passed: $PASSED_CHECKS ($pass_percent%)${NC}"
          echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
          echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
          echo ""

          if [[ $FAILED_CHECKS -eq 0 ]]; then
              echo -e "${GREEN}🎉 All critical checks passed! Your Rose Pine theme setup looks good.${NC}"
          elif [[ $FAILED_CHECKS -lt 5 ]]; then
              echo -e "${YELLOW}⚠️  Minor issues detected. Review failed checks above.${NC}"
          else
              echo -e "${RED}❌ Multiple issues detected. Consider running manual fixes.${NC}"
          fi
          echo ""
      }

      main() {
          while [[ $# -gt 0 ]]; do
              case $1 in
                  --verbose|-v)
                      VERBOSE=true
                      shift
                      ;;
                  --fix-suggestions|-f)
                      SHOW_FIX_SUGGESTIONS=true
                      shift
                      ;;
                  --version)
                      echo "Rose Pine Theme Diagnostic Tool v$SCRIPT_VERSION"
                      exit 0
                      ;;
                  --help|-h)
                      echo "Usage: check-rose-pine-theme [OPTIONS]"
                      echo ""
                      echo "Options:"
                      echo "  --verbose, -v           Show detailed output"
                      echo "  --fix-suggestions, -f   Show fix suggestions for issues"
                      echo "  --version              Show version information"
                      echo "  --help, -h             Show this help message"
                      echo ""
                      echo "This script performs comprehensive checks of your Rose Pine theme setup."
                      exit 0
                      ;;
                  *)
                      echo "Unknown option: $1"
                      echo "Use --help for usage information."
                      exit 1
                      ;;
              esac
          done

          print_header "Rose Pine Theme Diagnostic Tool"
          echo -e "${CYAN}Version: $SCRIPT_VERSION${NC}"
          echo -e "${CYAN}Checking Rose Pine theme integration...${NC}"

          check_environment_variables
          check_packages
          check_theme_files
          check_fonts

          if [[ $FAILED_CHECKS -gt 0 ]] || [[ $WARNING_CHECKS -gt 3 ]]; then
              show_troubleshooting
          fi

          print_summary

          if [[ $FAILED_CHECKS -gt 0 ]]; then
              exit 1
          else
              exit 0
          fi
      }

      main "$@"
    '')
  ];
}
