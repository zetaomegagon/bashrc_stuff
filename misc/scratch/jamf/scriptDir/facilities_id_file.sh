#!/bin/bash

dotDir=/usr/local/TPS

    if [[ ! -d $dotDir ]]; then
	mkdir $dotDir
    fi
    
touch $dotDir/.facilities
