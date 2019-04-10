{ pkgs }:
{

  flatwhite = pkgs.vimUtils.buildVimPlugin {
    name = "flatwhite";
    src = pkgs.fetchFromGitHub {
    owner = "kamwitsta";
    repo = "flatwhite-vim";
    rev = "534c6f2f524c8444fd9d712ff995365e6d3f2f32";
    sha256 = "04r0y7kq7lr98gks090w6i6wm3kv7vrjyd0kh836qf2fwkqajljr";
    };
  };

  base2-tone = pkgs.vimUtils.buildVimPlugin {
    name = "base2-tone";
    src = pkgs.fetchFromGitHub {
      owner = "atelierbram";
      repo = "Base2Tone-vim";
      rev = "37675fb1f3a0f6de991fee37a5db3d32011c2240";
      sha256 = "0v9azp819ywj8aqvm0nzx5zv8lj1nl8swzbkgl1c1mibwayqyrn1";
    };
  };

  cursor-line-current-window = pkgs.vimUtils.buildVimPlugin {
    name = "cursor-line-current-window";
    src = pkgs.fetchFromGitHub {
      owner = "vim-scripts";
      repo = "CursorLineCurrentWindow";
      rev = "b4eeea98b0d139772969fd243a8802a9883fd2a8";
      sha256 = "17pz4xv58rd89lxqbazlhwyz0vv273ajsx9d6ay5ibpp1wv4adzy";
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
