# zed.nix
#
# Purpose: Configure Zed code editor with PMD theming and AI integration
#
# This module:
# - Enables Zed editor with custom configuration
# - Integrates with PMD theming for consistent styling
# - Configures AI agent and language model settings

{ lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    userSettings = {
      agent = {
        always_allow_tool_actions = true;
        default_model = {
          model = "zai-org/GLM-4.7-TEE";
          provider = "openai";
        };
        model_parameters = [ ];
      };
      buffer_font_family = lib.mkForce "FiraCode Nerd Font";
      buffer_font_size = lib.mkForce 12.0;
      context_servers = {
        "mcp-server-context7" = {
          settings = {
            default_minimum_tokens = "2000";
          };
        };
        "mcp-server-exa-search" = {
          enabled = true;
          settings = {
            exa_api_key = null;
          };
        };
      };
      language_models = {
        openai = {
          api_url = "https://llm.chutes.ai/v1";
          available_models = [
            {
              display_name = "GLM-4.7-TEE";
              max_tokens = 200000;
              name = "zai-org/GLM-4.7-TEE";
            }
            {
              display_name = "Kimi-K2-Thinking";
              max_tokens = 262000;
              name = "moonshotai/Kimi-K2-Thinking";
            }
            {
              display_name = "MiniMax-M2.1-TEE";
              max_tokens = 196000;
              name = "MiniMaxAI/MiniMax-M2.1-TEE";
            }
          ];
        };
      };
      ui_font_family = lib.mkForce "Rounded Mplus 1c";
      ui_font_size = lib.mkForce 12;
      ui_font_weight = lib.mkForce 500;
    };
  };
}
