#!/bin/bash

if [ ! -f "${WEB_ROOT}/sites/default/settings.php" ]; then
  if [ -n "${NO_INSTALL}" ]; then
    echo "skipping drupal setup, please setup manually."
    echo "mysql-user: admin drupal-user: admin pass: admin"
  else
    echo "setup drupal in ${WEB_ROOT}"
    # Start mysql
    mysql_install_db
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
    mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
    chmod 755 "${WEB_ROOT}/sites/default"
    cd "${WEB_ROOT}"
    drush site-install minimal -y --account-name=admin --account-pass=admin --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"
    drush en ${PROJECT_NAME}_deploy
    killall mysqld
    sleep 10s
  fi
fi
supervisord -n
