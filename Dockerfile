#*********************************************************************
#
# Copyright (c) 2015-2019 BITPlan GmbH
#
# see LICENSE
#
# Dockerfile to build MediaWiki server
# Based on ubuntu
#
#*********************************************************************

# Ubuntu image
FROM ubuntu:18.04

#
# Maintained by Wolfgang Fahl / BITPlan GmbH http://www.bitplan.com
#
MAINTAINER Wolfgang Fahl info@bitplan.com

#*********************************************************************
# Settings
#*********************************************************************

# MEDIAWIKI LTS Version
# https://www.mediawiki.org/wiki/MediaWiki_1.31
# LTS
ENV MEDIAWIKI_VERSION 1.31
ENV MEDIAWIKI mediawiki-1.31.3
ARG IMAGEHOSTNAME=smw
ENV IMAGEHOSTNAME ${IMAGEHOSTNAME}
ARG DEBIAN_FRONTEND=noninteractive

# see https://www.mediawiki.org/wiki/Download
# as of 2019-10-04:
# LEGACY long-term: 1.31.3

# Semantic Mediawiki Version (optional install)
# see https://semantic-mediawiki.org
# and https://semantic-mediawiki.org/wiki/Help:Installation/Using_Composer_with_MediaWiki_1.22_-_1.24
# Please always omit the bugfix release number, i.e. the third number.
ENV SMW_VERSION 3.1.0

#*********************************************************************
# Install Linux Apache MySQL PHP (LAMP)
#*********************************************************************

# see https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Ubuntu
RUN \
  apt-get update && \
  apt-get install -y \
	apache2 \
	apt-utils \
	curl \
	dialog \
	git \
	libapache2-mod-php7.2 \
	mysql-server \
	vim \
	unzip \
	php7.2 \
	php7.2-cli \
	php7.2-gd \
	php7.2-mbstring \
	php7.2-xml \
	php7.2-mysql

# see https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki
RUN cd /var/www/html/ && \
  curl -O https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/$MEDIAWIKI.tar.gz && \
	tar -xzvf $MEDIAWIKI.tar.gz && \
	rm *.tar.gz

# Activate Apache PHP module
RUN a2enmod php7.2

# Copy the install script
COPY ./image/docker-entrypoint.sh /

# run it
RUN /bin/bash /docker-entrypoint.sh -smw

# COPY run script to be used as an entrypoint after installation
COPY ./image/run.sh /

# Use it as an entry point
ENTRYPOINT ["/bin/bash","/run.sh"]

#*********************************************************************
#* Expose relevant ports
#*********************************************************************
# http
EXPOSE 80
# https
EXPOSE 443
# mysql
EXPOSE 3306
