#!/bin/sh
set -ex

sh -e notes.sh install_dev_env
rm -rf target/
mkdir target/
cp static/* target/
cp blog.sh target/
cd target/

cat notes.sh | grep -e "^function" | sed 's/function //' | sed 's/{//' | xargs -I{}  sh -c "sh blog.sh {}"
pandoc -H head.htmlsnip -A after.htmlsnip --metadata="title=seandavis.sh" -s index.md | SCRIPT="$(cat blog.sh)" envsubst > index.html
mv blog.sh raw
