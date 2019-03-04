#!/bin/bash

#### Create snapshots of the fedora-28-jss vm
#### To be called by a systemd unit timer


##====================== functions and variables =========================================##
vmanage() { vboxmanage "$@"; }
_vmname="fedora-28-jss"
_uuid="$(vmanage list vms | grep "$_vmname" | awk '{ print $2 }' | tr -d \{ | tr -d \})"
_runningvms="$(vmanage list runningvms | grep -q "$_vmname")"
_now=$(date +'%F_%T')
_snapshotname="fedora_28_jss-$_now"
_snapshotdesc="Snapshot taken on: $_now"
##=============================== main ===================================================##

# Stop the vm if running
if [[ -z "$_runningvms" ]]; then
    vmanage controlvm "$_uuid" poweroff
fi

# Snapshot the vm
vmanage snapshot "$_uuid" take "$_snapshotname" --description "$_snapshotdesc"

# Start the vm
vmanage startvm "$_uuid" --type headless
