{ pkgs, ... }: {
  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    settings = {
      font_size = if builtins.currentSystem == "x86_64-darwin" then 16 else 13;
      shell = "${pkgs.fish}/bin/fish";
    };
  };
}
