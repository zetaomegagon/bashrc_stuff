#!/bin/bash

get_install_stat() {
    # get installation status of a policy ID in the JSS 
    # example: get_install_stat 6
    # returns: install|cache
    
    _getStat=$(curl -su $_user:$_pass "$_baseUrl"/policies/id/"$1"/subset/Packages \
		   | xmllint --format - \
		   | grep --color=always -E '(Cache|Install)' \
		   | sed 's/^[ \t]*//;s/[ \t]*$//;s/<action>//;s/<\/action>//')

    install_stat() {
    	if [[ -z "$_getStat" ]]; then
    	    printf "\n%s\n\n" "ID: $1: Not a policy or this policy has no package attached"
    	else
    	    printf "\n%s\n\n" "ID: $1: Status is set to: $_getStat"
    	fi
    }

    install_stat "$1"

}

get_install_stat "$1"
