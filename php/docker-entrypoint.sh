#!/bin/bash

set -e

if [ -n "$MYSQL_PORT_3306_TCP" ]; then
    if [ -z "$MAUTIC_DB_HOST" ]; then
            MAUTIC_DB_HOST='mysql'
    else
        echo >&2 "warning: both MAUTIC_DB_HOST and MYSQL_PORT_3306_TCP found"
        echo >&2 "  Connecting to MAUTIC_DB_HOST ($MAUTIC_DB_HOST)"
        echo >&2 "  instead of the linked mysql container"
    fi
fi

if [ -z "$MAUTIC_DB_HOST" ]; then
    echo >&2 "error: missing MAUTIC_DB_HOST and MYSQL_PORT_3306_TCP environment variables"
    echo >&2 "  Did you forget to --link some_mysql_container:mysql or set an external db"
    echo >&2 "  with -e MAUTIC_DB_HOST=hostname:port?"
    exit 1
fi

# If the DB user is 'root' then use the MySQL root password env var
: ${MAUTIC_DB_USER:=root}
if [ "$MAUTIC_DB_USER" = 'root' ]; then
    : ${MAUTIC_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${MAUTIC_DB_NAME:=mautic}

if [ -z "$MAUTIC_DB_PASSWORD" ]; then
    echo >&2 "error: missing required MAUTIC_DB_PASSWORD environment variable"
    echo >&2 "  Did you forget to -e MAUTIC_DB_PASSWORD=... ?"
    echo >&2
    echo >&2 "  (Also of interest might be MAUTIC_DB_USER and MAUTIC_DB_NAME.)"
    exit 1
fi

if ! [ -f index.php -a -e app/AppKernel.php ]; then
    echo >&2 "Mautic not found in $(pwd) - copying now..."

    if [ "$(ls -A)" ]; then
        echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
        ( set -x; ls -A; sleep 10 )
    fi

    tar cf - --one-file-system -C /usr/src/mautic . | tar xf -
    chown -R www-data:www-data .

    echo >&2 "Complete! Mautic has been successfully copied to $(pwd)"
fi

# run composer to set up dependencies if not already there...

if ! [ -f /usr/local/bin/composer ]; then
    echo >&2 "first getting Composer"
    # Get Composer
    curl -S https://getcomposer.org/installer | php
    chmod a+x composer.phar
    mv composer.phar /usr/local/bin/composer
fi

# check if composer's already running on this system of containers... 
SEMAPH=composer-running

if ! [ -f $SEMAPH ] ; then 
        # create the semaphore file with the date in it... 
            date > $SEMAPH

    if ! [ -f vendor/autoload.php ]; then
        echo >&2 "installing dependencies with Composer"
        if ! [ -e .git/hooks ]; then
            echo >&2 "creating a .git/hooks dir to avoid errors"
            mkdir -p .git/hooks
        fi
    else
        echo >&2 "vendor dependencies already in place."
    fi
    #sudo -u www-data composer install
    #echo >&2 "installing/updating vendor dependencies... running as user www-data"
    echo >&2 "installing/updating vendor dependencies..."
    composer install
    chown -R www-data:www-data .
    
    #remove semaphore
    rm $SEMAPH
else
    echo >&2 "Looks like another composer is already running. If not, please remove $SEMAPH"
fi

#
# normally we expect a database to be pre-configured... in which case you just need
# the appropriate details in app/config/local.php file, e.g.
#
#  <?php
#    $parameters = array(
#  	     'db_driver' => 'pdo_mysql',
#     	 'db_host' => '[localhost or host IP or container name]',
#	     'db_port' => '3306',
#	     'db_name' => 'mautic',
#	     'db_user' => 'mautic',
#	     'db_password' => '[your password]',
#  );

## Ensure the MySQL Database is created
#php /makedb.php "$MAUTIC_DB_HOST" "$MAUTIC_DB_USER" "$MAUTIC_DB_PASSWORD" "$MAUTIC_DB_NAME"
#
#echo >&2 "========================================================================"
#echo >&2
#echo >&2 "This server is now configured to run Mautic!"
#echo >&2 "You will need the following database information to install Mautic:"
#echo >&2 "Host Name: $MAUTIC_DB_HOST"
#echo >&2 "Database Name: $MAUTIC_DB_NAME"
#echo >&2 "Database Username: $MAUTIC_DB_USER"
#echo >&2 "Database Password: $MAUTIC_DB_PASSWORD"
#echo >&2
#echo >&2 "========================================================================"

# Write the database connection to the config so the installer prefills it
#if ! [ -e app/config/local.php ]; then
#    php /makeconfig.php "$MAUTIC_DB_HOST" "$MAUTIC_DB_USER" "$MAUTIC_DB_PASSWORD" "$MAUTIC_DB_NAME"
#
#    # Make sure our web user owns the config file if it exists
#    chown www-data:www-data app/config/local.php
#fi

exec "$@"
