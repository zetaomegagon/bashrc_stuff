    #!/bin/bash

    id_path=/usr/local/TPS
    id_file=.spanish

    if [[ -f "$id_path"/"$id_file" ]]; then
       echo "<result>true</result>"
    fi
