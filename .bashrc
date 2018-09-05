# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Source path to SML/NJ bingary
if [ -d "${HOME}/bin/smlnj/bin" ]; then
    export PATH="${HOME}/bin:${HOME}/bin/smlnj/bin:$PATH"
else
    export PATH="${HOME}/bin:$PATH"
fi

# Source user specific aliases and functions
if [ -f "~/.functions" ]; then
    . ~/.functions
fi

if [ -f "~/.aliases" ]; then
    . ~/.aliases
fi

## MasterPassword
if [ -f "~/.mpw" ]; then
    . ~/.mpw
    export MPW_FULLNAME=Elijah\ Thomas\ Beale
    export MPW_ASKPASS=${HOME}/bin/mpw_ask
fi

if [ -f "~/bin/bashlib" ]; then
    . bashlib
fi

# Startup commands in ${HOME}/.functions
tmux-start
clipc &

#gam() { "/home/ebeale/bin/gam/gam" "$@" ; }
