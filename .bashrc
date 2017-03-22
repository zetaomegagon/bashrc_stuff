# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=




######################################################################
#                          #  Shell  #                               #
######################################################################

# Color prompt with working directory
PS1="\\[$(tput setaf 0; tput setab 3)\\]\
\\u@\\h:\\w $:\\[$(tput sgr0)\\] "

# Start tmux attached to a session or
# create a new one
tsession() {

    local ID="$(tmux ls | grep -vm1 attached | cut -d: -f1)"
    
    if [[ -z "$TMUX" ]] ;then
        if [[ -z "$ID" ]] ;then
            tmux new-session
        else
            tmux attach-session -t "$ID"
        fi
    fi
}

tsession
######################################################################
#                        #  END Shell  #                             #
######################################################################




######################################################################
#                                                                    #
#                                                                    #
#==============#  User Added Functions and Aliases  #================#
#                                                                    #
#                                                                    #
######################################################################




######################################################################
#                      #  Master Password  #                         #
######################################################################
source bashlib
mpw() {                                                                                                 
    _copy() {
        if hash pbcopy 2>/dev/null; then                                                                
            pbcopy                                                                                      
        elif hash gpaste-client 2>/dev/null; then                                                       
            gpaste-client add-password "From Master Password"
        else
            cat; echo 2>/dev/null
            return
        fi
            
        echo >&2 "Copied!"                                                                              
    }                                                                                                   
                                                                                                        
    # Empty the clipboard                                                                               
    :| _copy 2>/dev/null                                                                                
                                                                                                        
    # Ask for the user's name and password if not yet known.                                            
    MP_FULLNAME=${MP_FULLNAME:-$(ask 'Your Full Name:')}                                                
                                                                                                        
    # Start Master Password and copy the output.                                                        
    printf %s "$(MP_FULLNAME=$MP_FULLNAME command mpw "$@")" | _copy                                      
}

export MP_FULLNAME=Elijah\ Thomas\ Beale
######################################################################
#                   #  END Master Password  #                        #
######################################################################




######################################################################
#                     #  Remote Servers  #                           #
######################################################################
fonas() {

    local user="foadmin"
    local host="FONAS"
    local addr1="10.0.4.64"
    local port1="22"
    local addr2="209.118.43.165"
    local port2="65535"
    local r="\033[0;31m" # Ansi red 
    local c="\033[0m" # Ansi no color (clear)
    
    if nc -z -w 3 $addr1 $port1; then

        echo -e "\nConnecting to ${r}${host}${c} over LAN...(${addr1})\n"
        ssh ${user}@${addr1}
        
    elif nc -z -w 3 $addr2 $port2; then

        echo -e "\nConnecting to ${r}${host}${c} over WWW...(${addr2})\n"
        ssh -p $port2 ${user}@${addr2}
        
    else
        echo -e "\n     ${r}${addr1}${c}: cannot establish connection..."
        echo -e "${r}${addr2}${c}: cannot establish connection...\n"
        (exit 1)
    fi
}

protosrv() {

    local user="padmin"
    local host="PROTOSRV"
    local addr1="10.0.5.162"
    local port1="22"
    local addr2="209.118.43.165"
    local port2="65534"
    local r="\033[0;31m" # Ansi red 
    local c="\033[0m" # Ansi no color (clear)
    
    if nc -z -w 3 $addr1 $port1; then

        echo -e "\nConnecting to ${r}${host}${c} over LAN...(${addr1})\n"
        ssh ${user}@${addr1}
        
    elif nc -z -w 3 $addr2 $port2; then

        echo -e "\nConnecting to ${r}${host}${c} over WWW...(${addr2})\n"
        ssh -p $port2 ${user}@${addr2}
        
    else
        echo -e "\n    ${r}${addr1}${c}: cannot establish connection..."
        echo -e "${r}${addr2}${c}: cannot establish connection...\n"
        (exit 1)
    fi
}
######################################################################
#                   #  END Remote Servers  #                         #
######################################################################



######################################################################
#                     #  MISC Functions  #                           #
######################################################################
rsft() {
    # This needs to become a systemd unit.
    redshift -b 0.9:0.8 \
             -l 40.0114538:-75.1326503 \
             -l manual \
             -m randr \
             -t 4900:4000 \
             > /dev/null 2>&1 &
}

rain() {
    ## 
    local path="/home/ebeale/Music"
    
    systemd-inhibit \
        --what=handle-lid-switch \
        --mode=block --who='ebeale' \
        --why='Rain Sounds' \
        mpv --no-video ${path}/rain.mp3 \
        > /dev/null 2>&1 &
    (exit 0)
}

emacsctl() {
    ## Maintain an Emacs service unit
    case $1 in
        stop|start|restart|status)
            systemctl --user "$1" emacs
            ;;
        *)
            echo "Usage:"
            echo "  emacsctl {stop|start|restart|status}"
    esac
}

emacs() {
    ## Wrapper for Emacs that makes sure
    ## Emacs runs despite the service state
    local status=$(emacsctl status \
                       | grep 'Active' \
                       | awk '{print $2}')
    
    case "$status" in
        active)
            emacsclient -ta "" ${1}
            ;;
        failed)
            systemctl --user start emacs
            emacsclient -ta "" ${1}
            ;;
        *)
            systemctl --user restart emacs
            emacsclient -ta "" ${1}
    esac
}

sms() {
    ## A textmessage utility
    local key=""

    case $1 in
        quota)
            curl https://textbelt.com/quota/"${key}"
            echo ""
            (exit 0)
            ;;
        status)
            curl https://textbelt.com/status/"${2}"
            echo ""
            (exit 0)
            ;;
        *)
            if [[ "$1" =~ [0-9]{10} ]] && [[ "$2" != '' ]]; then
                
                curl -X POST https://textbelt.com/text \
                     --data-urlencode number="${1}" \
                     --data-urlencode message="${2}" \
                     -d key="${key}"
                echo ""
                (exit 0)

            elif [[ "$2" == '' ]]; then

                echo "Please provide a message!"
                (exit 1)

            else
                echo "Usage:"
                echo "     Current quota:  sms quota"
                echo "    Send a message:  sms <number> <message>"
                echo "  Check sms status:  sms status <id>"
                echo "     Anything else:  this message."
                echo ""
                echo "Exit status:"
                echo "  0: success."
                echo "  1: failure."
                echo "  2: no message indicated."
                (exit 0)
            fi
    esac       
}

up() {
    ## A far-from-perfect website status checker
    local head=$(curl -sI "$1" | head -1 | cut -d ' ' -f 2)
    local moved=$(curl -sI "$1" | grep 'Location' \
                      | cut -d ' ' -f2 \
                      | tr -d '\r')
    
    local r="\033[0;31m" # Ansi red 
    local c="\033[0m" # Ansi no color (clear)

    if [[ "$head" =~ 2[0-9]{2} ]]; then
        echo -e "\n${r}${1}${c}...is up!\n"
        (exit 0)
    elif [[ "$head" =~ 3[0-9]{2} ]]; then
        up "${moved%/}"
        (exit 2)
    elif [[ "$head" =~ 4[0-9]{2} ]];then
        echo -e "\n${r}${1}${c}...is down!\n"
        (exit 1)
    else
        echo "Usage:"
        echo "  isitup {http|https}://<fqdn>"
        echo "  isitup <base-url>"
    fi
}
######################################################################
#                   #  END MISC Functions  #                         #
######################################################################




######################################################################
#                        #  Aliases  #                               #
######################################################################
alias lz="ls -AlFZ --color=always"
alias la="ls -AlF --color=always"
alias ll="ls -lF --color=always"
alias l="ls -CF --color=always"

alias pgrepg="ps -ax | grep -v grep | grep"
alias mountt="mount | column -t"
alias src="source /home/ebeale/.bashrc"
alias rc="emacs /home/ebeale/.bashrc"

alias meraki="mpw -c 3 meraki.com"
alias gmail-tps="mpw gmail-tps"
alias work-phone="mpw -t x work-phone"
alias jss-prod="mpw -t x jss-prod"
alias foadmin="mpw -t x foadmin"
alias foroot="mpw -t x foroot"
alias padmin="mpw -t x padmin"
alias proot="mpw -t x proot"

alias gmail-personal="mpw gmail-personal"

alias mpv="DRI=prime mpv"
######################################################################
#                      #  END Aliases  #                             #
######################################################################




######################################################################
#                                                                    #
#                                                                    #
#===========================#  END  #================================#
#                                                                    #
#                                                                    #
######################################################################
