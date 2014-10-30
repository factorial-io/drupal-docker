# dockerfile for drupal

a docker configuration which will create a fully functional backend-stack to run a drupal installation

The docker container comes with 2 services, apache on 80 and ssh on 22. You will need to map your local installation to /var/www.

## Logins / Passwords

    ssh    : root:root
    mysql  : admin:admin
    drupal : admin: admin


## Installation

Make sure you don't have a settings.php file in sites/default of your drupal-installation. This will instruct the scripts to run a minimal drupal install and enable the project's deploy module.

## Running

    cd drupal-docker
    ./run.sh <project-name> <path-to-drupal-installation>

here's an example:

    ./run.sh myproject /vagrant

The run-script accepts several optional parametes:

* --http <port> public http-port
* --ssh <port> public ssh-port
* --vhost <name> sets an environment-var named VHOST, this will help in automated setups to get the virtual hostname via docker inspect
* --webRoot <root-folder> in case your drupal installation is part of a git repository you can set the webRoot explicitely
* --no-install will skip the installation part, useful if you use [Fabalicious](https://github.com/stmh/fabalicious) for deployment

Example:

    ./run.sh myproject /vagrant --http 80 --ssh 2222 --vhost myproject.dev



This will run drupal from the path /vagrant. and will create an image called myproject/latest and a container named myproject.

The script will create all necessary docker images and install a minimal drupal if no settings.php is found.

## XHProf-Support

The docker-image install xhprof, if you want to use it with the devel module, use these settings:

    XHProf-directory: /usr/share/php
    XHProf URL:       http://<host>/xhprof

## Todo

* phpmyadmin does not work
