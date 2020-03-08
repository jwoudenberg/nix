eval (bash -c "source ~/.nix-profile/etc/profile.d/nix.sh; echo export NIX_PATH=\"\$NIX_PATH\"; echo export PATH=\"\$PATH\"; echo export SSL_CERT_FILE=\"\$SSL_CERT_FILE\"")
set -gx NIX_PATH $HOME/.nix-defexpr/channels:$NIX_PATH
random-colors --hook=fish | source
