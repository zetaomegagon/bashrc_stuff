#!/bin/bash

torrent() {
    local torrent_dir="~/Downloads/torrents"
    local log_file="$torrent_dir/aria2c.log"

    [[ ! -d "$torrent_dir" ]] && mkdir "$torrent_dir" || :
    
    aria2c --dir="$torrent_dir" \
	   --log="$log_file" \
	   --check-integrity true \
	   --bt-detach-seed-only true \
	   --bt-enable-lpd true \
	   --bt-force-encryption true \
	   --bt-hash-check-seed false \
	   --bt-save-metadata true \
	   --bt-load-saved-metadata \
	   --dht-listen-port=55535-65535 \
	   --listen-port=55535-65535 \
	   --max-overall-upload-limit=50K \
	   --seed-ratio=2.0 \
	   --metalink-preferred-protocol=https \
	   "$1"
}

