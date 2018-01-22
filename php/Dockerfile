FROM php:7.0-fpm
MAINTAINER Dave Lane <dave@oerfoundation.org> (@lightweight)
# based on that by MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Install PHP extensions
RUN apt-get update && apt-get install -y apt-utils git libc-client-dev \
    libcurl3-dev libcurl3-openssl-dev libicu-dev libkrb5-dev libmcrypt-dev \
    libpng-dev libpspell-dev libssl-dev libxml2-dev unzip zip
RUN apt-get install -y net-tools vim dnsutils
# install cron and msmtp for outgoing email
RUN apt-get install -y cron msmtp
# clean up
RUN rm -rf /var/lib/apt/lists/*
# install relevant PHP extensions
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install bcmath curl gd imap intl mbstring mcrypt \
    mysqli opcache pdo pdo_mysql pspell xml zip
# address Mautic-specific PHP config requirements
RUN echo "log_errors = on" > /usr/local/etc/php/conf.d/php.ini
RUN echo "display_errors = off" >> /usr/local/etc/php/conf.d/php.ini
RUN echo "always_populate_raw_post_data = -1" >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'date.timezone = "Pacific/Auckland"' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'cgi.fix_pathinfo = 0' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'sendmail_path = /usr/bin/msmtp -t' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'upload_max_filesize = 100M' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'post_max_size = 150M' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/php.ini

# the PHP-fpm configuration
RUN echo 'security.limit_extensions = .php' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'catch_workers_output = yes' >> /usr/local/etc/php-fpm.d/www.conf
RUN echo 'php_admin_value[memory_limit] = 250M' >> /usr/local/etc/php-fpm.d/www.conf

VOLUME ['/var/www/html']

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.12.1

# do a GitHub download
# Download package and extract to web volume
RUN curl -o mautic.zip -SL https://github.com/mautic/mautic/archive/${MAUTIC_VERSION}.zip \
	&& unzip mautic.zip -d /usr/src \
    && mv /usr/src/mautic-${MAUTIC_VERSION} /usr/src/mautic \
	&& rm mautic.zip \
	&& chown -R www-data:www-data /usr/src/mautic

# Copy configuration scripts to the container
COPY docker-entrypoint.sh /entrypoint.sh
COPY makeconfig.php /makeconfig.php
COPY makedb.php /makedb.php
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
