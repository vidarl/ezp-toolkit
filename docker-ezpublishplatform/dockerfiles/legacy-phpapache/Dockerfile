FROM php:5.6-apache


# Set defaults for variables used by run.sh
# If you change MAX_EXECUTION TIME, also change fastcgi_read_timeout accordingly in nginx!
ENV DEBIAN_FRONTEND=noninteractive \
    TIMEZONE=Europe/Warsaw \
    MEMORY_LIMIT=556M \
    MAX_EXECUTION_TIME=90


RUN apt-get update -q -y \
 && apt-get install -q -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libxpm-dev \
        libpng-dev \
        libicu-dev \
        libxslt1-dev \
        default-mysql-client \
        curl \
        wget \
        ca-certificates \
        less \
        vim \
        git \
        acl \
        sudo \
        tree \
        unzip \
        && rm -rf /var/lib/apt/lists/*

# Install and configure php plugins
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
 && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ --with-xpm-dir=/usr/include/ --enable-gd-native-ttf --enable-gd-jis-conv \
 && docker-php-ext-install exif gd mbstring intl xsl zip mysqli pdo_mysql \
 && docker-php-ext-enable opcache

RUN a2enmod rewrite

COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-phpapache/apache2.conf /etc/apache2/apache2.conf
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-phpapache/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-phpapache/php.ini /etc/php/5.6/apache2/php.ini
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-phpapache/php.ini /etc/php/5.6/cli/php.ini


# Set timezone
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata




# Set some php.ini config
RUN echo "date.timezone = $TIMEZONE" >> /usr/local/etc/php/php.ini \
 && echo "memory_limit = $MEMORY_LIMIT" >> /usr/local/etc/php/php.ini \
 && echo "realpath_cache_size = 256k" >> /usr/local/etc/php/php.ini \
 && echo "display_errors = Off" >> /usr/local/etc/php/php.ini \
 && echo "max_execution_time = $MAX_EXECUTION_TIME" >> /usr/local/etc/php/php.ini

#RUN chmod 755 /*.sh
#RUN groupadd -g 10000 ez && useradd -g ez -u 10000 ez

# Change uid to match eZ Platform docker setup
RUN usermod -u 1000 www-data

WORKDIR /var/www

#CMD /run.sh
