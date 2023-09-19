#!/bin/sh
set -ex

sh -e notes.sh install_dev_env
rm -rf target/
mkdir target/
cp static/* target/
cp notes.sh target/
cd target/

cat notes.sh | grep -e "^function" | sed 's/function //' | sed 's/{//' | xargs -I{}  sh -c "sh notes.sh {}"
pandoc -H head.htmlsnip -A after.htmlsnip --metadata="title=seandavis.sh" -s index.md | SCRIPT="$(cat notes.sh)" envsubst > index.html
mv notes.sh raw
