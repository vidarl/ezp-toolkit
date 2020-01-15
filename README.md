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