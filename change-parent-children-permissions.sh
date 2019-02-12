#!/bin/bash

# Goal: Make all objects in "Data Center Drive rclone" unsearcheable

# Types
# - folders
# - forms
# - document
# - drawings
# - presentation
# - spreadsheets
# - file

#@ variables
_dir="~/.tps/TPS-Scratch/GAM-Scripts"
_filelist="$_dir/all-tech-files.txt"
_urllist="$_dir/all-tech-urls.txt"

#@ functions
grep() { /usr/bin/grep "$@"; }

#@ main

# 1. get all objects
gam user technology show file list > $_filelist

# 2. strip all but url
grep -o "https://.*" $_filelist > $_urllist

# 3. url types have standard form per type: https://aa/bb/cc vs https://one/two/three
_types=( 'folders' 'forms' 'documents' 'drawings' 'presentation' 'spreadsheets' 'file')

parallel --will-cite \
	 grep $_urllist {} > {}.txt ::: $(echo "{$_types[*]}") || return
					  
# 4. get IDs from urls using standard url forms
echo "For this step you need to inspect each file" && exit

# 5. determine "Data Center Drive rclone" ID
echo "Requires more manual intervention"

# 6. GAM: utilize "<object_id> in <parent_id>" where parent_id is ID of "Data Center Drive rclone"
echo "Requires experimentation"

