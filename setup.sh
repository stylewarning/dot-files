#!/bin/sh

#ln -s $PWD/dot-test-file $HOME/.test-file
#mkdir -p $HOME/test-config/a/b/

mkdir -p $HOME/.emacs.d/backups/
mkdir -p $HOME/.emacs.d/additions/

cp -R emacs-extras/* $HOME/.emacs.d/additions/

curl --create-dirs -O --output-dir $HOME/.emacs.d/additions/ https://paredit.org/releases/26/paredit.el
