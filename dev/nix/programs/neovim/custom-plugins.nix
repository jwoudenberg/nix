{ pkgs }: {

  vim-dogrun = pkgs.vimUtils.buildVimPlugin {
    name = "vim-dogrun";
    src = pkgs.fetchFromGitHub {
      owner = "wadackel";
      repo = "vim-dogrun";
      rev = "155aff4b4ae432e3360027dee7a7aa5da2877676";
      sha256 = "1hyr5f5f2qbiar4j5511r3sgwx2qji0y9qlfrj724bh1l5rdcaa9";
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
