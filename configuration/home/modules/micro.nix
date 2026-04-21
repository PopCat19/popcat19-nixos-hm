# micro.nix
#
# Purpose: Configures the Micro terminal text editor.
#
# This module:
# - Enables Micro text editor
# - Sets editor preferences for editing experience

_: {
  programs.micro = {
    enable = true;
    settings = {
      autoclose = true;
      autoindent = true;
      autosave = 5;
      clipboard = "terminal";
      cursorline = true;
      diffgutter = true;
      ignorecase = true;
      mkparents = true;
      scrollbar = true;
      smartpaste = true;
      softwrap = true;
      statusline = true;
      syntax = true;
      tabsize = 4;
      tabstospaces = true;
      wordwrap = true;
    };
  };
}
