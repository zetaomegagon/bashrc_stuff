# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

export PATH="${HOME}/bin:$PATH"

# User specific aliases and functions
if [ -f ${HOME}/functions ]; then
    source functions
fi

if [ -f ${HOME}/aliases ]; then
    source aliases
fi

# Startup commands
tstart
