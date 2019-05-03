#!/Bin/bash -x

#@ Vars
logged_in_user="$(stat -f%Su /dev/console)"

#@ Functions
make_tps_directories() {
    dirs=(
	"tps"
	"tps/group"
	"tps/asset"
	"tps/name"
	"tps/print"
	"tps/script"
    )

    for dir in "${dirs[@]}"; do
	mkdir -p /usr/local/"$dir" || :
    done

    base_dir="/usr/local/tps"
    group_dir="$base_dir/group"
    asset_dir="$base_dir/asset"
    name_dir="$base_dir/name"
    print_dir="$base_dir/print"
    script_dir="$base_dir/script"
}

gen_random_four() {
    # generate random four digit number
    local number=$(( (RANDOM % 4999) + 5000))

    if [[ ${#number} -lt 4 ]]; then
	gen_user_code
    else
	number=${number:0:4}
    fi

    printf "%s" "$number"
}


set_copier_vars() {
    copier_vars=1

    ppd_path="/Library/Printers/PPDs/Contents/Resources"

    cups_name=(
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

    ppd_name=(
	'RICOH MP 9003'
	'RICOH MP 5055'
	'RICOH MP C6004ex'
	'RICOH MP C3004ex'
    )

    human_name=(
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
} 

get_name() {
    # Get UserName & PrintUserName

    osa_get_nameh() {
	# osascript helper function
	osascript -e 'set varName to display dialog "Enter Your Name" default answer "FirstName LastName"' \
	    | awk -F ':' '{ print $3 }' | tr 'A-Z' 'a-z'
    }

    read -r first_name last_name <<< "$(osa_get_nameh)"

    while : ; do
	if [[ ! "$first_name" =~ [a-z]+|[-]+ ]] && [[ ! "$last_name" =~ [a-z]+|[-]+ ]]; then
	    osascript -e 'set invalid_name to display dialog "Valid charaters are: A-Z, a-z, and the dash (-) charater"'
	    get_name
	else
	    break
	fi
    done

    full_name="$(tr '[:lower:]' '[:upper:]' <<< ${first_name:0:1})${first_name:1} $(tr '[:lower:]' '[:upper:]' <<< ${last_name:0:1})${last_name:1}" 
    first_initial="${first_name:0:1}"
    user_name="${first_initial}${last_name}"
    rem_dash_name="${user_name//[-]/}"
    print_user_name="${rem_dash_name:0:8}"

    printf "%s\n" "$user_name" > "$name_dir"/user_name
    printf "%s\n" "$full_name" > "$name_dir"/full_name
    printf "%s\n" "$print_user_name" > "$name_dir"/print_user_name
}

get_password() {
    # Get user inputted password
	
    init_pass="$(osascript -e 'set initv to display dialog "Please enter your password:" default answer "" with hidden answer' | awk -F : '{ print $3 }')"

    check_pass="$(osascript -e 'set checkv to display dialog "Please verify your password below:" default answer "" with hidden answer' | awk -F : '{ print $3 }')"

    while : ; do
	if [[ "$init_pass" != "$check_pass" ]]; then
	    osascript -e 'set ne_pass to display dialog "Passwords do not match!"'
	    get_password
	elif [[ "$check_pass" -lt 8 ]]; then
	    osascript -e 'set len_pass to display dialog "Password must be atleast 8 charachters!"'
	    get_password
	else
	    break
	fi
    done

    printf "%s" "$check_pass"
}

sysadminctl() {
    # sysadminctl syntactic sugar
    /usr/sbin/sysadminctl "$@"
}

make_user() {
    # Delete user if already on system
    if dscl . -ls /Users | grep -q -E ^"$user_name"; then
	sysadminctl -deleteUser "$user_name"
    fi
    
    # Create permanent user
    sysadminctl -addUser "$user_name" \
		-fullName "$full_name" \
		-UID "$(gen_random_four)" \
		-shell /bin/bash \
		-password "$(get_password)" \
		-home /Users/"$user_name" \
		-adminUser jamf \
		-adminPassword "ArtisLife%100"
}

plistbuddy() {
    # PlistBuddy syntactic sugar
    /usr/libexec/PlistBuddy "$@"
}

delete_user_on_boot() {
    # Delete default user on boot with LaunchDaemon
    local plist_name="org.tps.ebeale.delete_user_on_boot.plist"
    local plist_dir="/Library/LaunchDaemons"
    local plist_loc="$plist_dir/$plist_name"

    rm "$plist_loc" || :

    plistbuddy -c "add :Label string $plist_name" \
	       -c "add :ProgramArguments array" \
	       -c "add :ProgramArguments:0 string /usr/sbin/sysadminctl" \
	       -c "add :ProgramArguments:1 string -deleteUser" \
	       -c "add :ProgramArguments:2 string $logged_in_user" \
	       -c "add :RunAtLoad bool true" \
	       "$plist_loc"

    chown root:wheel "$plist_loc"
    chmod 644 "$plist_loc"

    launchctl load -w "$plist_loc" || :
}

add_copiers() {
    rem_copiersh() {
	# remove matching copiers
	for copier in $(lpstat -p 2>/dev/null | awk '{ print $2 }'); do

	    if  [[ "$copier" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] || \
		    [[ "$copier" =~ .*_[cC][oO][pP][iI][eE][rR] ]] || \
		    [[ "$copier" =~ .*_[tT][pP][sS] ]] || \
		    [[ "$copier" = "mcx_"* ]]; then

		lpadmin -x "$copier" &

	    fi

	done
    }

    map_copiersh() {
	# map new copiers

	local count=0

	for copier in "${cups_name[@]}"; do

	    if [[ -e "$ppd_path"/"${ppd_name[$count]}" ]]; then

		lpadmin -p "${cups_name[$count]}" \
			-E -v ipp://"${address[$count]}/ipp/print" \
			-P "$ppd_path"/"${ppd_name[$count]}" \
			-D "${human_name[$count]}" \
			-L "${location[$count]}"

		count=$((count + 1))
	    fi

	done
    }

    reload_cupsh() {
	# reload the cups daemon

	local cups_daemon="/System/Library/LaunchDaemons/org.cups.cupsd.plist"

	# if running stop cupsDaemon,
	# else start it
	if launchctl list | grep -q org.cups.cupsd; then

	    launchctl unload -F "$cups_daemon"
	    sleep 3
	    launchctl load -F "$cups_daemon"

	else

	    launchctl load -F "$cups_daemon"

	fi
    }

    reload_presetsh() {
	# reload cached preferences
	killall -u "$logged_in_user" cfprefsd
    }

    do_add_copiersh() {
	# Set copier vars
	[[ "$copier_vars" != 1 ]] && set_copier_vars

	# Remove TPS copiers
	rem_copiersh

	# Map copiers
	map_copiersh

	# Apply presets
	reload_presetsh

	# Reload CUPS daemon
	reload_cupsh
    }

    do_add_copiersh
}

copy_presets_on_login() {
    # Create Preset LaunchAgent and Preset binaries

    # Ensure copier vars are instantiated
    [[ "$copier_vars" != 1 ]] && set_copier_var

    # Generate user_code
    user_code="$(gen_random_four)"

    printf "%s\n" "$user_code" > "$print_dir"/user_code

#com.apple.print.custompresets.forprinter.bw_copier_tps.plist
cat <<-EOF > "$print_dir"/com.apple.print.custompresets.forprinter.bw_copier_tps.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
       <key>com.apple.print.lastPresetPref</key>
       <string>Black &amp; White</string>
       <key>com.apple.print.lastPresetPrefType</key>
       <integer>5</integer>
       <key>com.apple.print.lastUsedSettingsPref</key>
       <dict>
	       <key>com.apple.print.preset.id</key>
	       <string>com.apple.print.lastUsedSettingsPref</string>
	       <key>com.apple.print.preset.settings</key>
	       <dict>
		       <key>AP_D_InputSlot</key>
		       <string></string>
		       <key>BookletBinding</key>
		       <false/>
		       <key>BookletType</key>
		       <integer>0</integer>
		       <key>ColorModel</key>
		       <string>Gray</string>
		       <key>DuplexBindingEdge</key>
		       <integer>2</integer>
		       <key>PaperInfoIsSuggested</key>
		       <true/>
		       <key>RIAngel</key>
		       <string>30</string>
		       <key>RIBlack</key>
		       <string>0</string>
		       <key>RIBrightness</key>
		       <string>0</string>
		       <key>RIContrast</key>
		       <string>0</string>
		       <key>RIEnableUserCode</key>
		       <string>True</string>
		       <key>RIFileName</key>
		       <string>None</string>
		       <key>RIFolderNumber</key>
		       <string>0</string>
		       <key>RIJobType</key>
		       <string>HoldPrint</string>
		       <key>RILineSpace</key>
		       <string>70</string>
		       <key>RISize</key>
		       <string>70</string>
		       <key>RIStartNumber</key>
		       <string>1</string>
		       <key>RIText</key>
		       <string>Copy</string>
		       <key>RITimeHour</key>
		       <string>0</string>
		       <key>RITimeMin</key>
		       <string>0</string>
		       <key>RIUserCode</key>
		       <string>Custom</string>
		       <key>RIUserId</key>
		       <string>Custom</string>
		       <key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
		       <true/>
		       <key>com.apple.print.PageToPaperMappingMediaName</key>
		       <string>Letter</string>
		       <key>com.apple.print.PageToPaperMappingType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMCopies</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMCopyCollate</key>
		       <true/>
		       <key>com.apple.print.PrintSettings.PMDestinationType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMDuplexing</key>
		       <integer>2</integer>
		       <key>com.apple.print.PrintSettings.PMFirstPage</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMLastPage</key>
		       <integer>2147483647</integer>
		       <key>com.apple.print.PrintSettings.PMLayoutColumns</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMLayoutRows</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMPageRange</key>
		       <array>
			       <integer>1</integer>
			       <integer>2147483647</integer>
		       </array>
		       <key>com.apple.print.preset.Orientation</key>
		       <integer>1</integer>
		       <key>com.apple.print.preset.PaperInfo</key>
		       <dict>
			       <key>paperInfo</key>
			       <dict>
				       <key>PMPPDPaperCodeName</key>
				       <string>Letter</string>
				       <key>PMPPDTranslationStringPaperName</key>
				       <string>Letter (8.5 x 11)</string>
				       <key>PMTiogaPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PageFormat.PMAdjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PageFormat.PMAdjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMCustomPaper</key>
				       <false/>
				       <key>com.apple.print.PaperInfo.PMPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
				       <string>Letter</string>
				       <key>com.apple.print.ticket.type</key>
				       <string>com.apple.print.PaperInfoTicket</string>
			       </dict>
		       </dict>
		       <key>com.apple.print.subTicket.paper_info_ticket</key>
		       <dict>
			       <key>PMPPDPaperCodeName</key>
			       <string>Letter</string>
			       <key>PMPPDTranslationStringPaperName</key>
			       <string>Letter (8.5 x 11)</string>
			       <key>PMTiogaPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMDisplayName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMPPDPaperDimension</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>612</real>
				       <real>792</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>768</real>
				       <real>588</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
			       <array>
				       <real>-12</real>
				       <real>-12</real>
				       <real>780</real>
				       <real>600</real>
			       </array>
			       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
			       <string>Letter</string>
			       <key>com.apple.print.ticket.type</key>
			       <string>com.apple.print.PaperInfoTicket</string>
		       </dict>
		       <key>com.apple.print.ticket.type</key>
		       <string>com.apple.print.PrintSettingsTicket</string>
		       <key>job-sheets</key>
		       <string>none</string>
	       </dict>
       </dict>
</dict>
</plist>
EOF

#com.apple.print.custompresets.forprinter.co_copier_tps.plist
cat <<-EOF > "$print_dir"/com.apple.print.custompresets.forprinter.co_copier_tps.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
       <key>com.apple.print.lastPresetPref</key>
       <string>Color</string>
       <key>com.apple.print.lastPresetPrefType</key>
       <integer>5</integer>
       <key>com.apple.print.lastUsedSettingsPref</key>
       <dict>
	       <key>com.apple.print.preset.id</key>
	       <string>com.apple.print.lastUsedSettingsPref</string>
	       <key>com.apple.print.preset.settings</key>
	       <dict>
		       <key>AP_D_InputSlot</key>
		       <string></string>
		       <key>BookletBinding</key>
		       <false/>
		       <key>BookletType</key>
		       <integer>0</integer>
		       <key>DuplexBindingEdge</key>
		       <integer>2</integer>
		       <key>PaperInfoIsSuggested</key>
		       <true/>
		       <key>RIAngel</key>
		       <string>30</string>
		       <key>RIBlack</key>
		       <string>0</string>
		       <key>RIBrightness</key>
		       <string>0</string>
		       <key>RIContrast</key>
		       <string>0</string>
		       <key>RICyan</key>
		       <string>0</string>
		       <key>RIEnableUserCode</key>
		       <string>True</string>
		       <key>RIFileName</key>
		       <string>None</string>
		       <key>RIFolderNumber</key>
		       <string>0</string>
		       <key>RIJobType</key>
		       <string>HoldPrint</string>
		       <key>RILineSpace</key>
		       <string>70</string>
		       <key>RIMagenta</key>
		       <string>0</string>
		       <key>RISize</key>
		       <string>70</string>
		       <key>RIText</key>
		       <string>Copy</string>
		       <key>RITimeHour</key>
		       <string>0</string>
		       <key>RITimeMin</key>
		       <string>0</string>
		       <key>RIUserCode</key>
		       <string>Custom</string>
		       <key>RIUserId</key>
		       <string>Custom</string>
		       <key>RIYellow</key>
		       <string>0</string>
		       <key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
		       <true/>
		       <key>com.apple.print.PageToPaperMappingMediaName</key>
		       <string>Letter</string>
		       <key>com.apple.print.PageToPaperMappingType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
		       <integer>3</integer>
		       <key>com.apple.print.PrintSettings.PMCopies</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMCopyCollate</key>
		       <true/>
		       <key>com.apple.print.PrintSettings.PMDestinationType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMDuplexing</key>
		       <integer>2</integer>
		       <key>com.apple.print.PrintSettings.PMFirstPage</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMLastPage</key>
		       <integer>2147483647</integer>
		       <key>com.apple.print.PrintSettings.PMPageRange</key>
		       <array>
			       <integer>1</integer>
			       <integer>2147483647</integer>
		       </array>
		       <key>com.apple.print.preset.Orientation</key>
		       <integer>1</integer>
		       <key>com.apple.print.preset.PaperInfo</key>
		       <dict>
			       <key>paperInfo</key>
			       <dict>
				       <key>PMPPDPaperCodeName</key>
				       <string>Letter</string>
				       <key>PMPPDTranslationStringPaperName</key>
				       <string>Letter (8.5 x 11)</string>
				       <key>PMTiogaPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PageFormat.PMAdjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PageFormat.PMAdjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMCustomPaper</key>
				       <false/>
				       <key>com.apple.print.PaperInfo.PMPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
				       <string>Letter</string>
				       <key>com.apple.print.ticket.type</key>
				       <string>com.apple.print.PaperInfoTicket</string>
			       </dict>
		       </dict>
		       <key>com.apple.print.subTicket.paper_info_ticket</key>
		       <dict>
			       <key>PMPPDPaperCodeName</key>
			       <string>Letter</string>
			       <key>PMPPDTranslationStringPaperName</key>
			       <string>Letter (8.5 x 11)</string>
			       <key>PMTiogaPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMDisplayName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMPPDPaperDimension</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>612</real>
				       <real>792</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>768</real>
				       <real>588</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
			       <array>
				       <real>-12</real>
				       <real>-12</real>
				       <real>780</real>
				       <real>600</real>
			       </array>
			       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
			       <string>Letter</string>
			       <key>com.apple.print.ticket.type</key>
			       <string>com.apple.print.PaperInfoTicket</string>
		       </dict>
		       <key>com.apple.print.ticket.type</key>
		       <string>com.apple.print.PrintSettingsTicket</string>
		       <key>job-sheets</key>
		       <string>none</string>
	       </dict>
       </dict>
</dict>
</plist>
EOF

#com.apple.print.custompresets.forprinter.ec_copier_tps.plist
cat <<-EOF > "$print_dir"/com.apple.print.custompresets.forprinter.ec_copier_tps.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
       <key>com.apple.print.lastPresetPref</key>
       <string>Black &amp; White</string>
       <key>com.apple.print.lastPresetPrefType</key>
       <integer>5</integer>
       <key>com.apple.print.lastUsedSettingsPref</key>
       <dict>
	       <key>com.apple.print.preset.id</key>
	       <string>com.apple.print.lastUsedSettingsPref</string>
	       <key>com.apple.print.preset.settings</key>
	       <dict>
		       <key>AP_D_InputSlot</key>
		       <string></string>
		       <key>BookletBinding</key>
		       <false/>
		       <key>BookletType</key>
		       <integer>0</integer>
		       <key>ColorModel</key>
		       <string>Gray</string>
		       <key>DuplexBindingEdge</key>
		       <integer>2</integer>
		       <key>PaperInfoIsSuggested</key>
		       <true/>
		       <key>RIAngel</key>
		       <string>30</string>
		       <key>RIBlack</key>
		       <string>0</string>
		       <key>RIBrightness</key>
		       <string>0</string>
		       <key>RIContrast</key>
		       <string>0</string>
		       <key>RIEnableUserCode</key>
		       <string>True</string>
		       <key>RIFileName</key>
		       <string>None</string>
		       <key>RIFolderNumber</key>
		       <string>0</string>
		       <key>RIJobType</key>
		       <string>HoldPrint</string>
		       <key>RILineSpace</key>
		       <string>70</string>
		       <key>RISize</key>
		       <string>70</string>
		       <key>RIStartNumber</key>
		       <string>1</string>
		       <key>RIText</key>
		       <string>Copy</string>
		       <key>RITimeHour</key>
		       <string>0</string>
		       <key>RITimeMin</key>
		       <string>0</string>
		       <key>RIUserCode</key>
		       <string>Custom</string>
		       <key>RIUserId</key>
		       <string>Custom</string>
		       <key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
		       <true/>
		       <key>com.apple.print.PageToPaperMappingMediaName</key>
		       <string>Letter</string>
		       <key>com.apple.print.PageToPaperMappingType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMCopies</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMCopyCollate</key>
		       <true/>
		       <key>com.apple.print.PrintSettings.PMDestinationType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMDuplexing</key>
		       <integer>2</integer>
		       <key>com.apple.print.PrintSettings.PMFirstPage</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMLastPage</key>
		       <integer>2147483647</integer>
		       <key>com.apple.print.PrintSettings.PMLayoutColumns</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMLayoutRows</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMPageRange</key>
		       <array>
			       <integer>1</integer>
			       <integer>2147483647</integer>
		       </array>
		       <key>com.apple.print.preset.Orientation</key>
		       <integer>1</integer>
		       <key>com.apple.print.preset.PaperInfo</key>
		       <dict>
			       <key>paperInfo</key>
			       <dict>
				       <key>PMPPDPaperCodeName</key>
				       <string>Letter</string>
				       <key>PMPPDTranslationStringPaperName</key>
				       <string>Letter (8.5 x 11)</string>
				       <key>PMTiogaPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PageFormat.PMAdjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PageFormat.PMAdjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMCustomPaper</key>
				       <false/>
				       <key>com.apple.print.PaperInfo.PMPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
				       <string>Letter</string>
				       <key>com.apple.print.ticket.type</key>
				       <string>com.apple.print.PaperInfoTicket</string>
			       </dict>
		       </dict>
		       <key>com.apple.print.subTicket.paper_info_ticket</key>
		       <dict>
			       <key>PMPPDPaperCodeName</key>
			       <string>Letter</string>
			       <key>PMPPDTranslationStringPaperName</key>
			       <string>Letter (8.5 x 11)</string>
			       <key>PMTiogaPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMDisplayName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMPPDPaperDimension</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>612</real>
				       <real>792</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>768</real>
				       <real>588</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
			       <array>
				       <real>-12</real>
				       <real>-12</real>
				       <real>780</real>
				       <real>600</real>
			       </array>
			       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
			       <string>Letter</string>
			       <key>com.apple.print.ticket.type</key>
			       <string>com.apple.print.PaperInfoTicket</string>
		       </dict>
		       <key>com.apple.print.ticket.type</key>
		       <string>com.apple.print.PrintSettingsTicket</string>
		       <key>job-sheets</key>
		       <string>none</string>
	       </dict>
       </dict>
</dict>
</plist>
EOF

#com.apple.print.custompresets.forprinter.fo_copier_tps.plist
cat <<-EOF > "$print_dir"/com.apple.print.custompresets.forprinter.fo_copier_tps.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
       <key>com.apple.print.lastPresetPref</key>
       <string>Black &amp; White</string>
       <key>com.apple.print.lastPresetPrefType</key>
       <integer>5</integer>
       <key>com.apple.print.lastUsedSettingsPref</key>
       <dict>
	       <key>com.apple.print.preset.id</key>
	       <string>com.apple.print.lastUsedSettingsPref</string>
	       <key>com.apple.print.preset.settings</key>
	       <dict>
		       <key>AP_D_InputSlot</key>
		       <string></string>
		       <key>BookletBinding</key>
		       <false/>
		       <key>BookletType</key>
		       <integer>0</integer>
		       <key>ColorModel</key>
		       <string>Gray</string>
		       <key>DuplexBindingEdge</key>
		       <integer>2</integer>
		       <key>PaperInfoIsSuggested</key>
		       <true/>
		       <key>RIAngel</key>
		       <string>30</string>
		       <key>RIBlack</key>
		       <string>0</string>
		       <key>RIBrightness</key>
		       <string>0</string>
		       <key>RIContrast</key>
		       <string>0</string>
		       <key>RIEnableUserCode</key>
		       <string>True</string>
		       <key>RIFileName</key>
		       <string>None</string>
		       <key>RIFolderNumber</key>
		       <string>0</string>
		       <key>RIJobType</key>
		       <string>HoldPrint</string>
		       <key>RILineSpace</key>
		       <string>70</string>
		       <key>RISize</key>
		       <string>70</string>
		       <key>RIStartNumber</key>
		       <string>1</string>
		       <key>RIText</key>
		       <string>Copy</string>
		       <key>RITimeHour</key>
		       <string>0</string>
		       <key>RITimeMin</key>
		       <string>0</string>
		       <key>RIUserCode</key>
		       <string>Custom</string>
		       <key>RIUserId</key>
		       <string>Custom</string>
		       <key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
		       <true/>
		       <key>com.apple.print.PageToPaperMappingMediaName</key>
		       <string>Letter</string>
		       <key>com.apple.print.PageToPaperMappingType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMCopies</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMCopyCollate</key>
		       <true/>
		       <key>com.apple.print.PrintSettings.PMDestinationType</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMDuplexing</key>
		       <integer>2</integer>
		       <key>com.apple.print.PrintSettings.PMFirstPage</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMLastPage</key>
		       <integer>2147483647</integer>
		       <key>com.apple.print.PrintSettings.PMLayoutColumns</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMLayoutRows</key>
		       <integer>1</integer>
		       <key>com.apple.print.PrintSettings.PMPageRange</key>
		       <array>
			       <integer>1</integer>
			       <integer>2147483647</integer>
		       </array>
		       <key>com.apple.print.preset.Orientation</key>
		       <integer>1</integer>
		       <key>com.apple.print.preset.PaperInfo</key>
		       <dict>
			       <key>paperInfo</key>
			       <dict>
				       <key>PMPPDPaperCodeName</key>
				       <string>Letter</string>
				       <key>PMPPDTranslationStringPaperName</key>
				       <string>Letter (8.5 x 11)</string>
				       <key>PMTiogaPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PageFormat.PMAdjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PageFormat.PMAdjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMCustomPaper</key>
				       <false/>
				       <key>com.apple.print.PaperInfo.PMPaperName</key>
				       <string>na-letter</string>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
				       <array>
					       <integer>0</integer>
					       <integer>0</integer>
					       <real>768</real>
					       <real>588</real>
				       </array>
				       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
				       <array>
					       <real>-12</real>
					       <real>-12</real>
					       <real>780</real>
					       <real>600</real>
				       </array>
				       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
				       <string>Letter</string>
				       <key>com.apple.print.ticket.type</key>
				       <string>com.apple.print.PaperInfoTicket</string>
			       </dict>
		       </dict>
		       <key>com.apple.print.subTicket.paper_info_ticket</key>
		       <dict>
			       <key>PMPPDPaperCodeName</key>
			       <string>Letter</string>
			       <key>PMPPDTranslationStringPaperName</key>
			       <string>Letter (8.5 x 11)</string>
			       <key>PMTiogaPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMDisplayName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMPPDPaperDimension</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>612</real>
				       <real>792</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMPaperName</key>
			       <string>na-letter</string>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
			       <array>
				       <integer>0</integer>
				       <integer>0</integer>
				       <real>768</real>
				       <real>588</real>
			       </array>
			       <key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
			       <array>
				       <real>-12</real>
				       <real>-12</real>
				       <real>780</real>
				       <real>600</real>
			       </array>
			       <key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
			       <string>Letter</string>
			       <key>com.apple.print.ticket.type</key>
			       <string>com.apple.print.PaperInfoTicket</string>
		       </dict>
		       <key>com.apple.print.ticket.type</key>
		       <string>com.apple.print.PrintSettingsTicket</string>
		       <key>job-sheets</key>
		       <string>none</string>
	       </dict>
       </dict>
</dict>
</plist>
EOF

#com.apple.print.custompresets.plist
cat <<-EOF > "$print_dir"/com.apple.print.custompresets.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Black &amp; White</key>
	<dict>
		<key>com.apple.print.preset.id</key>
		<string>Black &amp; White</string>
		<key>com.apple.print.preset.settings</key>
		<dict>
			<key>AP_D_InputSlot</key>
			<string></string>
			<key>BookletBinding</key>
			<false/>
			<key>BookletType</key>
			<integer>0</integer>
			<key>ColorModel</key>
			<string>Gray</string>
			<key>DuplexBindingEdge</key>
			<integer>2</integer>
			<key>PaperInfoIsSuggested</key>
			<true/>
			<key>RIAngel</key>
			<string>30</string>
			<key>RIBlack</key>
			<string>0</string>
			<key>RIBrightness</key>
			<string>0</string>
			<key>RIContrast</key>
			<string>0</string>
			<key>RIEnableUserCode</key>
			<string>True</string>
			<key>RIFileName</key>
			<string>None</string>
			<key>RIFolderNumber</key>
			<string>0</string>
			<key>RIJobType</key>
			<string>HoldPrint</string>
			<key>RILineSpace</key>
			<string>70</string>
			<key>RISize</key>
			<string>70</string>
			<key>RIStartNumber</key>
			<string>1</string>
			<key>RIText</key>
			<string>COPY</string>
			<key>RITimeHour</key>
			<string>0</string>
			<key>RITimeMin</key>
			<string>0</string>
			<key>RIUserCode</key>
			<string>Custom.${user_code}</string>
			<key>RIUserId</key>
			<string>Custom.${print_user_name}</string>
			<key>com.apple.print.PageToPaperMappingMediaName</key>
			<string>Letter</string>
			<key>com.apple.print.PageToPaperMappingType</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMCopies</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMCopyCollate</key>
			<true/>
			<key>com.apple.print.PrintSettings.PMDestinationType</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMDuplexing</key>
			<integer>2</integer>
			<key>com.apple.print.PrintSettings.PMFirstPage</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMLastPage</key>
			<integer>2147483647</integer>
			<key>com.apple.print.PrintSettings.PMLayoutColumns</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMLayoutRows</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMPageRange</key>
			<array>
				<integer>1</integer>
				<integer>2147483647</integer>
			</array>
			<key>com.apple.print.preset.Orientation</key>
			<integer>1</integer>
			<key>com.apple.print.preset.PaperInfo</key>
			<dict>
				<key>paperInfo</key>
				<dict>
					<key>PMPPDPaperCodeName</key>
					<string>Letter</string>
					<key>PMPPDTranslationStringPaperName</key>
					<string>Letter (8.5 x 11)</string>
					<key>PMTiogaPaperName</key>
					<string>na-letter</string>
					<key>com.apple.print.PageFormat.PMAdjustedPageRect</key>
					<array>
						<integer>0</integer>
						<integer>0</integer>
						<real>768</real>
						<real>588</real>
					</array>
					<key>com.apple.print.PageFormat.PMAdjustedPaperRect</key>
					<array>
						<real>-12</real>
						<real>-12</real>
						<real>780</real>
						<real>600</real>
					</array>
					<key>com.apple.print.PaperInfo.PMCustomPaper</key>
					<false/>
					<key>com.apple.print.PaperInfo.PMPaperName</key>
					<string>na-letter</string>
					<key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
					<array>
						<integer>0</integer>
						<integer>0</integer>
						<real>768</real>
						<real>588</real>
					</array>
					<key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
					<array>
						<real>-12</real>
						<real>-12</real>
						<real>780</real>
						<real>600</real>
					</array>
					<key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
					<string>Letter</string>
					<key>com.apple.print.ticket.type</key>
					<string>com.apple.print.PaperInfoTicket</string>
				</dict>
			</dict>
			<key>com.apple.print.subTicket.paper_info_ticket</key>
			<dict>
				<key>PMPPDPaperCodeName</key>
				<string>Letter</string>
				<key>PMPPDTranslationStringPaperName</key>
				<string>Letter (8.5 x 11)</string>
				<key>PMTiogaPaperName</key>
				<string>na-letter</string>
				<key>com.apple.print.PaperInfo.PMDisplayName</key>
				<string>na-letter</string>
				<key>com.apple.print.PaperInfo.PMPPDPaperDimension</key>
				<array>
					<integer>0</integer>
					<integer>0</integer>
					<real>612</real>
					<real>792</real>
				</array>
				<key>com.apple.print.PaperInfo.PMPaperName</key>
				<string>na-letter</string>
				<key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
				<array>
					<integer>0</integer>
					<integer>0</integer>
					<real>768</real>
					<real>588</real>
				</array>
				<key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
				<array>
					<real>-12</real>
					<real>-12</real>
					<real>780</real>
					<real>600</real>
				</array>
				<key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
				<string>Letter</string>
				<key>com.apple.print.ticket.type</key>
				<string>com.apple.print.PaperInfoTicket</string>
			</dict>
			<key>com.apple.print.ticket.type</key>
			<string>com.apple.print.PrintSettingsTicket</string>
		</dict>
	</dict>
	<key>Color</key>
	<dict>
		<key>com.apple.print.preset.id</key>
		<string>Color</string>
		<key>com.apple.print.preset.settings</key>
		<dict>
			<key>AP_D_InputSlot</key>
			<string></string>
			<key>BookletBinding</key>
			<false/>
			<key>BookletType</key>
			<integer>0</integer>
			<key>DuplexBindingEdge</key>
			<integer>2</integer>
			<key>PaperInfoIsSuggested</key>
			<true/>
			<key>RIAngel</key>
			<string>30</string>
			<key>RIBlack</key>
			<string>0</string>
			<key>RIBrightness</key>
			<string>0</string>
			<key>RIContrast</key>
			<string>0</string>
			<key>RICyan</key>
			<string>0</string>
			<key>RIEnableUserCode</key>
			<string>True</string>
			<key>RIFileName</key>
			<string>None</string>
			<key>RIFolderNumber</key>
			<string>0</string>
			<key>RIJobType</key>
			<string>HoldPrint</string>
			<key>RILineSpace</key>
			<string>70</string>
			<key>RIMagenta</key>
			<string>0</string>
			<key>RISize</key>
			<string>70</string>
			<key>RIText</key>
			<string>COPY</string>
			<key>RITimeHour</key>
			<string>0</string>
			<key>RITimeMin</key>
			<string>0</string>
			<key>RIUserCode</key>
			<string>Custom.${user_code}</string>
			<key>RIUserId</key>
			<string>Custom.${print_user_name}</string>
			<key>RIYellow</key>
			<string>0</string>
			<key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
			<true/>
			<key>com.apple.print.PageToPaperMappingMediaName</key>
			<string>Letter</string>
			<key>com.apple.print.PageToPaperMappingType</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
			<integer>3</integer>
			<key>com.apple.print.PrintSettings.PMCopies</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMCopyCollate</key>
			<true/>
			<key>com.apple.print.PrintSettings.PMDestinationType</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMDuplexing</key>
			<integer>2</integer>
			<key>com.apple.print.PrintSettings.PMFirstPage</key>
			<integer>1</integer>
			<key>com.apple.print.PrintSettings.PMLastPage</key>
			<integer>2147483647</integer>
			<key>com.apple.print.PrintSettings.PMPageRange</key>
			<array>
				<integer>1</integer>
				<integer>2147483647</integer>
			</array>
			<key>com.apple.print.preset.Orientation</key>
			<integer>1</integer>
			<key>com.apple.print.preset.PaperInfo</key>
			<dict>
				<key>paperInfo</key>
				<dict>
					<key>PMPPDPaperCodeName</key>
					<string>Letter</string>
					<key>PMPPDTranslationStringPaperName</key>
					<string>Letter (8.5 x 11)</string>
					<key>PMTiogaPaperName</key>
					<string>na-letter</string>
					<key>com.apple.print.PageFormat.PMAdjustedPageRect</key>
					<array>
						<integer>0</integer>
						<integer>0</integer>
						<real>768</real>
						<real>588</real>
					</array>
					<key>com.apple.print.PageFormat.PMAdjustedPaperRect</key>
					<array>
						<real>-12</real>
						<real>-12</real>
						<real>780</real>
						<real>600</real>
					</array>
					<key>com.apple.print.PaperInfo.PMCustomPaper</key>
					<false/>
					<key>com.apple.print.PaperInfo.PMPaperName</key>
					<string>na-letter</string>
					<key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
					<array>
						<integer>0</integer>
						<integer>0</integer>
						<real>768</real>
						<real>588</real>
					</array>
					<key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
					<array>
						<real>-12</real>
						<real>-12</real>
						<real>780</real>
						<real>600</real>
					</array>
					<key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
					<string>Letter</string>
					<key>com.apple.print.ticket.type</key>
					<string>com.apple.print.PaperInfoTicket</string>
				</dict>
			</dict>
			<key>com.apple.print.subTicket.paper_info_ticket</key>
			<dict>
				<key>PMPPDPaperCodeName</key>
				<string>Letter</string>
				<key>PMPPDTranslationStringPaperName</key>
				<string>Letter (8.5 x 11)</string>
				<key>PMTiogaPaperName</key>
				<string>na-letter</string>
				<key>com.apple.print.PaperInfo.PMDisplayName</key>
				<string>na-letter</string>
				<key>com.apple.print.PaperInfo.PMPPDPaperDimension</key>
				<array>
					<integer>0</integer>
					<integer>0</integer>
					<real>612</real>
					<real>792</real>
				</array>
				<key>com.apple.print.PaperInfo.PMPaperName</key>
				<string>na-letter</string>
				<key>com.apple.print.PaperInfo.PMUnadjustedPageRect</key>
				<array>
					<integer>0</integer>
					<integer>0</integer>
					<real>768</real>
					<real>588</real>
				</array>
				<key>com.apple.print.PaperInfo.PMUnadjustedPaperRect</key>
				<array>
					<real>-12</real>
					<real>-12</real>
					<real>780</real>
					<real>600</real>
				</array>
				<key>com.apple.print.PaperInfo.ppd.PMPaperName</key>
				<string>Letter</string>
				<key>com.apple.print.ticket.type</key>
				<string>com.apple.print.PaperInfoTicket</string>
			</dict>
			<key>com.apple.print.ticket.type</key>
			<string>com.apple.print.PrintSettingsTicket</string>
			<key>job-sheets</key>
			<string>none</string>
		</dict>
	</dict>
	<key>com.apple.print.customPresetNames</key>
	<array>
		<string>Black &amp; White</string>
		<string>Color</string>
	</array>
</dict>
</plist>
EOF

    # Convert xml to plist
    find "$print_dir" -name "*plist" -print0 | xargs -0 -I {} plutil -convert binary1 {}

    # Create script to copy and cache prefs, and restart CUPS
    cat <<-'EOF' > "${script_dir}/copy_print_prefs.sh"
	#!/bin/bash

	# Copy all print plists to pref dirs
	logged_in_user="$(stat -f%Su /dev/console)"
	pref_dir="/Users/$logged_in_user/Library/Preferences"
	print_dir="/usr/local/tps/print"
	cups_daemon="/System/Library/LaunchDaemons/org.cups.cupsd.plist"
	agent_dir="/Users/${logged_in_user}/Library/LaunchAgents"
	agent_name="org.tps.ebeale.copy_print_prefs.plist"
	agent_loc="$agent_dir/$agent_name"

	# copy print prefs
	find "$print_dir" -iname "*plist" -print0 | xargs -0 -I {} cp {} "$pref_dir"

	# reload cache
	killall -u "$logged_in_user" cfprefsd

	# restart cups
	if ! launchclt list | grep -q org.cups.cupsd; then
	   launchctl load -F "$cups_daemon"
	else
	    launchctl unload -F "$cups_daemon"
	    launchctl load -F "$cups_daemon"
	fi

	# remove LaunchAgent
	rm -f "$agent_loc"
	EOF

    chown root:wheel "${script_dir}/copy_print_prefs.sh"
    chmod +x "${script_dir}/copy_print_prefs.sh"

    #Create LaunchAgent
    local agent_dir="/Users/${user_name}/Library/LaunchAgents"
    local plist_name="org.tps.ebeale.copy_print_prefs.plist"
    local plist_dir="$agent_dir"
    local plist_loc="$plist_dir/$plist_name"

    createhomedir -c -u "$user_name"

    mkdir -p "$agent_dir" || :
    chown "${user_name}":staff "$agent_dir" || :
    chmod 700 "$agent_dir" || :

    plistbuddy -c "add :Label string $plist_name" \
	       -c "add :ProgramArguments array" \
	       -c "add :ProgramArguments:0 string $script_dir/copy_print_prefs.sh" \
	       -c "add :RunAtLoad bool true" \
	       "$plist_loc"

    chown root:wheel "$plist_loc"
    chmod 644 "$plist_loc"
}

make_asset_tag() {
    # Create asset tag id file
    osa_get_asseth() {
	# osascript helper function
	osascript -e 'set asset_tag to display dialog "Enter Asset Tag" default answer "[0-9][0-9]-[0-9][0-9]"' \
	    | awk -F ':' '{ print $3 }'
    }

    read init_asset check_asset <<<$(osa_get_asseth)

    while :; do
	if [[ ! "$check_asset" =~ [0-9]{,2}\-[0-9]{,2} ]]; then
	    osascript -e 'set invalid_asset to display dialog "Must be in the form of: [0-9][0-9]-[0-9][0-9]"'
	    make_asset_tag
	elif [[ "$init_asset" != "$check_asset" ]]; then
	    osascript -e 'set invalid_asset to display dialog "Tags do not match"'
	    make_asset_tag
	else
	    break
	fi
    done

    printf "%s" "$check_asset" > "$name_dir"/asset_tag
}

set_computer_name() {
    # Create computer name file
    #
    # computer_name="$asset_tag$group_id$first_name$last_name"
    #
    # for name in {Computer,Host,LocalHost}Name; do
    #     scutil --set "$name" "$computer_name" 
    #     printf "%s\n" "${name}: $computer_name" >> "$name_dir"/computer_name
    # done
    :
} 

#@ Main
# create /usr/local/tps/{id,asset,print,script,name...}
make_tps_directories

# get username
get_name

# get password and create user
make_user

# delete default user
delete_user_on_boot

# add copiers and create printer presets
add_copiers

# copy presets to new user prefs dir
copy_presets_on_login

# get asset tag and write to /usr/local/tps/asset
make_asset_tag

# set {Computer,Host,LocalHost}Name all the same
set_computer_name
