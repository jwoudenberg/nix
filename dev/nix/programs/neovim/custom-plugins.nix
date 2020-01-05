{ pkgs }: {

  candid = pkgs.vimUtils.buildVimPlugin {
    name = "candid";
    src = pkgs.fetchFromGitHub {
      owner = "flrnprz";
      repo = "candid.vim";
      rev = "a1b688256f474821d3ac8c905c02666e343484b5";
      sha256 = "0cvixd3q9cxka3jvsjywkjdw4cr3jhacxji4fc7yx0wxgbpbb3ps";
    };
  };

  gv = pkgs.vimUtils.buildVimPlugin {
    name = "gv.vim";
    src = pkgs.fetchFromGitHub {
      owner = "junegunn";
      repo = "gv.vim";
      rev = "023b315ea1fb92aba20c71ef54f806d2903cfc9e";
      sha256 = "0m6ikvdnngiscdk3bdyr4hpja16dlvi5d8bq4z1iprvw40sqb2zq";
    };
  };

  tabnine = pkgs.vimUtils.buildVimPlugin {
    name = "tabnine";
    src = pkgs.fetchFromGitHub {
      owner = "zxqfl";
      repo = "tabnine-vim";
      rev = "f7be9252afe46fa480593bebdd154278b39baa06";
      sha256 = "1jzpsrrdv53gji3sns1xaj3pq8f6bwssw5wwh9sccr9qdz6i6fwa";
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
}
