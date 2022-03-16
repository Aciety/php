FROM php:8.1-fpm
ENV APT_LISTCHANGES_FRONTEND mail
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_OPENSSL yes
ADD ./aciety.ini /usr/local/etc/php/conf.d/aciety.ini
RUN apt-get update && apt-get install -y -o DPkg::options::='--force-confdef' -o Dpkg::Options::='--force-confold' \
	curl \
        ffmpeg \
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
        libnss3 \
	libwebp-dev \
        librabbitmq-dev \
        libsasl2-dev \
        libssl-dev \
        libssl1.0 \
        mariadb-client \
        unzip \
        wget \
        wkhtmltopdf \
        zip \
    && wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get -f install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && apt-get autoremove -y \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip iconv intl bcmath curl exif opcache \
    && pecl install APCu redis \
    && docker-php-ext-enable apcu bcmath redis sodium \
    && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) gd imap sockets \
    && curl --output composer -Ss https://getcomposer.org/download/2.2.1/composer.phar \
    && mv composer /usr/bin/composer \
    && chmod 755 /usr/bin/composer \
    && chown root:root /usr/bin/composer \
    && curl -LO https://github.com/deployphp/deployer/releases/download/v7.0.0-rc.4/deployer.phar \
    && mv deployer.phar /usr/bin/dep \
    && chmod +x /usr/bin/dep \
    && groupadd -g 1001 supervisor \
    && useradd -m -g 1001 -u 1001 supervisor
