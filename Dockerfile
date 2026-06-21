# Drupal Development Container
# Based on:
# https://github.com/docker-library/drupal
# Uses mcr.microsoft.com/vscode/devcontainers/php as base image
# Tags:
# https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list
# Debian releases:
# https://wiki.debian.org/DebianReleases#Production_Releases

ARG VARIANT
ARG OS=bookworm

FROM mcr.microsoft.com/vscode/devcontainers/php:${VARIANT}-${OS}

ARG VARIANT
ARG OS=bookworm
ARG CREATE_DATE
ARG NODE_VERSION=node
ARG TARGETARCH

LABEL org.opencontainers.image.title="Drupal Devcontainer Image with Node"
LABEL org.opencontainers.image.description="Drupal development image with PHP ${VARIANT}, Xdebug, Composer and Node.js"
LABEL org.opencontainers.image.authors="Majed Al-Chatti"
LABEL org.opencontainers.image.source="https://github.com/alchatti/drupal-devcontainer-image"
LABEL org.opencontainers.image.documentation="https://github.com/alchatti/drupal-devcontainer-image"
LABEL org.opencontainers.image.base.name="mcr.microsoft.com/vscode/devcontainers/php:${VARIANT}-${OS}"
LABEL org.opencontainers.image.ref.name="ghcr.io/alchatti/drupal-devcontainer:${VARIANT}-${OS}"
LABEL org.opencontainers.image.created="${CREATE_DATE}"

# Apache defaults
ENV APACHE_SERVER_NAME="localhost" \
    APACHE_DOCUMENT_ROOT="docroot" \
    WORKSPACE_ROOT="/var/www/html" \
    POSH_THEME_ENVIRONMENT="ys" \
    W="/var/www/html" \
    D="/var/www/html/docroot"

# Prefer project Composer binaries first, then legacy image binaries.
# This makes /var/www/html/vendor/bin/drush win when available,
# and falls back to /opt/drush-legacy/drush when not available.
ENV PATH="/var/www/html/vendor/bin:/opt/drush-legacy:${PATH}"

RUN set -eux; \
    echo "${CREATE_DATE}" > /var/.buildInfo

# Shared installer scripts from docker-drupal - uses dev branch make sure to update
RUN set -eux; \
    curl -fsSL -o /usr/local/bin/install-php-dependencies \
      https://raw.githubusercontent.com/alchatti/docker-drupal/refs/heads/dev/scripts/install-php-dependencies.sh; \
    curl -fsSL -o /usr/local/bin/install-runtimes \
      https://raw.githubusercontent.com/alchatti/docker-drupal/refs/heads/dev/scripts/install-runtimes.sh; \
    chmod +x \
      /usr/local/bin/install-php-dependencies \
      /usr/local/bin/install-runtimes

# Base packages, repositories, Apache, and Drupal filesystem
RUN set -eux; \
    # Fish
    echo 'deb [signed-by=/etc/apt/keyrings/fish.gpg] http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_12/ /' > /etc/apt/sources.list.d/fish.list; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_12/Release.key \
      | gpg --dearmor > /etc/apt/keyrings/fish.gpg; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      gnup \
      curl \
      ca-certificate \
      gettext-base \
      libpcre2-32-0 \
      build-essential \
      git-quick-stats \
      fish \
    a2enmod rewrite expire alias; \
    sed -ri -e 's!/var/www/html!${WORKSPACE_ROOT}/${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf; \
    echo "ServerName ${APACHE_SERVER_NAME}" >> /etc/apache2/apache2.conf; \
    echo "PassEnv APACHE_DOCUMENT_ROOT" >> /etc/apache2/apache2.conf; \
    echo "PassEnv WORKSPACE_ROOT" >> /etc/apache2/apache2.conf; \
    mkdir -p /mnt/files/{public,private,config}; \
    chown -R www-data:www-data /mnt/files; \
    chmod -R 775 /mnt/files; \
    install-php-dependencies.sh; \
    install-runtimes.sh --db

# PHP development settings
COPY ./php.ini /usr/local/etc/php/conf.d/x-docker-dev-php.ini

# Helper scripts
COPY --chmod=+x ./scripts /usr/local/bin

RUN set -eux; \
    ln -sf /usr/local/bin/php /usr/bin/php

# Legacy Drush fallback.
# Project Drush from /var/www/html/vendor/bin/drush takes precedence through PATH.
RUN set -eux; \
    mkdir -p /opt/drush-legacy; \
    curl -fsSL -o /opt/drush-legacy/drush https://github.com/drush-ops/drush/releases/download/8.4.12/drush.phar; \
    chmod +rx /opt/drush-legacy/drush

# Acquia CLI and BLT launcher
RUN set -eux; \
    curl -fsSL -o /usr/local/bin/acli https://github.com/acquia/cli/releases/latest/download/acli.phar; \
    chmod +rx /usr/local/bin/acli

# Oh My Posh
RUN set -eux; \
    curl -fsSL -o /usr/local/bin/oh-my-posh https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${TARGETARCH}; \
    chmod +x /usr/local/bin/oh-my-posh; \
    curl -fsSL -o /opt/themes.zip https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip; \
    unzip /opt/themes.zip -d /opt/.poshthemes; \
    rm /opt/themes.zip; \
    chmod o+r /opt/.poshthemes/*.json

# Copy shell config
COPY ./config /home/vscode/.config/

RUN set -eux; \
    chown -R vscode:vscode /home/vscode/.config

USER vscode

# Shell configuration
RUN set -eux; \
    echo "$(oh-my-posh init zsh)" >> ~/.zshrc; \
    echo "exec \$SHELL -l" >> ~/.bashrc; \
    mkdir -p ~/.acquia ~/.drush

# Placeholder Drupal document root
RUN set -eux; \
    mkdir -p "${WORKSPACE_ROOT}/${APACHE_DOCUMENT_ROOT}"; \
    echo '<?php phpinfo();' > "${WORKSPACE_ROOT}/${APACHE_DOCUMENT_ROOT}/index.php"

# Drupal Coder and PHPCS requirements
RUN set -eux; \
    composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true; \
    composer global require drupal/coder; \
    COMPOSER_HOME="$(composer global config home --absolute)"; \
    "${COMPOSER_HOME}/vendor/bin/phpcs" --config-set installed_paths "${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer"; \
    sudo ln -sf "${COMPOSER_HOME}/vendor/bin/phpcs" /usr/local/bin/phpcs; \
    sudo ln -sf "${COMPOSER_HOME}/vendor/bin/phpcbf" /usr/local/bin/phpcbf

USER root

# Optional Node.js installation through nvm from the devcontainer base image
RUN set -eux; \
    if [ "${NODE_VERSION}" != "none" ] && [ -n "${NODE_VERSION}" ]; then \
      su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} && npm install -g npm@latest"; \
    fi

USER vscode
