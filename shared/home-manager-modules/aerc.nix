{ pkgs, ... }:

{
  home.packages = [ pkgs.aerc ];

  xdg.configFile."aerc/aerc.conf".text = ''
    [general]
    unsafe-accounts-conf = true

    [ui]
    timestamp-format = "Mon 06-01-02 15:04"
    this-day-time-format = "             15:04"
    this-week-time-format = "Mon          15:04"
    this-year-time-format = "Mon    01-02 15:04"
    new-message-bell = false
    sort = -r date

    [viewer]
    pager = nvim +Man!

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
    copy-to = Sent
    outgoing = smtp+none://ai-banana.panther-trout.ts.net:8025
  '';
}
