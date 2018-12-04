FROM php:7.1-fpm
MAINTAINER Dave Lane <dave@oerfoundation.org> (@lightweight) https://oeru.org
# based on that by MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Install PHP extensions
RUN apt-get update && apt-get install -y apt-utils git libc-client-dev \
    libcurl3-dev libcurl3-openssl-dev libicu-dev libkrb5-dev libmcrypt-dev \
    libpng-dev libpspell-dev libssl-dev libxml2-dev sudo telnet unzip zip
RUN apt-get install -y net-tools vim dnsutils
# install cron and msmtp for outgoing email
RUN apt-get install -y cron msmtp
# clean up
RUN rm -rf /var/lib/apt/lists/*
# install relevant PHP extensions
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install bcmath curl gd imap intl mbstring \
    mysqli opcache pdo pdo_mysql pspell xml zip
# address Mautic-specific PHP config requirements
RUN set -ex \
    && { \
        echo 'log_errors = on'; \
        echo 'display_errors = off'; \
        echo 'always_populate_raw_post_data = -1'; \
        echo 'date.timezone = "Pacific/Auckland"'; \
        echo 'cgi.fix_pathinfo = 0'; \
        echo 'sendmail_path = /usr/bin/msmtp -t'; \
        echo 'upload_max_filesize = 100M'; \
        echo 'post_max_size = 150M'; \
        echo 'memory_limit = 512M'; \
        echo 'max_execution_time = 600'; \
    } | tee /usr/local/etc/php/conf.d/php.ini

# the PHP-fpm configuration
RUN rm /usr/local/etc/php-fpm.d/www.conf
RUN touch /usr/local/etc/php-fpm.d/www.conf
RUN set -ex \
    && { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo '[www]'; \
        echo 'user = www-data'; \
        echo 'group = www-data'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo 'clear_env = no'; \
        echo 'security.limit_extensions = .php'; \
        echo 'catch_workers_output = yes'; \
        echo 'php_admin_value[memory_limit] = 512M';\
        echo 'pm = ondemand'; \
        echo 'pm.max_children = 20'; \
        echo 'pm.start_servers = 2'; \
        echo 'pm.min_spare_servers = 1'; \
        echo 'pm.max_spare_servers = 3'; \
    } | tee /usr/local/etc/php-fpm.d/www.conf

VOLUME ['/var/www/html']

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.14.2

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
