#/bin/bash

curl -Lo VSCode-darwin-stable.zip https://go.microsoft.com/fwlink/?LinkID=620882
unzip VSCode-darwin-stable.zip
rm VSCode-darwin-stable.zip
mv Visual\ Studio\ Code.app/ /Applications/
