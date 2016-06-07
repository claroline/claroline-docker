#!/usr/bin/env bash
sleep 10
mysql --user=root --password=root -e "SET GLOBAL sql_mode=''"
cd /var/www/http/claroline/
php app/console claroline:user:create -a John Doe admin pass admin@test.com
