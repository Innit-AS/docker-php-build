FROM php:7.3-stretch

LABEL maintainer="Erik Weber <terbolous@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y libzip-dev libzip4 wget \
    && docker-php-ext-install zip \
    && pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions -name 'xdebug.so')" > /usr/local/etc/php/conf.d/xdebug.ini \
    && apt-get remove -y libzip-dev \
    && apt-get autoremove -y \
    && EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)" \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; \
        then \
        >&2 echo 'ERROR: Invalid installer signature'; \
        rm composer-setup.php; \
        exit 1; \
        fi \
    && php composer-setup.php --install-dir=/usr/bin --quiet --filename=composer \
    && rm composer-setup.php \