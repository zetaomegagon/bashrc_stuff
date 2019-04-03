    #!/bin/bash

    id_path=/usr/local/TPS
    id_file=.art

    if [[ -f "$id_path"/"$id_file" ]]; then
       echo "<result>true</result>"
    fi
