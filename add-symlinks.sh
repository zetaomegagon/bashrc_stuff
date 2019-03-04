#!/bin/bash

# add symlinks for shell env
for file in $(pwd)/env/*; do
    ln -s "$file" ~/."$(basename "$file")"
done

# add symlinks for user scripts
if [[ ! -d ~/bin ]]; then
    mkdir ~/bin
fi

for file in $(pwd)/bin/*; do
    ln -s "$file" ~/bin/"$(basename "$file")"
done

# add symlink for init.el
if [[ ! -d ~/bin/.emacs.d ]]; then
    mkdir ~/bin/.emacs.d
fi

ln -s $(pwd)/emacs/init.el ~/bin/.emacs.d/init.el
