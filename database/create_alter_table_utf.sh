#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "Error: param 1 (filename) missing"
fi
filename=$1

echo "SET FOREIGN_KEY_CHECKS=0;"
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [ $line == "Tables_in_main" ]; then
        continue;
    fi

    if [ $line == "Tables_in_ezp" ]; then
        continue;
    fi

    if [ $line == "ezsearch_search_phrase" ]; then
        # Workaround if you get errors like for weird row in table. Table are not in use anyway, so this is quickfix
        # ERROR 1062 (23000) at line 95: Duplicate entry '.....' for key 'ezsearch_search_phrase_phrase'
        # Then enable utf8mb4_general_ci collation, or possibly a re-index will also solve the problem
        collation="utf8mb4_unicode_520_ci";
        #collation="utf8mb4_general_ci";
    else
        collation="utf8mb4_unicode_520_ci";
    fi
    echo "ALTER TABLE $line CONVERT TO CHARACTER SET utf8mb4 COLLATE $collation;"

    # For debug if you wanna see what tables cannot be converted
    #echo table : $line
    #echo "ALTER TABLE $line CONVERT TO CHARACTER SET utf8mb4 COLLATE $collation;" | platform sql -e master
    #echo "ALTER TABLE $line CONVERT TO CHARACTER SET utf8mb4 COLLATE $collation;" | mysql -u ezp -pSetYourOwnPassword ezp -h db
done < "$filename"
