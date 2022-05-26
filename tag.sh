#!/bin/bash

IMAGE="drupal-devcontainer"
REPOS=("alchatti" "ghcr.io/alchatti")
FLAG=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$FLAG" == "push" ]; then
  for repo in ${REPOS[@]}; do
    IMAGES=($(docker images $repo/$IMAGE --format "{{.Repository}}:{{.Tag}}"))

    for image in ${IMAGES[@]}; do
      echo "Pushing $image"
      docker push $image
    done;
  done;
  exit 0;
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
  TAG_F=$(echo $TAGS | jq -r '.TAG_F')

  TAGS=($TAG $TAG_L $TAG_S $TAG_F)
  POSTFIX=""
  if [ "$BRANCH" != "main" ]; then
    POSTFIX="-$BRANCH"
  fi;

  for repo in ${REPOS[@]}; do
    tag=$repo/$image-$POSTFIX

    docker tag $image $tag
    echo "✔️  $tag"

    for tag in ${TAGS[@]}; do
      tag="$repo/$IMAGE:${tag}-$POSTFIX"
      docker tag $image $tag
      echo "✔️  $tag"
    done;
  done;
    echo ""
done;
