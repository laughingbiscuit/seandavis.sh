#!/bin/sh
set -ex

sh -e notes.sh install_dev_env
rm -rf target/
mkdir target/
cp static/* target/
cp notes.sh target/
cd target/

cat notes.sh | grep -e "^function" | sed 's/function //' | sed 's/{//' | xargs -I{}  sh -e -c "sh -e notes.sh {}"
pandoc -H head.htmlsnip -A after.htmlsnip --metadata="title=seandavis.sh" -s index.md | SCRIPT="$(cat notes.sh)" envsubst > index.html
mv notes.sh raw
sed -i '1s/.*/{"version": 2, "width": 66, "height": 37, "timestamp": 1695663471, "env": {"SHELL": "/bin/ash", "TERM": "xterm-256color"}}/' out.cast
