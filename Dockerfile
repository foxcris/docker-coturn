FROM debian:buster

MAINTAINER foxcris

#repositories richtig einrichten
RUN echo 'deb http://deb.debian.org/debian buster main' > /etc/apt/sources.list
RUN echo 'deb http://deb.debian.org/debian buster-updates main' >> /etc/apt/sources.list
RUN echo 'deb http://security.debian.org buster/updates main' >> /etc/apt/sources.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales && apt-get clean
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF8
#automatische aktualiserung installieren + basic tools
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y nano less wget anacron unattended-upgrades htop && apt-get clean

#coturn
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y coturn && apt-get clean

RUN mv /etc/turnserver.conf /etc/turnserver.conf_default
RUN echo "TURNSERVER_ENABLED=1" >> /etc/default/coturn

VOLUME /var/log

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
