FROM php:7.0-fpm
MAINTAINER Dave Lane <dave@oerfoundation.org> (@lightweight)
# based on that by MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Install PHP extensions
RUN apt-get update && apt-get install -y apt-utils git libc-client-dev libicu-dev \
    libkrb5-dev libmcrypt-dev libssl-dev unzip zip
RUN apt-get install -y net-tools vim dnsutils
# install cron and msmtp for outgoing email
RUN apt-get install -y cron msmtp
# clean up
RUN rm -rf /var/lib/apt/lists/*
# install relevant PHP extensions
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install imap intl mbstring mcrypt mysqli pdo pdo_mysql zip
# address Mautic-specific PHP config requirements
RUN echo "always_populate_raw_post_data = -1;" > /usr/local/etc/php/conf.d/php.ini
RUN echo 'date.timezone = "Pacific/Auckland";' >> /usr/local/etc/php/conf.d/php.ini
RUN echo 'cgi.fix_pathinfo = 0;' >> /usr/local/etc/php/conf.d/php.ini
# set up cron tasks
RUN echo '# cron jobs for Mautic - dave@oerfoundation.org' > /etc/cron.d/mautic-cron
RUN echo '# see https://mautic.org/docs/en/setup/cron_jobs.html for details' >> /etc/cron.d/mautic-cron
RUN echo 'CONSOLE=/var/www/html/app/console' >> /etc/cron.d/mautic-cron
RUN echo '# Run Segment updates 3 times per hour' >> /etc/cron.d/mautic-cron
RUN echo '0,20,40 * * * * root php $CONSOLE mautic:segments:update' >> /etc/cron.d/mautic-cron
RUN echo '# Run Campaign updates - ensure candidates are correct - 3 times per hour' >> /etc/cron.d/mautic-cron
RUN echo '5,25,45 * * * * root php $CONSOLE mautic:campaigns:rebuild' >> /etc/cron.d/mautic-cron
RUN echo '# Run Campaign events 3 times per hour' >> /etc/cron.d/mautic-cron
RUN echo '10,30,50 * * * * root php $CONSOLE mautic:campaigns:trigger' >> /etc/cron.d/mautic-cron
RUN echo '# Process Email Queue every other hour' >> /etc/cron.d/mautic-cron
RUN echo '15 */2 * * * root php $CONSOLE ' >> /etc/cron.d/mautic-cron
RUN echo '# Fetch and Process Monitored Email 4 times daily' >> /etc/cron.d/mautic-cron
RUN echo '15 1,7,13,19 * * * root php $CONSOLE ' >> /etc/cron.d/mautic-cron
RUN echo '# Social Monitoring 4 times daily' >> /etc/cron.d/mautic-cron
RUN echo '15 3,9,15,21 * * * root php $CONSOLE ' >> /etc/cron.d/mautic-cron
RUN echo '# Process Webhooks 4 times daily' >> /etc/cron.d/mautic-cron
RUN echo '15 5,11,17,23 * * * root php $CONSOLE ' >> /etc/cron.d/mautic-cron

VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.7.1

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
