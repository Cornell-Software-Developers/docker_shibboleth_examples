FROM php:7.4-fpm

# Not sure if we should have this
# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
  && printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini \
  && "date"

RUN docker-php-ext-install mysqli

RUN echo 'alias sf="php app/console"' >> ~/.bashrc \
  && echo 'alias sf3="php bin/console"' >> ~/.bashrc

WORKDIR /app
COPY ./ /app
COPY secrets-entrypoint.sh /usr/bin/
# Install Composer
# There is probably a more "secure" way of installing composer instead of curl piping.
# TODO: WARNING: you probably want to be more secure when installing composer.

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
      && composer --version
RUN composer install

CMD ["php-fpm"]
VOLUME /app
ENTRYPOINT ["/usr/bin/secrets-entrypoint.sh"]
