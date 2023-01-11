#!/usr/bin/env bash

#########################################################################################
# Pull top 8077 baby names in 2017, for boys, from namecensus.com                       #
#                                                                                       #
# NOTES                                                                                 #
# - help function                                                                       #
# - legit debugging                                                                     #
# - error messages                                                                      #
# - better modularity                                                                   #
# - return line for number literal input                                                #
# - max: return the highest line number as a natural number                             #
# - top: 10 - 1000, 5000, 10000, 20000                                                  #
# - random: 1, 5, 10, 20 (whith ability to select, and write liked names out to a file) #
# - option to use local data; or re-request the data                                    #
#########################################################################################

## variables
DEBUG="${1:-0}"

base_url="https://namecensus.com/baby_names/boys-2017"
target_dir="$HOME/projects/baby_names"
target_name="baby_names.txt"
target="${target_dir}/${target_name}"
pages=1000

## functions
requested-names-filter() {
    set -x
    # request and filter baby names
    local http_status
    http_status="$(curl -Iso /dev/null -w "%{http_code}" "${base_url}${postfix}")"

    if [[ "$http_status" = 200 ]]; then
        curl -s "${base_url}${postfix}" \
            | grep \<td\> \
            | awk -F 'td' '{ print $4 }' \
            | sed -e 's:\(<\|>\|/\)::g'
    elif grep -qvE . "$target"; then
        rm "$target"
        exit 3
    else
        exit 0
    fi
    set +x
}

paginate-names-requests() {
    # paginate requests for names
    for ((page=1;page<="${pages}";page++)); do
        if [[ "$page" -eq 1 ]]; then
            postfix=".html"
            requested-names-filter
        else
            postfix="_pg${page}.html"
            requested-names-filter
        fi
    done
}

get-baby-name() {
    # print a random baby name from the target
    grep -E ^$(( 1 + RANDOM % 8077 )) "$target"
}

## main
[[ "$DEBUG" -eq 1 ]] && set -x

# create target directory if it doesn't exit
if ! [[ -d "target_dir" ]]; then
    mkdir -p "$target_dir" || exit 1
fi

# ensure target file is empty
printf '' > "$target"

# append baby names to baby_names.txt
count=1

while read -r name; do
    printf "%s\n" "$count $name" >> "$target"
    count=$((count + 1))
done < <(paginate-names-requests)

# get a random baby name
get-baby-name

[[ "$DEBUG" -eq 1 ]] && set +x
