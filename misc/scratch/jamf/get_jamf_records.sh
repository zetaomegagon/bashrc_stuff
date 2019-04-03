#!/bin/bash

_password='r0;tWE(rmkN8FLvzT$kD'
_user='ebeale'
_credentials=$(printf "$_user:$_password" | iconv -t ISO-8859-1 | base64 -i -)
_urlPrefix="https://tpschool.jamfcloud.com/JSSResource"
_urlRequest="$(echo policies | tr 'A-Z' 'a-z')/id/8"

grep() { /usr/bin/grep "$@"; }

curl -s \
     --header "authorization: Basic $_credentials" \
     --header "accept: application/xml" \
     --request GET "${_urlPrefix}"/"${_urlRequest}" \
     | xmllint --format -



