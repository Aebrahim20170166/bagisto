#!/bin/bash

chmod 777 -R /var/www

if [ "$RUN_MIGRATIONS" = true ] ; then

    php /var/www/artisan key:generate --force
    php /var/www/artisan migrate --force
    #php /var/www/artisan tenants:migrate --force
    php /var/www/artisan optimize:clear

    php-fpm

#else
    #/usr/bin/supervisord -n -c /etc/supervisord.conf
fi
