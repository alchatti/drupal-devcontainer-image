#!/bin/bash

DRUPAL_CODER_VERSION="8.3.13" # version is specified due to bug https://www.drupal.org/project/coder/issues/3262291

print_usage() {
  printf "\nBuild script usage: -p phpVer -s sassVer -n nodeJSVer\n\nIf no version is provided the latest will be used\n\n# For list of tags vsist https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list\n\n"
}

while getopts p:s:n: flag;
do
    case "${flag}" in
        p) PHP=${OPTARG};;
        n) NODE=${OPTARG};;
        s) SASS=${OPTARG};;
		*) print_usage
       	   exit 1 ;;
    esac
done

if [ -z "$PHP" ]
then
  PHP=("7" "8")
  echo "No version setting PHP to defaults"
else
  PHP=($PHP);
fi;

if [ -z "$NODE" ]
then
  NODE="node"
  NODE_LTS="--lts"
  printf "\n\nNo version provided setting NodeJs to latest version & latest LTS\n\n"

fi;

if [ -z "$SASS" ]; then SASS=$(curl https://api.github.com/repos/sass/dart-sass/releases/latest | jq -r '.tag_name'); echo "No version provided setting SASS to latest > $SASS";fi

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
printf "\n\ntimeStamp > $timestamp \n\n"

for phpver in ${PHP[@]}
do
  printf "\nBuilding image with \n - PHP $phpver \n - NodeJs $NODE \n - dart-sass $SASS \n\n"

  docker build \
    --build-arg VARIANT="$phpver" \
    --build-arg NODE_VERSION="node" \
    --build-arg DART_SASS_VERSION="$SASS" \
    --build-arg CREATE_DATE="$timestamp" \
    --build-arg DRUPAL_CODER_VERSION="$DRUPAL_CODER_VERSION" \
    -t drupal-devcontainer:"$phpver" .

  # printf "\nBuilding image with \n - PHP $phpver \n - NodeJs Lts \n - dart-sass $SASS \n\n"

  docker build \
    --build-arg VARIANT="$phpver" \
    --build-arg NODE_VERSION="--lts" \
    --build-arg DART_SASS_VERSION="$SASS" \
    --build-arg CREATE_DATE="$timestamp" \
    --build-arg DRUPAL_CODER_VERSION="$DRUPAL_CODER_VERSION" \
    -t drupal-devcontainer:"$phpver"-nLTS .
done

