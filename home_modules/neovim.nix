# LazyVim Neovim Configuration
{ config, pkgs, lib, ... }:

{
  # Install Neovim and required dependencies
  home.packages = with pkgs; [
    neovim
    # Language servers
    nil # Nix LSP
    rust-analyzer # Rust LSP
    pyright # Python LSP
    lua-language-server # Lua LSP
    nodePackages_latest.typescript-language-server # TypeScript LSP
    nodePackages_latest.vscode-langservers-extracted # HTML/CSS/JSON LSP
    # Formatters
    nixfmt-rfc-style # Nix formatter
    black # Python formatter
    prettierd # JavaScript/TypeScript/HTML/CSS formatter
    # Tools
    ripgrep # For telescope
    fd # For telescope
    # Git integration
    lazygit
  ];

  # Clone LazyVim starter and set up configuration
  home.activation = {
    setupLazyVim = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Create Neovim config directory if it doesn't exist
      mkdir -p $HOME/.config/nvim

      # Clone LazyVim starter if not already present
      if [ ! -f $HOME/.config/nvim/lazyvim.json ]; then
        ${pkgs.git}/bin/git clone https://github.com/LazyVim/starter $HOME/.config/nvim-tmp
        cp -r $HOME/.config/nvim-tmp/* $HOME/.config/nvim/
        rm -rf $HOME/.config/nvim-tmp
        rm -rf $HOME/.config/nvim/.git
      fi
    '';
  };

  # XDG configuration for Neovim
  xdg.configFile = {
    # LazyVim options
    "nvim/lua/config/options.lua" = {
      text = ''
        -- Options for LazyVim
        vim.g.lazyvim_python_lsp = "pyright"
        vim.g.lazyvim_rust_diagnostics = "rust-analyzer"

        -- Disable animations for better performance
        vim.g.snacks_animate = false

        -- Root detection
        vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

        -- Disable some features for minimal setup
        vim.g.lazyvim_check_order = false
        vim.g.lazygit_config = false
      '';
    };

    # LazyVim plugins and extras
    "nvim/lua/plugins/custom.lua" = {
      text = ''
        return {
          -- Language extras
          { import = "lazyvim.plugins.extras.lang.nix" },
          { import = "lazyvim.plugins.extras.lang.rust" },
          { import = "lazyvim.plugins.extras.lang.python" },
          { import = "lazyvim.plugins.extras.lang.typescript" },
          { import = "lazyvim.plugins.extras.lang.json" },
          { import = "lazyvim.plugins.extras.lang.yaml" },
          { import = "lazyvim.plugins.extras.lang.markdown" },

          -- Formatting extras
          { import = "lazyvim.plugins.extras.formatting.prettier" },

          -- Custom plugins for unsupported languages
          {
            "tikhomirov/vim-glsl",
            ft = { "glsl", "vert", "frag", "geom", "comp" },
          },
          {
            "dag/vim-fish",
            ft = "fish",
          },

          -- Hyprland syntax highlighting
          {
            "theRealCarneiro/hyprland-vim-syntax",
            ft = "hypr",
          },

          -- QT development support
          {
            "octol/vim-cpp-enhanced-highlight",
            ft = { "cpp", "hpp", "c", "h" },
          },

          -- Rose Pine theme
          {
            "rose-pine/neovim",
            name = "rose-pine",
            priority = 1000,
            config = function()
              require("rose-pine").setup({
                variant = "main",
                dark_variant = "main",
                bold_vert_split = false,
                dim_nc_background = false,
                disable_background = false,
                disable_float_background = false,
                disable_italics = false,
                groups = {
                  background = "base",
                  background_nc = "_experimental_nc",
                  panel = "surface",
                  panel_nc = "base",
                  border = "highlight_med",
                  comment = "muted",
                  link = "iris",
                  punctuation = "subtle",
                  error = "love",
                  hint = "iris",
                  info = "foam",
                  warn = "gold",
                  headings = {
                    h1 = "iris",
                    h2 = "foam",
                    h3 = "rose",
                    h4 = "gold",
                    h5 = "pine",
                    h6 = "foam",
                  },
                },
                highlight_groups = {
                  ColorColumn = { bg = "rose" },
                  CursorLine = { bg = "foam", blend = 10 },
                  StatusLine = { fg = "love", bg = "love", blend = 10 },
                },
              })
              vim.cmd("colorscheme rose-pine")
            end,
          },
        }
      '';
    };

    # Custom autocommands
    "nvim/lua/config/autocmds.lua" = {
      text = ''
        -- Autocommands for custom filetypes
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "hypr",
          callback = function()
            vim.bo.commentstring = "# %s"
            vim.bo.filetype = "hypr"
          end,
        })

        -- QT specific settings
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "cpp", "hpp" },
          callback = function()
            vim.bo.makeprg = "make"
            vim.bo.commentstring = "// %s"
          end,
        })

        -- GLSL file detection
        vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
          pattern = { "*.glsl", "*.vert", "*.frag", "*.geom", "*.comp" },
          callback = function()
            vim.bo.filetype = "glsl"
          end,
        })
      '';
    };

    # Keymaps customization
    "nvim/lua/config/keymaps.lua" = {
      text = ''
        -- Custom keymaps for LazyVim
        local map = vim.keymap.set

        -- Additional keymaps
        map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
        map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
        map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

        -- Terminal keymaps
        map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
      '';
    };
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Shell aliases
  programs.fish.shellAliases = lib.mkIf config.programs.fish.enable {
    vim = "nvim";
    vi = "nvim";
  };

  programs.bash.shellAliases = lib.mkIf config.programs.bash.enable {
    vim = "nvim";
    vi = "nvim";
  };
}