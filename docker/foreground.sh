#!/bin/bash
set -x
read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

sed -i "s#/var/www#${WEB_ROOT}#g" /etc/apache2/sites-available/default
sed -i "s#/var/www#${WEB_ROOT}#g" /etc/apache2/conf.d/security

/usr/bin/htpasswd -b -c /etc/htpasswd ${PROJECT_NAME} ${PROJECT_NAME}
source /etc/apache2/envvars
apache2 -D FOREGROUND
