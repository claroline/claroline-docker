FROM ubuntu:16.04

MAINTAINER Donovan Tengblad

# Install packages
ENV DEBIAN_FRONTEND noninteractive

RUN echo "mysql-server-5.6 mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server-5.6 mysql-server/root_password_again password root" | debconf-set-selections

RUN apt-get update && apt-get install -y \
  supervisor \
  vim \
  git \
  wget \
  curl \
  apache2 \
  unzip \
  zip \
  xz-utils \
  php-zip \
  mysql-client \
  mysql-server \
  xfonts-75dpi \
  libav-tools \
  php \
  libapache2-mod-php \
  libav-tools \
  wkhtmltopdf \
  php-xml \
  php-mcrypt \
  php-mysql \
  php-curl \
  php-intl \
  npm \
  apache2-utils \
  php-mbstring \
  php-gettext

RUN npm cache clean -f \
  && npm install -g n \
  && n latest

RUN a2enmod rewrite

WORKDIR /var/www/html
RUN rm index.html
RUN wget http://packages.claroline.net/releases/16.05/claroline-16.05.tar.gz
RUN tar -xzf claroline-16.05.tar.gz
RUN rm claroline-16.05.tar.gz
RUN mv claroline-16.05 claroline

COPY files/claroline/parameters.yml /var/www/html/claroline/app/config/

WORKDIR /var/www/html/claroline
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
RUN /bin/bash -c "/usr/bin/mysqld_safe &" && composer fast-install
RUN chmod -R 777 /var/www/html/claroline/app/cache /var/www/html/claroline/app/logs /var/www/html/claroline/app/config /var/www/html/claroline/app/sessions /var/www/html/claroline/files /var/www/html/claroline/web/uploads

RUN /bin/bash -c "/usr/bin/mysqld_safe &" && \
  sleep 20 && \
  mysql --user=root --password=root -v -e "set global sql_mode=''" && \
  composer fast-install && \
  php app/console claroline:user:create -a John Doe admin pass admin@test.com

COPY files/apache2/claroline.conf /etc/apache2/sites-available/
RUN a2dissite 000-default && a2ensite claroline.conf
