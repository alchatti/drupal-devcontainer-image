# Based on https://github.com/docker-library/drupal/blob/master/9.2/php8.0/apache-bullseye/Dockerfile file
# Uses mcr.microsoft.com/vscode/devcontainers/php as base image
# For list of tags vsist https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list
# Relesases code names at https://wiki.debian.org/DebianReleases#Production_Releases

ARG PHP
ARG DEBIAN

FROM mcr.microsoft.com/vscode/devcontainers/php:${PHP}-${DEBIAN}

ARG PHP
ARG CREATE_DATE
ARG NODE_VERSION
ARG TARGETARCH

LABEL org.opencontainers.image.title="Drupal Devcontainer Image with Node" \
  org.opencontainers.image.description="Drupal development image with PHP $PHP, Xdebug, Composer and Node.js" \
  org.opencontainers.image.authors="Majed Al-Chatti" \
  org.opencontainers.image.source="https://github.com/alchatti/drupal-devcontainer-image" \
  org.opencontainers.image.documentation="https://github.com/alchatti/drupal-devcontainer-image" \
  org.opencontainers.image.base.name="ghcr.io/alchatti/drupal-devcontainer" \
  org.opencontainers.image.ref.name="ghcr.io/alchatti/drupal-devcontainer:$PHP" \
  org.opencontainers.image.created=$CREATE_DATE

# ENV Defaults fpr APACHE
ENV APACHE_SERVER_NAME="localhost"
ENV APACHE_DOCUMENT_ROOT="docroot"
ENV WORKSPACE_ROOT="/var/www/html"
# ENV Default theme for Oh My Posh
ENV POSH_THEME_ENVIRONMENT="ys"
# Shortcut to make development easier
ENV W="$WORKSPACE_ROOT"
ENV D="$WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT"
# Set PHP to scan the per-user conf.d first (so runtime values override global)
ENV PHP_INI_SCAN_DIR=/home/vscode/.php/conf.d:/usr/local/etc/php/conf.d

USER root

# PHP Development settings overwrite
COPY ./php.ini /usr/local/etc/php/conf.d/x-docker-dev-php.ini
RUN set -eux; \
  cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
  # # Build Info && Apache Configurations
  && echo "${CREATE_DATE}" >> /var/.buildInfo \
  && echo "ServerName ${APACHE_SERVER_NAME}" >> /etc/apache2/apache2.conf \
  # Drupal filesystem
  && mkdir /mnt/files \
  && chown -R www-data:www-data /mnt/files \
  && chmod -R 775 /mnt/files \
  && mkdir -p /home/vscode/.php/conf.d && chown -R vscode:vscode /home/vscode/.php \
  && rm -f /etc/apache2/sites-enabled/000-default.conf \
  && cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf \
  && chown www-data:www-data /etc/apache2/sites-enabled/000-default.conf \
  && chmod g+w /etc/apache2/sites-enabled/000-default.conf


RUN set -eux; \
  # Install dependencies
  apt-get update && apt-get install -y --no-install-recommends \
  # GD/Image dependencies
  libfreetype6-dev \
  libjpeg-dev \
  libpng-dev \
  libwebp-dev \
  # Other PHP extension dependencies
  libpq-dev \
  libzip-dev \
  zlib1g-dev \
  libpcre2-32-0 \
  libicu-dev \
  libxml2-dev \
  libmagickwand-dev \
  pkg-config \
  libssl-dev \
  # Utilities
  gettext-base \
  default-mysql-client \
  redis-tools \
  git-quick-stats \
  fish \
  && \
  # Configure PHP Extensions
  docker-php-ext-configure gd \
  --with-freetype \
  --with-jpeg=/usr \
  --with-webp \
  && \
  # Install PHP Extensions
  docker-php-ext-install -j "$(nproc)" \
  gd \
  opcache \
  intl \
  zip \
  xml \
  pdo_mysql \
  pdo_pgsql \
  && \
  # Install PECL extensions
  pecl install redis imagick && \
  docker-php-ext-enable redis imagick && \
  # Clean up
  # savedAptMark="$(apt-mark showmanual)" && \
  # apt-mark auto ".*" > /dev/null && \
  # apt-mark manual "$savedAptMark" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable Apachae Mods
RUN a2enmod rewrite headers expires

# Init Script
COPY --chmod=+x ./scripts/ /usr/local/bin/

# EntryPoint Script
COPY --chmod=+x entrypoint.sh /usr/local/bin/entrypoint.sh

# Zsh Startup
RUN echo startup.sh >> /home/vscode/.zshrc

# Copy fish config
COPY --chown=vscode:vscode ./config /home/vscode/.config/


# ### TODO: Clean UP


# #Zsh Plugins
# ADD https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.zip /tmp/zsh-autosuggestions.zip
# RUN unzip /tmp/zsh-autosuggestions.zip -d  /tmp/zsh-autosuggestions \
#   && mv /tmp/zsh-autosuggestions/zsh-autosuggestions-master /home/vscode/.oh-my-zsh/plugins/zsh-autosuggestions \
#   && chown vscode:vscode /home/vscode/.oh-my-zsh/plugins/zsh-autosuggestions

# ADD https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.zip /tmp/zsh-syntax-highlighting.zip
# RUN unzip /tmp/zsh-syntax-highlighting.zip -d  /tmp/zsh-syntax-highlighting \
#   && mv /tmp/zsh-syntax-highlighting/zsh-syntax-highlighting-master /home/vscode/.oh-my-zsh/plugins/zsh-syntax-highlighting \
#   && chown vscode:vscode /home/vscode/.oh-my-zsh/plugins/zsh-syntax-highlighting

# Oh My Posh - Install and configure with best practices
RUN set -eux; \
  # Download oh-my-posh binary
  curl -fsSL "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${TARGETARCH}" \
  -o /usr/local/bin/oh-my-posh && \
  chmod +x /usr/local/bin/oh-my-posh && \
  # Download and extract themes
  curl -fsSL https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip \
  -o /tmp/oh-my-posh-themes.zip && \
  mkdir -p /opt/.poshthemes && \
  unzip /tmp/oh-my-posh-themes.zip -d /opt/.poshthemes && \
  # Set proper permissions for all users to read themes
  chmod -R o+r /opt/.poshthemes && \
  find /opt/.poshthemes -type d -exec chmod 755 {} \; && \
  # Clean up temporary files
  rm -rf /tmp/*




# USER vscode

# RUN echo "$(oh-my-posh init zsh)" >> ~/.zshrc && \
#   sed -ri -e 's!export POSH_THEME=.*!export POSH_THEME="/opt/.poshthemes/$POSH_THEME_ENVIRONMENT.omp.json"!g' ~/.zshrc && \
#   echo "exec \$SHELL -l"  >> ~/.bashrc

# RUN sed -ri -e 's!plugins=.*!plugins=(git zsh-autosuggestions zsh-syntax-highlighting)!g' ~/.zshrc

# RUN mkdir ~/.acquia
# RUN mkdir ~/.drush

RUN mkdir $WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT && \
  echo '<?php phpinfo();' >> $WORKSPACE_ROOT/$APACHE_DOCUMENT_ROOT/index.php

# USER root

# # Drush Launcher global drush as fallback
# ENV DRUSH_LAUNCHER_FALLBACK=/opt/drush
# # Add Drush Launcher for Global and local Drush
# ADD https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar /usr/bin/drush
# RUN chmod +rx /usr/bin/drush

# # Install Drush 8.* globally for D6, D7, D8.3-
# # for D8.4+ use Drupal Composer site project with Drush listed as a dependency
# ADD https://github.com/drush-ops/drush/releases/download/8.4.12/drush.phar /opt/drush
# RUN chmod +rx /opt/drush

# # Add Acquia Cli
# ADD https://github.com/acquia/cli/releases/latest/download/acli.phar /usr/local/bin/acli
# RUN chmod +rx /usr/local/bin/acli

# # Symfony CLI
# COPY --link \
#   --from=ghcr.io/symfony-cli/symfony-cli:latest \
#   /usr/local/bin/symfony /usr/local/bin/symfony




# # Drupal Coder and phpcs Requirements
# RUN composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
# RUN composer global require drupal/coder
# RUN ~/.composer/vendor/bin/phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer
# RUN sudo ln -s ~/.composer/vendor/bin/phpcs /usr/local/bin/phpcs && \
#   sudo ln -s ~/.composer/vendor/bin/phpcbf /usr/local/bin/phpcbf

####-------------

USER vscode

#RUN if [ "${NODE_VERSION}" != "none" ] &&  [ "${NODE_VERSION}" != "" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1 && npm install -g npm@latest"; fi

ENTRYPOINT ["entrypoint.sh"]
