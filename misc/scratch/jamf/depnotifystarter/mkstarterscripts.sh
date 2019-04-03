#!/bin/bash

_pattern="tf6tCjm1e"
_dep_notify_path="${HOME}/.tps/scratch/jamf/depnotifystarter"

while read -r _package_name; do
    _name=${_package_name//_id_file.pkg}
    _upcase_name=${_name^}
    _dep_notify_name="depNotify_${_name}.sh"

    echo "Creating: ${_dep_notify_name}"
    
    sed "s/${_pattern}/install${_upcase_name}ID/" \
	"${_dep_notify_path}"/depNotifyTemplate.sh > "${_dep_notify_path}"/scripts/"${_dep_notify_name}"
    
done < gid_package_names.txt
