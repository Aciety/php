FROM php:8.4-fpm

ENV APT_LISTCHANGES_FRONTEND mail
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_OPENSSL yes

ADD ./aciety.ini /usr/local/etc/php/conf.d/zz-aciety.ini
ADD fonts/Roboto /usr/share/fonts/truetype/Roboto

RUN apt-get update -qq \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    chromium \
    curl \
    ffmpeg \
    libcurl4 \
    libexif12 \
    libfreetype6 \
    libicu72 \
    libjpeg62-turbo \
    libmagickwand-7.q16-7 \
    libmariadb3 \
    libnss3 \
    libssl3 \
    libwebp7 \
    libzip4 \
    libavif15 \
    poppler-utils \
    mariadb-client \
    unzip \
    uuid-runtime \
    wget \
    zip \
    libuv1 \
    fontconfig \
  && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    autoconf \
    libcurl4-gnutls-dev \
    libexif-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libssl-dev \
    libwebp-dev \
    libzip-dev \
    libavif-dev \
    uuid-dev \
    libuv1-dev \
  && git clone https://github.com/Imagick/imagick.git --depth 1 /tmp/imagick \
  && cd /tmp/imagick \
  && git fetch origin master \
  && git switch master \
  && phpize \
  && ./configure \
  && make -j"$(nproc)" \
  && make install \
  && git clone https://github.com/amphp/ext-uv.git /tmp/php-uv \
  && cd /tmp/php-uv \
  && phpize \
  && ./configure \
  && make -j"$(nproc)" \
  && make install \
  && docker-php-ext-install -j"$(nproc)" pdo_mysql zip iconv intl bcmath curl exif opcache bz2 \
  && pecl install APCu redis uuid \
  && docker-php-ext-enable apcu bcmath redis sodium uuid imagick uv \
  && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype --with-avif \
  && docker-php-ext-configure pcntl --enable-pcntl \
  && docker-php-ext-install -j"$(nproc)" gd sockets pcntl \
  && curl --output composer -Ss https://getcomposer.org/download/2.8.10/composer.phar \
  && mv composer /usr/bin/composer \
  && chmod 755 /usr/bin/composer \
  && chown root:root /usr/bin/composer \
  && curl -LO https://github.com/deployphp/deployer/releases/download/v7.5.12/deployer.phar \
  && mv deployer.phar /usr/bin/dep \
  && chmod +x /usr/bin/dep \
  && groupadd -g 1001 supervisor \
  && useradd -m -g 1001 -u 1001 supervisor \
  && fc-cache \
  && apt-get purge -y --auto-remove \
    build-essential \
    git \
    autoconf \
    libcurl4-gnutls-dev \
    libexif-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libssl-dev \
    libwebp-dev \
    libzip-dev \
    libavif-dev \
    uuid-dev \
    libuv1-dev \
  && rm -rf /var/lib/apt/lists/* /tmp/*
