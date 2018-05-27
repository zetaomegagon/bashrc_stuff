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
if [ -f "${HOME}/.functions" ]; then
    source ~/.functions
fi

if [ -f "${HOME}/.aliases" ]; then
    source ~/.aliases
fi

## MasterPassword
if [ -f "${HOME}/.mpw" ]; then
    source ~/.mpw
    export MPW_FULLNAME=Elijah\ Thomas\ Beale
    export MPW_ASKPASS=${HOME}/bin/mpw_ask
fi

if [ -f "{HOME}/bin/bashlib" ]; then
    source bashlib
fi

# Startup commands in ${HOME}/.functions
tmux-start

#gam() { "/home/ebeale/bin/gam/gam" "$@" ; }
