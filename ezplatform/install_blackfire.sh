#!/bin/bash

if [ -f /usr/local/blackfire_installed ]; then
    sudo service blackfire-agent restart
else
    apt-get update
    apt-get install -y procps
    mkdir /usr/local/tmp
    mv /usr/local/etc/php/conf.d/blackfire.ini /usr/local/tmp
    mv /usr/local/lib/php/extensions/no-debug-non-zts-*/blackfire.so /usr/local/tmp/

    bash -c "$(curl -L https://installer.blackfire.io/installer.sh)"

    blackfire php:install

    touch /usr/local/blackfire_installed
fi
