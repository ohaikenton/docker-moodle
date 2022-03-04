FROM ubuntu:20.04

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
 
# Basic Requirements
RUN apt-get -y install mysql-server mysql-client pwgen python3-pip curl git unzip supervisor

# Moodle Requirements
RUN apt-get -y install apache2 php7.4 php7.4-gd libapache2-mod-php7.4 postfix wget supervisor php7.4-pgsql vim curl libcurl4 php7.4-curl php7.4-xmlrpc php7.4-intl php7.4-mysql

# SSH
RUN apt-get -y install openssh-server
RUN mkdir -p /var/run/sshd

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# RUN python /usr/lib/python2.7/dist-packages/easy_install.py pip supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz
RUN cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html
RUN chown -R www-data:www-data /var/www/html/moodle
RUN mkdir /var/moodledata
RUN chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata
RUN chmod 755 /start.sh /etc/apache2/foreground.sh
RUN mkdir -p /var/run/mysqld
RUN chown mysql:mysql /var/run/mysqld

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]

