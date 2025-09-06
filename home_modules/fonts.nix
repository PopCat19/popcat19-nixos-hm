{ pkgs, config, system, lib, inputs, ... }:

let
  # Font configuration
  fontMain = "Rounded Mplus 1c Medium";
  fontMono = "JetBrainsMono Nerd Font";
  fuzzelFontSize = 14;
  kittyFontSize = 11;
  gtkFontSize = 11;

  gtkCss = ''
    * {
      font-family: "${fontMain}";
    }
  '';
in
{
  gtk = {
    font = {
      name = fontMain;
      size = gtkFontSize;
    };
    gtk3.extraCss = gtkCss;
    gtk4.extraCss = gtkCss;
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
      fixed="${fontMono},11,-1,5,50,0,0,0,0,0"
      general="${fontMain},${builtins.toString gtkFontSize},-1,5,50,0,0,0,0,0"

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
      font-name = "${fontMain} ${builtins.toString gtkFontSize}";
      document-font-name = "${fontMain} ${builtins.toString gtkFontSize}";
      monospace-font-name = "${fontMono} ${builtins.toString kittyFontSize}";
    };
  };

  programs.kitty.font = {
    name = fontMono;
    size = kittyFontSize;
  };

  programs.fuzzel.settings.main.font = "${fontMain}:size=${builtins.toString fuzzelFontSize}";

  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>${fontMain}</family>
        </prefer>
      </alias>
      <alias>
        <family>${fontMain}</family>
        <default>
          <family>sans-serif</family>
        </default>
      </alias>
    </fontconfig>
  '';

  home.packages = with pkgs; [
    google-fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
  ];
}