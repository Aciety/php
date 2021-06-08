FROM php:8.0-fpm
ENV APT_LISTCHANGES_FRONTEND mail
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_OPENSSL yes
ADD ./aciety.ini /usr/local/etc/php/conf.d/aciety.ini
RUN apt-get update && apt-get install -y -o DPkg::options::='--force-confdef' -o Dpkg::Options::='--force-confold' \
	curl \
	git \
	libc-client2007e \
	libc-client2007e-dev \
	libcurl4 \
	libcurl4-gnutls-dev \
	libexif-dev \
	libicu-dev \
	libkrb5-dev \
	libmariadbclient-dev-compat \
	libzip-dev \
        libfreetype6-dev \
        libjpeg-dev \
	libwebp-dev \
        librabbitmq-dev \
        libsasl2-dev \
        libssl-dev \
        libssl1.0 \
        mariadb-client \
        unzip \
        zip \
    && apt-get clean \
    && apt-get autoremove -y \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip iconv intl bcmath curl exif opcache \
    && pecl install APCu redis \
    && docker-php-ext-enable apcu bcmath redis sodium \
    && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) gd imap sockets \
    && curl --output composer -Ss https://getcomposer.org/download/2.1.2/composer.phar \
    && mv composer /usr/bin/composer \
    && chmod 755 /usr/bin/composer \
    && chown root:root /usr/bin/composer \
    && groupadd -g 1001 supervisor \
    && useradd -m -g 1001 -u 1001 supervisor
