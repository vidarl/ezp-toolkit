#!/bin/bash

set -e

if [ "$1" = "platformsh" ]; then
    TARGET="platformsh"
    mysqlcmd="platform db:sql --environment master"
    echo "WARNING target is platform. Hit Ctrl-C now if you don't want to do it"
    echo 'You might also want to run ssh-agent before continuing: eval `ssh-agent -s`; ssh-add'
    read
elif [ "$1" = "local" ]; then
    TARGET="local"
    mysqlcmd="mysql -u ezp -pSetYourOwnPassword ezp -h db"
else
    echo "Error :specify target"
    exit 1
fi

echo -n "Upgrading db..."
#sleep 5
echo "Started!"

if [ -f external/ezp-upgrade-toolkit/custom_pre_upgrade.sql ]; then
    echo "custom_pre_upgrade.sql"
    $mysqlcmd < external/ezp-upgrade-toolkit/custom_pre_upgrade.sql
else
    echo "Skipping custom_pre_upgrade.sql"
fi

echo "dbupdate-5.4.0-to-6.13.0.sql:"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-5.4.0-to-6.13.0.sql

echo "dbupdate-7.1.0-to-7.2.0.sql:"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.1.0-to-7.2.0.sql

echo "dbupdate-7.1.0-to-7.2.0-dfs.sql:"
#$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.1.0-to-7.2.0-dfs.sql

echo "dbupdate-7.2.0-to-7.3.0.sql"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.2.0-to-7.3.0.sql

echo "dbupdate-7.4.0-to-7.5.0.sql"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.4.0-to-7.5.0.sql

echo "dbupdate-7.5.2-to-7.5.3.sql"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.5.2-to-7.5.3.sql

if [ -f external/ezp-toolkit/custom_upgrade.sql ]; then
    echo "custom_upgrade.sql"
    $mysqlcmd < external/ezp-toolkit/custom_upgrade.sql
else
    echo "Skipping custom_upgrade.sql"
fi

# Only run this if you want to update utf8altertable.sql
echo "show tables" | $mysqlcmd > external/ezp-toolkit/database/tables.txt
# Make sure there is no debug out in script
#echo Finding tables to convert to utf8
./external/ezp-toolkit/database/create_alter_table_utf.sh external/ezp-toolkit/database/tables.txt > external/ezp-toolkit/database/utf8altertable.sql

echo "utf8altertable.sql"
time $mysqlcmd < external/ezp-toolkit/database/utf8altertable.sql

# sql for setting standard admin pwd
#update ezuser set password_hash='c78e3b0f3d9244ed8c6d1c29464bdff9', password_hash_type=2 where login='admin';
