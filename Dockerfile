FROM ubuntu:12.04

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
			org.label-schema.name="openshift-php4" \
			org.label-schema.description="php4 httpd non root container" \
			org.label-schema.url="http://andradaprieto.es" \
			org.label-schema.vcs-ref=$VCS_REF \
			org.label-schema.vcs-url="https://github.com/jandradap/openshift-php4" \
			org.label-schema.vendor="Jorge Andrada Prieto" \
			org.label-schema.version=$VERSION \
			org.label-schema.schema-version="1.0" \
			maintainer="Jorge Andrada Prieto <jandradap@gmail.com>" \
			org.label-schema.docker.cmd=""

RUN apt-get update \
  && apt-get install -y \
      apt-utils \
      autoconf \
      bc \
      bison \
      build-essential \
      bzip2 \
      ca-certificates \
      file \
      flex \
      g++ \
      gcc \
      git \
      imagemagick \
      libaspell-dev \
      libbz2-dev \
      libc-client2007e-dev \
      libc-dev \
      libcurl4-openssl-dev \
      libfontconfig1-dev \
      libfreetype6-dev \
      libgd2-xpm-dev \
      libgpg-error-dev \
      libjpeg-dev \
      libmagickwand-dev \
      libmcrypt-dev \
      libmcrypt4 \
      libmhash-dev \
      libpng-dev \
      libpq-dev \
      libreadline6-dev \
      librecode0 \
      libsnmp-dev \
      libsqlite3-0 \
      libsqlite3-dev \
      libt1-dev \
      libxml2 \
      libldap2-dev \
      libldb-dev \
      make \
      php5-gd \
      libphp-adodb \
      pkg-config \
      re2c \
      uuid-dev \
      vim \
      wget \
      zlib1g-dev \
      apache2 \
      elinks \
      apache2-threaded-dev \
      apache2.2-common \
      --no-install-recommends \
      graphicsmagick spawn-fcgi \
  && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
  && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
  && ldconfig \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/*

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html \
  && useradd default -u 1001 -c "Default Application User" -G www-data -d /var/www/html -s /sbin/nologin \
  && chown -R default:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

RUN mkdir -p /tmp/install/ \
  && cd /tmp/install \
  && wget http://www.ijg.org/files/jpegsrc.v7.tar.gz \
  && tar xzf jpegsrc.v7.tar.gz \
  && cd jpeg-7 \
  && ./configure --prefix=/usr/local --enable-shared --enable-static \
  && make \
  && make install \
  && cd /tmp/install \
  && wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.0.tar.gz \
  && tar zxf freetype-2.4.0.tar.gz \
  && cd freetype-2.4.0 \
  && ./configure \
  && make \
  && make install \
  && cd /tmp/install \
  && wget --no-check-certificate  https://curl.haxx.se/download/archeology/curl-7.12.0.tar.gz \
  && tar zxvf curl-7.12.0.tar.gz \
  && cd curl-7.12.0 \
  && ./configure --without-ssl \
  && make \
  && make install \
  && cd \
  && rm -rf /tmp/install

ENV PHP_VERSION 4.4.9
RUN mkdir -p /tmp/install/ \
  && cd /tmp/install \
  && wget http://museum.php.net/php4/php-${PHP_VERSION}.tar.bz2 \
  && tar xfj php-${PHP_VERSION}.tar.bz2 \
  && cd php-${PHP_VERSION} \
  && cp /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/ \
  && cd /tmp/install/php-${PHP_VERSION} \
  && ./configure \
      --with-libdir=lib64 \
      --with-tsm-pthreads \
      --enable-maintainer-zts \
      --enable-debug \
      --disable-rpath \
      --enable-bcmath \
      --enable-ctype \
      --enable-exif \
      --enable-fastcgi \
      --enable-ftp \
      --enable-gd-native-ttf \
      --enable-inline-optimization \
      --enable-intl \
      --enable-mbregex \
      --enable-mbstring \
      --enable-pcntl \
      --enable-soap  \
      --enable-sockets \
      --enable-sysvsem \
      --enable-sysvshm \
      --enable-zip \
      --with-apxs2=/usr/bin/apxs2 \
      --with-bz2 \
      --with-config-file-path=/etc/php4 \
      --with-config-file-path=/etc \
      --with-config-file-scan-dir=/etc/php4/conf.d \
      --with-curl \
      --with-gettext \
      --with-iconv \
      --with-libdir=lib/x86_64-linux-gnu \
      --with-libxml-dir=/usr \
      --with-mcrypt \
      --with-mhash \
      --with-mysql \
      --with-mysqli \
      --with-ldap \
      --with-pcre-regex \
      --with-pdo-mysql \
      --with-pgsql \
      --without-snmp \
      --without-sapi \
      --disable-sapi \
      --with-t1lib=/usr \
      --with-tidy \
      --with-gd \
      --with-png-dir=/usr \
      --with-jpeg-dir=/usr \
      --with-freetype-dir=shared,/usr \
      --with-zlib \
      --with-zlib-dir=/usr \
      --with-xsl \
  && make \
  && make install \
  && rm -rf /tmp/install \
  && mkdir -p /var/lib/php/session \
  && chown -R default:www-data /var/lib/php/ \
  && chmod -R a+rwx /var/lib/php/session

RUN mkdir -p /etc/php4/conf.d/ \
  && echo 'date.timezone = "Europe/Madrid"' > /etc/php4/conf.d/10_timezone.ini

COPY config/php.ini /etc/
COPY config/docker-php-ext-* /usr/local/bin/
COPY config/apache/apache2.conf /etc/apache2/
COPY config/apache/000-default /etc/apache2/sites-available/default
COPY config/apache/ports.conf /etc/apache2/

COPY code/index.php /var/www/html/

RUN sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=default/g" /etc/apache2/envvars \
  && sed -i "s/APACHE_PID_FILE=\/var\/run\/apache2/APACHE_PID_FILE=\/var\/run\/apache2\/apache2/g" /etc/apache2/envvars \
  && chown -R default /var/run/apache* \
  && chown -R default /etc/apache2 \
  && chown -R default /var/lib/php/session \
  && chown -R default /var/log/apache2 \
  && chmod -R a+rwx /var/log/apache2 \
  && chmod -R a+rwx /var/run/apache

WORKDIR /var/www/html

EXPOSE 8080 8443

USER default

ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
