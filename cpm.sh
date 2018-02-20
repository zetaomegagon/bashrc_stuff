#!/bin/bash -xe

#  A wrapper for the chromium-browser for managing profiles
#  as separate chromium data directories and running them out
#  of ram.
#
#  Functionality:
#
#    1. Copies data dir to a unique dir in tmpfs
#    2. Executes chromium-browser
#    2. Dates, archives, and compresses orig. data dir
#    3. Upon exit copies data dir from tmpfs to base dir
#
#  Usage:
#
#    chromium <data_dir>
#
#  Example(s):
#
#    chromium personal
#    chromium work
#    chromium guest
#
#  TODO
#
#    1. Are all checks meaningful?
#    2. Keep only last x archives
#    3. Roll back to last archive (better: rollback to n archive via menu)
#    4. Unqualified call to script uses guest account:
#     a. Features
#      1. Self-destructing (shred?)
#      2. No backups
#      3. Incognito by default
#
#    5. What do exit statuses mean?
#    6. Raise exceptions for errors.
#    7. Add debug/testing features.
#    8. Better discovery of already running chromium pids (too much grepping)
#    9. Refactor/restructure


# Sanity check: already got a PID?
pid=$(ps -ax \
          | grep -v grep \
          | grep "chromium-browser" \
          | grep "$1" \
          | head -1)

[[ "$pid" != '' ]] && exit 2

# Main function
cpm() {
    _chromium="/usr/bin/chromium-browser"
    _chrome="/usr/bin/google-chrome-stable"
    _default_url="https://www.netflix.com/"
    
    cd "${HOME}/.config/chromium/"

    case "$1" in
        personal|tps)
            "$_chromium" \
		--user-data-dir="$1" \
                --disk-cache-dir=/tmp/chromium/cache-"$1"
            ;;
	incognito)
	    "$_chromium" \
		--incognito \
		--user-data-dir="$1" \
		>/dev/null 2>&1 &
	    wait "$!"
	    sleep 3
	    rm -r "$1"
	    ;;
	chrome-stable)
	    "$_chrome" \
		--user-data-dir="$1" \
		--disk-cache-dir=/tmp/chromium/cache-"$1" \
		"$_default_url"
	    ;;
        *)
            echo "Call with one of:"
            echo " - personal"
            echo " - tps"
            echo " - incognito"
            exit 1
    esac
}

# Make sure the process and spawn die
pid=$(ps -ax \
          | grep -v grep \
          | grep "chromium-browser" \
          | grep "$1" \
          | head -1)

kill-pid() {
    for _pid in "$pid"; do
	if [[ "$_pid" != '' ]]; then
	    kill -HUP "$_pid"
	fi
    done
}

cpm "$1" & wait "$!"; kill-pid && exit 0
