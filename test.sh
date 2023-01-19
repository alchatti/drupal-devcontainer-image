#!/bin/bash

docker run --rm -it \
-h "drupal-dev" \
-u "vscode" \
-p 80:80 \
local/drupal-devcontainer:latest fish
