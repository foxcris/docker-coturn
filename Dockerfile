FROM debian:stretch

MAINTAINER foxcris

#repositories richtig einrichten
RUN echo 'deb http://deb.debian.org/debian stretch main' > /etc/apt/sources.list
RUN echo 'deb http://deb.debian.org/debian stretch-updates main' >> /etc/apt/sources.list
RUN echo 'deb http://security.debian.org stretch/updates main' >> /etc/apt/sources.list

ENV LANG en_US.UTF8
#automatische aktualiserung installieren + basic tools
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y nano less wget anacron unattended-upgrades htop && apt-get clean

#coturn
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y coturn && apt-get clean

RUN mv /etc/turnserver.conf /etc/turnserver.conf_default

VOLUME /var/log

EXPOSE 8478
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
