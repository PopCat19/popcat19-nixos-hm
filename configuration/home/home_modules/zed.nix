# Zed Configuration Module
#
# Purpose: Configure Zed code editor with PMD theming and custom settings
# Dependencies: zed-editor, stylix, pmd
# Related: stylix.nix, fonts.nix
#
# This module:
# - Enables Zed editor with custom configuration
# - Integrates with PMD theming for consistent styling
# - Configures AI agent and language model settings
# - Sets up context servers for enhanced functionality
{
  config,
  pkgs,
  lib,
  inputs,
  userConfig,
  ...
}: {
  # Enable Zed editor
  programs.zed-editor = {
    enable = true;

    # Configure Zed settings
    # These settings integrate with PMD theming and provide AI functionality
    userSettings = {
      # AI Agent Configuration
      agent = {
        always_allow_tool_actions = true;
        default_model = {
          provider = "openai";
          model = "MiniMaxAI/MiniMax-M2";
        };
        model_parameters = [];
      };

      # Language Models Configuration
      language_models = {
        openai = {
          api_url = "https://llm.chutes.ai/v1";
          available_models = [
            {
              name = "zai-org/GLM-4.6-FP8";
              display_name = "GLM-4.6-FP8";
              max_tokens = 200000;
            }
            {
              name = "moonshotai/Kimi-K2-Thinking";
              display_name = "Kimi-K2-Thinking";
              max_tokens = 128000;
            }
            {
              name = "MiniMaxAI/MiniMax-M2";
              display_name = "MiniMax-M2";
              max_tokens = 128000;
            }
          ];
        };
      };

      # Context Servers Configuration
      context_servers = {
        "mcp-server-exa-search" = {
          enabled = true;
        };
        "mcp-server-context7" = {
          settings = {
            default_minimum_tokens = "2000";
          };
        };
      };
    };
  };

  # Note: zed-editor package is included in editors.nix
}
