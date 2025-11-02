{
  pkgs,
  config,
  ...
}: {
  # Micro text editor configuration
  programs.micro = {
    enable = true;
    settings = {
      # Note: colorscheme is now handled by Stylix
      mkparents = true;
      softwrap = true;
      wordwrap = true;
      tabsize = 4;
      autoclose = true;
      autoindent = true;
      autosave = 5;
      clipboard = "terminal";
      cursorline = true;
      diffgutter = true;
      ignorecase = true;
      scrollbar = true;
      smartpaste = true;
      statusline = true;
      syntax = true;
      tabstospaces = true;
    };
  };

  # Micro editor colorscheme - now handled by Stylix
  # Removing custom colorscheme file as Stylix provides Rose Pine theming
}
