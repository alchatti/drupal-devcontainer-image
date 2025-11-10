#!/bin/bash

printf "Local database drop & restore using drush\n======\n\n"

if [ $# -lt 1 ]
  then
    printf "Usage: $0 <file>\n\n"
    exit 1
fi

if [ ! -f $1 ]
  then
	printf "File $1 not found\n\n"
	exit 1
fi;

drush sql:drop

drush sql:query --file=$1
