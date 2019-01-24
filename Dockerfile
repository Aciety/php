FROM php:7.3-fpm
ENV APT_LISTCHANGES_FRONTEND mail
ENV DEBIAN_FRONTEND noninteractive
ADD ./aciety.ini /usr/local/etc/php/conf.d/aciety.ini
RUN apt-get update && apt-get install -y -o DPkg::options::='--force-confdef' -o Dpkg::Options::='--force-confold' \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
	imagemagick \
	libgraphicsmagick1-dev \
	libmagickwand-dev \
	libcurl3 \
	curl \
	libcurl4-gnutls-dev \
	libicu-dev \
        librabbitmq-dev \
	libc-client2007e-dev \
	libc-client2007e \
	libkrb5-dev \
	libmariadbclient-dev-compat \
	libzip-dev \
	libexif-dev \
        libsasl2-dev \
	git \
        optipng \
        jpegoptim \
        mysql-client \
    && apt-get clean \
    && apt-get autoremove -y \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip iconv intl bcmath curl exif opcache \
    && pecl install imagick APCu amqp redis \
    && docker-php-ext-enable imagick apcu amqp bcmath redis \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) gd imap \
    && rm -rf /var/lib/apt/lists/* \
    && curl --output composer -Ss https://getcomposer.org/download/1.8.0/composer.phar \
    && mv composer /usr/bin/composer \
    && chmod 755 /usr/bin/composer \
    && chown root:root /usr/bin/composer \
    && curl --output wp -Ss https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod 755 wp \
    && mv wp /usr/local/bin/wp \
    && groupadd -g 1001 supervisor \
    && useradd -m -g 1001 -u 1001 supervisor
