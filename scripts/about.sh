#!/bin/bash


vr_php=$(php -v | head -1 | awk '{print $2}')
IFS=. read vr_php_major vr_php_minor <<<"${vr_php}"

vr_node=$(node -pe process.versions.node)
IFS=. read vr_node_major vr_node_minor <<<"${vr_node}"

vr_node_lts=$(node -pe process.release.lts)
vr_npm=$(npm -v)
vr_sass=$(sass --version)
vr_composer=$(composer --version | awk '{print $3}')


if [ $vr_node_lts == "undefined" ]
then
	TAG_S="$vr_php_major-n$vr_node_major"

else
	TAG_S="$vr_php_major-n${vr_node_major}LTS"
fi;

TAG_L="$TAG_S-s$vr_sass"
TAG=$vr_php-n$vr_node-s$vr_sass-c$vr_composer-npm$vr_npm

case $1 in
	s) echo $TAG_S;;
	l) echo $TAG_L;;
	*) echo '{ "TAG_S": "'$TAG_S'", "TAG_L": "'$TAG_L'" , "TAG": "'$TAG'"}' ;;
esac
