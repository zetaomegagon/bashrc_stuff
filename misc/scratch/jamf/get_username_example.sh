# #!/bin/bash

# OIFS="$IFS"
# GetName="osascript -e \'set varName to display dialog "Enter Some Text" default answer ""\'"
# FullName="$(for NAME in {First,Last}; do "$GetName"| awk -F : { print $3 }; done)"

# IFS="$OIFS" read FirsName LastName <<< $FullName

#!/bin/bash

for NAME in {First,Last}Name; do
    read $NAME <<< $(osascript -e 'set varName to display dialogue "Enter Your Name"' \
			       -e 'default answer "FirstName LastName"' \
			 | awk -F ':' '{ print $3 }' | tr '[A-Z]' '[a-z]')
done

FirstInitial="${FirstName:0:1}"
UserName="${FirstInitial}${LastName}"
RemDashName="${UserName//-/}"
PrintUserName="${RemDashName:0:8}"

echo "FirstName:         $FirstName"
echo "LastName:          $LastName"
echo "FirstInitial:      $FirstInitial"
echo "UserName:          $UserName"
echo "RemDashName:       $RemChars"
echo "PrintUserName:     $PrintUserName"

