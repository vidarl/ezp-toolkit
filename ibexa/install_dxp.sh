#!/bin/bash

# usage : ./install_dxp.sh flavour project_name directory version

set -e

# For debugging purposes, outputs each line before being executed
# set -o xtrace


flavour=$1
project_name=$2
target_dir=$PWD/$3
version=$4

# example : ./ezp-toolkit/ibexa/install_dxp.sh experience exp50dev exp50dev '~5.0.x-dev'
DEV_INSTALL=false


if [ "$version" == "" ]; then
    version=3.3.20
fi

if [[ "$version" =~ ^~?([0-9]+\.[0-9]+).*-dev$ ]] || [[ "$version" =~ ^([0-9]+\.[0-9]+)\.* ]]; then
    MAJOR_VERSION=${BASH_REMATCH[1]}
else
    echo Invalid version provided : $version
    exit 1
fi

# Maybe this one is for <=3.2 ?
export PHP_IMAGE=ezsystems/php:7.4-v2-node12

if [[ "$version" =~ ^3.3 ]]; then
    export PHP_IMAGE=ghcr.io/ibexa/docker/php:8.2-node14
fi

if [[ "$version" =~ ^4.0 ]]; then
    export PHP_IMAGE=ezsystems/php:8.0-v2-node14
fi

if [[ "$version" =~ ^4.1 ]]; then
    export PHP_IMAGE=ezsystems/php:8.0-v2-node14
fi

if [[ "$version" =~ ^4.2 ]]; then
    export PHP_IMAGE=ezsystems/php:8.0-v2-node14
fi

if [[ "$version" =~ ^4.3 ]]; then
    export PHP_IMAGE=ezsystems/php:8.1-v2-node14
fi

if [[ "$version" =~ ^4.4 ]]; then
    export PHP_IMAGE=ezsystems/php:8.1-v2-node14
    patch_44=0
fi

if [[ "$version" =~ ^4.5 ]]; then
    export PHP_IMAGE=ezsystems/php:8.1-v2-node14
fi

if [[ "$version" =~ ^4.6 ]]; then
    export PHP_IMAGE=ghcr.io/ibexa/docker/php:8.4-node22
fi


if [[ "$version" == "~5.0.x-dev" ]]; then
    export PHP_IMAGE=ghcr.io/ibexa/docker/php:8.3-node22
    DEV_INSTALL=true
elif [[ "$version" =~ ^5.0 ]]; then
    export PHP_IMAGE=ghcr.io/ibexa/docker/php:8.3-node22
fi

echo Removing  container install_dxp if it already exists
docker rm -v install_dxp || /bin/true

if [ -d $target_dir ]; then
    rmdir $target_dir
fi

mkdir $target_dir

function composer_container() {
    local extra_param
    if [ $1 == "create-project" ]; then
        extra_param=""
    else
        extra_param="--workdir /var/www "
    fi

    echo docker run $extra_param --rm \
      --name install_dxp \
      -t -i \
      -u www-data \
      --mount type=bind,source="$target_dir",target=/var/www \
      --mount type=bind,source="$HOME/www-data",target=/home/www-data \
      --mount type=bind,source="$HOME/.ssh",target=/home/www-data/.ssh \
      -e HOME=/home/www-data \
      --entrypoint composer \
      -e COMPOSER_HOME=/home/www-data/.composer \
      $PHP_IMAGE \"$@\"
    docker run $extra_param --rm \
      --name install_dxp \
      -t -i \
      -u www-data \
      --mount type=bind,source="$target_dir",target=/var/www \
      --mount type=bind,source="$HOME/www-data",target=/home/www-data \
      --mount type=bind,source="$HOME/.ssh",target=/home/www-data/.ssh \
      -e HOME=/home/www-data \
      --entrypoint composer \
      -e COMPOSER_HOME=/home/www-data/.composer \
      $PHP_IMAGE "$@"
}

function patch_dxp44() {
    if [[ "$version" =~ ^4.4 ]]; then
        echo "Patching for DXP 4.4, Taxonomi"
        patch -p0 < external/ezp-toolkit/ezplatform/dxp44_taxonomi_fix.patch
    fi
}

function check_homedir_skeleton() {
    if [ ! -f "$HOME/www-data/.composer/auth.json" ]; then
        echo "Missing $HOME/www-data/.composer/auth.json"
        echo "Create $HOME/www-data/.composer and add your Composer auth.json file."
        exit 1
    fi
}

check_homedir_skeleton

if [[ "$DEV_INSTALL" == "true" ]]; then
    composer_container create-project ibexa/website-skeleton:${version} /var/www
else
    composer_container create-project --no-install --no-scripts ibexa/${flavour}-skeleton:${version} /var/www
fi

# Prevent yarn install to fail on slow connections
composer_container config process-timeout 1800

if [[ "$version" =~ ^4.0 ]]; then
    composer_container config extra.symfony.endpoint "https://api.github.com/repos/ibexa/recipes/contents/index.json?ref=flex/main"
fi


if [ $flavour = "commerce" ]; then
    echo Copying auth.json for commerce
    if [ -f ~/.composer/auth.json.commerce ]; then
        cp ~/.composer/auth.json.commerce $target_dir/auth.json
    fi
fi

cd $target_dir

if [[ "$DEV_INSTALL" == true ]]; then
    composer_container config repositories.ibexa composer https://updates.ibexa.co
    composer_container require ibexa/${flavour}:${version} -W --no-scripts
fi

echo -e "\n### Local additions\npublic/assets\nide-twig.json\n#yarn\n.cache" >> .gitignore

git init
git add .
git commit -m "Initial commit - create-project"

if [ `whoami` == "vl" ]; then
    mkdir external; cd external; git clone git@github.com:vidarl/ezp-toolkit.git; cd ..
else
    mkdir external; cd external; git clone https://github.com/vidarl/ezp-toolkit.git; cd ..
fi


composer_container install --no-scripts
if [[ "$DEV_INSTALL" == true ]]; then
    composer_container require ibexa/docker:${version} --no-scripts
else
    composer_container require ibexa/docker:^$MAJOR_VERSION --no-scripts
fi

# Looks like the "--no-scripts" also prevents the recipes for ibexa/docker to execute properly
composer_container recipes:install ibexa/docker --force

# Like not needed.. Timeout in composer is increased already
# echo "Extending yarn network timeout" :
# echo "network-timeout 1000000" >> .yarnrc

git add .env composer.json composer.lock symfony.lock bin/vhost.sh doc
git commit -m "Installed ibexa/docker"

echo -e "\n\n### Local modifications ###" >> .env
echo "PHP_IMAGE=$PHP_IMAGE" >> .env
echo "COMPOSE_PROJECT_NAME=$project_name" >> .env
echo -e "PHP_INI_ENV_memory_limit=600M\n" >> .env
echo "COMPOSE_FILE=doc/docker/base-dev.yml:external/ezp-toolkit/ezplatform/ssh.yml" >> .env


docker compose up -d --remove-orphans

if [[ "$DEV_INSTALL" == true ]]; then
    docker compose exec --user www-data app composer install --no-scripts
else
    docker compose exec --user www-data app composer install
fi

patch_dxp44

if [[ "$DEV_INSTALL" == true ]]; then
    docker compose exec --user www-data app composer recipes:install ibexa/${flavour} --force --reset
    docker compose exec --user www-data app composer run post-update-cmd
fi
docker compose exec --user www-data app php bin/console ibexa:install --no-interaction
docker compose exec --user www-data app php bin/console ibexa:graphql:generate-schema

echo 'mysqldump -u $DATABASE_USER --password=$DATABASE_PASSWORD -h $DATABASE_HOST --add-drop-table --extended-insert  --protocol=tcp $DATABASE_NAME > doc/docker/entrypoint/mysql/2_dump.sql' > create_mysql_dump.sh
docker compose exec --user www-data app bash create_mysql_dump.sh
rm create_mysql_dump.sh

git commit .env -m "Added modifications to .env"

docker compose exec --user www-data app composer ibexa:setup --platformsh
git add .platform.app.yaml .platform bin/platformsh_prestart_cacheclear.sh
if [[ "$version" =~ ^4.1 ]]; then
    git add config/packages/http.yaml
fi

git commit  -m "Installed platform.sh scripts"

docker compose exec --user www-data app composer run post-install-cmd

echo -e "\nconfig/graphql/types/ibexa/\ndoc/docker/entrypoint/mysql/2_dump.sql\nexternal/" >> .gitignore
git commit -m "Updated .gitignore" .gitignore

git add .nvmrc config/packages/http.yaml src/Migrations/
git commit -m "Added additional files created during installation"
