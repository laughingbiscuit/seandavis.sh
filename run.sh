#!/bin/sh
set -e

# generate shell script in target dir
rm -rf target/
mkdir -p target/

cp -r static/* target/
cp index.md target/

echo -e "#!/bin/sh\n#Autogenerated\nset -e\n" > target/index.sh
cat index.md | sed -n '/^```/,/^```/ p' | sed '/^```/ d' >> target/index.sh
echo '"$@"' >> target/index.sh 

# run all functions in shell script
(cd target/ &&
  cat index.sh | grep -e "^function" | sed 's/function //' | sed 's/{//' | xargs -I{} sh -e -c "sh -e index.sh {}" &&

# generate html
  pandoc index.md -H head.htmlsnip -A after.htmlsnip --metadata="title=seandavis.sh" -s --toc -o index.html)


#fix cast files
#cat out.cast | tail -n +2 > out.snip
#echo '{"version": 2, "width": 66, "height": 15, "timestamp": 1695663471, "env": {"SHELL": "/bin/ash", "TERM": "xterm-256color"}}' > out.cast
#cat out.snip >> out.cast
