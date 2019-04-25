#!/bin/bash -x

## VARS for mounting fileshare and installing drivers

# fileshare
#smbDomain="WORKGROUP"
# smbUser="casperinstall"
# smbPass="casperinstall"
# server="jss-prod.tpschool.org"
# share="ProductionShare"
#mountPath="/Udsers/Shared"
#packageDir="$mountPath/Packages"



# installing drivers and adding printers
cachePath="."

pkgPath="$cachePath/pkg"

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

location=('3rd Floor, Middle School 6 Area' \
	      '1st Floor, Middle School 7/8 Area' \
	      '1st Floor, Middle School 7/8 Area')


## Functions
install-drivers() {
	if [[ ! -e "$ppdPath"/"${ppd[0]}" ]]; then
		for driver in "${printerDrivers[@]}"; do

	    	installer -verboseR -pkg "$pkgPath"/"$driver" -target /

		done
	fi
}

rem-printers() {
    # For each printer name matching *_printer, *_copier, *_tps, or mcx_*
    # remove that printer. NOTE: this will possibly blow away personal
    # printers/copiers too!!!

    for printer in $(lpstat -p 2>/dev/null | awk '{ print $2 }'); do

	if [[ "$printer" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] || \
               [[ "$printer" =~ .*_[pP][rR][iI][nN][tT][eE][rR] ]] || \
	       [[ "$printer" =~ .*_[cC][oO][pP][iI][eE][rR] ]] || \
	       [[ "$printer" =~ .*_[tT][pP][sS] ]] || \
               [[ "$printer" = "mcx_"* ]]; then

	    lpadmin -x "$printer" &

	fi

    done
}

map-printers() {
    # Map a printer for each cupsName in array.
    # Note the special case. what's the more elegant solution?

    local count=0

    for printer in "${cupsName[@]}"; do

	if [[ -e "$ppdPath"/"${ppd[0]}" ]]; then

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
    # Set default printer based on groupName: MS6, MS7, SM8
    # and for any user that has a home dir. Backup machines
    # are ignored.

    local computerName="$(scutil --get ComputerName)"
    local head="${computerName:0:5}"
    local middle="${computerName:${#head}:3}"
    local groupName="$middle"

    if [[ ! "$computerName" =~ .*[bB]ackup.* ]]; then

    	for userName in $(dscl . -ls /Users); do

            if [[ -d "/Users/$userName" ]] || \
						   [[ -d "/private/var/$userName" ]]; then

		su - "$userName" -c "defaults write org.cups.PrintingPrefs UseLastPrinter -bool False"

		case "$groupName" in

            	    MS6)
			su - "$userName" -c "lpoptions -d ${cupsName[0]}" ;;
            	    MS7)
			su - "$userName" -c "lpoptions -d ${cupsName[1]}" ;;
            	    MS8)
			su - "$userName" -c "lpoptions -d ${cupsName[2]}" ;;
            	    *)
			printf "%s is not a valid ComputerName for this script!!!\\n" "$computerName" >&2
			exit 1

		esac

            fi

    	done

    fi
}

## Main
    # Mount ProductionShare
    install-drivers

    # Remove TPS printers
    rem-printers

    # Map printer
    map-printers

    # Set default printer
    set-default-printer
