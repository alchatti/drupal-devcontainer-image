#!/bin/bash

printf "Local database dump using drush\n======\n\n"

if [ ! -d "/var/www/html/dump" ]
then
  mkdir /var/www/html/dump
fi;
drush sql:dump --result-file=/var/www/html/dump/db_`date +"%m_%d_%Y-%H:%M"`.sql --extra-dump=--no-tablespaces --skip-tables-list=cache,cache_*
