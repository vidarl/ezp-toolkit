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

function createEETables
{
    if [ ! -f external/ezp-toolkit/database/ezplatform-ee-installer-schema_no_drop_table.sql ]; then
        echo "Downloading https://raw.githubusercontent.com/ezsystems/ezplatform-ee-installer/2.4/Resources/sql/schema.sql..."
        curl -sf https://raw.githubusercontent.com/ezsystems/ezplatform-ee-installer/2.4/Resources/sql/schema.sql > external/ezp-toolkit/database/ezplatform-ee-installer-schema.sql
        # Making it less descructive by removing drop tables...
        cat external/ezp-toolkit/database/ezplatform-ee-installer-schema.sql | grep -vi "DROP TABLE IF EXISTS" > external/ezp-toolkit/database/ezplatform-ee-installer-schema_no_drop_table.sql
    else
        echo "external/ezp-toolkit/database/ezplatform-ee-installer-schema.sql already exists. Skip downloading it again."
    fi
    echo "ezplatform-ee-installer-schema_no_drop_table.sql:"
    $mysqlcmd < external/ezp-toolkit/database/ezplatform-ee-installer-schema_no_drop_table.sql
}

echo -n "Upgrading db..."
#sleep 5
echo "Started!"

if [ -f external/ezp-toolkit/custom_pre_upgrade.sql ]; then
    echo "custom_pre_upgrade.sql"
    $mysqlcmd < external/ezp-toolkit/custom_pre_upgrade.sql
else
    echo "Skipping custom_pre_upgrade.sql"
fi

# EE domain
echo "Creating eZ Platform EE tables (not applicable if using community version)"
createEETables

echo "dbupdate-5.4.0-to-6.13.0.sql:"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-5.4.0-to-6.13.0.sql

echo "dbupdate-7.1.0-to-7.2.0.sql:"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.1.0-to-7.2.0.sql

echo "Skipping dbupdate-7.1.0-to-7.2.0-dfs.sql. Enable it if using DFS !!!!"
#$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.1.0-to-7.2.0-dfs.sql

echo "dbupdate-7.2.0-to-7.3.0.sql"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.2.0-to-7.3.0.sql

echo "dbupdate-7.4.0-to-7.5.0.sql"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.4.0-to-7.5.0.sql

echo "dbupdate-7.5.2-to-7.5.3.sql"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.5.2-to-7.5.3.sql

echo "dbupdate-7.5.4-to-7.5.5.sql"
$mysqlcmd < vendor/ezsystems/ezpublish-kernel/data/update/mysql/dbupdate-7.5.4-to-7.5.5.sql

if [ -f external/ezp-toolkit/custom_upgrade.sql ]; then
    echo "custom_upgrade.sql"
    $mysqlcmd < external/ezp-toolkit/custom_upgrade.sql
else
    echo "Skipping custom_upgrade.sql"
fi

echo -e "\neZ Platform 2.3 scripts"
# Form builder is EE domain
php bin/console cache:clear
echo "Running form builder script, see https://doc.ezplatform.com/en/2.5/updating/4_update_2.3/#form-builder on how to customize"
php bin/console ezplatform:form-builder:create-forms-container
# Customizing it : php bin/console ezplatform:form-builder:create-forms-container --content-type custom --field title --value 'My Forms' --field description --value 'Custom container for the forms' --language-code eng-US
echo "You manually have to create the Form Builder content type. See url above for more info"

echo -e "\neZ Platform 2.4 issues"
# Form builder is EE domain
echo "Follow chapter 'Changes to the Forms folder' on https://doc.ezplatform.com/en/2.5/updating/4_update_2.4/#changes-to-the-forms-folder"
echo "Section of Forms folder has changed, 'content/read' policy needed for anonymous user"

echo "Configuration of custom tags has changed slightly : https://doc.ezplatform.com/en/2.5/updating/4_update_2.4/#changes-to-custom-tags"

echo -e "\neZ Platform 2.5 issues"
echo "Skipping migrating eZ matrix in case you want to use legacy bridge. More info : https://doc.ezplatform.com/en/2.5/updating/4_update_2.5/#changes-to-matrix-field-type"
# bin/console ezplatform:migrate:legacy_matrix

# Page builder is EE domain
echo "Adding Page builder indexes: database/ezp25_pagebuilder_indexes.sql"
$mysqlcmd < external/ezp-toolkit/database/ezp25_pagebuilder_indexes.sql

# Only run this if you want to update utf8altertable.sql
echo "show tables" | $mysqlcmd > external/ezp-toolkit/database/tables.txt
# Make sure there is no debug out in script
#echo Finding tables to convert to utf8
./external/ezp-toolkit/database/create_alter_table_utf.sh external/ezp-toolkit/database/tables.txt > external/ezp-toolkit/database/utf8altertable.sql

echo -e "\nutf8altertable.sql"
time $mysqlcmd < external/ezp-toolkit/database/utf8altertable.sql

echo -e "\nNote : This script skip db updates related to Page Builder"
echo "See these resources for more info on how to upgrade: "
echo "- https://doc.ezplatform.com/en/2.5/migrating/migrating_from_ez_publish_platform/#migrating-legacy-page-field-ezflow-to-new-page-enterprise"
echo "- https://doc.ezplatform.com/en/2.5/updating/4_update_2.2/#page-builder"
echo "- https://doc.ezplatform.com/en/2.5/updating/4_update_2.2/#migrate-custom-blocks"

echo -e "\nNote this script does not migrate ezflow --> pagebuilder"
echo "For ezflow upgrade see:"
echo "- https://doc.ezplatform.com/en/2.5/migrating/migrating_from_ez_publish_platform/#migrating-legacy-page-field-ezflow-to-new-page-enterprise"
echo "- https://doc.ezplatform.com/en/2.5/updating/4_update_2.2/#migrate-landing-pages"

echo -e "\nNote this script does not migrate ezxmltext --> richtext"
echo "For ezxmltext to richttext see :"
echo "- https://doc.ezplatform.com/en/2.5/migrating/migrating_from_ez_publish_platform/#321-migrate-xmltext-content-to-richtext"

echo -e "\nDone. Remember to clear all caches, including Redis ( if you are using that )"

# sql for setting standard admin pwd
#update ezuser set password_hash='c78e3b0f3d9244ed8c6d1c29464bdff9', password_hash_type=2 where login='admin';
