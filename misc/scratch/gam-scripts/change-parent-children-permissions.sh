#!/bin/bash

# Goal: Make all objects in "Data Center Drive rclone" unsearcheable

#    1. get all objects
#    2. strip all but url
#    3. url types have standard form per type (listed below): https://aa/bb/cc vs https://one/two/three.
#       form will determine the field the object ID is in. Sort lists by form and put somewhere for inspection.
#    4. Make sure everything matches: (all urls) = (folders + forms + ...)
#    5. get IDs from urls using standard url forms
#    6. determine "Data Center Drive rclone" ID (from technology acct)
#    7. GAM: utilize "<object_id> in <parent_id>" where parent_id is ID of "Data Center Drive rclone"
#
#    Types for pattern matching
#
#    - folders|document|drawings|presentation|spreadsheets = 6th field
#    - file|forms                                          = 8th field

#@ variables
_gam_user="${1:-ebeale}"
_dir="/home/ebeale/TPS-Scratch/GAM-Scripts/${_gam_user}_drive"
_filelist="$_dir/${_gam_user}-files.txt"
_urllist="$_dir/${_gam_user}-urls.txt"
_idlog="$_dir/${_gam_user}-id-log.txt"
_not_a_type="$_dir/${_gam_user}-not-a-type.txt"
tee="tee -a"

#@ arrays
types=( 'folders' 'forms' 'document' 'drawings' 'presentation' 'spreadsheets' 'file')

#@ functions
grep() { /usr/bin/grep "$@"; }
get_line_count() { wc -l "$@" | awk '{ print $1 }'; }

#@ main

# ensure we are working in a safe place
mkdir -p "$_dir" || :
cd "$_dir" || exit

# status info about variables for debugging
{ printf   "%s\n" "Working Dir:     $_dir"\
  ; printf "%s\n" "Current Dir:     $(pwd)"\
  ; printf "%s\n" "Drive File list: $_filelist"\
  ; printf "%s\n" "Object URLS:     $_urllist"; } >> "$_dir/vars.txt"

# get our list of urls and write file list and urls to disk
gam user "$_gam_user" show filelist | tee "$_filelist" | grep -o "https://.*" | tee "$_urllist"

# separate out object ids by type and set line count vars
for type in "${types[@]}"; do
    grep "$type" "$_urllist" > "$type".txt

    if [[ "$type" =~ document|drawings|presentation|spreadsheets|folders ]]; then
	cat "$type".txt | awk -F '/' '{ print $6 }' > "$type".id
    else
	cat "$type".txt | awk -F '/' '{ print $8 }' > "$type".id
    fi

    declare -A counts
    counts+=( ["$type"]="$(get_line_count "$type".id)" )
done

# separate out objects that we don't want
grep \
    -v \
    -E \
    "${types[0]}|${types[1]}|${types[2]}|${types[3]}|${types[4]}|${types[5]}|${types[6]}" \
    "$_filelist" > "$_ntype"

# make sure line counts match that of file list
# echo "Prefixes:               ${!counts[@]}"
# echo "All ID counts:          ${counts[@]}"
# echo "Folder ID counts:       ${counts[folders]}"
# echo "Forms ID counts:        ${counts[forms]}"
# echo "Document ID counts:     ${counts[document]}"
# echo "Drawing ID counts:      ${counts[drawings]}"
# echo "Presentation ID counts: ${counts[presentation]}"
# echo "Spreadsheet ID counts:  ${counts[spreadsheets]}"
# echo "File ID counts:         ${counts[file]}"

filelist_count=$(($(get_line_count $_filelist) - $(get_line_count $_not_a_type)))
totalid_count=$((${counts[folders]} + ${counts[forms]} + ${counts[document]} + ${counts[drawings]} \
				    + ${counts[presentation]} + ${counts[spreadsheets]} + ${counts[file]}))

echo "File List Lines: $filelist_count"
echo "ID Lists Lines: $totalid_count"
