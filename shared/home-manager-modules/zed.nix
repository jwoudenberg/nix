{ pkgs, ... }:
{
  home.packages =
    let
      zed-fhs = pkgs.buildFHSUserEnv {
        name = "zed";
        targetPkgs = p: [ p.zed-editor ];
        runScript = "zed";
      };
    in
    [ zed-fhs ];

  home.file.".config/zed/settings.json".text = builtins.toJSON {
    assistant = {
      enabled = false;
    };
    auto_install_extensions = {
      nix = true;
      ruby = true;
    };
    auto_update = false;
    buffer_font_size = 14;
    buffer_font_weight = 100;
    gutter = {
      folds = false;
      code_actions = false;
    };
    indent_guides = {
      enabled = false;
    };
    journal = {
      hour_format = "hour24";
    };
    languages = {
      Ruby = {
        language_servers = [
          "ruby-lsp"
          "!solargraph"
        ];
      };
    };
    lsp = {
      ruby-lsp = {
        initialization_options = {
          diagnostics = false;
        };
      };
    };
    preview_tabs = {
      enabled = true;
      enable_preview_from_file_finder = true;
      enable_preview_from_code_navigation = true;
    };
    restore_on_startup = "none";
    tab_bar = {
      show_nav_history_buttons = false;
    };
    telemetry = {
      metrics = false;
      diagnostics = false;
    };
    toolbar = {
      breadcrumbs = false;
      quick_actions = false;
      selections_menu = false;
    };
    use_autoclose = false;
    vim_mode = true;
  };
}
