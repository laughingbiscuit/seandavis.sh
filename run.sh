#!/bin/sh
set -e

# generate shell script in target dir
rm -rf target/
mkdir -p target/

cp -r static/* target/
cp index.md target/

echo -e "#!/bin/sh\n#Autogenerated\nset -e\n" > target/seandavis.sh
cat index.md | sed -n '/^```/,/^```/ p' | sed '/^```/ d' >> target/seandavis.sh
echo '"$@"' >> target/seandavis.sh 

if [ $DEBUG = "true" ]; then exit; fi

# make sure devenv is installed first
(cd target/ &&
  sh seandavis.sh install_dev_env)

# run all functions in shell script
(cd target/ &&
  FUNCTIONS=$(cat seandavis.sh | grep -e "^function" | sed 's/function //' | sed 's/{//')
  for FUN in $FUNCTIONS; do
    sh -xe seandavis.sh $FUN
  done

# generate html
  pandoc index.md -H head.htmlsnip -B before.htmlsnip -A after.htmlsnip --metadata="title=seandavis.sh" -s --toc -o index.html)

cp target/seandavis.sh target/raw
