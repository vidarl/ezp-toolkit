#!/bin/bash

docker-compose up -d
docker-compose exec app bash -c ./external/ezp-toolkit/xdebug/internal_install_xdebug.sh

# Insert wsl host's IP in .env
cat .env|grep "DOCKERHOST=" || echo -e "\nDOCKERHOST=1.2.3.4" >> .env
sed -ie 's/DOCKERHOST=.*/DOCKERHOST='$(ip route show | awk '/default/ {print $3}')'/g' .env
docker-compose stop app
docker-compose up -d

