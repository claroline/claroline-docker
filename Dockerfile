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
  php-gd \
  npm \
  apache2-utils \
  php-mbstring \
  php-gettext

RUN npm cache clean -f \
  && npm install -g n \
  && n 5.11.1

RUN a2enmod rewrite

WORKDIR /var/www/html
RUN rm index.html

RUN git clone http://github.com/claroline/Claroline claroline

COPY files/claroline/parameters.yml /var/www/html/claroline/app/config/
COPY files/apache2/claroline.conf /etc/apache2/sites-available/

WORKDIR /var/www/html/claroline
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
# This needs to be a tag, once the repo is tagged
# RUN git checkout 7.x
RUN /bin/bash -c "/usr/bin/mysqld_safe &" && sleep 5 && echo "create database claroline" | mysql -u root -proot
RUN /bin/bash -c "/usr/bin/mysqld_safe &" && sleep 5 && composer sync
RUN /bin/bash -c "/usr/bin/mysqld_safe &" && sleep 5 && php app/console claroline:user:create -a John Doe admin pass admin@test.com
RUN chmod -R 777 /var/www/html/claroline/app/cache /var/www/html/claroline/app/logs /var/www/html/claroline/app/config /var/www/html/claroline/app/sessions /var/www/html/claroline/files /var/www/html/claroline/web/uploads
RUN a2dissite 000-default && a2ensite claroline.conf

# Install supervisor to allow starting mutliple processes
RUN        mkdir -p /var/log/supervisord && \
           mkdir -p /etc/supervisor/conf.d

# Add supervisor configuration
ADD        files/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]
