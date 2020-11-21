{ pkgs, ... }: {
  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    settings = {
      font_size = 18;
      shell = "${pkgs.fish}/bin/fish";
    };
  };
}
