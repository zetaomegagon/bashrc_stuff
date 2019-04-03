#!/bin/bash -x

## Vars for installing drivers from pkgs
cachePath="."

copierDrivers=('Ricoh_PS_Printers_Vol4_EXP_LIO_Driver.pkg' \
		   'NRG_PS_Printers_Vol4_EXP_LIO_Driver.pkg')

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
install-drivers() {
    # Cache & install copier drivers
    for driver in "${copierDrivers[@]}"; do

	if [[ ! -e "$ppdPath"/"${ppd[0]}" ]] || \
	       [[ ! -e "$ppdPath"/"${ppd[1]}" ]] || \
	       [[ ! -e "$ppdPath"/"${ppd[2]}" ]] || \
	       [[ ! -e "$ppdPath"/"${ppd[3]}" ]]; then
	    
	    
	    installer -target / -pkg "$cachePath"/"$driver"
	    
	fi
	
    done
}

rem-copiers() {
    for copier in $(lpstat -p 2>/dev/null | awk '{ print $2 }'); do

	if [[ "$copier" =~ .*_[cC][oO][pP][iI][eE][rR] ]] || \
	       [[ "$copier" =~ [[0-9]{1,3}]\.{4} ]] || \
	       [[ "$copier" =~ .*_[tT][pP][sS] ]] || \
	       [[ "$copier" = "mcx_"* ]]; then

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

assoc-presets() {
    # Associate printer presets
    # If they exist
    local userName="$(stat -f%Su /dev/console)"

    reload-cups() {
	local cupsDaemon="/System/Library/LaunchDaemons/org.cups.cupsd.plist"
	
	launchctl unload -F "$cupsDaemon"
	wait $?
	launchctl load -F "$cupsDaemon"
    }
        
    cd "/Users/$userName/Library/Preferences/" || exit

    for preset in $(echo "*"); do

	if [[ "$preset" = *"forprinter"* ]]; then

	    case "$preset" in
		*bw_copier*)
		    mv "$preset" ${preset/"bw_copier"*/"${cupsName[0]}".plist} ;;
		*fo_copier*)
		    mv "$preset" ${preset/"fo_copier"*/"${cupsName[1]}".plist} ;;
		*co_copier*)
		    mv "$preset" ${preset/"co_copier"*/"${cupsName[2]}".plist} ;;
		*ec_copier*)
		    mv "$preset" ${preset/"ec_copier"*/"${cupsName[3]}".plist} ;;
		*)
		    printf "" >&2
	    esac

	fi
	
    done

    reload-cups
}

do-add-copiers() {
    # Mount ProductionShare
    install-drivers

    # Remove TPS copiers
    rem-copiers

    # Map copiers
    map-copiers

    # Associate Presets
    assoc-presets
}

do-add-copiers   
