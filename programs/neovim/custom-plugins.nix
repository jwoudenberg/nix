{ pkgs }:
{

  flatwhite = pkgs.vimUtils.buildVimPlugin {
    name = "flatwhite";
    src = ./flatwhite;
  };

  tabnine = pkgs.vimUtils.buildVimPlugin {
    name = "tabnine";
    src = pkgs.fetchFromGitHub {
        owner = "zxqfl";
        repo = "tabnine-vim";
        rev = "b9f7b52e8d42f868c31399f92783b721b5851363";
        sha256 = "0qpi11r07yh72v1hb5ylw45inm08iml1ncfr3h4gbjmlnq8fx5iw";
    };
  };

  quickfix-reflector = pkgs.vimUtils.buildVimPlugin {
    name = "quickfix-reflector";
    src = pkgs.fetchFromGitHub {
      owner = "stefandtw";
      repo = "quickfix-reflector.vim";
      rev = "c76b7a1f496864315eea3ff2a9d02a53128bad50";
      sha256 = "02vb7qkdprx3ksj4gwnj3j180kkdal8jky69dcjn8ivr0x8g26s8";
    };
  };

  todo = pkgs.vimUtils.buildVimPlugin {
    name = "todo";
    src = pkgs.fetchFromGitHub {
      owner = "elentok";
      repo = "todo.vim";
      rev = "789ab3b8fca9b4433792d33ecbef062646798571";
      sha256 = "1b182w084zpp384b07k68kf58fs7crv0gfss57ay58v8s9ppkbqd";
    };
  };

  unimpaired = pkgs.vimUtils.buildVimPlugin {
    name = "unimpaired";
    src = pkgs.fetchFromGitHub {
      owner = "bronson";
      repo = "vim-visual-star-search";
      rev = "fa55818903301d61cef67341d3524a63a14bc033";
      sha256 = "1ny6sdl08mbh5j3fvsznlgxdv2hip190dmsgs22gygn8wpj2xc8l";
    };
  };

  visual-star-search = pkgs.vimUtils.buildVimPlugin {
    name = "visual-star-search";
    src = pkgs.fetchFromGitHub {
      owner = "tpope";
      repo = "vim-unimpaired";
      rev = "b3f0f752d7563d24753b23698d073632267af3d1";
      sha256 = "01s4fb4yj960qjdrakyw3v08jrsajqidx8335c1z9c9j1736svj8";
    };
  };
}
