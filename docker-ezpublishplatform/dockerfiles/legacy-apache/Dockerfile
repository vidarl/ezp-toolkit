FROM ubuntu:xenial
ADD https://deb.nodesource.com/node_0.10/pool/main/n/nodejs/nodejs_0.10.48-1nodesource1~wheezy1_amd64.deb nodejs.deb

RUN apt-get update -y && \
    #Install dependencies for front end asset compiling (Ruby sass and node js at 0.10.48)
    apt-get install ruby-full build-essential rubygems locales -y && \
    gem install sass && \
    apt-get remove ruby-full build-essential rubygems -y && \
    apt-get install ./nodejs.deb -y && \
    rm ./nodejs.deb && \
    #Lock down locale to UTF-8 as sass defaults to US-ASCII
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8

# Install base packages
RUN echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/php-ppa.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
    curl \
    wget \
    vim \
    nano \
    apache2 \
    apache2-utils \
    libapache2-mod-php5.6 \
    php5.6 \
    php5.6-intl \
    php5.6-mysql \
    php5.6-mcrypt \
    php5.6-gd \
    php5.6-curl \
    php5.6-xsl \
    php5.6-xml \
    php5.6-zip \
    php5.6-mbstring \
    php-apcu \
    git \
    cron \
    rsyslog \
    mysql-client \
    supervisor \
    postfix \
    sudo \
    && update-alternatives --set php /usr/bin/php5.6 \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && \
    apt-get install -y php5.6-dev pkg-config libmagickwand-dev php-imagick imagemagick build-essential \
    && \
    # Install tideways' extension
    echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list && \
    curl -sS https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install tideways-php \
    && \
    apt-get remove -y php7.1 php5.6-dev pkg-config libmagickwand-dev build-essential && \
    apt-get auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && a2enmod rewrite && \
    rm /etc/apache2/conf-enabled/other-vhosts-access-log.conf \
    # Install confd for templating \
    && curl -sSL -o /usr/local/bin/confd \
       https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 \
    && chmod +x /usr/local/bin/confd

COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/apache2.conf /etc/apache2/apache2.conf
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/php.ini /etc/php/5.6/apache2/php.ini
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/php.ini /etc/php/5.6/cli/php.ini
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/confd/ /etc/confd/
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/postfix/postfix-variables.sh /usr/local/share/postfix-variables.sh
COPY external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/postfix/postfix.sh /usr/local/sbin/postfix.sh

# Add the application
#ADD . /app
WORKDIR /var/www

# Install dependencies
ARG EZ_INSTALLATION_KEY=
ARG GITHUB_TOKEN=
ARG EZ_TOKEN_PASSWORD=

# Change uid to match eZ Platform docker setup
RUN usermod -u 1000 www-data


CMD ["/var/www/external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/run.sh"]
