#!/bin/bash -x

_urlInclude="$(echo ComputerGroups | tr 'A-Z' 'a-z')/id"
_xmlPath="${HOME}/.tps/Scratch/JAMF/extAttributes"


attribute_names=( 'finanace' 'development' \
			     'facilities' 'front_office' \
			     'technology' 'faculty' 'staff' \
			     'student' 'blt' 'admissions' \
			     'communications' 'heads' 'humanresources' \
			     'art' 'spanish' 'physed' 'pka' 'pkb' 'ka' 'kb' \
			     'pa' 'pb' 'pc' 'pd' '3a' '3b' 'jua' 'jub' 'jud' \
			     'juc' 'ms6' 'ms7' 'ms8' )


for _name in "${attribute_names[@]}"; do

    curl --silent \
	 --request POST \
	 "${_urlPrefix}"/"${_urlInclude}"/0 \
	 --header "Authorization: Basic ${_credentials}" \
    	 --header "Accept: application/xml" \
	 --header "Content-Type: application/xml" \
	 --data \
"<computer_group>
  <id>0</id>
  <name>[EA] [Group ID] - ${_name}</name>
  <is_smart>true</is_smart>
  <site>
    <id>-1</id>
    <name>None</name>
  </site>
  <criteria>
    <size>1</size>
    <criterion>
      <name>Group File ${_name}?</name>
      <priority>0</priority>
      <and_or>and</and_or>
      <search_type>is</search_type>
      <value>true</value>
      <opening_paren>false</opening_paren>
      <closing_paren>false</closing_paren>
    </criterion>
  </criteria>
</computer_group>"
  

done
