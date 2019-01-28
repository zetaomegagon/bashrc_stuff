# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Set $EDITOR to Emacs
EDITOR='emacsclient -nw'

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Source path to SML/NJ binary
if [ -d "${HOME}/bin/smlnj/bin" ]; then
    export PATH="${HOME}/bin:${HOME}/bin/smlnj/bin:$PATH"
else
    export PATH="${HOME}/bin:$PATH"
fi

# Source path to GAM binary
if [ -d "${HOME}/bin/gam" ]; then
    export PATH="${HOME}/bin:${HOME}/bin/gam:$PATH"
else
    export PATH="${HOME}/bin:$PATH"
fi

# Source user specific aliases and functions
if [ -f ${HOME}/.functions ]; then
    . ${HOME}/.functions
fi

if [ -f ${HOME}/.aliases ]; then
    . ${HOME}/.aliases
fi

if [ -f ${HOME}/.keypass ]; then
    . ${HOME}/.keypass
fi

## MasterPassword
if [ -f ${HOME}/.mpw ] && [ -e ${HOME}/bin/mpw ]; then
    . ${HOME}/.mpw
    export MPW_FULLNAME=Elijah\ Thomas\ Beale
    export MPW_ASKPASS=${HOME}/bin/mpw_ask
    export MPW_FORMAT=none

    if [ -d ${HOME}/.mpw.d ]; then
	rm -r ${HOME}/.mpw.d/* >/dev/null 2>&1
    fi

fi

if [ -f ${HOME}/bin/bashlib ]; then
    . bashlib
fi

## emacs-read-stdin
if [[ -d "${HOME}/gits/emacs-read-stdin" ]]; then
    . "${HOME}/gits/emacs-read-stdin/emacs-read-stdin.sh"
fi

# Startup commands in ${HOME}/.functions
tmux-start
#aria2-restart

#gam() { "/home/ebeale/bin/gam/gam" "$@" ; }
