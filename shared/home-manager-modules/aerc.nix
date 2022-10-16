{ pkgs, config, ... }:

{
  home.packages = [ pkgs.aerc ];

  xdg.configFile."aerc/aerc.conf".text = let
    addressBook = "${config.home.homeDirectory}/hjgames/agenda/mensen.ini";
    addressBookCmd = pkgs.writers.writePython3 "address-book-cmd" { } ''
      import configparser
      import sys

      config = configparser.ConfigParser()
      config.read('${addressBook}')
      needle = ' '.join(sys.argv[1:]).lower().strip()

      for key in config:
          email = config[key].get('email')
          if email is None:
              continue
          if needle in key.lower() or needle in email.lower():
              print(f'{email}\t{key}')
    '';
  in ''
    [general]
    unsafe-accounts-conf = true

    [ui]
    timestamp-format = "Mon 06-01-02 15:04"
    this-day-time-format = "             15:04"
    this-week-time-format = "Mon          15:04"
    this-year-time-format = "Mon    01-02 15:04"
    new-message-bell = false
    sort = -r date
    dirlist-format = %n

    [viewer]
    pager = nvim -R -c 'set ft=mail laststatus=0 nomod nolist nonumber'

    [compose]
    reply-to-self = false
    editor = ${pkgs.neovim}/bin/nvim
    address-book-cmd = "${addressBookCmd} '%s'"

    [filters]
    text/html = ${pkgs.aerc}/share/aerc/filters/html
    text/* = awk -f ${pkgs.aerc}/share/aerc/filters/plaintext
  '';

  xdg.configFile."aerc/accounts.conf".text = ''
    [jasper]
    default = INBOX
    archive = archive
    postpone = drafts
    from = "Jasper Woudenberg <mail@jasperwoudenberg.com>"
    source = maildir://~/docs/email
    copy-to = sent
    outgoing = smtp+none://ai-banana.panther-trout.ts.net:8025
  '';

  xdg.configFile."aerc/binds.conf".text = ''
    # Binds are of the form <key sequence> = <command to run>
    # To use '=' in a key sequence, substitute it with "Eq": "<Ctrl+Eq>"
    # If you wish to bind #, you can wrap the key sequence in quotes: "#" = quit
    <C-p> = :prev-tab<Enter>
    <C-n> = :next-tab<Enter>
    <C-t> = :term<Enter>

    [messages]
    q = :quit<Enter>

    j = :next<Enter>
    <Down> = :next<Enter>
    <C-d> = :next 50%<Enter>
    <C-f> = :next 100%<Enter>
    <PgDn> = :next 100%<Enter>

    k = :prev<Enter>
    <Up> = :prev<Enter>
    <C-u> = :prev 50%<Enter>
    <C-b> = :prev 100%<Enter>
    <PgUp> = :prev 100%<Enter>
    g = :select 0<Enter>
    G = :select -1<Enter>

    J = :next-folder<Enter>
    K = :prev-folder<Enter>
    H = :collapse-folder<Enter>
    L = :expand-folder<Enter>

    v = :mark -t<Enter>
    V = :mark -v<Enter>

    T = :toggle-threads<Enter>

    <Enter> = :view<Enter>
    d = :prompt 'Really delete this message?' 'delete-message'<Enter>
    D = :delete<Enter>
    A = :archive flat<Enter>

    C = :compose<Enter>

    rr = :reply -a<Enter>
    rq = :reply -aq<Enter>
    Rr = :reply<Enter>
    Rq = :reply -q<Enter>

    c = :cf<space>
    $ = :term<space>
    ! = :term<space>
    | = :pipe<space>

    / = :search<space>
    \ = :filter<space>
    n = :next-result<Enter>
    N = :prev-result<Enter>
    <Esc> = :clear<Enter>

    [view]
    / = :toggle-key-passthrough<Enter>/
    q = :close<Enter>
    O = :open<Enter>
    S = :save<space>
    | = :pipe<space>
    D = :delete<Enter>
    A = :archive flat<Enter>q

    f = :forward<Enter>
    rr = :reply -a<Enter>
    rq = :reply -aq<Enter>
    Rr = :reply<Enter>
    Rq = :reply -q<Enter>

    H = :toggle-headers<Enter>
    <C-k> = :prev-part<Enter>
    <C-j> = :next-part<Enter>
    J = :next<Enter>
    K = :prev<Enter>

    [view::passthrough]
    $noinherit = true
    $ex = <C-x>
    <Esc> = :toggle-key-passthrough<Enter>

    [compose]
    # Keybindings used when the embedded terminal is not selected in the compose
    # view
    $ex = <C-x>
    <C-k> = :prev-field<Enter>
    <C-j> = :next-field<Enter>
    <tab> = :next-field<Enter>

    [compose::editor]
    # Keybindings used when the embedded terminal is selected in the compose view
    $noinherit = true
    $ex = <C-x>
    <C-k> = :prev-field<Enter>
    <C-j> = :next-field<Enter>
    <C-p> = :prev-tab<Enter>
    <C-n> = :next-tab<Enter>

    [compose::review]
    # Keybindings used when reviewing a message to be sent
    y = :send<Enter>
    n = :abort<Enter>
    p = :postpone<Enter>
    q = :choose -o d discard abort -o p postpone postpone<Enter>
    e = :edit<Enter>
    a = :attach<space>
    d = :detach<space>

    [terminal]
    $noinherit = true
    $ex = <C-x>

    <C-p> = :prev-tab<Enter>
    <C-n> = :next-tab<Enter>
  '';

  xdg.desktopEntries.aerc = {
    name = "aerc";
    exec = "${pkgs.kitty}/bin/kitty ${pkgs.aerc}/bin/aerc %F";
    terminal = true;
  };
}
