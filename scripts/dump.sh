#!/bin/bash

printf "Local database dump using drush\n======\n\n"

if [ ! -d "$WORKSPACE_ROOT/dump" ]
then
  mkdir $WORKSPACE_ROOT/dump
fi;


DRIVER=$(drush status --format "json" | jq -r '."db-driver"')

if [ $DRIVER == "mysql" ] || [ $DRIVER == "pgsql" ]
then
  echo "$DRIVER detected, intializing dump"

  drush sql:dump --result-file=$WORKSPACE_ROOT/dump/db_`date +"%m_%d_%Y-%H:%M"`.sql --extra-dump=--no-tablespaces --skip-tables-list=cache,cache_*

  if [ $? -eq 0 ]; then
    echo "✔️  Database dump completed"
    exit 0;
  fi;

  exit 1;
fi;

if [ $DRIVER == "sqlite" ]
then
  echo "$DRIVER detected, intializing Database Copy"

  DB_FILE=$(drush status --format "json" | jq -r '."db-name"')

  cp $WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT/$DB_FILE $WORKSPACE_ROOT/dump/db_`date +"%m_%d_%Y-%H:%M"`.sqlite

  if [ $? -eq 0 ]; then
    echo "✔️  Database copy completed"
    ls $WORKSPACE_ROOT/dump -latr | grep '.sqlite' | tail -1
    exit 0;
  fi;

  exit 1;
fi;

echo "$DRIVER not supported, exiting"
exit 1
