{ pkgs, ... }:

{
  home.packages = [ pkgs.aerc ];

  xdg.configFile."aerc/aerc.conf".text = ''
    [general]
    unsafe-accounts-conf = true

    [ui]
    timestamp-format = Mon Jan 2 2006 15:04
    this-day-time-format = 15:04
    this-week-time-format = Mon 15:04
    this-year-time-format = Mon Jan 2 15:04
    new-message-bell = false

    [compose]
    reply-to-self = false

    [filters]
    text/html = ${pkgs.aerc}/share/aerc/filters/html
    text/* = awk -f ${pkgs.aerc}/share/aerc/filters/plaintext
  '';

  xdg.configFile."aerc/accounts.conf".text = ''
    [jasper]
    default = INBOX
    archive = archive
    from = mail@jasperwoudenberg.com
    source = maildir://~/docs/email
  '';
}
