# docker-coturn installation

A simple coturn isntallation. 
  
## Configuration
 
### Environment variables
The following environment variables are available to configure the container on startup.

 | Environment Variable | Description |
 | ---------------------- | ----------- |
 | TURN_SERVER_NAME | Server name used for the oAuth authentication purposes. The default value is the realm name.
 | TURN_SECRET | Static authentication secret value (a string) for TURN REST API only. If not set, then the turn server will try to use the dynamic value in turn_secret table in user database (if present). The database-stored value can be changed on-the-fly by a separate program, so this is why that other mode is dynamic. Multiple shared secrets can be used (both in the database and in the "static" fashion). |
 | TURN_REALM | The default realm to be used for the users when no explicit origin/realm relationship was found in the database, or if the TURN server is not using any database (just the commands-line settings and the userdb file). Must be used with long-term credentials mechanism or with TURN REST API. |
 | TURN_PORT | TURN listener port for UDP and TCP listeners (Default: 3478). Note: actually, TLS & DTLS sessions can connect to the "plain" TCP & UDP port(s), too - if allowed by configuration. |
 | TURN_PORT_START | Lower bound of the UDP port range for relay endpoints allocation. Default value is 49152, according to RFC 5766. |
 | TURN_PORT_END | Upper bound of the UDP port range for relay endpoints allocation. Default value is 65535, according to RFC 5766. |
 | TURN_EXTRA | Possibility to add extra options to the commandline invokation of the coturn server.|

## Container Tags

 | Tag name | Description |
 | ---------------------- | ----------- |
 | latest | Latest stable version of the container |
 | stable | Latest stable version of the container |
 | dev | latest development version of the container. Do not use in production environments! |

## Usage

To run the container and store the data and configuration on the local host run the following commands:
1. Create storage directroy for the configuration files, log files and data. Also create a directroy to store the necessary script to create the docker container and replace it (if not using eg. watchtower)
```
mkdir /srv/docker/coturn
mkdir /srv/docker-config/coturn
```

2. Create an file to store the configuration of the environment variables
```
touch /srv/docker-config/coturn/env_file
``` 
```
#Comma seperated list of domainnames
TURN_SERVER_NAME=your.server.name
TURN_SECRET=yoursecret
TURN_REALM=default.realm
```

3. Create the docker container and configure the docker networks for the container. I always create a script for that and store it under
```
touch /srv/docker-config/coturn/create.sh
```
Content of create.sh:
```
#!/bin/bash

version=stable

docker pull foxcris/docker-coturn:${version}
docker create\
 --restart always\
 --name coturn\
 --env-file=/srv/docker-config/coturn/env_file\
 -p 3478:3478\
 foxcris/docker-coturn:${version}
```

4. Create replace.sh to install/update the container. Store it in
```
touch /srv/docker-config/coturn/replace.sh
```
```
#/bin/bash
docker stop coturn
docker rm coturn
./create.sh
docker start coturn
```

### Update of coturn
Simply remove an recreate the container.