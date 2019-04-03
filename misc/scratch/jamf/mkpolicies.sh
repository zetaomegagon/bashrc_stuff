#!/bin/bash

_password=''
_user=''
_org=''
_credentials="$(printf "$_user:$_password" | iconv -t ISO-8859-1 | base64 -i -)"
_urlPrefix="https://${_org}.jamfcloud.com/JSSResource"
_urlRequest="policies/id"
_xmlFilePath="${HOME}/.tps/Scratch/JAMF/policyDir"

cd ${_xmlFilePath}

for _xmlFile in *; do

    curl --verbose \
    	 --request POST \
    	 "${_urlPrefix}"/"${_urlRequest}"/0 \
    	 --header "Authorization: Basic ${_credentials}" \
    	 --header "Accept: text/xml" \
    	 --header "Content-Type: text/xml" \
    	 --data @"${_xmlFile}"
    
done
