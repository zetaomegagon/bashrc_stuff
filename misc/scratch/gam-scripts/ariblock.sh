#!/bin/bash

#@ variables
SUFFIX="@tpschool.org"
SRCUSER="$1"
DESTUSER="$2"
ARCHIVE="archived.accounts.user"
RUN=
FILEIDS=#something with IFS to get all other params

#@ functions
change_file_owner() {
    RUN=0
    
    if [[ $RUN -eq 1 ]]; then
	SRCUSER=$DESTUSER
	DESTUSER=$SRCUSER
    else
	SRCUSER=$SRCUSER
	DESTUSER=$DESTUSER
    fi
    
    for ID in "${FILEIDS[@]}"; do
	gam user "$SRCUSER$SUFFIX" add drivefileacl "$ID" user "$DESTUSER$SUFFIX" role owner &
    done

    RUN=1
}

create_transfer() {
    transfer_apps=( 'gdrive' 'calendar' ) #google plus is transferable, but don't know how it is reffered to

    for APP in $(echo "$FILEIDS"); do #will this work?
	if [[ "$APP" = gdrive ]]; then
	    gam create datatransfer "$SRCUSER$SUFFIX" "$APP" "$ARCHIVE$SUFFIX" privacy_level shared,private
	else
	    gam create datatransfer "$SRCUSER$SUFFIX" "$APP" "$ARCHIVE$SUFFIX"
	fi
    done

    #also transfer all emails
}

#@ main

# change ownership to another account
change_file_owner

# begin EVERYTHING transfer
create_transfer

# change ownership back to original owner
change_file_owner
