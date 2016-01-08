# dockerized drupal development box
#
# VERSION               1
# DOCKER-VERSION        1
FROM    debian:wheezy

MAINTAINER Stephan Maximilian Huber <stephan@factorial.io>

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing && apt-get -y install git mysql-client mysql-server apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny php5-mysql php-apc php5-gd php5-curl php5-memcache memcached openssh-server vim curl graphviz make php5-dev php-pear php5-mcrypt imagemagick cron

# composer and drush
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN /usr/local/bin/composer global require drush/drush:dev-master
RUN sed -i '1i export PATH="/.composer/vendor/bin:$HOME/.composer/vendor/bin:$PATH"' /root/.bashrc
RUN $HOME/.composer/vendor/bin/drush dl registry_rebuild --default-major=7

# xhprof
RUN pecl install xhprof-beta

RUN echo "extension=apc.so" >> /etc/php5/apache2/php.ini

# sshd
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

# configure apache
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default
RUN a2enmod rewrite vhost_alias headers

VOLUME ["/var/lib/mysql", "/var/www"]


RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./php.ini /etc/php5/apache2/php.ini
ADD ./mysql.cnf /etc/mysql/conf.d/mysql.cnf
ADD ./xhprof.conf /etc/apache2/conf.d/xhprof.conf
ADD ./phpsendmail /usr/local/bin/phpsendmail
RUN chmod +x /usr/local/bin/phpsendmail
RUN touch /var/log/mail_php.log
RUN chmod 777 /var/log/mail_php.log
RUN touch /var/log/php_errors.log
RUN chmod 777 /var/log/php_errors.log

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
