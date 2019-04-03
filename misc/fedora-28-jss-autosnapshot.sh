#!/bin/bash

#### Create snapshots of the fedora-28-jss vm
#### To be called by a systemd unit timer


##====================== functions and variables =========================================##
vmanage() { vboxmanage "$@"; }
grep() { /usr/bin/grep "$@"; }

_vmname="fedora-28-jss"
_uuid="$(vmanage list vms | grep "$_vmname" | awk '{ print $2 }' | sed 's/\{//;s/\}//')"
_runningvms="$(vmanage list runningvms | grep -q "$_vmname")"
_now="$(date +'%F_%T')"
_snapshotname="${_vmname}-$_now"
_snapshotdesc="Snapshot taken on: $_now"
##=============================== main ===================================================##

# Stop the vm if running
if [[ -n "$_runningvms" ]]; then
    vmanage controlvm "$_uuid" poweroff
fi

# Snapshot the vm
vmanage snapshot "$_uuid" take "$_snapshotname" --description "$_snapshotdesc"

# Start the vm
vmanage startvm "$_uuid" --type headless
