#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "Error: param 1 (filename) missing"
fi
filename=$1

while IFS='' read -r line || [[ -n "$line" ]]; do
    if [ $line == "Tables_in_main" ]; then
        continue;
    fi
    #echo show create table $line ';' | platform sql -e master|grep -v 'CHARSET=utf8'
    echo show create table $line ';' | mysql -u ezp -pSetYourOwnPassword ezp -h db|grep -v 'CHARSET=utf8'
done < "$filename"
