#!/bin/sh
set -e

echo "Init DB client credentials"

rm -f ~/.my.cnf
cat > ~/.my.cnf << EOF
[mysqldump]
user=${MYSQL_ROOT_USER}
password=${MYSQL_ROOT_PASSWORD}
[mysql]
user=${MYSQL_ROOT_USER}
password=${MYSQL_ROOT_PASSWORD}
EOF