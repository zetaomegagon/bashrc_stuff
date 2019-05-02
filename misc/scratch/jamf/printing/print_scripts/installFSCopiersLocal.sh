#!/bin/bash

## Variables and Arrays

ppdPath="/Library/Printers/PPDs/Contents/Resources"

copierDrivers=(
    'Ricoh_PS_Printers_Vol4_EXP_LIO_Driver.pkg'
    'NRG_PS_Printers_Vol4_EXP_LIO_Driver.pkg'
    'hp-printer-essentials-S-5_10_5.pkg'
    'hp-easy-scan-1_9_2.pkg'
)

cupsName=(
    'bw_copier_tps'
    'fo_copier_tps'
    'co_copier_tps'
    'ec_copier_tps'
)

address=(
    '10.0.3.1'
    '10.0.3.2'
    '10.0.3.3'
    '10.2.0.251'
    '10.0.3.33'
)

ppd=(
    'RICOH MP 9003'
    'RICOH MP 5055'
    'RICOH MP C6004ex'
    'RICOH MP C3004ex'
)

humanName=(
    'Black and White Copier'
    'Front Office Copier'
    'Color Copier'
    'ECEC Copier'
    'HR Office MFP'
)

location=(
    '1st Floor, Room 154'
    '1st Floor, Front Office'
    'Lower Level, Patagonia' 
    'ECEC Front Office'
)

rem-copiers() {
    for copier in $(lpstat -p 2>/dev/null | awk '{ print $2 }'); do

	  if  [[ "$copier" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] || \
	      [[ "$copier" =~ .*_[cC][oO][pP][iI][eE][rR] ]] || \
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

reload-cups() {
	local cupsDaemon="/System/Library/LaunchDaemons/org.cups.cupsd.plist"
		
	# if running stop cupsDaemon,
	# else start it
	if [[ -n $(launchctl list | grep org.cups.cupsd) ]]; then
	    
	  launchctl unload -F "$cupsDaemon"
	  sleep 3
	  launchctl load -F "$cupsDaemon"
	        
	else
	    
      launchctl load -F "$cupsDaemon"
	        
    fi
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
    
    # Reload CUPS daemon
    reload-cups
}

do-add-copiers   
