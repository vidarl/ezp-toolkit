-- https://doc.ezplatform.com/en/latest/updating/4_update_2.2/#page-builder
-- Page builder enterprise changes

ALTER TABLE `eznotification`
CHANGE COLUMN `data` `data` BLOB NULL ;

ALTER TABLE `eznotification`
DROP INDEX `owner_id` ,
ADD INDEX `eznotification_owner` (`owner_id` ASC);

ALTER TABLE `eznotification`
DROP INDEX `is_pending` ,
ADD INDEX `eznotification_owner_is_pending` (`owner_id` ASC, `is_pending` ASC);

