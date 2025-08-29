# LazyVim Setup Documentation

## Overview

This document describes the LazyVim configuration integrated into your NixOS home-manager setup. LazyVim is a Neovim configuration framework that provides a modern, extensible editing experience with excellent language server support.

## What's Included

### Core Components
- **LazyVim Base**: Modern Neovim distribution with lazy.nvim plugin manager
- **Language Support**: Comprehensive LSP configuration for multiple languages
- **Theme Integration**: Rose Pine theme matching your existing desktop theme
- **Custom Plugins**: Additional plugins for specialized language support

### Supported Languages

#### Official LazyVim Extras (Auto-configured)
- **Nix**: `nil` LSP server with `nixfmt-rfc-style` formatter
- **Rust**: `rust-analyzer` with `rustaceanvim` integration
- **Python**: `pyright` LSP with `ruff` linting and `black` formatting
- **TypeScript/JavaScript**: `vtsls` LSP with Prettier formatting
- **HTML/CSS/JSON**: `vscode-langservers-extracted` for web technologies
- **YAML**: Full YAML support with schema validation
- **Markdown**: Enhanced markdown editing with preview support

#### Custom Language Support
- **GLSL**: Shader language syntax highlighting
- **Hyprlang**: Hyprland configuration syntax
- **Fish**: Fish shell syntax highlighting
- **QT/C++**: Enhanced C++ support for QT development
- **Lua**: Built-in Lua support (LazyVim core)

## Installation & Setup

### Automatic Setup
The LazyVim configuration is automatically set up when you rebuild your NixOS configuration:

```bash
# Rebuild your system (run on the target host)
sudo nixos-rebuild switch --flake .#hostname

# Or for home-manager only rebuild
home-manager switch --flake .#username@hostname
```

### First Run
On first launch, LazyVim will:
1. Install all configured plugins automatically
2. Set up language servers
3. Configure the Rose Pine theme

```bash
# Launch Neovim (will trigger plugin installation)
nvim
```

## Usage

### Basic Editing
- **File Navigation**: `<leader>fe` (file explorer), `<leader>ff` (find files)
- **Buffer Management**: `<leader>bb` (switch buffers), `<leader>bd` (delete buffer)
- **Search**: `<leader>sg` (grep), `<leader>sw` (search word)
- **Git**: `<leader>gg` (lazygit), `<leader>gb` (blame)

### Language Features
- **Go to Definition**: `gd`
- **Find References**: `gr`
- **Hover Documentation**: `K`
- **Code Actions**: `<leader>ca`
- **Rename**: `<leader>cr`
- **Format Document**: `<leader>cf`

### Language-Specific Commands

#### Nix Development
- **Format**: `<leader>cf` (uses nixfmt-rfc-style)
- **Organize Imports**: `<leader>co`

#### Rust Development
- **Code Actions**: `<leader>cR`
- **Debuggables**: `<leader>dr`
- **Run**: `<leader>rr`

#### Python Development
- **Format**: `<leader>cf` (uses black)
- **Organize Imports**: `<leader>co`

#### Web Development (TypeScript/JavaScript)
- **Organize Imports**: `<leader>co`
- **Fix All**: `<leader>cF`
- **Go to Source Definition**: `<leader>cD`

## Configuration Files

### Main Configuration
- `~/.config/nvim/`: LazyVim base configuration (auto-generated)
- `~/.config/nvim/lua/config/options.lua`: Custom options
- `~/.config/nvim/lua/plugins/custom.lua`: Custom plugins
- `~/.config/nvim/lua/config/autocmds.lua`: Custom autocommands
- `~/.config/nvim/lua/config/keymaps.lua`: Custom keymaps

### Customization
To customize LazyVim:

1. **Add Plugins**: Edit `~/.config/nvim/lua/plugins/custom.lua`
2. **Modify Options**: Edit `~/.config/nvim/lua/config/options.lua`
3. **Add Keymaps**: Edit `~/.config/nvim/lua/config/keymaps.lua`
4. **Add Autocommands**: Edit `~/.config/nvim/lua/config/autocmds.lua`

## Theme Configuration

### Rose Pine Integration
The configuration includes a customized Rose Pine theme that matches your desktop theme:

```lua
-- Theme settings in ~/.config/nvim/lua/plugins/custom.lua
require("rose-pine").setup({
  variant = "main",
  dark_variant = "main",
  -- ... additional customization
})
```

### Theme Switching
You can switch themes by modifying the colorscheme in your LazyVim configuration.

## Troubleshooting

### Plugin Installation Issues
If plugins fail to install:
```bash
# Clean and reinstall plugins
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
nvim  # This will reinstall everything
```

### LSP Server Issues
Check LSP status:
```vim
:LspInfo
```

Restart LSP servers:
```vim
:LspRestart
```

### Performance Issues
Disable animations for better performance:
```lua
vim.g.snacks_animate = false
```

## Keybindings Reference

### Core LazyVim Keymaps
- `<leader>fe`: File explorer
- `<leader>ff`: Find files
- `<leader>sg`: Grep search
- `<leader>bb`: Switch buffers
- `<leader>bd`: Delete buffer
- `<leader>gg`: Lazygit
- `<leader>ca`: Code actions
- `<leader>cr`: Rename
- `<leader>cf`: Format document

### Custom Keymaps Added
- `<leader>fn`: New file
- `<leader>xl`: Location list
- `<leader>xq`: Quickfix list
- `<C-h/j/k/l>`: Window navigation (if tmux is configured)

## Integration with Existing Tools

### Fish Shell
Aliases are automatically set up:
```fish
alias vim="nvim"
alias vi="nvim"
```

### Git Integration
- **Lazygit**: `<leader>gg` for terminal UI
- **Git blame**: `<leader>gb`
- **Git diff**: Built into status line

### Terminal Integration
- **Terminal mode**: `<C-\><C-n>` to exit terminal mode
- **New terminal**: `<leader>ft`

## Advanced Configuration

### Adding New Language Support
1. Add the language server to `home_modules/packages.nix`
2. Create a LazyVim extra or custom plugin configuration
3. Add file type detection in autocommands

### Custom Plugin Example
```lua
-- Add to ~/.config/nvim/lua/plugins/custom.lua
{
  "username/plugin-name",
  config = function()
    require("plugin-name").setup({
      -- plugin configuration
    })
  end,
}
```

## Resources

- [LazyVim Documentation](https://www.lazyvim.org/)
- [Neovim Documentation](https://neovim.io/doc/)
- [LSP Configuration](https://github.com/neovim/nvim-lspconfig)

## Support

If you encounter issues:
1. Check `:Lazy` for plugin status
2. Check `:LspInfo` for LSP status
3. Review LazyVim logs: `~/.local/state/nvim/lazyvim.log`
4. Check Neovim logs: `~/.local/state/nvim/log`

## Migration from Other Editors

### From Micro
- **File opening**: `nvim filename` (same as `micro filename`)
- **Search**: `<leader>sg` instead of Ctrl+F
- **Save**: `:w` instead of Ctrl+S
- **Quit**: `:q` instead of Ctrl+Q

### Learning Curve
LazyVim has a learning curve but provides:
- Better language support
- More powerful editing features
- Extensive plugin ecosystem
- Modern development workflow

Start with basic editing and gradually explore advanced features as needed.