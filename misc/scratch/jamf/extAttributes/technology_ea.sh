    #!/bin/bash

    id_path=/usr/local/TPS
    id_file=.technology

    if [[ -f "$id_path"/"$id_file" ]]; then
       echo "<result>true</result>"
    fi
