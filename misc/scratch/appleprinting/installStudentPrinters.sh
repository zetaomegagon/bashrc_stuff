#!/bin/bash -x

## VARS for mounting fileshare and installing drivers

# fileshare
smbDomain="WORKGROUP"
smbUser="casperinstall"
smbPass="casperinstall"
server="jss-prod.tpschool.org"
share="ProductionShare"
mountPath="/Users/Shared"
packageDir="$mountPath/Packages"
cachePath="/Library/Application Support/JAMF/Waiting Room"

## installing drivers and adding printers
printerDrivers=('HewlettPackardPrinterDrivers_v5.1.pkg')

cupsName=('ms6_printer_tps' \
	      'ms7_printer_tps' \
	      'ms8_printer_tps')

address=('10.0.3.50' \
	     '10.0.3.51' \
	     '10.0.3.52')

ppdPath="/Library/Printers/PPDs/Contents/Resources"

ppd=('HP LaserJet 4250.gz')

humanName=('MS6 Printer' \
	       'MS7 Printer' \
	       'MS8 Printer')

location=('2nd Floor, Middle School 6 Area' \
	      '1st Floor, Middle School 7/8 Area' \
	      '1st Floor, Middle School 7/8 Area')


## Functions
jamf() {
    # syntactic sugar
    /usr/local/jamf/bin/jamf "$@"
}

mount-install() {
    # Unmount if dirty unmount
    if mount | grep -q casper ; then
	umount "$mountPath"
    fi

    # Make sure mount is successful
    until [[ -d "$packageDir" ]]; do
	mount -t smbfs //"$smbUser":"$smbPass"@"$server"/"$share" "$mountPath"
    done


    # Cache & install printer drivers
    for driver in "${printerDrivers[@]}"; do
	rsync -rzq "$packageDir"/"$driver" "$cachePath/"
	installer -pkg "$cachePath"/"$driver" -target /
    done


    umount "$mountPath"
}

rem-printers() {
    for printer in $(lpstat -p 2>/dev/null | awk '{ print $2 }'); do
	if [[ "$printer" =~ .*_[pP][rR][iI][nN][tT][eE][rR] ]] || \
	       [[ "$printer" =~ .*_[cC][oO][pP][iI][eE][rR] ]] || \
	       [[ "$printer" =~ .*_[tT][pP][sS] ]] || \
	       [[ "$printer" =~ [0-9]{1,3}\.* ]]; then

	    lpadmin -x "$printer" &

	fi
    done
}

map-printers() {
    count=0

    for printer in "${cupsName[@]}"; do
	if [[ -e "$ppdPath"/"${ppd[$count]}" ]]; then
	    lpadmin -p "${cupsName[$count]}" \
            	    -E -v ipp://"${address[$count]}/ipp/print" \
                    -P "$ppdPath"/"${ppd[0]}" \
		    -D "${humanName[$count]}" \
		    -L "${location[$count]}"

	    count=$((count + 1))
	fi
    done
}

set-default-printer() {
    local computerName="$(scutil --get ComputerName)"
    local head="${computerName:0:5}"
    local middle="${computerName:${#head}:3}"
    local groupName="$middle"

    case "$groupName" in
	MS6)
	    lpoptions -d "${cupsName[0]}" ;;
	MS7)
	    lpoptions -d "${cupsName[1]}" ;;
	MS8)
	    lpoptions -d "${cupsName[2]}" ;;
	*)
	    printf "%s is not a valid ComputerName for this script!!!\\n" "$computerName" >&2
	    exit 1
    esac
}

## Main
if [[ ! -e "$ppdPath"/"${ppd[0]}" ]]; then

    # Re-create Waiting Room -- (why? I forget...)
    if [[ ! -d "$cachePath" ]]; then
	rm -rf "$cachePath" || :
	mkdir "$cachePath"
    fi

    # Mount ProductionShare
    mount-install

    # Remove TPS printer
    rem-printers

    # Map printer
    map-printers

    # Set default printer
    set-default-printer

else
    # Remove TPS printers
    rem-printers

    # Map printers
    map-printers

    # Set default printer
    set-default-printer
fi
