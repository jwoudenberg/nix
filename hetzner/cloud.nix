let
  sources = import ../nix/sources.nix;
  resilio = {
    listeningPort = 18776;
    dirs = {
      "music" = "readonly";
      "photo" = "readonly";
      "books" = "readonly";
      "jasper" = "readonly";
      "hiske" = "readonly";
      "hjgames" = "readwrite";
    };
    pathFor = dir: "/srv/volume1/${dir}";
  };
in {
  network = { };

  "ai-banana.jasperwoudenberg.com" = { pkgs, config, ... }: {

    # Morph
    deployment.targetUser = "root";

    imports = [ ./configuration.nix ];

    deployment.secrets.resilio-music = {
      source = "/tmp/secrets/resilio_key_music_readonly";
      destination = "/var/secrets/resilio_key_music_readonly";
    };

    deployment.secrets.resilio-books = {
      source = "/tmp/secrets/resilio_key_books_readonly";
      destination = "/var/secrets/resilio_key_books_readonly";
    };

    deployment.secrets.resilio-photo = {
      source = "/tmp/secrets/resilio_key_photo_readonly";
      destination = "/var/secrets/resilio_key_photo_readonly";
    };

    deployment.secrets.resilio-jasper = {
      source = "/tmp/secrets/resilio_key_jasper_readonly";
      destination = "/var/secrets/resilio_key_jasper_readonly";
    };

    deployment.secrets.resilio-hiske = {
      source = "/tmp/secrets/resilio_key_hiske_readonly";
      destination = "/var/secrets/resilio_key_hiske_readonly";
    };

    deployment.secrets.resilio-hjgames = {
      source = "/tmp/secrets/resilio_key_hjgames_readwrite";
      destination = "/var/secrets/resilio_key_hjgames_readwrite";
    };

    deployment.secrets.ssh-key = {
      source = "/tmp/secrets/ssh-key";
      destination = "/var/secrets/ssh-key";
      owner.user = "rslsync";
      owner.group = "rslsync";
    };

    deployment.secrets.sftp-password = {
      source = "/tmp/secrets/sftp-password";
      destination = "/var/secrets/sftp-password";
      owner.user = "rslsync";
      owner.group = "rslsync";
    };

    deployment.secrets.restic-password = {
      source = "/tmp/secrets/restic-password";
      destination = "/var/secrets/restic-password";
    };
  };
}
