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
	- [X] [Acquia BLT launcer](https://github.com/acquia/blt-launcher/)

- Front-End development
	- [X] [Node.js](https://nodejs.org)
	- [X] [Dart Sass](https://github.com/sass/dart-sass)

- Terminal enhancements:
	- [Oh My Posh](https://ohmyposh.dev/) for Zsh
	- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
	- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

The image is targeting the latest 7 & 8 versions of PHP with latest NodeJs/lts version.

## Usage

> This section is work in progress stay tune.

### PHP 8

```bash
# Latest PHP 8 & NodeJs
docker pull alchatti/drupal-devcontainer:8
# PHP 8.1 & lastest NodeJs
docker pull alchatti/drupal-devcontainer:8.1
```

```bash
# Latest PHP 8 & NodeJs LTS
docker pull alchatti/drupal-devcontainer:8-nLTS
# PHP 8.1 & lastest NodeJs LTS
docker pull alchatti/drupal-devcontainer:8.1-nLTS
```
### PHP 7

```bash
# Latest PHP 7 & NodeJs
docker pull alchatti/drupal-devcontainer:7
# PHP 7.4 & lastest NodeJs
docker pull alchatti/drupal-devcontainer:7.4
```

```bash
# Latest PHP 7 & NodeJs LTS
docker pull alchatti/drupal-devcontainer:7-nLTS
# PHP 7.4 & lastest NodeJs LTS
docker pull alchatti/drupal-devcontainer:7.4-nLTS
```

### Tag definition

To target a specific version build the tag is configured as follow `$php-n$nodeJs-s$sass-c$composer-$npm`

Example

- `8`: PHP 8 with latest NodeJs, Sass and Composer at build.
- `8-n18`: PHP 8 with latest NodeJs 18 and latest Sass and Composer at build.
- `8-n18-s1.51.0`: PHP 8 with latest NodeJs 18, Sass 1.51.0 and latest Composer at build.
- `8.1.4-n18.2.0-s1.51.0-c2.3.4-npm8.9.0`: PHP 8.1.4 with NodeJs 18.2.0, Sass 1.51.0, Composer 2.3.4 and npm 8.9.0 at build.

# Reference

- Docker Repo https://hub.docker.com/r/alchatti/drupal-devcontainer
- Image issues, details, source https://github.com/alchatti/drupal-devcontainer-image
