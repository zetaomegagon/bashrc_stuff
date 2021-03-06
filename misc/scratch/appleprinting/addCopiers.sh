#!/bin/bash -x

## VARS for mounting fileshare
## and installing drivers
#smbDomain="WORKGROUP"
smbUser="casperinstall"
smbPass="casperinstall"
server="jss-prod.tpschool.org"
share="ProductionShare"
mountPath="/Users/Shared"
packageDir="$mountPath/Packages"
cachePath="/Library/Application Support/JAMF/Waiting Room"
copierDrivers=('Ricoh_PS_Printers_Vol4_EXP_LIO_Driver.pkg' 'NRG_PS_Printers_Vol4_EXP_LIO_Driver.pkg')

## Vars for adding copiers
cupsName=('bw_copier_tps' \
	      'fo_copier_tps' \
	      'co_copier_tps' \
	      'ec_copier_tps')

address=('10.0.3.1' \
	     '10.0.3.2' \
	     '10.0.3.3' \
	     '10.2.0.251')

ppdPath="/Library/Printers/PPDs/Contents/Resources"

ppd=('RICOH MP 9003' \
	 'RICOH MP 5055' \
	 'RICOH MP C6004ex' \
	 'RICOH MP C3004ex')

humanName=('Black and White Copier' \
	       'Front Office Copier' \
	       'Color Copier'\
	       'ECEC Copier')

location=('1st Floor, Room 154' \
	      '1st Floor, Front Office' \
	      'Lower Level, Patagonia' \
	      'ECEC Front Office')


## Functions
jamf() {
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


    # Cache & install copier drivers
    for driver in "${copierDrivers[@]}"; do
	rsync -rzq "$packageDir"/"$driver" "$cachePath/"
	installer -pkg "$cachePath"/"$driver" -target /
    done


    umount "$mountPath"
}

rem-copiers() {
    for copier in $(lpstat -p 2>/dev/null | awk '{ print $2 }'); do
	if [[ "$copier" =~ .*_[cC][oO][pP][iI][eE][rR] ]] || \
	   [[ "$copier" =~ .*_[tT][pP][sS] ]] || \
	   [[ "$copier" =~ [0-9]{1,3}\.* ]]; then

		lpadmin -x "$copier" &

	fi
    done
}

map-copiers() {
    local count=0
    
    for copier in "${cupsName[@]}"; do
	if [[ -e "$ppdPath"/"${ppd[$count]}" ]]; then
	    lpadmin -p "${cupsName[$count]}" \
		    -E -v ipp://"${address[$count]}/ipp/print" \
		    -P "$ppdPath"/"${ppd[$count]}" \
		    -D "${humanName[$count]}" \
		    -L "${location[$count]}"

	    count=$((count + 1))
	fi
    done
}

## Main
if [[ ! -e "$ppdPath"/"${ppd[0]}" ]] || \
   [[ ! -e "$ppdPath"/"${ppd[1]}" ]] || \
   [[ ! -e "$ppdPath"/"${ppd[2]}" ]] || \
   [[ ! -e "$ppdPath"/"${ppd[3]}" ]]; then

    # Re-create Waiting Room -- (why? I forget...)
    if [[ ! -d "$cachePath" ]]; then
	rm -rf "$cachePath" || :
	mkdir "$cachePath"
    fi

    # Mount ProductionShare
    mount-install

    # Remove TPS copiers
    rem-copiers

    # Map copiers
    map-copiers

else
    # Remove TPS copiers
    rem-copiers

    # Map copiers
    map-copiers
fi
