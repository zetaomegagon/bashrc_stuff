#!/bin/bash

#@ Functions
getName() {
    # Get UserName & PrintUserName

    osaGetName() {
	osascript -e 'set varName to display dialog "Enter Your Name" default answer "FirstName LastName"' \
			  | awk -F ':' '{ print $3 }' \
			  | tr '[A-Z]' '[a-z]'
    }

    read FirstName LastName <<< $(osaGetName)

    while : ; do
	if [[ ! "$FirstName" =~ [a-z]+|[-]+ ]] && [[ ! "$LastName" =~ [a-z]+|[-]+ ]]; then
	    osascript -e 'set varName to display dialog "Valid charaters are: A-Z, a-z, and the dash (-) charater"'
	    get_name
	else
	    break
	fi
    done

    FirstInitial="${FirstName:0:1}"
    UserName="${FirstInitial}${LastName}"
    RemDashName="${UserName//[-]/}"
    PrintUserName="${RemDashName:0:8}"
}

getPassword() {
    # Get user inputted password
    printf "%s" "$UserName"
}

mkUser() {
    # Create permanent user
    sysadminctl -AddUser "$UserName" \
	        -fullName "$FirstName $LastName" \
	        -UID "$(( ($RANDOM % 4999) + 5000 ))" \
	        -shell /bin/bash \
                -password "$(getPassword)" \
	        -home /Users/"$UserName" \
	        -adminUser jamf \
                -adminPassword "ArtisLife%100"
}

plistbuddy() {
    # PlistBuddy
    /usr/libexec/PlistBuddy "$@"
}

mkDelUserLaunchDaemon() {
    # Delete default user
    plistbuddy -c "add :Lable:"
    
}

mkPrintPresetsLaunchAgent() {
    # Create Preset LaunchAgent
    plistbuddy -c ""
}

mkComuterAsset() {
    # Create asset tag id file
}

mkComputerName() {
    # Create ComputerName id file
    touch /usr/local/tps/id/".$AssetTag$Group$UserName"
} 
