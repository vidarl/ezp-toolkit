#!/bin/bash

# Usage :
# ./external/ezp-toolkit/xdebug/prepare_container_for_xdebug.sh
# ./external/ezp-toolkit/xdebug/prepare_container_for_xdebug.sh --disable
# ./external/ezp-toolkit/xdebug/prepare_container_for_xdebug.sh --force-reinstall

option=$1

if [[ "$option" = "--disable" ]]; then
    echo "Disabling xdebug by removing '/usr/local/etc/php/conf.d/99-xdebug.ini' inside container"
    docker compose exec app bash -c "rm -rf /usr/local/etc/php/conf.d/99-xdebug.ini"
    docker compose stop app
    docker compose up -d

    exit
fi


forceReinstall=""
if [[ "$option" = "--force-reinstall" ]]; then
    forceReinstall="--force-reinstall"
elif [[ "$option" != "" ]]; then
    echo "Unkown option : $1"
    exit 1
fi

# Insert wsl host's IP in .env.
cat .env|grep "DOCKERHOST=" || echo -e "\nDOCKERHOST=1.2.3.4" >> .env
sed -ie 's/DOCKERHOST=.*/DOCKERHOST='$(ip route show | awk '/default/ {print $3}')'/g' .env
# If ip changed, app container will be recreated now:
docker compose up -d

docker compose exec app bash -c "./external/ezp-toolkit/xdebug/internal_install_xdebug.sh $forceReinstall" && docker compose stop app && docker compose up -d
