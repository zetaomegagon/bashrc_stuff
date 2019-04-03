#!/bin/bash

source ~/gits/bashrc_stuff/misc/scratch/jamf/sensetive.sh

_urlRequest="$(echo policies | tr 'A-Z' 'a-z')/id/8"

grep() { /usr/bin/grep "$@"; }

curl -s \
     --header "authorization: Basic $_credentials" \
     --header "accept: application/xml" \
     --request GET "${_urlPrefix}"/"${_urlRequest}" \
     | xmllint --format -



