#!/bin/bash

XDEBUG_VERSION=3.2.2

option=$1
forceReinstall=""

if [[ "$option" = "--force-reinstall" ]]; then
    forceReinstall="true"
fi

if [ ! -f /usr/local/etc/php/conf.d/99-xdebug.ini ]; then
    if [ ! -f /tmp/xdebug-${XDEBUG_VERSION}/modules/xdebug.so ] || [ "$forceReinstall" = "true" ]; then
        echo "(Re)Installing XDEBUG"
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

        extensionDir=`php-config --extension-dir`
        cp modules/xdebug.so $extensionDir/

        # Install validator scripts ( see Settings -> PHP -> Debug -> Validate debugger configuration on the Web Server -> Debug validaton script
        sudo -u www-data bash -c "cd /var/www/public && curl -f -L  -o ./phpstorm_xdebug.zip "https://packages.jetbrains.team/files/p/ij/xdebug-validation-script/script/phpstorm_xdebug_validator.zip" && unzip -n ./phpstorm_xdebug.zip -d . && rm -f ./phpstorm_xdebug.zip"
    fi

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
    exit 1
fi
