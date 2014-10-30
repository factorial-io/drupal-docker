# dockerized drupal development box
#
# VERSION       1
# DOCKER-VERSION        1
FROM    debian:wheezy

MAINTAINER Stephan Maximilian Huber <hello@stephanmaximilianhuber.com>

#RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git mysql-client mysql-server apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny php5-mysql php-apc php5-gd php5-curl php5-memcache memcached phpmyadmin openssh-server vim curl

# composer and drush
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN /usr/local/bin/composer global require drush/drush:dev-master
RUN sed -i '1i export PATH="/.composer/vendor/bin:$HOME/.composer/vendor/bin:$PATH"' /root/.bashrc

RUN echo "extension=apc.so" >> /etc/php5/apache2/php.ini

# sshd
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

# configure apache
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default
RUN a2enmod rewrite vhost_alias

VOLUME ["/var/lib/mysql", "/var/www"]


RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./php.ini /etc/php5/apache2/php.ini

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
