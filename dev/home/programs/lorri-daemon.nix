{ pkgs, ... }:
let target = "Library/LaunchAgents/lorri.daemon.plist";
in {
  home.file.lorri-daemon = {
    target = target + ".link";
    executable = false;
    onChange = "rm -f ${target}; cp $(readlink ${
      target + ".link"
    }) ${target}; launchctl unload -w ${target}; launchctl load -w ${target}";
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>lorri.daemon</string>
          <key>KeepAlive</key>
          <true/>
          <key>EnvironmentVariables</key>
          <dict>
              <key>PATH</key>
              <string>${pkgs.nix}/bin</string>
              <key>NIX_PATH</key>
              <string>nixpkgs=${pkgs.path}</string>
          </dict>
          <key>ProgramArguments</key>
          <array>
              <string>${pkgs.lorri}/bin/lorri</string>
              <string>daemon</string>
          </array>
          <key>StandardErrorPath</key>
          <string>/Users/jasper/Library/Logs/lorri.err.log</string>
          <key>StandardOutPath</key>
          <string>/Users/jasper/Library/Logs/lorri.out.log</string>
      </dict>
      </plist>
    '';
  };
}
