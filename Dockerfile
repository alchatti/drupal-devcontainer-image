# Based on https://github.com/docker-library/drupal/blob/master/9.2/php8.0/apache-bullseye/Dockerfile file
# Uses mcr.microsoft.com/vscode/devcontainers/php as base image
# For list of tags vsist https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list

ARG VARIANT

FROM mcr.microsoft.com/vscode/devcontainers/php:0-${VARIANT}

ARG VARIANT
ARG CREATE_DATE
ARG DRUPAL_CODER_VERSION
ARG NODE_VERSION
ARG DART_SASS_VERSION

LABEL org.opencontainers.image.title="Drupal Devcontainer Image"
LABEL org.opencontainers.image.description="Drupal development image with PHP $VARIANT, Xdebug, Composer, NodeJS, and Dart Sass"
LABEL org.opencontainers.image.authors="Majed Al-Chatti"
LABEL org.opencontainers.image.source="https://github.com/alchatti/drupal-devcontainer-image"
LABEL org.opencontainers.image.documentation="https://github.com/alchatti/drupal-devcontainer-image"
LABEL org.opencontainers.image.base.name="ghcr.io/alchatti/drupal-devcontainer"
LABEL org.opencontainers.image.ref.name="ghcr.io/alchatti/drupal-devcontainer:$VARIANT"
LABEL org.opencontainers.image.created=$CREATE_DATE

# ENV Defaults fpr APACHE
ENV APACHE_SERVER_NAME="localhost"
ENV APACHE_DOCUMENT_ROOT "docroot"
ENV WORKSPACE_ROOT "/var/www/html"
# Default theme
ENV POSH_THEME_ENVIRONMENT "ys"


# Apache Configurations
RUN sed -ri -e 's!/var/www/html!${WORKSPACE_ROOT}/${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN echo "ServerName ${APACHE_SERVER_NAME}" >> /etc/apache2/apache2.conf

# Drupal filesystem
RUN mkdir /mnt/files
RUN chown vscode:vscode /mnt/files

# PHP Development settings overwrite
COPY ./php.ini /usr/local/etc/php/conf.d/z-docker-dev-php.ini

# Init Script
COPY ./scripts/init.sh /usr/local/bin/
COPY ./scripts/about.sh /usr/local/bin/
COPY ./scripts/dump.sh /usr/local/bin/dump
COPY ./scripts/drestore.sh /usr/local/bin/drestore
COPY ./scripts/acli-dump.sh /usr/local/bin/acli-dump

RUN chmod +x /usr/local/bin/init.sh && \
  chmod +x /usr/local/bin/about.sh && \
  chmod +x /usr/local/bin/dump && \
  chmod +x /usr/local/bin/drestore && \
  chmod +x /usr/local/bin/acli-dump

# Drush Launcher global drush as fallback
ENV DRUSH_LAUNCHER_FALLBACK /opt/drush
# Add Drush Launcher for Global and local Drush
ADD https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar /usr/bin/drush
RUN chmod +rx /usr/bin/drush

# Install Drush 8.* globally for D6, D7, D8.3-
# for D8.4+ use Drupal Composer site project with Drush listed as a dependency
ADD https://github.com/drush-ops/drush/releases/download/8.4.8/drush.phar /opt/drush
RUN chmod +rx /opt/drush

# Add Acquia Cli
ADD https://github.com/acquia/cli/releases/latest/download/acli.phar /usr/local/bin/acli
RUN chmod +rx /usr/local/bin/acli

# Acquia BLT Launcher
ADD https://github.com/acquia/blt-launcher/releases/latest/download/blt.phar /usr/local/bin/blt
RUN chmod +rx /usr/local/bin/blt

# Oh My Posh
ADD https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 /usr/local/bin/oh-my-posh
ADD https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip /opt/themes.zip

RUN chmod +x /usr/local/bin/oh-my-posh && \
  unzip /opt/themes.zip -d /opt/.poshthemes && \
  rm /opt/themes.zip && \
  chmod o+r /opt/.poshthemes/*.json

#Zsh Plugins
ADD https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.zip /tmp/zsh-autosuggestions.zip
RUN unzip /tmp/zsh-autosuggestions.zip -d  /tmp/zsh-autosuggestions \
  && mv /tmp/zsh-autosuggestions/zsh-autosuggestions-master /home/vscode/.oh-my-zsh/plugins/zsh-autosuggestions \
  && chown vscode:vscode /home/vscode/.oh-my-zsh/plugins/zsh-autosuggestions

ADD https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.zip /tmp/zsh-syntax-highlighting.zip
RUN unzip /tmp/zsh-syntax-highlighting.zip -d  /tmp/zsh-syntax-highlighting \
  && mv /tmp/zsh-syntax-highlighting/zsh-syntax-highlighting-master /home/vscode/.oh-my-zsh/plugins/zsh-syntax-highlighting \
  && chown vscode:vscode /home/vscode/.oh-my-zsh/plugins/zsh-syntax-highlighting

USER vscode

RUN mkdir ~/.pnpm-store && mkdir ~/.acquia && \
  mkdir $WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT && \
  echo '<?php phpinfo();' >> $WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT/index.php

RUN echo "$(oh-my-posh init zsh)" >> ~/.zshrc && \
  sed -ri -e 's!export POSH_THEME=.*!export POSH_THEME="/opt/.poshthemes/$POSH_THEME_ENVIRONMENT.omp.json"!g' ~/.zshrc && \
  echo "exec \$SHELL -l"  >> ~/.bashrc

RUN sed -ri -e 's!plugins=.*!plugins=(git zsh-autosuggestions zsh-syntax-highlighting)!g' ~/.zshrc

# Start Apache on Zsh shell startup
RUN echo "apache2ctl start" >> ~/.zshrc

# Drupal Coder and phpcs Requirements
RUN composer global require drupal/coder ${DRUPAL_CODER_VERSION}
RUN ~/.composer/vendor/bin/phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer
RUN sudo ln -s ~/.composer/vendor/bin/phpcs /usr/local/bin/phpcs && \
  sudo ln -s ~/.composer/vendor/bin/phpcbf /usr/local/bin/phpcbf

USER root

# DART SASS
ADD https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz /tmp/dart-sass.tar.gz
RUN tar -C /opt/ -xzvf /tmp/dart-sass.tar.gz && \
  ln -s /opt/dart-sass/sass /usr/local/bin/sass

# Based on https://github.com/docker-library/drupal/blob/master/9.2/php8.0/apache-buster/Dockerfile
# install the PHP extensions we need
RUN set -eux; \
  \
  if command -v a2enmod; then \
  a2enmod rewrite; \
  fi; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt update; \
  apt install -y --no-install-recommends \
  libfreetype6-dev \
  libjpeg-dev \
  libpng-dev \
  libpq-dev \
  libzip-dev \
  default-mysql-client \
  ; \
  \
  docker-php-ext-configure gd \
  --with-freetype \
  --with-jpeg=/usr \
  ; \
  \
  docker-php-ext-install -j "$(nproc)" \
  gd \
  opcache \
  pdo_mysql \
  pdo_pgsql \
  zip \
  ; \
  \
  # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark; \
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
  | awk '/=>/ { print $3 }' \
  | sort -u \
  | xargs -r dpkg-query -S \
  | cut -d: -f1 \
  | sort -u \
  | xargs -rt apt-mark manual; \
  \
  apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*
#END



# Node.js node, --lts, --lts-latest
RUN if [ "${NODE_VERSION}" != "none" ] &&  [ "${NODE_VERSION}" != "" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1 && npm -g i pnpm"; fi

RUN rm -r /tmp/*
