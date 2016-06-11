#
# Docker configuration for Plex Media server
#
FROM joshhogle/ecloudfs:latest
MAINTAINER Josh Hogle <josh.hogle@gmail.com>

# Versions
ENV PLEX_VERSION 0.9.16.6.1993-5089475

# Upgrade packages and install required packages for build
RUN \
        apt-get update && \
	    apt-get -y dist-upgrade && \
        apt-get -o Dpkg::Options::="--force-confold" --no-install-recommends -y install \
            socat && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#############################################
# Plex Media Server Install
#############################################
# download and install Plex Media Server
RUN \
	curl -L https://downloads.plex.tv/plex-media-server/${PLEX_VERSION}/plexmediaserver_${PLEX_VERSION}_amd64.deb -o /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb && \
	dpkg -i /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb && \
	rm -f /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb

#########################
# Customizations
#########################
# Add files to image
ADD files /

# Configure image
RUN \
	chmod 0755 /usr/local/sbin/*

# Mount configuration folders
VOLUME [ "/var/lib/plexmediaserver" ]

# Expose ports
EXPOSE 32400
