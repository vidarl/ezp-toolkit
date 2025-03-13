#!/bin/bash

version=$1
target_dir=`pwd`

if [[ "$version" =~ ^3.3 ]]; then
    export PHP_IMAGE=ezsystems/php:7.4-v2-node14
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
fi

if [[ "$version" =~ ^4.5 ]]; then
    export PHP_IMAGE=ezsystems/php:8.1-v2-node14
fi


function container() {

    echo docker run $extra_param --rm --name install_dxp -t -i -u www-data --entrypoint composer --mount type=bind,source="$target_dir",target=/var/www $PHP_IMAGE $@
#    docker run $extra_param --rm --name install_dxp -t -i -u www-data --entrypoint composer --mount type=bind,source="$target_dir",target=/var/www $PHP_IMAGE $@
    docker run --workdir /var/www --rm --name install_dxp -t -i -u www-data --entrypoint /bin/bash --mount type=bind,source="$target_dir",target=/var/www $PHP_IMAGE
}

container
