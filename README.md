# Development Container for Drupal

![GitHub last commit](https://img.shields.io/github/last-commit/alchatti/drupal-devcontainer-image?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/alchatti/drupal-devcontainer?style=for-the-badge)

![Docker (tag)](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![PHP (tag)](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![NodeJS (tag)](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Drupal (tag)](https://img.shields.io/badge/Drupal-0678BE?style=for-the-badge&logo=drupal&logoColor=white)
![Ubuntu (tag)](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Apple silicon (tag)](https://img.shields.io/badge/apple%20silicon-333333?style=for-the-badge&logo=apple&logoColor=white)
![VS Code (tag)](https://img.shields.io/badge/VSCode-0078D4?style=for-the-badge&logo=visual%20studio%20code&logoColor=white)

![Docker Stars](https://badgen.net/docker/stars/alchatti/drupal-devcontainer?icon=docker&label=stars)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/alchatti/drupal-devcontainer/7.4?label=7.4&logo=PHP)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/alchatti/drupal-devcontainer/8.1?label=8.1&logo=PHP)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/alchatti/drupal-devcontainer/8.1?label=8.2&logo=PHP)

[![Build & Publish Images](https://github.com/alchatti/drupal-devcontainer-image/actions/workflows/build-and-push.yml/badge.svg?branch=main)](https://github.com/alchatti/drupal-devcontainer-image/actions/workflows/build-and-push.yml)
[![Update Container Description](https://github.com/alchatti/drupal-devcontainer-image/actions/workflows/update-container-description.yml/badge.svg)](https://github.com/alchatti/drupal-devcontainer-image/actions/workflows/update-container-description.yml)

Drupal development container based on [Microsoft PHP devcontainer image](https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list).

## Usage

[Devcontainer](https://code.visualstudio.com/docs/remote/containers) image is to be used for development inside a container. This image is loaded with the tools required to develop a Drupal & NodeJs project.

It can be used as standalone and it is recommended to use [alchatti/drupal-devcontainer](https://github.com/alchatti/drupal-devcontainer) with VS Code for an interactive development experience with required extentions installed.

A base Drupal project is available at [alchatti/drupal-devcontainer-sample-project](https://github.com/alchatti/drupal-devcontainer-sample-project)

Dev feature are set for the container user `vscode`, a none root user provided by the Microsoft base image.

> Apache server will start as part of the a startup script using command `apache2ctl start`

### Quick Start: Self contained Drupal site for testing & Demonstration

Drupal 10 can be installed with SQLite without the need for an additional database container.

For best Dev experience, start the container as `vscode` user. Hostname `drupal-dev` can be changed to any other name.

1. To start a container in interactive mode and remove once exited, docker will auto create the volume `drupal-dev-html` to persist the site installation. type

```bash
docker run --rm -it \
-h "drupal-dev" \
-u "vscode" \
-p 80:80 \
-v "drupal-dev-html:/var/www/html" \
alchatti/drupal-devcontainer:8.1 fish
```

2. Once the container finishes intializing visit <http://localhost> to show PHP information page.

1. You can use `init.sh` command to create a new Drupal 10 site. Use `SQLite` as the database option for a self contained image. This script is based on [Acquia configuration](https://docs.acquia.com/cloud-platform/create/install/drupal9/). You can also setup Drupal your self.

```bash
init.sh
```

4. Once the Drupal is installed visit http://localhost, to start setting up Drupal.

1. For demo purpose, select `Demo: Umami Food Magazine (Experimental)` as installation profile.

1. For database use the `SQLite` and the Database file as default `sites/default/files/.ht.sqlite`.

1. Configure the site by setting up the `admin` user name and password

1. visit <http://localhost> to show the Drupal site.

1. To exit the container and stop the service, type

```bash
exit
```

- To delete the created volume and start fresh, type

```bash
docker volume rm drupal-dev-html
```

### Additional usage options & flags

- Change the shell to `zsh` and the theme to 'blue-owl' by using environment variable `POSH_THEME_ENVIRONMENT`, for more theme options check [Oh My Posh theme](https://ohmyposh.dev/docs/themes).

```bash
docker run --rm -it \
-e POSH_THEME_ENVIRONMENT='blue-owl'
-h "drupal-dev" \
-u "vscode" \
-p 80:80 \
-v "drupal-dev-html:/var/www/html" \
alchatti/drupal-devcontainer:8.1 zsh
```

## Tags

To target a specific version build the tag is configured as follow `$php-$datetime`

Available tags:

- `8.2`: PHP 8.2 with latest Node.js, and Composer at build.
- `8.1`: PHP 8.1 with latest Node.js, and Composer at build.

Legacy / Deprecated tags:

- `7.4`: PHP 7.4 with latest Node.js, and Composer at build. (last build 2023DEC01)

You can also use timestamped tags to target a specific build. Check https://hub.docker.com/r/alchatti/drupal-devcontainer/tags for available tags.

## Image

The image is targeting the latest 8.1 & 8.2 versions of PHP with latest Node.js.

## Scripts

```bash
# print image package versions/tags in json format
about | jq
# create a time stamped sql dump of the database using drush and store it under /var/www/html/dump
dump.sh
# Download latest acquia cloud database backup using acli
acli-dump.sh
```

## Installed packages

The base image comes with Zsh, [Apache](https://httpd.apache.org/), [Xdebug](https://xdebug.org/), [Composer](https://getcomposer.org/).

With the following additional packages:

- Drupal dev tools
	- [X] [Drush launcher](https://github.com/drush-ops/drush-launcher).
	- [X] [Drush 8](https://www.drush.org/latest/) as global fallback and for Drupal 7.
	- [X] [Drupal Coder](https://www.drupal.org/project/coder)

- Acquia tools
	- [X] [Acquia CLI](https://docs.acquia.com/acquia-cli/) requires PHP 8
	- [X] [Acquia BLT launcher](https://github.com/acquia/blt-launcher/)

- Front-End development
	- [X] [Node.js](https://nodejs.org)

- Terminal enhancements:
	- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
	- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
	- [fish](https://fishshell.com/)
	- [Oh My Posh](https://ohmyposh.dev/) for Zsh & Fish

- Git enhancements:
	- [git-quick-stats](https://github.com/arzzen/git-quick-stats) a simple and efficient way to access various statistics in a git repository

## Environment variables

The following are environment variables for customization.

```bash
# ENV Defaults fpr APACHE
ENV APACHE_SERVER_NAME="localhost"
ENV APACHE_DOCUMENT_ROOT "docroot"
ENV WORKSPACE_ROOT "/var/www/html"
ENV WR # Alias for WORKSPACE_ROOT
# Default theme
ENV POSH_THEME_ENVIRONMENT "ys"
```

## CI Build & Tagging

The process is automated using `GitHub Actions` workflow with two scripts:

- `build.sh`: Builds the image based on PHP, Node, Sass version with the following arguments:
	- `-p`: PHP version or (`7` & `8`).
	- `-n`: Node.js version, `node` for latest, `--lts` for lts version.

- `test.sh`: to load the latest local build image.

The workflow is set on schedule and triggered on push to the main branch. It also can be triggered manually from GitHub.

## References

- Docker Repo https://hub.docker.com/r/alchatti/drupal-devcontainer
- Image issues, details, source https://github.com/alchatti/drupal-devcontainer-image

## Change logs

### January 2024

- feat: base image updated to Debian 12 (Bookworm).
- feat: `fish` now uses repository for installation.
- feat: github/actions updated as follows:
 	- actions/checkout@v`2`->`3`
 	- docker/setup-qemu-action@v`2`->`3`
 	- docker/setup-buildx-action@v`2.0.0`->`3`
 	- docker/build-push-action@v`3`->`5`

### December 2023

- feat: `git-quick-stats` added to the image.
- feat: `fish` updated to  `3.6.4-1`.
- feat: `about` script to prints base image OS version.
- feat: retired `7.4` PHP version.

### January 2023

- feat: PHP 8.1 support and deprecated PHP 8.0
- feat: Apple Silicon `arm64` support for both PHP 8.1 and 7.4
- feat: Drupal 10 support and updated the installation script.
- feat: removed Drupal Console as it is deprecated.
- feat: GitHub action workflow update to support multiple architecture, tag and push the image.
- fix: `fish` with `nvm`.
