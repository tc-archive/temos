#!/bin/bash

# install plug vimrc file
cp ./vim-plug.vimrc ~/.vimrc

# install vim plugins
# vim +PlugUpdate +PlugUpgrade +PlugInstall +PlugClean +qa
vim +PlugInstall +qall

# compile YouCompleteMe plugin if declared
YCM=$(cat ~/.vimrc | grep Plug 'Valloric/YouCompleteMe')
if [[ -z ${YCM} ]]; then
    pushd ~/.vim/plugged/YouCompleteMe
    ./install.py
    popd
fi
