#!/usr/bin/env /bin/bash

# switch to git dir
cd $HOME/gits/bashrc_stuff

# add symlinks for shell env
for file in "${PWD}/env/"*; do
    if [[ -e ~/."$(basename "$file")" ]]; then
	rm ~/."$(basename "$file")"
	ln -s "$file" ~/."$(basename "$file")"
    else
	ln -s "$file" ~/."$(basename "$file")"
    fi
done

# add symlinks for user scripts
if [[ ! -d ~/bin ]]; then
    mkdir ~/bin
fi

for file in "${PWD}/bin/"*; do
    if [[ -e ~/bin/"$(basename "$file")" ]]; then
	rm ~/bin/"$(basename "$file")"
	ln -s "$file" ~/bin/"$(basename "$file")"
    else
	ln -s "$file" ~/bin/"$(basename "$file")"
    fi
done

# add symlink for init.el
if [[ ! -d ~/bin/.emacs.d ]] && [[ ! ~/bin/emacs.d/init.el ]]; then
    mkdir ~/bin/.emacs.d
    ln -s "${PWD}/emacs/init.el" ~/bin/.emacs.d/init.el
fi

source ~/.bashrc
