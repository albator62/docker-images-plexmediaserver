#
# Docker configuration for Plex Media server
#
FROM joshhogle/ubuntu:xenial
MAINTAINER Josh Hogle <josh.hogle@gmail.com>

# Versions
ENV PLEX_VERSION 0.9.16.6.1993-5089475

# Upgrade packages and install required packages for build
RUN \
        apt-get update && \
	apt-get -y dist-upgrade && \
        apt-get -o Dpkg::Options::="--force-confold" --no-install-recommends -y install \
		git python3-setuptools python3-appdirs python3-dateutil python3-requests python3-sqlalchemy \
		python-fuse socat encfs && \
	easy_install3 -U pip && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#############################################
# Plex Media Server Install
#############################################
# download and install Plex Media Server
RUN \
	curl -L https://downloads.plex.tv/plex-media-server/${PLEX_VERSION}/plexmediaserver_${PLEX_VERSION}_amd64.deb -o /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb && \
	dpkg -i /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb && \
	rm -f /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb

#############################################
# Amazon Cloud Drive Client Install
#############################################
RUN \
	pip3 install certifi && \
	pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git 

#########################
# Customizations
#########################
# Add files to image
ADD files /

# Configure image
RUN \
	chmod 0755 /usr/local/sbin/*

# Mount configuration folders
VOLUME [ "/etc/plex", "/var/lib/plexmediaserver" ] 

# Expose ports
EXPOSE 32400

