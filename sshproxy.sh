#!/bin/bash

# Start an ssh proxy to my linode in the background

# functions
start_proxy(){
    while : ; do
	if pgrep -a ssh | grep -q zomegagon; then
	    continue
	    sleep 5
	else
	    /usr/bin/ssh -o "ServerAliveInterval 5" \
			 -o "ServerAliveCountMax 3" \
			 -D 8080 -qCN zomegagon@50.116.63.65
	fi
    done >/dev/null 2>&1
}

# main
start_proxy &
    
    
