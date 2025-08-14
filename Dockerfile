FROM php:8.4-fpm

# Environment
ENV APT_LISTCHANGES_FRONTEND=mail
ENV DEBIAN_FRONTEND=noninteractive
ENV CFLAGS="-D_GNU_SOURCE"
ENV PHP_OPENSSL=yes

# PHP config
ADD ./aciety.ini /usr/local/etc/php/conf.d/zz-aciety.ini

# Fonts
ADD fonts/Roboto /usr/share/fonts/truetype/Roboto

# Install dependencies, build extensions, IMAP, composer, deployer, user, cleanup
RUN apt-get update -qq \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
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
      libpam0g-dev \
      libkrb5-dev \
      libmagickwand-dev \
      libmariadbclient-dev-compat \
      libnss3 \
      libsasl2-dev \
      libssl-dev \
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
      make \
      gcc \
  # Imagick
  && cd /tmp \
  && git clone https://github.com/Imagick/imagick.git --depth 1 /tmp/imagick \
  && cd /tmp/imagick \
  && phpize \
  && ./configure \
  && make -j$(nproc) \
  && make install \
  && cd /tmp && rm -rf /tmp/imagick \
  # ext-uv
  && git clone https://github.com/amphp/ext-uv.git /tmp/php-uv \
  && cd /tmp/php-uv \
  && phpize \
  && ./configure \
  && make -j$(nproc) \
  && make install \
  && cd /tmp && rm -rf /tmp/php-uv \
  # UW IMAP
  && git clone https://github.com/uw-imap/imap.git /tmp/imap \
  && cd /tmp/imap \
  && make distclean || true \
  # Patch to disable unencrypted auth (prevents cancel)
  && sed -i 's/#define NO_UNENCRYPTED_LOGIN 0/#define NO_UNENCRYPTED_LOGIN 1/' c-client/osdep.h || true \
  && make lnp SSLTYPE=unix EXTRACFLAGS="-fPIC -Dflock=flock" \
  && mkdir -p /usr/local/imap/include /usr/local/imap/lib \
  && cp c-client/*.h /usr/local/imap/include \
  && cp c-client/*.a /usr/local/imap/lib \
  && cd /tmp && rm -rf /tmp/imap \
  # PHP extensions
  && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype --with-avif \
  && docker-php-ext-configure pcntl --enable-pcntl \
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl=/usr/local/imap \
  && docker-php-ext-install -j$(nproc) pdo_mysql zip iconv intl bcmath curl exif opcache bz2 gd sockets pcntl imap \
  && pecl install APCu redis uuid \
  && docker-php-ext-enable apcu bcmath redis sodium uuid imagick uv imap \
  # Composer
  && curl -Ss -o /usr/bin/composer https://getcomposer.org/download/2.8.3/composer.phar \
  && chmod 755 /usr/bin/composer \
  && chown root:root /usr/bin/composer \
  # Deployer
  && curl -LO https://github.com/deployphp/deployer/releases/download/v7.5.8/deployer.phar \
  && mv deployer.phar /usr/bin/dep \
  && chmod +x /usr/bin/dep \
  # User
  && groupadd -g 1001 supervisor \
  && useradd -m -g 1001 -u 1001 supervisor \
  # Fonts
  && fc-cache -f -v \
  # Cleanup
  && apt-get clean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*
