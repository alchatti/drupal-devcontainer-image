# Development Container for Drupal

Drupal development container based on [Microsoft PHP devcontainer image](https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list).

The base image comes with Zsh, [Apache](https://httpd.apache.org/), [Xdebug](https://xdebug.org/), [Composer](https://getcomposer.org/).

This image adds the following:

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

The image is targeting the latest 7 & 8 versions of PHP with latest NodeJs/lts version.

## Usage

> This section is work in progress.

Dev feature are set for the container user `vscode` which is a none root user provided by the base image.

To access the container `zsh` shell in interactive mode as `vscode`.

> Apache server will start as part of the zsh startup script using command `apache2ctl start`

- Latest PHP 8 & NodeJs with hostname `drupal-devcontainer`

```bash
docker run -h "drupal-devcontainer" -u "vscode" -it --rm -p 80:80 docker.io/alchatti/drupal-devcontainer:8 zsh
```

- Example of usage with a 'blue-owl' by overriding environment variable `POSH_THEME_ENVIRONMENT`, for more theme options check [Oh My Posh theme](https://ohmyposh.dev/docs/themes).

```bash
docker run -u "vscode" -e POSH_THEME_ENVIRONMENT='blue-owl' -it --rm -p 80:80 docker.io/alchatti/drupal-devcontainer:8 zsh
```

Note: `--rm` flag deletes the created container on exit.

### Tag definition

To target a specific version build the tag is configured as follow `$php-n$nodeJs-s$sass-c$composer-$npm`

Example

- `8`: PHP 8 with latest NodeJs, Sass and Composer at build.
- `8-n18`: PHP 8 with latest NodeJs 18 and latest Sass and Composer at build.
- `8-n16LTS`: PHP 8 with NodeJs LTS 16 and latest Sass and Composer at build.
- `8.1.4-n18.2.0-s1.51.0-c2.3.4-npm8.9.0`: PHP 8.1.4 with NodeJs 18.2.0, Sass 1.51.0, Composer 2.3.4 and npm 8.9.0 at build.

Replace `8` with `7` to target PHP 7, you can also use `8.1` or `7.4`.

# Reference

- Docker Repo https://hub.docker.com/r/alchatti/drupal-devcontainer
- Image issues, details, source https://github.com/alchatti/drupal-devcontainer-image
