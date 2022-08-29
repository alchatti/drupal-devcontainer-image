#!/bin/bash

# Manual download of the latest Fish version
# https://software.opensuse.org/download.html?project=shells%3Afish%3Arelease%3A3&package=fish
FISH_URL="https://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/amd64/fish_3.5.1-1_amd64.deb"

DRUPAL_CODER_VERSION="8.3.13" # version is specified due to bug https://www.drupal.org/project/coder/issues/3262291

print_usage() {
  printf "\nBuild script usage: -p phpVer -s sassVer -n nodeJSVer -f fishVersion\n\nIf no version is provided the latest will be used\n\n# For list of tags vsist https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list\n\n"
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

[ -d ".build" ] || mkdir ".build"

if [ -f ".build/fish.deb" ]; then
  printf "📦 Using downloaded Fish packgage\n"
else
  printf "📦 Downloading Fish ${FISH_URL}\n"
  curl -L ${FISH_URL} -o .build/fish.deb
  printf "✔️ Downloading Fish Completed\n"
fi

if [ -z "$PHP" ]
then
  PHP=("7" "8")
  printf "- No PHP version setting defaulting to 7 and 8 \n\n"
fi;

if [ -z "$NODE" ]
then
  NODE=("--lts" "node")
  printf "- No Node.js version provided setting NodeJs to latest version & latest LTS\n\n"
fi;

if [ -z "$SASS" ]
then
  SASS=$(curl https://api.github.com/repos/sass/dart-sass/releases/latest | jq -r '.tag_name')
  echo "- No SASS version provided setting SASS to latest > $SASS"
fi

timestamp=$(date "+%a, %d %b %Y %T %Z" --u)
printf "\n\ntimeStamp > $timestamp \n\n"

for phpver in ${PHP[@]}
do
  printf "\nBuilding image with \n - PHP $phpver - dart-sass $SASS \n\n"

  tag=$phpver

  if [ $phpver == "7.4" ]; then
    printf "📦 Downloaded Acqui CLI for PHP 7.4\n"
    curl -L https://github.com/acquia/cli/releases/download/1.30.1/acli.phar -o .build/acli.phar
  else
    printf "📦 Downloaded Acqui CLI for PHP 8.0 or later\n"
    curl -L https://github.com/acquia/cli/releases/latest/download/acli.phar -o .build/acli.phar
  fi

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

      if [ "$nodever" == "--lts" ]; then tag="$phpver-nLTS"; else tag="$phpver" ; fi;

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
