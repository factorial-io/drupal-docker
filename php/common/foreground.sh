#!/bin/bash
set -x
read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

# sed -i "s_/var/www/html_${WEB_ROOT}_g" /etc/apache2/sites-available/000-default.conf

source /etc/apache2/envvars

# Delete any leftovers
rm -rf $APACHE_PID_FILE

# Start apache
apache2 -D FOREGROUND
