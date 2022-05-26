# Development Container for Drupal
<sub>Document Version: 2022MAY26</sub>

Drupal development container based on [Microsoft PHP devcontainer image](https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list).

The image is a base for a [devcontainer](https://code.visualstudio.com/docs/remote/containers) project which is currently _work in progress_ and it can used as a stand alone.

## Usage

> This section is work in progress.

Dev feature are set for the container user `vscode` which is a none root user provided by the base image.

To access the container `zsh` shell in interactive mode as `vscode`.

> Apache server will start as part of the zsh startup script using command `apache2ctl start`

### Quick new Drupal site for testing

Drupal can be installed with SQLite without the need for an additional database container.

1. Initialize the container in interactive mode as `vscode` user with hostname `drupal-dev` using `zsh` shell.

```bash
docker run -h "drupal-dev" -u "vscode" -it -p 80:80 alchatti/drupal-devcontainer:8 zsh
```
```bash
# Removes container on exit `--rm`
docker run -h "drupal-dev" -u "vscode" --rm -it -p 80:80 alchatti/drupal-devcontainer:8 zsh
```

2. Once shell is loaded confirm the initialization & php version by visiting http://localhost, this will display `phpinfo()` details.

3. To intiate Drupal 9 composer project, run `init.sh`, this script is based on [Acquia configuration](https://docs.acquia.com/cloud-platform/create/install/drupal9/).

```bash
# vscode @ drupal-devcontainer in /var/www/html
init.sh
```

4. Once the script finishes visit http://localhost, to start the Drupal setup and complete the steps.

5. To exit the container and stop the service, type

```bash
exit
```

### Additional usage options & flags

- Change the zsh theme to 'blue-owl' by using environment variable `POSH_THEME_ENVIRONMENT`, for more theme options check [Oh My Posh theme](https://ohmyposh.dev/docs/themes).

```bash
docker run -u "vscode" -e POSH_THEME_ENVIRONMENT='blue-owl' -it -p 80:80 alchatti/drupal-devcontainer:8 zsh
```

- Change Apache document root from `docroot` to `web` by using environment variable `APACHE_DOCUMENT_ROOT`. Check https://docs.docker.com/storage/bind-mounts/ for loading existing projects.

```bash
docker run -u "vscode" \
-e POSH_THEME_ENVIRONMENT='blue-owl' \
-e APACHE_DOCUMENT_ROOT='web' \
-it -p 80:80 alchatti/drupal-devcontainer:8 zsh
```

```bash
# mv the container docroot to web
mv docroot web
```

## Tags

To target a specific version build the tag is configured as follow `$php-n$nodeJs-s$sass-c$composer-$npm`

Example

- `8`: PHP 8 with latest Node.js, Sass and Composer at build.
- `8-n18`: PHP 8 with latest Node.js 18 and latest Sass and Composer at build.
- `8-n16LTS`: PHP 8 with Node.js LTS 16 and latest Sass and Composer at build.
- `8.1.4-n18.2.0-s1.51.0-c2.3.4-npm8.9.0`: PHP 8.1.4 with Node.js 18.2.0, Sass 1.51.0, Composer 2.3.4 and npm 8.9.0 at build.

Replace `8` with `7` to target PHP 7, you can also use `8.1` or `7.4`.

## Image

The image is targeting the latest 7 & 8 versions of PHP with latest Node.js/lts version.
### Scripts

```bash
# print image package versions/tags in json format
about | jq
# create a time stamped sql dump of the database using drush and store it under /var/www/html/dump
dump.sh
# restore an sql dump from file using drush
drestore.sh $file
# Download latest acquia cloud database backup using acli
acli-dump.sh
```

### Installed packages

The base image comes with Zsh, [Apache](https://httpd.apache.org/), [Xdebug](https://xdebug.org/), [Composer](https://getcomposer.org/).

With the following additional packages:

- Drupal dev tools
	- [X] [Drush launcher](https://github.com/drush-ops/drush-launcher).
	- [X] [Drush 8](https://www.drush.org/latest/) as global fallback and for Drupal 7.
	- [X] [Drupal Coder](https://www.drupal.org/project/coder)

- Acquia tools
	- [X] [Acquia CLI](https://docs.acquia.com/acquia-cli/)
	- [X] [Acquia BLT launcher](https://github.com/acquia/blt-launcher/)

- Front-End development
	- [X] [Node.js](https://nodejs.org)
	- [X] [Dart Sass](https://github.com/sass/dart-sass)

- Terminal enhancements:
	- [Oh My Posh](https://ohmyposh.dev/) for Zsh
	- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
	- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

### Environment variables

The following are environment variables for customization.

```bash
# Zsh theme
ENV POSH_THEME_ENVIRONMENT "ys"
# ENV Defaults fpr APACHE
ENV APACHE_SERVER_NAME="localhost"
ENV APACHE_DOCUMENT_ROOT "docroot"
ENV WORKSPACE_ROOT "/var/www/html"
```

# CI Build & Tagging

The process is automated using `GitHub Actions` workflow with two scripts:

- `build.sh`: Builds the image based on PHP, Node, Sass version with the following arguments:
	- `-p`: PHP version or (`7` & `8`) as default.
	- `-n`: Node.js version or (latest & lts) as defaults.
	- `-s`: Sass version or (latest) as default by checking api.github.com.

- `tag.sh`: tags or push the built images by executing `about.sh` in the targeted image container.
	- `tag.sh`: for tagging only, if branch is not main it will postfix the tag with `--branch-name`.
	- `tag.sh push`: for pushing the tagged image to the docker & github registry.

The workflow is set on schedule and triggered on push to the main branch. It also can be triggered manually from GitHub.

# Reference

- Docker Repo https://hub.docker.com/r/alchatti/drupal-devcontainer
- Image issues, details, source https://github.com/alchatti/drupal-devcontainer-image
