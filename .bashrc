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
if [ -f ~/.functions ]; then
    . ~/.functions
fi

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

if [ -f ~/.ssh-key-pw ]; then
    . ~/.ssh-key-pw
fi

## MasterPassword
if [ -f ~/.mpw ] && [ -e ~/bin/mpw ]; then
    . ~/.mpw
    export MPW_FULLNAME=Elijah\ Thomas\ Beale
    export MPW_ASKPASS=${HOME}/bin/mpw_ask
    export MPW_FORMAT=none

    if [ -d ~/.mpw.d ]; then
	rm -r ~/.mpw.d/* >/dev/null 2>&1
    fi

fi

if [ -f ~/bin/bashlib ]; then
    . bashlib
fi

## emacs-read-stdin
if [[ -d "${HOME}/gits/emacs-read-stdin" ]]; then
    . "${HOME}/gits/emacs-read-stdin/emacs-read-stdin.sh"
fi

# Startup commands in ${HOME}/.functions
tmux-start
aria2-start

#gam() { "/home/ebeale/bin/gam/gam" "$@" ; }
