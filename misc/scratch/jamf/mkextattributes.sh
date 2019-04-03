#!/bin/bash -x

_password=''
_user=''
_credentials="$(printf "$_user:$_password" | iconv -t ISO-8859-1 | base64 -i -)"
_urlPrefix="https://tpschool.jamfcloud.com/JSSResource"
_urlInclude="$(echo ComputerExtensionAttributes | tr 'A-Z' 'a-z')/id"
_xmlPath="${HOME}/.tps/Scratch/JAMF/extAttributes"


attribute_names=( 'finanace' 'development' \
			     'facilities' 'front_office' \
			     'technology' 'faculty' 'staff' \
			     'student' 'blt' 'admissions' \
			     'communications' 'heads' 'humanresources' \
			     'art' 'spanish' 'physed' 'pka' 'pkb' 'ka' 'kb' \
			     'pa' 'pb' 'pc' 'pd' '3a' '3b' 'jua' 'jub' 'jud' \
			     'juc' 'ms6' 'ms7' 'ms8' )

# loop over attribute_names array
for _name in "${attribute_names[@]}"; do

    # write a script to file with
    # unique attribute name
    printf "%s\n" \
"#!/bin/bash

id_path=/usr/local/TPS
id_file=.${_name}

if [[ -f "\$id_path"/"\$id_file" ]]; then
  echo \"<result>true</result>\"
fi" > ${_xmlPath}/${_name}_ea.sh

    # encode script for upload with curl
    _encoded_script=$(perl -p -e 'BEGIN { use CGI qw(escapeHTML); } $_ = escapeHTML($_);' \
			   ${_xmlPath}/${_name}_ea.sh)

    # upload xml with unique attribute name
    # and script uto jss
    curl --verbose \
	 --request POST \
	 "${_urlPrefix}"/"${_urlInclude}"/0 \
	 --header "Authorization: Basic ${_credentials}" \
    	 --header "Accept: application/xml" \
	 --header "Content-Type: application/xml" \
	 --data  "<computer_extension_attribute>
<id>0</id>
<name>Group File ${_name}?</name>
<description>looks for /usr/local/TPS/.${_name}</description>
<data_type>String</data_type>
<input_type>
<type>script</type>
<platform>Mac</platform>
<script>
${_encoded_script}
</script>
</input_type>
<inventory_display>Extension Attributes</inventory_display>
<recon_display>Extension Attributes</recon_display>
</computer_extension_attribute>"

done
