#!/bin/bash

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
