#!/bin/bash -x

dot_files=( 'finanace' 'development' \
			 'facilities' 'front_office' \
			 'technology' 'faculty' 'staff' \
			 'student' 'blt' 'admissions' \
			 'communications' 'heads' 'humanresources' \
			 'art' 'spanish' 'physed' 'pka' 'pkb' 'ka' 'kb' \
			 'pa' 'pb' 'pc' 'pd' '3a' '3b' 'jua' 'jub' 'jud' \
			 'juc' 'ms6' 'ms7' 'ms8' 'test')

dir="scriptDir"
prefix="_id_file.sh"

if [[ ! -d $dir ]]; then
    mkdir $dir || exit
fi

cd $dir && rm ./* 2>/dev/null

for file in "${dot_files[@]}"; do
    touch ${file}${prefix}
    
    printf "%s" "\
#!/bin/bash

dotDir="/usr/local/TPS"

    if [[ ! -d \$dotDir ]]; then
	mkdir \$dotDir
    fi
    
touch \$dotDir/.$file
" > ${file}${prefix}
    
done
