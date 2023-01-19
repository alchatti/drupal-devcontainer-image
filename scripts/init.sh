#!/bin/bash

# Script for Intial setup
# Checks if drupal is installed and if not, installs it

echo ">> init script started <<"
echo "Checking if Drupal is installed..."

DIR=$WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT

FILE=$DIR/index.php

if [ ! -e $FILE ] || [ $(ls $DIR | wc -l) -le 2 ]
then
	echo "Drupal is not installed, installing..."
	# Create the database.
	mkdir /tmp/drupal
	cd /tmp/drupal

	# Source https://docs.acquia.com/cloud-platform/create/install/drupal9/
	composer create-project --no-install drupal/recommended-project:^10 .
	sed -i'.original' 's/web\//docroot\//g' composer.json && rm composer.json.original

	# composer require drush/drush:^10.2 drupal/mysql56 --no-update
	composer require --no-update drush/drush:^11

	# Drupal Modules
	composer require --no-update drupal/stage_file_proxy
    composer require --no-update cweagans/composer-patches
	composer config --no-plugins allow-plugins.cweagans/composer-patches true

	# composer require acquia/blt --no-update

	mv /tmp/drupal/* $WORKSPACE_ROOT
	rm /tmp/drupal -rf
	cd $WORKSPACE_ROOT

	# chown -R vscode:vscode $WORKSPACE_ROOT

	yes | composer update
else
	printf "Found more than one file in $DIR, skipping installation\n\nUse >> rm -r $DIR/* >> to empty the directory\n"
fi;
