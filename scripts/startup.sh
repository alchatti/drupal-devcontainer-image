#!/bin/bash

printf "👋  Welcome to the world of Dev Containers...\n\n"
apache2ctl start

printf "\n⚒️  Image Details "
about.sh d | jq

printf "\n"
