# Various database scripts

Here is a few db tools

# delete_tables.sh

Script for deleting all database tables in db ( in case you can't/won't delete the whole database and create it from scratch)

Locally run:

```
    docker-compose exec --user www-data app bash
    ./external/ezp-toolkit/database/delete_tables.sh ezp SetYourOwnPassword ezp

    # Due to foreign key contrain, run the script again:
    ./external/ezp-toolkit/database/delete_tables.sh ezp SetYourOwnPassword ezp
```

#Upgrade database from eZ Publish Platform 5.4 to eZ Platform 2.5

## DFS

If your database do not contain dfs tables, remove line about `vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.1.0-to-7.2.0-dfs.sql` in `./external/ezp-toolkit/database/upgrade_db.sh local`

## UTF8

If your database already is in utf8mb4, you edit `./external/ezp-toolkit/database/upgrade_db.sh` and remove line where `external/ezp-toolkit/utf8altertable.sql` is imported

```
    docker-compose exec --user www-data app bash
    ./external/ezp-toolkit/database/upgrade_db.sh local
```

Various scripts for help upgrading ezpublish to ezplatform

# Using legacy apache docker

You may want to run legacy directly from ezpublish_legacy/ folder. To do that:

## Alter .env file

Add `:external/ezp-upgrade-toolkit/docker/legacy-apache.yml` to the end of the COMPOSE_FILE variable in `.env`

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
