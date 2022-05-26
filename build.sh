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
fi;

if [ -z "$NODE" ]
then
  NODE=("--lts" "node")
  printf "\n\nNo version provided setting NodeJs to latest version & latest LTS\n\n"
fi;

if [ -z "$SASS" ]
then
  SASS=$(curl https://api.github.com/repos/sass/dart-sass/releases/latest | jq -r '.tag_name')
  echo "No version provided setting SASS to latest > $SASS"
fi

timestamp=$(date "+%a, %d %b %Y %T %Z" --u)
printf "\n\ntimeStamp > $timestamp \n\n"

for phpver in ${PHP[@]}
do
  printf "\nBuilding image with \n - PHP $phpver - dart-sass $SASS \n\n"

  tag=$phpver

  docker build \
    --build-arg VARIANT="$phpver" \
    --build-arg DART_SASS_VERSION="$SASS" \
    --build-arg CREATE_DATE="$timestamp" \
    --build-arg DRUPAL_CODER_VERSION="$DRUPAL_CODER_VERSION" \
    -t base/drupal-devcontainer:"$tag" .

  if [ $? -eq 0 ]; then

    printf "\n\nSuccessfully built base image with tag $tag\n\n"

    for nodever in ${NODE[@]}
    do

      if [ "$nodever" == "--lts" ]; then tag="$phpver-nLTS"; fi;

      printf "\Adding Node $nod image with \n - PHP $phpver with Node $nodever \n\n"

      docker build \
      --build-arg VARIANT="$phpver" \
      --build-arg NODE_VERSION="$nodever" \
      --build-arg CREATE_DATE="$timestamp" \
      -t drupal-devcontainer:"$tag" \
      -f Dockerfile.node .
    done
  else
    printf "\n\nFailed to build image with tag $tag\n\n"
  fi

done

