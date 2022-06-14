# ezp-toolkit
Various scripts for help running and upgrading ezpublish to ezplatform

# Running eZ Publish Platform 5.4 via docker

Using legacy apache docker

You may want to run legacy directly from ezpublish_legacy/ folder. To do that:

## Alter .env file

Add `:external/ezp-toolkit/docker/legacy-apache.yml` to the end of the COMPOSE_FILE variable in `.env`

## Alter .dockerignore file

Add the following to `.dockerignore` file:

```
dumps/
ezpublish_legacy/var/ezflow_site/storage/
vendor/
ezpublish_legacy/
ezpublish_legacy.composer/
node_modules/
vendor.old/
```

# Install legacy directly

If you only want to run pure legacy, you need a container where you may run composer install:

```
docker run -d --name [proj]_console -v /var/www/[folder]:/app -v /home/vl/.ssh/id_rsa:/id_rsa ezsystems/legacy-apache bash -c "while [ 1 ]; do echo -n .; sleep 60; done"
```



# Install eZ Publish Platform 5.x ( 5.4 )

## Install files

```
    git clone git@github.com:ezsystems/ezpublish-platform.git
    cd ezpublish-platform
    git checkout v5.4.14
    mkdir external
    cd external
    git clone git@github.com:vidarl/ezp-toolkit.git
    cd ..
    
    cp external/ezp-toolkit/docker-ezpublishplatform/.dockerignore .
    cp external/ezp-toolkit/docker-ezpublishplatform/.env-dist .env
    
    # set COMPOSE_PROJECT_NAME in .env
    # Also make note that you may change COMPOSE_FILE depending on if want xdebug etc
    vim .env

    docker-compose up -d
```

## Run composer install

Add `auth.json` to installation directory with credentials for updates.ez.no, next run:

```
    docker-compose exec -u www-data ezphp5 bash
    # Now, inside the container run:

    COMPOSER_HOME="/tmp/.composer" COMPOSER_MEMORY_LIMIT=-1 composer install
```

## Run setup wizard

Run setup wizard directly from [legacy](http://localhost:8082) ( using legacyapache container on port 8082)
http://localhost:8082

Use the following db settings when asked by setup wizard:

```
servername=db
username=ezp
password=youmaychangethis

```

## Configure symfony stack

Run following program from console

```
    docker-compose exec -u www-data ezphp5 bash
    php ezpublish/console ezpublish:configure --env prod ezdemo_site ezdemo_site_admin
```

## Access site

Access site directly from legacy, PHP 5.6 on port [8082](http://localhost:8082)
Access site using symfony stack, PHP 5.6 on port [8081](http://localhost:8081)
Access site using symfony stack, PHP 7.1 on port [8080](http://localhost:8081)

## Debugging Symfony stack with PHP 5.6 (port 8081) with XDebug and PHPStorm

Enabling xdebug by including `:external/ezp-toolkit/docker-ezpublishplatform/xdebug.yml` in `COMPOSE_FILE` variable in .env

Specify your computer's IP in `DOCKERHOST` in .env

Install a [browser Debugging extension](https://www.jetbrains.com/help/phpstorm/browser-debugging-extensions.html), for instance XDebug Helper.

How to configure xdebug in PHPStorm is documented [here](https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html#integrationWithProduct).
Specifically, it is important that you configure the Directory mapping correctly in PHPStorm, as the path to the .php files inside the container (seen by xdebug) is likely different from the path PHPStorm sees.
Let's say you have installed eZ Publish Platform in `/home/phpdeveleoper/project/ezpsite`.
To configure the directory mapping, press [Ctrl]-[Alt]-[s]. Next click `Languages & Frameworks` -> `PHP` -> `Servers`
File/Directory : /home/phpdeveleoper/project/ezpsite
Absolute path on the server : /var/www


# Debugging eZ Platform with XDebug and PHPStorm

Note : This chapter is about how to enabled debugging in eZ Platform, not eZ Publish Platform

In `.env`, add following variable (substitute `192.168.0.1` with your real IP)

```
# Insert the IP your computer here. xdebug inside the container will try to reach phpstorm using this IP
DOCKERHOST=192.168.0.1
```

Also, in `.env`, add `:external/ezp-toolkit/ezplatform/xdebug.yml` to `COMPOSE_FILE` variable

# Usefull commands

Get some more tools in the app container

```
    docker-compose exec app bash
    apt-get update; apt-get install -y vim less openssh-client procps mysql-client
```

Remove all cache if you use legacy bridge ( PS : your var_dir in legacy might be called ezflow_site or someting similar) :

```
    rm -Rf ezpublish_legacy/var/cache/* ezpublish_legacy/var/ezdemo_site/cache/* var/cache/*/*
```


## Typically things to do after installing legacy bridge

```
    # copy settings/override and settings/siteaccess to src/legacy_files/settings/

    # Generate autoloads
    cd ezpublish_legacy
    php bin/php/ezpgenerateautoloads.php -e

    # Run composer scripts once or twice :
    composer symfony-scripts
    composer symfony-scripts

    # FYI : The above comands with among other things run (which makes symlinks from src/ to ezpublish_legacy/...:
    # php bin/console ezpublish:legacy:symlink

    # If you have custom extensions in src/AppBundle/ezpublish_legacy/, symlink them  using:
    # php bin/console ezpublish:legacybundles:install_extensions

    # Or run the following script (which will do all of this in one go)
    composer legacy-scripts

```

Add the rewrite rules to `doc/nginx/ez_params.d/ez_rewrite_params` :

```
    (...)
    rewrite "^/var/([^/]+/)?storage/images(-versioned)?/(.*)" "/var/$1storage/images$2/$3" break;
    rewrite "^/var/([^/]+/)?cache/(texttoimage|public)/(.*)" "/var/$1cache/$2/$3" break;
    rewrite "^/design/([^/]+)/(stylesheets|images|javascript|fonts)/(.*)" "/design/$1/$2/$3" break;
    rewrite "^/share/icons/(.*)" "/share/icons/$1" break;
    rewrite "^/extension/([^/]+)/design/([^/]+)/(stylesheets|flash|images|lib|javascripts?)/(.*)" "/extension/$1/design/$2/$3/$4" break;
    rewrite "^/packages/styles/(.+)/(stylesheets|images|javascript)/([^/]+)/(.*)" "/packages/styles/$1/$2/$3/$4" break;
    rewrite "^/packages/styles/(.+)/thumbnail/(.*)" "/packages/styles/$1/thumbnail/$2" break;
    rewrite "^/var/storage/packages/(.*)" "/var/storage/packages/$1" break;

    rewrite "^(.*)$" "/app.php$1" last;
```

And restart web container

```
    docker-compose stop web; docker-compose up -d
```

# Install Ibexa DXP 3.3 and later in docker containers

This repo contains a helper script for running Ibexa DXP in docker containers.

## Usage

- First clone this repo ( for instance in the subdirectory ezp-toolkit/ )
- Make sure you have a `~/.composer/auth.json` which have credentials to updates.ibexa.co
- Next, execute:
  `./ezp-toolkit/ibexa/install_dxp.sh experience projectvtest vtest 3.3.21`
  - `experience` is the flavour (content, experience, commerce)
    - commerce not tested ATM
  - `projectvtest` is the PROJECT_NAME used by docker-compose when naming the containers
  - `vtest` is the target directory where the installation will be created
  - '3.3.21' is the version you want to install
 

