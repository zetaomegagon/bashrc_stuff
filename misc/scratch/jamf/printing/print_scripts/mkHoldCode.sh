#!/bin/bash

# Create unique print hold codes

gen_hold_code() {
    local NUMBER=$RANDOM

    if [[ ${#NUMBER} -lt 4 ]]; then
	gen_hold_code
    else
	NUMBER=${NUMBER:0:4}
    fi
    
    printf "%s\n" "$NUMBER"
}

gen_hold_code