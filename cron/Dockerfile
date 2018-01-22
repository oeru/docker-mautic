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

# set up cron tasks
RUN echo '# cron jobs for Mautic - dave@oerfoundation.org' > /etc/cron.d/mautic-cron
RUN echo '# see https://mautic.org/docs/en/setup/cron_jobs.html for details' >> /etc/cron.d/mautic-cron
RUN echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' >> /etc/cron.d/mautic-cron
RUN echo 'CONSOLE=/var/www/html/app/console' >> /etc/cron.d/mautic-cron
RUN echo 'OUT=/var/log/cron.log' >> /etc/cron.d/mautic-cron
RUN echo '# Run contact imports every 5 minutes' >> /etc/cron.d/mautic-cron
RUN echo '*/5 * * * * root php $CONSOLE mautic:import >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Run Segment updates 3 times every hour' >> /etc/cron.d/mautic-cron
RUN echo '0,20,40 * * * * root php $CONSOLE mautic:segments:update >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Run Campaign updates - ensure candidates are correct - 3 times per hour' >> /etc/cron.d/mautic-cron
RUN echo '5,25,45 * * * * root php $CONSOLE mautic:campaigns:rebuild >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Run Campaign events 3 times per hour' >> /etc/cron.d/mautic-cron
RUN echo '10,30,50 * * * * root php $CONSOLE mautic:campaigns:trigger >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Process Email Queue every other hour' >> /etc/cron.d/mautic-cron
RUN echo '15 */2 * * * root php $CONSOLE mautic:emails:send >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Fetch and Process Monitored Email 4 times daily' >> /etc/cron.d/mautic-cron
RUN echo '15 1,7,13,19 * * * root php $CONSOLE mautic:email:fetch >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Social Monitoring 4 times daily' >> /etc/cron.d/mautic-cron
RUN echo '15 3,9,15,21 * * * root php $CONSOLE mautic:social:monitoring >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Process Webhooks 4 times daily' >> /etc/cron.d/mautic-cron
RUN echo '15 5,11,17,23 * * * root php $CONSOLE mautic:webhooks:process >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Update MaxMind Geolite2 IP Database, 0:30, 10th day of the month' >> /etc/cron.d/mautic-cron
RUN echo '30 0 10 * * root php $CONSOLE mautic:iplookup:download >> $OUT' >> /etc/cron.d/mautic-cron
RUN echo '# Just testing' >> /etc/cron.d/mautic-cron
RUN echo '*/1 * * * * root echo "Running cron at $(date)" >> $OUT ' >> /etc/cron.d/mautic-cron
RUN echo '# empty line' >> /etc/cron.d/mautic-cron

RUN touch 0644 /var/log/cron.log

#VOLUME ['/var/www/html', '/var/log']
VOLUME ['/var/www/html']

CMD cron && tail -f /var/log/cron.log
