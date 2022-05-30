#!/bin/bash

IMAGE="drupal-devcontainer"
REPOS=("alchatti" "ghcr.io/alchatti")
FLAG=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$FLAG" == "push" ]; then

  for repo in ${REPOS[@]}; do
    IMAGES=($(docker images $repo/$IMAGE --format "{{.Repository}}:{{.Tag}}"))

    # Reverse push order for shorter tag to be pushed last
    for (( idx=${#IMAGES[@]}-1 ; idx>=0 ; idx-- )) ; do
      image=${IMAGES[$idx]}

      echo "Pushing $image"
      if [ "$BRANCH" != "main" ]; then
        echo "[DEBUG] You are not on the main branch, pushing is only enabled on the main branch"
      else
        docker push $image
      fi;
    done;

  done;
  exit 0;
fi;

# List the built images
IMAGES=($(docker images $IMAGE --format "{{.Repository}}:{{.Tag}}"))

# timestamp=$(date "+%y%m%d_%H%M" --u)
timestamp=$(date "+%y%m%d" --u)

for image in ${IMAGES[@]}; do
  echo ">> $image"

  # Get the versions from the image
  TAGS=$(docker run --rm $image about.sh)

  TAG=$(echo $TAGS | jq -r '.TAG')
  TAG_T="$TAG-T$timestamp"
  TAG_S=$(echo $TAGS | jq -r '.TAG_S')
  TAG_L=$(echo $TAGS | jq -r '.TAG_L')

  TAGS=($TAG $TAG_T $TAG_S $TAG_L )
  POSTFIX=""
  if [ "$BRANCH" != "main" ]; then
    POSTFIX="--dev"
  fi;

  for repo in ${REPOS[@]}; do
    tag=$repo/$image$POSTFIX

    for tag in ${TAGS[@]}; do
      tag="$repo/$IMAGE:${tag}$POSTFIX"

      docker tag $image $tag

      echo "✔️  $tag"
    done;
  done;
    echo ""
done;
