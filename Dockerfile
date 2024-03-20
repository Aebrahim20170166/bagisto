FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www

# Copy composer.lock and composer.json
COPY composer.json /var/www/
RUN if [-f $composer.lock ]; then \
    cp $composer.lock /var/www/; \
    fi
# Remove cache
RUN rm -rf /var/www/apk*
RUN rm -rf /tmp/*

RUN apk update && apk add \
    git \
    curl \
    zip \
    unzip \
    build-base \
    libzip-dev \
    zlib-dev \
    icu-dev \
    oniguruma-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    openssl-dev \
    supervisor \
    && rm -rf /var/cache/apk/*

# Install and configure php extensions
RUN docker-php-ext-install pdo pdo_mysql mysqli zip pcntl intl calendar \
    && docker-php-ext-install -j$(nproc) mbstring

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

RUN docker-php-ext-configure exif
RUN docker-php-ext-install exif
RUN docker-php-ext-enable exif
#install OPcache extension to improve performance by caching compiled php code in memory
RUN docker-php-ext-install opcache

#install pcre-dev package (which includes dev files for PECR, a regular expression library
#the $PHPIZE_DEPS var likely contains additional dependecies nedded for building php exts
#the --no-cache flag ensures that no package cache is stored, reducing the image size
RUN apk add --no-cache pcre-dev $PHPIZE_DEPS
#prepares the environment for installing the redis extension
RUN pecl install redis && docker-php-ext-enable redis

#install bash terminal inside the container to enable the user to go inside the container
RUN apk add bash

#detect application env
ARG APP_ENV
ARG RUN_MIGRATIONS

#install composer in /usr/local/bin with the name composer
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN php /usr/local/bin/composer install -vvv --no-scripts --no-ansi --no-interaction --working-dir=/var/www


COPY . .

#all files and subdirectories under /var/www/ will have thier ownership changed to the
#www-data user and group, this is commonly done to ensure that web server processes
#like (Apache or Nginx) have the permissions to read & write files in the wen directory
RUN chown -R www-data:www-data /var/www

#control whether OPcache checks for updated script files based on their timestamps
#By default OPcache checks the timpstamps of PHP files to determine if they have changed since
#the last cache entry
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"

COPY ./docker/php/php.ini "$PHP_INI_DIR/php.ini"

COPY ./docker/php/entrypoint.sh /usr/bin/entrypoint.sh

#the entrypoint script will have the necessary permissions to be executed also to ensure
#that the specified script can be run when the container starts.
RUN chmod +x /usr/bin/entrypoint.sh

ENV RUN_MIGRATIONS=$RUN_MIGRATIONS
ENV APP_ENV=$APP_ENV

CMD "/usr/bin/entrypoint.sh"


