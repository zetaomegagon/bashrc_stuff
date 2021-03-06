#!/bin/bash

#@ variables
parentFolder="1bC2-Q4qPmfUaZlFxcDo0tQuN4lNjcDbz"

#@ arrays
declare -A driveFolders

driveFolders=(
    [folders]='1pjJtrMPNy9Rbwqh7Zx4UitlSRSdSkAg-'
    [forms]='1oCbEBjyxPliWhRBZHdxAmzyf8SQW1Wn1'
    [document]='12eIuMBi-jBnSw4i4b6Qx4QUxhPjnhBSG'
    [drawing]='1hEJOnUqOnr5j0VsccO2qa8agTt2AyMvq'
    [presentation]='1de5YINCdS4p2hHz8M8q6kLwVu_J_P_9c'
    [spreadsheets]='10OEATwdzpqvQz9tOK7E9Z6AcAMT_2wXw'
    [file]='1MShruVJAeL6VMwt75UztBNqiwHiJDzqF'
)

mimeType=(
    'gdrawing'
    'gfolder'
    'gdocument'
    'gpresentation'
    'gspreadsheet'
    'gdirectory'
    'gfusion'
    'gsite'
    'gdoc'
    'gform'
    'gscript'
    'gsheet'
)

types=(
    'folders'
    'forms'
    'document'
    'drawings'
    'presentation'
    'spreadsheets'
    'file'
)

#@ functions
grep() { /usr/bin/grep "$@"; }

create_file() {

    echo "$1"
    echo "g${1%s}"
    echo "$count"
    echo "${1}.folder.foo.bar"

    parallel \
	gam user "$2" add drivefile \
	drivefilename "test.file.${1}.foo.bar.{}" \
	mimetype "g${1%s}" \
	parentname "${1}.folder.foo.bar" \
    ::: {0..999}

}

#@ main
echo "${driveFolders[@]}"

for folderType in "${!driveFolders[@]}"; do
    if [[ "$folderType" != "file" ]]; then
    	create_file "$folderType" ebeale &
    fi
done
