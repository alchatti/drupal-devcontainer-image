#!/bin/bash

IMAGE="drupal-devcontainer"
REPOS=("alchatti")
FLAG=$1

if [ "$FLAG" == "push" ]; then
  for repo in ${REPOS[@]}; do
    IMAGES=($(docker images $repo/$IMAGE --format "{{.Repository}}:{{.Tag}}"))

    for image in ${IMAGES[@]}; do
      echo "Pushing $image"
      docker push $image
    done;

  done;
  exit 1;
fi;

# List the built images
IMAGES=($(docker images $IMAGE --format "{{.Repository}}:{{.Tag}}"))

for image in ${IMAGES[@]}; do
  echo ">> $image"

  # Get the versions from the image
  TAGS=$(docker run --rm $image about.sh)

  TAG=$(echo $TAGS | jq -r '.TAG')
  TAG_L=$(echo $TAGS | jq -r '.TAG_L')
  TAG_S=$(echo $TAGS | jq -r '.TAG_S')

  TAGS=($TAG $TAG_L $TAG_S)

  for repo in ${REPOS[@]}; do
    docker tag $image $repo/$image
    echo "$repo/$image"

    for tag in ${TAGS[@]}; do
      taged=$repo/$IMAGE":${tag}"

      docker tag $image $taged
      echo $taged
    done;

  done;

done;
