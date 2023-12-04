#!/bin/bash

XDEBUG_VERSION=3.2.2


if [ ! -f /usr/local/etc/php/conf.d/99-xdebug.ini ]; then
    echo "Installing XDEBUG"
    rm -f /tmp/xdebug.tar.gz xdebug-${XDEBUG_VERSION}
    curl https://xdebug.org/files/xdebug-${XDEBUG_VERSION}.tgz --output /tmp/xdebug.tar.gz
    # apt-get install php-dev autoconf automake
    apt-get update
    apt-get install -y autoconf automake libtool iputils-ping telnet procps


    cd /tmp
    tar -xzf xdebug.tar.gz
    cd xdebug-${XDEBUG_VERSION}
    phpize
    # autoreconf -i
    ./configure
    make

    cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20210902

    echo "zend_extension = xdebug.so" > /usr/local/etc/php/conf.d/99-xdebug.ini
    #  echo "xdebug.mode=develop,coverage,debug,profile" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "xdebug.log=/dev/stdout" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "xdebug.client_port=$XDEBUG_PORT" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/99-xdebug.ini
    echo "" >> /usr/local/etc/php/conf.d/99-xdebug.ini
else
    echo "XDEBUG already installed !"
fi
