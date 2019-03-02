#!/bin/bash

# Check if root
if [[ "$EUID" != 0 ]]; then
    printf "Please run as root!"
    printf "\n"
    exit 1
fi

# Add official Flash repo
dnf install -y "http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm"

# Refresh repos and upgrade
dnf upgrade --refresh -y

# Install depends for Pepper Flash
dnf provides -y */libpepflashplayer.so

# Install Pepper Flash
dnf install -y "flash-player-ppapi"

link-pepper-flash() {
    # Symlink required files into Chromium dirs

    local pepper_link="/usr/lib64/chromium-browser/PepperFlash/libpepflashplayer.so"
    local manifest_link="/usr/lib64/chromium-browser/PepperFlash/manifest.json"

    if [[ ! -h "$pepper_link" ]]; then
	ln -s /usr/lib64/flash-plugin/libpepflashplayer.so "$pepper_link"
    fi
    
    if [[ ! -h "$manifest_link" ]]; then
	ln -s /usr/lib64/flash-plugin/manifest.json "$manifest_link"
    fi 
}

# Install Chromium if not installed
if $(which chromium-browser >/dev/null 2>&1); then
    dnf install -y chromium
fi

# Provide Pepper Flash to Chromium
link-pepper-flash
    
# Chromium H.264 support
dnf install -y chromium-libs-media-freeworld
