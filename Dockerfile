FROM php:8.3.0-apache

RUN apt-get update && apt-get install -y lsb-release curl sudo nano git zip unzip libzip-dev zip gnupg dirmngr

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list

RUN apt-get update && apt-get install -y gum

RUN curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
    apt-get -y install nodejs &&\
    ln -s /usr/bin/nodejs /usr/local/bin/node

# 2. apache configs + document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# 4. Install PHP extensions
# RUN docker-php-ext-install zip
RUN docker-php-ext-install pdo_mysql pcntl

RUN pecl install redis && docker-php-ext-enable redis

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer --version=2.6.5

RUN pecl install excimer

COPY devtools /usr/bin/

RUN chmod +x /usr/bin/devtools

ARG uid

RUN useradd -G www-data,root -u $uid -d /home/app app-user

RUN mkdir -p /home/app/.composer && \
    chown -R app-user:app-user /home/app && \
    mkdir /var/www/html/storage && \
    chown -R 777 /var/www/html/storage
