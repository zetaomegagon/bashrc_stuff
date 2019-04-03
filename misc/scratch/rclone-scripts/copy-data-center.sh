#!/bin/bash

SRC_DRIVE="technology_drive"
DEST_DRIVE="data_center_archive"
SRC="Data Center Drive"
DEST="$(date +'%m_%d_%y-%T')-data_center_drive_archive"

copy() {
    # copy contents of sourc to dest with md5sum compare
    rclone copy "$SRC_DRIVE":/"$SRC" "$DEST_DRIVE":/"$DEST" --progress
}

copy
