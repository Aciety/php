FROM php:8.1-fpm
ENV APT_LISTCHANGES_FRONTEND mail
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_OPENSSL yes
ADD ./aciety.ini /usr/local/etc/php/conf.d/zz-aciety.ini
RUN apt-get update -qq \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    chromium \
    curl \
    ffmpeg \
    git \
    libc-client2007e \
    libc-client2007e-dev \
    libcurl4 \
    libcurl4-gnutls-dev \
    libexif-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libkrb5-dev \
    libmariadbclient-dev-compat \
    libnss3 \
    librabbitmq-dev \
    libsasl2-dev \
    libssl-dev \
    libssl1.0 \
    libwebp-dev \
    libzip-dev \
    libavif-dev \
    poppler-utils \
    mariadb-client \
    unzip \
    uuid-dev \
    wget \
    zip \
  && apt-get dist-upgrade -y \
  && apt-get clean \
  && apt-get autoremove -y \
  && docker-php-ext-install -j$(nproc) pdo_mysql zip iconv intl bcmath curl exif opcache \
  && pecl install APCu redis pcov uuid \
  && docker-php-ext-enable apcu bcmath redis sodium pcov uuid \
  && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype --with-avif \
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install -j$(nproc) gd imap sockets \
  && curl --output composer -Ss https://getcomposer.org/download/2.4.1/composer.phar \
  && mv composer /usr/bin/composer \
  && chmod 755 /usr/bin/composer \
  && chown root:root /usr/bin/composer \
  && curl -LO https://github.com/deployphp/deployer/releases/download/v7.0.0/deployer.phar \
  && mv deployer.phar /usr/bin/dep \
  && chmod +x /usr/bin/dep \
  && groupadd -g 1001 supervisor \
  && useradd -m -g 1001 -u 1001 supervisor
