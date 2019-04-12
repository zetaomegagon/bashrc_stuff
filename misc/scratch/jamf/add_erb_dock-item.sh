#!/bin/bash -x

#-- create dockutil script
script_dir="/usr/local/TPS/scripts"
script_name="addERBDockItem.sh"
plist_dir="/Library/LaunchAgents"
plist_name="org.tps.ebeale.addERBDockItem.plist"

plistbuddy() { /usr/libexec/PlistBuddy "$@"; }

# test for directories
mkdir -p "$script_dir" || :
mkdir -p "$plist_dir" || :

# Create addERBDockItem.sh
cat <<'EOF'> "$script_dir"/"$script_name"
#!/bin/bash

script_dir="/usr/local/TPS/scripts"
script_name="addERBDockItem.sh"
app_name="/Applications/TPS Apps/ERBSecureBrowser.app"
user_dir="/Users/erb"
plist_dir="/Library/LaunchDaemons"
plist_name="org.tps.ebeale.addERBDockItem.plist"

dockutil() { /usr/local/bin/dockutil "$@"; }

while :; do
  if [[ "$(who | grep console | awk '{ print $1 }')" = erb ]] && \
     [[ -e "user_name/Library/Preferences/com.apple.dock.plist" ]]; then
    
    dockutil --add "$app_name" "$user_dir"
    rm "$script_dir"/"$script_name"
    launchctl unload -w "$plist_dir"/"$plist_name"
    rm "$plist_dir"/"$plist_name"
    break

  fi
done
EOF

# set script permissions and ownership
chown root:wheel "$script_dir"/"$script_name"
chmod +x "$script_dir"/"$script_name"


# Create LaunchAgent

plistbuddy -c "add :Label string $plist_name" \
	       -c "add :ProgramArguments array" \
	       -c "add :ProgramArguments:0 string $script_dir/$script_name" \
	       -c "add :RunAtLoad string true" \
	       "$plist_dir"/"$plist_name"

# set LaunchAgent permissions and ownership
chown erb:staff "$plist_dir"/"$plist_name"
chmod 644 "$plist_dir"/"$plist_name"

# enable and start LaunchAgent. reload if already running.
if ! launchctl load -w "$plist_dir"/"$plist_name" >/dev/null 2>&1; then
    launchctl unload -w "$plist_dir"/"$plist_name"
    launchctl load -w "$plist_dir"/"$plist_name"
else
    launchctl load -w "$plist_dir"/"$plist_name"
fi
