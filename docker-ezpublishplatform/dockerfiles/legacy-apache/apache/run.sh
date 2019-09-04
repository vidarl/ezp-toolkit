#!/bin/bash
set -xe

# Configure the basic authentication if needed
if [ ! -z "$HTTP_BASIC_USERNAME" ] && [ "$HTTP_BASIC_DISABLED" != "1" ]; then
	htpasswd -cb /etc/apache2/users $HTTP_BASIC_USERNAME $HTTP_BASIC_PASSWORD
	sed -i 's/#AUTH: / /g' /etc/apache2/sites-available/000-default.conf
fi

# Configure the basic authentication if needed
if [ "$SYMFONY_ENV" = "prod" ]; then
	sed -i 's/#PROD: / /g' /etc/apache2/sites-available/000-default.conf
fi

# Start Apache with the right permissions
#/app/docker/apache/start_safe_perms -DFOREGROUND
source /etc/apache2/envvars

#Kill all running apache processes before starting in foreground
/usr/sbin/apache2ctl -k stop
rm -Rf /run/apache2/apache2.pid

/usr/sbin/apache2ctl -D FOREGROUND
