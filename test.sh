#!/bin/bash

docker run --rm -it \
-h "drupal-dev" \
-u "vscode" \
-p 80:80 \
-v "drupal-dev-html:/var/www/html" \
local/drupal-devcontainer:latest fish
