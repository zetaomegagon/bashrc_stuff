#!/bin/bash

sudo dnf install \
     http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm

dnf provides */libpepflashplayer.so

sudo dnf install flash-player-ppapi

sudo ln -s \
     /usr/lib64/flash-plugin/libpepflashplayer.so \
     /usr/lib64/chromium-browser/PepperFlash/libpepflashplayer.so

sudo ln -s \
     /usr/lib64/flash-plugin/manifest.json \
     /usr/lib64/chromium-browser/PepperFlash/manifest.json
