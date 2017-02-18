FROM php:5.6-fpm
MAINTAINER Dave Lane <dave@oerfoundation.org> (@lightweight)
# based on that by MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Install PHP extensions
RUN apt-get update && apt-get install -y git libc-client-dev libicu-dev \
    libkrb5-dev libmcrypt-dev libssl-dev unzip zip
RUN apt-get install -y net-tools vim dnsutils
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install imap intl mbstring mcrypt mysqli pdo pdo_mysql zip
# address Mautic-specific config requirements
RUN echo "always_populate_raw_post_data = -1;" > /usr/local/etc/php/conf.d/php.ini
RUN echo 'date.timezone = "Pacific/Auckland";' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'cgi.fix_pathinfo = 0;' >> /usr/local/etc/php/conf.d/php.ini

VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.6.0

# do a GitHub download
# Download package and extract to web volume
RUN curl -o mautic.zip -SL https://github.com/mautic/mautic/archive/${MAUTIC_VERSION}.zip \
	&& unzip mautic.zip -d /usr/src \
    && mv /usr/src/mautic-${MAUTIC_VERSION} /usr/src/mautic \
	&& rm mautic.zip \
	&& chown -R www-data:www-data /usr/src/mautic

# Copy init scripts and custom .htaccess
COPY docker-entrypoint.sh /entrypoint.sh
COPY makeconfig.php /makeconfig.php
COPY makedb.php /makedb.php
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
