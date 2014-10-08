#!/bin/bash

if [ ! -d /var/lib/mysql/mysql ]; then
  echo "Installing database..."
  mysql_install_db --user=mysql >/dev/null 2>&1

  # start mysql server
  echo "Starting MySQL server..."
  /usr/bin/mysqld_safe >/dev/null 2>&1 &

  # wait for mysql server to start (max 30 seconds)
  timeout=30
  while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
  do
    timeout=$(($timeout - 1))
    if [ $timeout -eq 0 ]; then
      echo "Could not connect to mysql server. Aborting..."
      exit 1
    fi
    echo "Waiting for database server to accept connections..."
    sleep 1
  done

  ## create a localhost only, debian-sys-maint user
  ## the debian-sys-maint is used while creating users and database
  ## as well as to shut down or starting up the mysql server via mysqladmin
  echo "Creating debian-sys-maint user..."
  mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"

  mysqladmin -u root password admin
  mysqladmin -u root --password=admin shutdown
  sleep 10s

fi


if [ ! -f "${WEB_ROOT}/sites/default/settings.php" ]; then

  # Start mysql
  /usr/bin/mysqld_safe &
  sleep 10s
  # Generate passwords
  DRUPAL_DB="drupal"
  MYSQL_PASSWORD='admin'
  DRUPAL_PASSWORD='admin'
  # This is so the passwords show up in logs.
  echo mysql root password: $MYSQL_PASSWORD
  echo drupal password: $DRUPAL_PASSWORD
  mysqladmin -u root password $MYSQL_PASSWORD

  if [ -n "${NO_INSTALL}" ]; then
    echo "skipping drupal setup, please setup manually."
    echo "mysql-user: admin drupal-user: admin pass: admin"
  else
    echo "setup drupal in ${WEB_ROOT}"
    mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
    chmod 755 "${WEB_ROOT}/sites/default"
    cd "${WEB_ROOT}"
    drush site-install minimal -y --account-name=admin --account-pass=admin --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"
    drush en ${PROJECT_NAME}_deploy

  fi
  killall mysqld
  sleep 10s

fi
supervisord -n
