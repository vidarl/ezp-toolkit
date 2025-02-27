#!/usr/bin/env bash

# Upgrade script from 3.3.33 to 4.6

set -e

username=$1
password=$2
db=$3
host=$4

if [ $# -ne 4 ]; then
    echo Usage: upgrade_4.6/upgrade_db_from_3.3_to_4.6.sh [username] [password] [db] [host]
    exit 1
fi

#is_system from ezcontentclassgroup

function mysqlcmd
{
    echo Running sql : $1
    mysql -u $username -p$password $db -h $host < $1
    rm -rf var/cache
}

if [ ! -d external/installer ]; then
  echo Please run the following command to checkout ibexa/installer:
  echo cd external
  echo git clone git@github.com:ibexa/installer.git
  echo cd ..
  exit 1
fi


echo "Upgrading schema"
mysqlcmd external/installer/upgrade/db/mysql/ibexa-3.3.33-to-3.3.34.sql

php bin/console ibexa:content:remove-duplicate-fields

# vendor/ibexa/installer/upgrade/db/mysql/ibexa-3.3.34-to-3.3.35.sql <--- not mentioned in upgrade docs
# cat vendor/ibexa/installer/upgrade/db/mysql/ibexa-3.3.34-to-3.3.35.sql
# -- IBX-6255: Form builder's `field_id` columns in some tables require indices to improve performance
# ALTER TABLE `ezform_field_attributes` ADD INDEX `ezform_fa_f_id` (`field_id`);
# ALTER TABLE `ezform_field_validators` ADD INDEX `ezform_fv_f_id` (`field_id`);


# Following only applies to content/experience/commerce
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-3.3.latest-to-4.0.0.sql


# https://doc.ibexa.co/en/latest/update_and_migration/from_3.3/to_4.0/#ibexa-open-source
echo 'Running sql : ALTER TABLE `ezcontentclassgroup` ADD COLUMN `is_system` BOOLEAN NOT NULL DEFAULT false;'
echo 'ALTER TABLE `ezcontentclassgroup` ADD COLUMN `is_system` BOOLEAN NOT NULL DEFAULT false;' | mysql -u $username -p$password $db -h $host
rm -rf var/cache


#note : on OSS, the `doctrine:schema:update` command will return no SQLs, therefore next line is commented out:
#mysqlcmd upgrade_4.6/doctrine_schema_update_on_4.0.8.sql


# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.0.3-to-4.0.4.sql

# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.0.0-to-4.1.0.sql

# Skip on OSS
#vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.1.0-to-4.1.1.sql

# Skip on OSS
#vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.1.5-to-4.1.6.sql

# Skip on OSS
#php bin/console ibexa:migrations:import vendor/ibexa/product-catalog/src/bundle/Resources/migrations/2022_06_23_09_39_product_categories.yaml --name=013_product_categories.yaml
#php bin/console ibexa:migrations:import vendor/ibexa/corporate-account/src/bundle/Resources/migrations/corporate_account.yaml --name=001_corporate_account.yaml
#php bin/console ibexa:migrations:import vendor/ibexa/corporate-account/src/bundle/Resources/migrations/corporate_account_commerce.yaml --name=002_corporate_account_commerce.yaml
#php bin/console ibexa:migrations:migrate


# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.1.latest-to-4.2.0.sql
# Instead do only this table:
echo "
CREATE TABLE IF NOT EXISTS ibexa_user_invitations
(
    id               int auto_increment primary key,
    email            varchar(255) not null,
    site_access_name varchar(255) not null,
    hash             varchar(255) not null,
    creation_date    int          not null,
    used             tinyint(1)   null,
    constraint ibexa_user_invitations_email_uindex
    unique (email(191)),
    constraint ibexa_user_invitations_hash_uindex
    unique (hash(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS ibexa_user_invitations_assignments
(
    id               int auto_increment primary key,
    invitation_id    int          not null,
    user_group_id    int          null,
    role_id          int          null,
    limitation_type  varchar(255) null,
    limitation_value varchar(255) null,
    constraint ibexa_user_invitations_assignments_ibexa_user_invitations_id_fk
    foreign key (invitation_id) references ibexa_user_invitations (id)
    on update cascade on delete cascade
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_general_ci
;" \
 |  mysql -u $username -p$password $db -h $host

# Skip on OSS
 # mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.2.2-to-4.2.3.sql

## to 4.3

# Skip on OSS
# php bin/console ibexa:migrations:import vendor/ibexa/corporate-account/src/bundle/Resources/migrations/corporate_account_registration.yaml --name=012_corporate_account_registration.yaml
# php bin/console ibexa:migrate:customers  --input-user-group=3a3beb3d09ae0dacebf1d324f61bbc34 --create-content-type
# php bin/console ibexa:migrations:migrate

# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.2.latest-to-4.3.0.sql
# php bin/console ibexa:taxonomy:remove-orphaned-content tags --force
# php bin/console ibexa:taxonomy:remove-orphaned-content product_categories --force


## to 4.4
# Skip on OSS
# Remove deprecated field types


# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/commerce/ibexa-4.3.latest-to-4.4.0.sql
# drop ses_ tables

## to 4.5

echo "Migrate richtext namespaces..."
php bin/console ibexa:migrate:richtext-namespaces

# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.4.latest-to-4.5.0.sql
# Instead just deal with token tables:
echo "Creating tables ibexa_token_type amd ibexa_token"
echo "CREATE TABLE ibexa_token_type
(
    id int(11) NOT NULL AUTO_INCREMENT,
    identifier varchar(64) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY ibexa_token_type_unique (identifier)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE TABLE ibexa_token
(
    id int(11) NOT NULL AUTO_INCREMENT,
    type_id int(11) NOT NULL,
    token varchar(255) NOT NULL,
    identifier varchar(128) DEFAULT NULL,
    created int(11) NOT NULL DEFAULT 0,
    expires int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY ibexa_token_unique (token,identifier,type_id),
    CONSTRAINT ibexa_token_type_id_fk
        FOREIGN KEY (type_id) REFERENCES ibexa_token_type (id)
            ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;" \
 |  mysql -u $username -p$password $db -h $host


# Skip on OSS
# "Clean-up taxonomy database"
# "Run data migration"


#
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.5.1-to-4.5.2.sql
# Adding all sqls in that file, but doing it one-by-one as 1,3,4 are likely duplicates:

echo "Creating indexes. 3 indexes are likely duplicates:";
echo "ALTER TABLE ezcontentobject_link ADD INDEX ezco_link_cca_id (\`contentclassattribute_id\`);" |  mysql -u $username -p$password $db -h $host || /bin/true
echo "ALTER TABLE ezcontentclass_attribute ADD INDEX ezcontentclass_attr_dts (\`data_type_string\`);" |  mysql -u $username -p$password $db -h $host || /bin/true
echo "ALTER TABLE ezurl_object_link ADD INDEX ezurl_ol_coa_id_cav (\`contentobject_attribute_id\`,\`contentobject_attribute_version\`);" |  mysql -u $username -p$password $db -h $host || /bin/true
echo "ALTER TABLE ezcontentobject_attribute ADD INDEX ezcontentobject_attribute_co_id_ver (\`contentobject_id\`,\`version\`);" |  mysql -u $username -p$password $db -h $host || /bin/true
echo "Done creating indexes";


# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.5.2-to-4.5.3.sql
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.5.3-to-4.5.4.sql



## Skipped for now
#echo Changing charset and collation
#mysqlcmd upgrade_4.6/update_collate_custom_preperations.sql
## Change charset and collation of all tables (to utf8mb4, utf8mb4_unicode_520_ci):
#echo "show tables" | mysql -u $username -p$password $db -h $host >upgrade_4.6/tables.txt; tail -n +2 "upgrade_4.6/tables.txt" > upgrade_4.6/tables.txt2; mv upgrade_4.6/tables.txt2 upgrade_4.6/tables.txt
#./upgrade_4.6/update_collate.sh > update_collate.sql
#mysqlcmd update_collate.sql
#rm update_collate.sql



# Todo : Updates are missing from doc
# doc says  that only sql for ibexa_token should be applied
# Run selected SQLS for ibexa_token should be executed : https://doc.ibexa.co/en/latest/update_and_migration/from_4.5/update_from_4.5/#ibexa-open-source
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.5.latest-to-4.6.0.sql
echo "
ALTER TABLE ibexa_token
    ADD COLUMN revoked BOOLEAN NOT NULL DEFAULT false;

-- Rewrites max file size values from data_int1 to data_float1 column and stores size unit
UPDATE ezcontentclass_attribute
SET data_float1 = CAST(data_int1 AS DOUBLE), data_int1 = NULL, data_text1 = 'MB'
WHERE data_type_string = 'ezimage';

UPDATE ezcontentclass_attribute SET is_searchable = 1 WHERE data_type_string = 'ezimage' AND contentclass_id = (SELECT id FROM ezcontentclass WHERE identifier = 'image');" \
 |  mysql -u $username -p$password $db -h $host


# Skip on OSS
# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.6.1-to-4.6.2.sql


# mysqlcmd vendor/ibexa/installer/upgrade/db/mysql/ibexa-4.6.3-to-4.6.4.sql
# Content of that .sql should be applied:
echo "
-- IBX-6592: The state/assign policy shouldn't utilize neither Location nor Subtree limitations
DELETE l
FROM \`ezpolicy_limitation\` l
INNER JOIN \`ezpolicy\` p ON p.id = l.policy_id
WHERE p.function_name = 'assign'
  AND p.module_name = 'state'
  AND l.identifier IN ('Node', 'Subtree');

DELETE lv
FROM \`ezpolicy_limitation_value\` lv
LEFT JOIN \`ezpolicy_limitation\` ON \`ezpolicy_limitation\`.id = lv.limitation_id
WHERE \`ezpolicy_limitation\`.id IS NULL; " \
 |  mysql -u $username -p$password $db -h $host

php bin/console ibexa:content:remove-duplicate-fields


echo DB upgrade completed
