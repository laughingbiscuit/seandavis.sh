#!/bin/sh
set -ex

sh blog.sh install_dev_env
rm -rf target/
mkdir target/
cp static/* target/
cp blog.sh target/
cd target/

cat blog.sh | grep -e "^function" | sed 's/function //' | sed 's/{//' | xargs -I{}  sh -c "sh blog.sh {}"
echo -e "\`\`\`\n\$SCRIPT\n\`\`\`" | pandoc -H head.htmlsnip -A after.htmlsnip --metadata="title=seandavis.sh" -s | SCRIPT="$(cat blog.sh)" envsubst > index.html
