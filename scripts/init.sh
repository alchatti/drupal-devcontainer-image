#!/bin/bash

# Script for Intial setup
# Checks if drupal is installed and if not, installs it

echo ">> init script started <<"
echo "Checking if Drupal is installed..."

FILE=/var/www/html/docroot/index.php

if [ ! -e $FILE ]
then
	echo "Drupal is not installed, installing..."
	# Create the database.
	mkdir /tmp/drupal
	cd /tmp/drupal

	# Source https://docs.acquia.com/cloud-platform/create/install/drupal9/
	composer create-project --no-install drupal/recommended-project:^9.0.0 .
	sed -i'.original' 's/web\//docroot\//g' composer.json && rm composer.json.original

	# composer require drush/drush:^10.2 drupal/mysql56 --no-update
	composer require --no-update drush/drush:^11

	# composer require acquia/blt --no-update

	mv /tmp/drupal/* $WORKSPACE_ROOT
	rm /tmp/drupal -rf
	cd $WORKSPACE_ROOT

	# chown -R vscode:vscode $WORKSPACE_ROOT

	yes | composer update
else
	echo "Drupal already installed..."
fi;
