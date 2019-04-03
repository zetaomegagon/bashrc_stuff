#!/bin/bash

_password=''
_user=''
_org=''
_credentials=$(printf "$_user:$_password" | iconv -t ISO-8859-1 | base64 -i -)
_urlPrefix="https://${_org}.jamfcloud.com/JSSResource"
_urlRequest="$(echo policies | tr 'A-Z' 'a-z')/id/8"

grep() { /usr/bin/grep "$@"; }

curl -s \
     --header "authorization: Basic $_credentials" \
     --header "accept: application/xml" \
     --request GET "${_urlPrefix}"/"${_urlRequest}" \
     | xmllint --format -



