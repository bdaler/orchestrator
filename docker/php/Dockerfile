FROM php:8.4-fpm AS base

ARG USER_UID=1000
ARG GROUP_GID=1000
ARG UGNAME=app

# --------------------
# User
# --------------------
RUN if getent passwd ${USER_UID} >/dev/null; then \
        deluser $(getent passwd ${USER_UID} | cut -d: -f1); \
    fi \
 && if getent group ${GROUP_GID} >/dev/null; then \
        delgroup $(getent group ${GROUP_GID} | cut -d: -f1); \
    fi \
 && addgroup --system --gid ${GROUP_GID} ${UGNAME} \
 && adduser  --system --disabled-password \
             --home /home/${UGNAME} \
             --uid ${USER_UID} \
             --ingroup ${UGNAME} \
             ${UGNAME}

# --------------------
# System deps
# --------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    git \
    zip unzip \
    netcat-openbsd \
    libpq-dev \
    librdkafka-dev \
    librabbitmq-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgmp-dev \
    libicu-dev \
    libzip-dev \
    libbz2-dev \
    libxml2-dev \
 && rm -rf /var/lib/apt/lists/*

# --------------------
# Composer
# --------------------
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

# --------------------
# PECL extensions
# --------------------
RUN pecl install rdkafka amqp \
 && docker-php-ext-enable rdkafka amqp

# --------------------
# Core PHP extensions
# --------------------
RUN docker-php-ext-install \
        zip \
        bz2 \
        soap \
        simplexml \
        dom \
        pcntl \
        sockets \
        bcmath \
        gettext \
        intl \
        gmp \
        pdo \
        pdo_pgsql \
        pgsql

# --------------------
# GD
# --------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd

# --------------------
# PHP config (убираем deprecated-шум)
# --------------------
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED" \
    > /usr/local/etc/php/conf.d/99-no-deprecated.ini

# --------------------
# wait-for-it
# --------------------
COPY ./wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

WORKDIR /var/www

# =========================================================
# DEV
# =========================================================
FROM base AS dev

RUN pecl install xdebug \
 && docker-php-ext-enable xdebug \
 && echo "xdebug.mode=debug,develop,profile" \
        > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.output_dir=/var/www/tmp/profiles" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && touch /tmp/xdebug.log \
 && chmod 777 /tmp/xdebug.log

USER app
