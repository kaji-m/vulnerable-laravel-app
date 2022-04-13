FROM php:7.4-fpm AS base

WORKDIR /var/www/html

RUN rm /etc/apt/preferences.d/no-debian-php
RUN apt-get update && apt-get install -y mariadb-client zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libmagickwand-dev zip libzip-dev php-soap vim netcat iputils-ping wget python cron \
    && docker-php-ext-configure gd \
		--with-freetype=/usr/lib/x86_64-linux-gnu/ \
		--with-jpeg=/usr/lib/x86_64-linux-gnu/ \
		--with-xpm=/usr/lib/x86_64-linux-gnu/ \
    && docker-php-ext-install pdo_mysql zip gd soap \
    && pecl install imagick \
    && docker-php-ext-enable imagick 

#Add curl dependency 
RUN apt-get update && apt-get install -y gnupg2 

#Add the Contrast agent 
RUN curl https://pkg.contrastsecurity.com/api/gpg/key/public | apt-key add - \
    && echo "deb https://pkg.contrastsecurity.com/debian-public/ $(sed -rne 's/^VERSION_CODENAME=(.*)$/\1/p' /etc/*ease) contrast" | tee /etc/apt/sources.list.d/contrast.list \
    && echo "deb https://pkg.contrastsecurity.com/debian-public/ all contrast" | tee -a /etc/apt/sources.list.d/contrast.list
RUN apt-get update && apt-get install contrast-php-agent
RUN echo "extension=/usr/local/lib/contrast/php/contrast.so" >> `php-config --ini-path`/php.ini

COPY . /var/www/html

# Setup Laravel scheduler to run as root for privesc demonstration
RUN echo '* * * * * root cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1' >> /etc/crontab

RUN chown -R www-data:www-data /var/www/html/
RUN find /var/www/html/ -type d -exec chmod 755 {} \;
RUN find /var/www/html/ -type f -exec chmod 644 {} \;
RUN chgrp -R www-data /var/www/html/storage /var/www/html/public/uploads /var/www/html/bootstrap/cache
RUN chmod -R ug+rwx /var/www/html/storage /var/www/html/public/uploads /var/www/html/bootstrap/cache

CMD service cron start && php-fpm
