#!/bin/bash

print_usage() {
  printf "\nBuild script usage: -p phpVer -n nodeJSVer\n\nIf no version is provided the latest will be used\n\n# For list of tags vsist https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list\n\n"
}

while getopts p:s:n: flag;
do
    case "${flag}" in
        p) PHP=${OPTARG};;
        n) NODE=${OPTARG};;
        *) print_usage
            exit 1 ;;
    esac
done

if [ -z "$PHP" ]
then
  # PHP=("7" "8.0" "8.1")
  PHP=("7.4" "8.1")
  printf "- No PHP version setting defaulting to 7 and 8 \n\n"
fi;

if [ -z "$NODE" ]
then
  # NODE="--lts"
  NODE="node"
  printf "- No Node.js version provided setting NodeJs to latest version\n\n"
fi;

timestamp=$(date +'%Y%m%d')
printf "\n\ntimeStamp > $timestamp \n\n"

TARGETARCH=$(uname -m)

if [ "$TARGETARCH" = "x86_64" ]; then
  TARGETARCH="amd64"
else
  TARGETARCH="arm64"
fi

for phpver in ${PHP[@]}
do
  printf "\nBuilding image with \n - PHP $phpver with Node $NODE for $TARGETARCH \n\n"

  tag=$phpver

  docker build \
    --build-arg VARIANT="$phpver" \
    --build-arg NODE_VERSION="$NODE" \
    --build-arg CREATE_DATE="$timestamp" \
    --build-arg TARGETARCH=$TARGETARCH \
    -t local/drupal-devcontainer:"$tag"-$NODE \
    -t local/drupal-devcontainer:latest .

  printf "\n\nSuccessfully built base image with tag $tag\n\n"

done
