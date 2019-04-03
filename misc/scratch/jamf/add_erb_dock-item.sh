#!/bin/bash                                    

createERBDockAgent() {
    # variables
    local label="org.tpschool.ebeale.erb-dock-item.plist"
    local dockutil="/usr/local/bin/dockutil"
    local verb="--add"
    local application="/Applications/TPS Apps/ERB Secure Browser.app"
    local user="/Users/erb"
    local service="/Library/LaunchAgents/$label"
    
    # functions
    plistbuddy() { /usr/libexec/PlistBuddy "$@"; }
    
    # body
    plistbuddy -c "add :Label string $label" \
	       -c "add :ProgramArguments array" \
	       -c "add :ProgramArguments:0 string $dockutil" \
	       -c "add :ProgramArguments:1 string $verb" \
	       -c "add :ProgramArguments:2 string $application" \
	       -c "add :ProgramArguments:3 string $user" \
	       -c "add :RunAtLoad array" \
	       -c "add :RunAtLoad string true" \
	       $service

    chown root:wheel "$service"
    chmod 644 "$service"

    launchctl enable user/"$label" "$service"
    launchctl bootstrap user "$service"
}
