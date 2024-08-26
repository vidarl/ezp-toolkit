#!/bin/bash

set -e

ip0=`getent hosts redis0 | awk '{ print $1 }'` ip1=`getent hosts redis1 | awk '{ print $1 }'` ip2=`getent hosts redis2 | awk '{ print $1 }'` ip3=`getent hosts redis3 | awk '{ print $1 }'` ip4=`getent hosts redis4 | awk '{ print $1 }'` ip5=`getent hosts redis5 | awk '{ print $1 }'`

touch /var/www/.env.local
cat /var/www/.env.local|grep "CACHE_DSN=" || echo -e "\nCACHE_DSN=foobar" >> /var/www/.env.local
sed -ie 's/CACHE_DSN=.*/CACHE_DSN='"${ip0}:7000?host[${ip1}:7000]\&host[${ip2}:7000]\&host[${ip3}:7000]\&host[${ip4}:7000]\&host[${ip5}:7000]\&redis_cluster=1"'/g' /var/www/.env.local


redis-cli --cluster create ${ip0}:7000 ${ip1}:7000 ${ip2}:7000 ${ip3}:7000 ${ip4}:7000 ${ip5}:7000 --cluster-replicas 1 --cluster-yes
redis-cli -h redis0 -c -p 7000 cluster info

while [ 1 ]; do echo .; sleep 10; done
