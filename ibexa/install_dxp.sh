#!/bin/bash


# usage : ./install_dxp.sh flavour project_name directory

set -e

flavour=$1
project_name=$2
target_dir=$3
version=$4

if [ "$version" == "" ]; then
    version=3.3.3
fi

YARN_WORKAROUND=y

# Maybe this one is for <=3.2
#export PHP_IMAGE=${4-ezsystems/php:7.4-v2-node12}
export PHP_IMAGE=ezsystems/php:7.4-v2-node14

COMPOSER_PATCH=`dirname $0`/composer_selfupdate.patch

composer create-project --no-install --no-scripts ibexa/${flavour}-skeleton:${version} $target_dir
if [ -f ~/.composer/auth.json ]; then
    cp ~/.composer/auth.json $target_dir
fi

if [ $flavour = "commerce" ]; then
    echo Copying auth.json for commerce
    if [ -f ~/.composer/auth.json.commerce ]; then
        cp ~/.composer/auth.json $target_dir
        cp ~/.composer/auth.json.commerce $target_dir/auth.json
    fi
fi

cd $target_dir

echo -e "\n### Local additions\npublic/assets\nide-twig.json\n#yarn\n.cache" >> .gitignore

git init
git add .
git commit -m "Initial commit - create-project"

cat >> update_composer.sh << EOF
if [ -f /var/www/composer ]; then
	cp /var/www/composer /usr/local/bin/composer
else
	composer selfupdate
fi
EOF
chmod a+x update_composer.sh

composer install --no-scripts
composer require ibexa/docker --no-scripts
# Looks like the "--no-scripts" also prevents the recipes for ibexa/docker to execute properly
composer recipes:install ibexa/docker --force

# Copying in composer if available as "composer selfupdate" has rate limits
if [ -f /usr/local/bin/composer ]; then
    cp /usr/local/bin/composer .
fi

# We need to make a copy and patch the copy because receips might change install_script.sh while we are executing it
cp doc/docker/install_script.sh doc/docker/install_script_patched.sh
patch -p0 < ../$COMPOSER_PATCH

# git init; git add . > /dev/null;

# Any change to .env file wil be overrwritten, so we need to write the changes to .env after this has completed:
echo COMPOSE_PROJECT_NAME=$project_name PHP_IMAGE=$PHP_IMAGE docker-compose -f doc/docker/install-dependencies.yml -f doc/docker/install-database.yml up --abort-on-container-exit --force-recreate
COMPOSE_PROJECT_NAME=$project_name PHP_IMAGE=$PHP_IMAGE docker-compose -f doc/docker/install-dependencies.yml -f doc/docker/install-database.yml up --abort-on-container-exit --force-recreate

echo -e "\n###### local config ####" >> .env
echo "COMPOSE_PROJECT_NAME=$project_name" >> .env
echo "PHP_IMAGE=$PHP_IMAGE" >> .env
echo "PHP_INI_ENV_memory_limit=356M" >> .env


docker-compose -f doc/docker/install-dependencies.yml -f doc/docker/install-database.yml down
docker-compose up -d --force-recreate

docker-compose exec app rm -rf var/cache
docker-compose exec app chown 1000:1000 -R .git config doc/docker/entrypoint/mysql/2_dump.sql public var
docker-compose exec app chown 1000:33 -R .git var public/var
docker-compose exec app chmod a+x bin/console

echo Trying to sleep 3 sec before updating composer
sleep 3
docker-compose exec app bash -c /var/www/update_composer.sh

# If you get something like An unexpected error occurred: "https://registry.yarnpkg.com/@symfony/stimulus-bridge/-/stimulus-bridge-1.1.0.tgz: getaddrinfo EAI_AGAIN registry.yarnpkg.com".
# then but "nameserver 8.8.8.8" in /etc/resolv.conf and re-execute command inside container

# Temporary, use google DNS
if [ "$YARN_WORKAROUND" == "y" ]; then
    echo "Applying workaround for yarn ( dns resolving ) in container"
    echo -e "nameserver 8.8.8.8\noptions ndots:0" > resolv.conf
    docker-compose exec app cp /etc/resolv.conf /etc/resolv.conf.org
    echo "cat resolv.conf > /etc/resolv.conf" > a.sh
    chmod a+x a.sh
    docker-compose exec app bash ./a.sh
fi

docker-compose exec --user www-data app composer run-script auto-scripts

# Restore /etc/resolv.conf
if [ "$YARN_WORKAROUND" == "y" ]; then
    echo "cat /etc/resolv.conf.org > /etc/resolv.conf" > a.sh
    docker-compose exec app bash ./a.sh
fi

# cleanup
rm a.sh resolv.conf
git rm -f update_composer.sh

git commit -m "Ran recipes"
#git add config/graphql/types/.gitignore
#git commit -m "Added config/graphql/types/.gitignore"
git commit bin/console -m "Fixed exec permission on bin/console"
git commit .env -m "Added modifications to .env"
git commit . -m "More recipes"
