FROM php:8.4-fpm
ENV APT_LISTCHANGES_FRONTEND mail
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_OPENSSL yes
ADD ./aciety.ini /usr/local/etc/php/conf.d/zz-aciety.ini
ADD fonts/Roboto /usr/share/fonts/truetype/Roboto
RUN apt-get update -qq \
  && apt-get dist-upgrade -y \
  && apt-get install -y --fix-missing \
    build-essential \
    chromium \
    curl \
    ffmpeg \
    git \
    libcurl4 \
    libcurl4-gnutls-dev \
    libexif-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libkrb5-dev \
    libmagickwand-dev \
    libmariadbclient-dev-compat \
    libnss3 \
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
    libuv1 \
    libuv1-dev \
    autoconf \
  && git clone https://github.com/Imagick/imagick.git --depth 1 /tmp/imagick \
  && cd /tmp/imagick \
  && git fetch origin master \
  && git switch master \
  && cd /tmp/imagick \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && git clone https://github.com/amphp/ext-uv.git /tmp/php-uv \
  && cd /tmp/php-uv \
  && phpize \
  && ./configure \
  && wget https://ftp.uni-stuttgart.de/pub/unix/mail/imap/c-client.tar.gz \
  && tar xzf c-client.tar.gz \
  && cd imap-2007f \
  && make lnp SSLTYPE=unix.nopwd EXTRACFLAGS=-fPIC \
  && mkdir -p /usr/local/include/imap \
  && cp c-client/*.h /usr/local/include/imap \
  && cp c-client/c-client.a /usr/local/lib/libc-client.a \
  && make -j$(nproc) \
  && make install \
  && apt-get dist-upgrade -y \
  && apt-get clean \
  && apt-get autoremove -y \
  && docker-php-ext-install -j$(nproc) pdo_mysql zip iconv intl bcmath curl exif opcache bz2 \
  && pecl install APCu redis uuid imap \
  && docker-php-ext-enable apcu bcmath redis sodium uuid imagick imap uv \
  && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype --with-avif \
  && docker-php-ext-configure pcntl --enable-pcntl \
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install -j$(nproc) gd sockets pcntl \
  && curl --output composer -Ss https://getcomposer.org/download/2.8.3/composer.phar \
  && mv composer /usr/bin/composer \
  && chmod 755 /usr/bin/composer \
  && chown root:root /usr/bin/composer \
  && curl -LO https://github.com/deployphp/deployer/releases/download/v7.5.8/deployer.phar \
  && mv deployer.phar /usr/bin/dep \
  && chmod +x /usr/bin/dep \
  && groupadd -g 1001 supervisor \
  && useradd -m -g 1001 -u 1001 supervisor \
  && fc-cache
