#!/bin/bash

printf "👋  Welcome to the world of Dev Containers...\n\n"

printf "\n⚒️  Image Details "
about.sh d | jq

printf "\n⚙️  Apache kick starting..\n"
apachectl stop
apachectl start
printf "Apache Ready! 🚀\n"

printf "\n💡 Hints"
echo '{"$W":"'$WORKSPACE_ROOT'", "$D": "'$WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT'"}' | jq

printf "\n"
