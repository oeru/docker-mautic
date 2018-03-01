FROM oeru/mautic
MAINTAINER Dave Lane <dave@oerfoundation.org> (@lightweight)
# based on that by MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# set up cron tasks
RUN set -ex \
    && { \
        echo '# cron jobs for Mautic - dave@oerfoundation.org'; \
        echo '# see https://mautic.org/docs/en/setup/cron_jobs.html for details'; \
        echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'; \
        echo 'CONSOLE=/var/www/html/app/console'; \
        echo 'OUT=/var/log/cron.log'; \
        echo '# contact imports every 5 minutes'; \
        echo '*/5 * * * * root php $CONSOLE mautic:import >> $OUT'; \
        echo '# Segment updates 3 times every hour'; \
        echo '0,20,40 * * * * root php $CONSOLE mautic:segments:update >> $OUT'; \
        echo '# Campaign updates - ensure candidates are correct - 3 times per hour'; \
        echo '5,25,45 * * * * root php $CONSOLE mautic:campaigns:rebuild >> $OUT'; \
        echo '# Campaign events 3 times per hour'; \
        echo '10,30,50 * * * * root php $CONSOLE mautic:campaigns:trigger >> $OUT'; \
        echo '# Process Email Queue every other hour'; \
        echo '10,25,40,55 * * * * root php $CONSOLE mautic:emails:send >> $OUT'; \
        echo '# Fetch and Process Monitored Email 4 times daily'; \
        echo '15 1,7,13,19 * * * root php $CONSOLE mautic:email:fetch >> $OUT'; \
        echo '# Social Monitoring 4 times daily'; \
        echo '15 3,9,15,21 * * * root php $CONSOLE mautic:social:monitoring >> $OUT'; \
        echo '# Process Webhooks 4 times daily'; \
        echo '15 5,11,17,23 * * * root php $CONSOLE mautic:webhooks:process >> $OUT'; \
        echo '# Update MaxMind Geolite2 IP Database, 0:30, 10th day of the month'; \
        echo '30 0 10 * * root php $CONSOLE mautic:iplookup:download >> $OUT'; \
        echo '# Just testing'; \
        echo '*/1 * * * * root echo "Running cron at $(date)" >> $OUT '; \
        echo '# empty line'; \
    } | tee /etc/cron.d/mautic-cron

RUN touch 0644 /var/log/cron.log

#VOLUME ['/var/www/html', '/var/log']
VOLUME ['/var/www/html']

CMD cron && tail -f /var/log/cron.log
