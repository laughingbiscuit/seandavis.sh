#!/bin/sh
set -e

sh blog.sh install_dev_env
rm -rf target/
mkdir target/
cp static/* target/
cp blog.sh target/
cd target/

echo -e "\`\`\`\n\$SCRIPT\n\`\`\`" | pandoc -A after.htmlsnip --metadata="title=seandavis.sh" -s | SCRIPT="$(cat blog.sh)" envsubst > index.html
