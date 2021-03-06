#!/bin/bash -x

## purpose
#
#  For suspended users:
#  - move to 'suspended.users.group@tpschool.org' for each user
#  - set long, random password for each user
#  - transfer drive to 'archived.accounts.user@tpschool.org'
#  - delete backup codes for users in suspended group
#  - delete oauth tokens for users in suspended group
#  - delete app specific passwords for each user
##

## variables
grep="/usr/bin/grep"
suspend_group="suspended.users.group@tpschool.org"
archive_account="archived.accounts.user@tpschool.org"
suspended_list="$(pwd)/tps.suspended.user.txt"
token_list="$(pwd)/tps.suspended.user.tokens.txt"
app_password_list="$(pwd)/tps.suspended.user.appids.txt"

## functions
mkrandom() { mktemp -u "$(for i in {0..64}; do printf X; done)"; }

list_suspended_to_file() {
    gam print users suspended \
	| ${grep} True \
	| awk -F ',' '{ print $1 }' >> $suspended_list 
}

list_tokens_to_file() {
    cat "$suspended_list" | while read -r user; do
	gam user ${user} show tokens \
	    | ${grep} 'Client ID:' \
	    | awk -F ':' '{ print $2 }' >> $token_list
    done
}

list_app_ids_to_file() {
    cat "$suspended_list" | while read -r user; do
	gam user ${user} show asps \
	    | ${grep} 'ID:' \
	    | awk -F ':' '{ print $2 }' >> $app_password_list
    done
}

gen_lists() {
    rm "$suspended_list" \
       "$token_list" \
       "$app_password_list"
    
    list_suspended_to_file
    list_tokens_to_file &
    list_app_ids_to_file
}

## body
main() {
    # generate lists
    gen_lists
    
    # add suspended users to suspend group; set random password; archive drive
    cat ${suspended_list} | parallel --will-cite "gam update group ${suspend_group} add member {} 2>/dev/null" & \
	parallel --will-cite "gam update user {} password $(mkrandom) changepassword off" & \
	parallel --will-cite "gam user {} transfer drive ${archive_account} 2>/dev/null" &
    
    # delete backup codes for all users in the group
    parallel --will-cite "gam group ${suspend_group} delete backupcodes 2>/dev/null" &

    # delete suspended user tokens from all users in suspend group
    cat ${token_list} | parallel --will-cite "gam group ${suspend_group} delete token clientid {} 2>/dev/null" &

    # delete app passwords for all users in group
    cat ${app_password_list} | parallel --will-cite "gam group ${suspend_group} delete asp {} 2>/dev/null" &
}

main
