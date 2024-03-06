#!/usr/bin/env nu

(
  systemd-run --user --
    qutebrowser
    https://ai-banana.panther-trout.ts.net/feeds/
    https://nrc.nl
    https://ftm.nl
    https://hachyderm.io/home
    https://discourse.nixos.org/latest
    https://roc.zulipchat.com/
)
