{ pkgs, ... }:
{
  home.packages = [ pkgs.zed-editor ];

  home.file.".config/zed/settings.json".text = builtins.toJSON {
    auto_installed_extensions = {
      nix = true;
      ruby = true;
    };
    auto_update = false;
    buffer_font_size = 14;
    buffer_font_weight = 100;
    hour_format = "hour24";
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
    };
    vim_mode = true;
  };
}
