#!/bin/bash
set -x
read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

sed -i "s#/var/www#${WEB_ROOT}#g" /etc/apache2/sites-available/default

source /etc/apache2/envvars
apache2 -D FOREGROUND
