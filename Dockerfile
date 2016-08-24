FROM php:7.0-fpm
ENV APT_LISTCHANGES_FRONTEND mail
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y -o DPkg::options::='--force-confdef' -o Dpkg::Options::='--force-confold' \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
	imagemagick \
	libgraphicsmagick1-dev \
	libmagickwand-dev \
	libcurl3 \
	curl \
	libcurl4-gnutls-dev \
	libicu-dev \
	libc-client2007e-dev \
	libc-client2007e \
	libkrb5-dev \
	libmysqlclient-dev \
	libzip-dev \
	git \
    && apt-get clean \
    && apt-get autoremove -y \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip iconv mcrypt intl curl \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) gd imap \
    && rm -rf /var/lib/apt/lists/* \
    && curl --output composer -Ss https://getcomposer.org/download/1.2.0/composer.phar \
    && mv composer /usr/bin/composer \
    && chmod 755 /usr/bin/composer \
    && chown root:root /usr/bin/composer
