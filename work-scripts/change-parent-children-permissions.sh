#!/bin/bash -x

# Goal: Make all objects in "Data Center Drive rclone" unsearcheable

#    1. get all objects
#    2. strip all but url
#    3. url types have standard form per type (listed below): https://aa/bb/cc vs https://one/two/three.
#       form will determine the field the object ID is in. Sort lists by form and put somewhere for inspection.
#    4. Make sure everything matches: (all urls) = (folders + forms + ...)
#    5. get IDs from urls using standard url forms
#    6. determine "Data Center Drive rclone" ID (from technology acct)
#    7. GAM: utilize "<object_id> in <parent_id>" where parent_id is ID of "Data Center Drive rclone"

#    Types for pattern matching

#    - folders      = 4th field
#    - forms        = 7th field
#    - document     = 5th field
#    - drawings     = 5th field
#    - presentation = 5th field
#    - spreadsheets = 5th field
#    - file	    = 4th field

#@ variables
_dir="/home/ebeale/TPS-Scratch/GAM-Scripts/change-permissions"
_filelist="$_dir/all-tech-files.txt"
_urllist="$_dir/all-tech-urls.txt"
tee="tee -a"

#@ functions
grep() { /usr/bin/grep "$@"; }
get_line_count() { wc -l "$@" | awk '{ print $2 }'; }

#@ main
mkdir -p "$_dir" || :
{ cd "$_dir" && parallel 'echo "" > {}' ::: *; } || exit


{ printf   "%s\n" "Working Dir:     $_dir"\
  ; printf "%s\n" "Current Dir:     $(pwd)"\
  ; printf "%s\n" "Drive File list: $_filelist"\
  ; printf "%s\n" "Object URLS:     $_urllist"; } >> "$_dir/vars.txt"

declare -a _types
_types=( 'folders' 'forms' 'document' 'drawings' 'presentation' 'spreadsheets' 'file')

if [[ -f "$_filelist" ]]; then
    cat "$_filelist" \
	| $tee  "$_filelist" \
	| grep -o "https://.*" \
	| $tee "$_urllist" \
	| while read -r _url; do
	for _type in "${_types[@]}"; do
	    echo "$_url" \
		| grep "$_type" \
		| $tee "${_type}".txt \
		| case "$_type" in ### How to get the ID? We have (3) cases. Do I write a case for each?
		document|drawings|presentation|spreadsheets)
		    echo "$_url" | awk -F '/' '{ print $4 }' | $tee "${_type}".id ;;
		file|folders)
		    echo "$_url" | awk -F '/' '{ print $4 }' | $tee "${_type}".id ;;
		forms)
		    echo "$_url" | awk -F '/' '{ print $4 }' | $tee "${_type}".id ;;
		*)
		    echo "${_type}: ${_url}: invalid type or malformed url, possibly unaccounted for."
	    esac
	done
    done
fi
