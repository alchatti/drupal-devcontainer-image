#!/bin/bash

docker run --rm -it \
-h "drupal-dev" \
-u "vscode" \
-p 80:80 \
-v "drupal-dev-html:/var/www/html" \
-e "TESTING_1=⭐⭐⭐Hello World!⭐⭐⭐" \
-e "TESTING_2=🚀🛸🛰️🕳️💫" \
local/drupal-devcontainer:latest fish
