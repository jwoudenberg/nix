{ pkgs, ... }:
let
  target =  "Library/LaunchAgents/lorri.daemon.plist";
in
{
  home.file.lorri-daemon = {
    target = target;
    executable = false;
    onChange = "launchctl unload -w ${target}; launchctl load -w ${target}; launchctl start lorri.daemon";
    text = ''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>lorri.daemon</string>
    <key>KeepAlive</key>
    <true/>
    <key>RunAtLoad</key>
    <true/>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${pkgs.nix}/bin</string>
    </dict>
    <key>ProgramArguments</key>
    <array>
        <string>${pkgs.lorri}/bin/lorri</string>
        <string>daemon</string>
    </array>
    <key>StandardErrorPath</key>
    <string>/Users/jasper/Library/Logs/lorri.start.log</string>
    <key>StandardOutPath</key>
    <string>/Users/jasper/Library/Logs/lorri.start.log</string>
</dict>
</plist>
'';
  };
}
