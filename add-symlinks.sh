#!/usr/bin/env /bin/bash

# add symlinks for shell env
for file in "${PWD}/env/"*; do
    if [[ -f ~/."$(basename "$file")" ]]; then
	rm ~/."$(basename "$file")"
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
    fi
done

# add symlink for init.el
if [[ ! -d ~/bin/.emacs.d ]]; then
    mkdir ~/bin/.emacs.d
fi

ln -s "${PWD}/emacs/init.el" ~/bin/.emacs.d/init.el

source ~/.bashrc
