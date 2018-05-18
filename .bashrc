# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

if [ -d "${HOME}/bin/smlnj/bin" ]; then
    export PATH="${HOME}/bin:${HOME}/bin/smlnj/bin:$PATH"
else
    export PATH="${HOME}/bin:$PATH"
fi

# User specific aliases and functions
if [ -f "${HOME}/.functions" ]; then
    source ~/.functions
fi

if [ -f "${HOME}/.aliases" ]; then
    source ~/.aliases
fi

if [ -f "${HOME}/.mpw" ]; then
    source ~/.mpw
fi

# Startup commands
tmux-start

## Added by Master Password
if [ -f "{HOME}/bin/bashlib" ]; then
    source bashlib
fi
export MPW_ASKPASS=/home/ebeale/bin/mpw_ask
