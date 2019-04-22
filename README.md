# docker-coturn installation

A simple coturn isntallation. 
  
## Configuration
 
### Environment variables
The following environment variables are available to configure the container on startup. The parameters are used to generate the configuration file /etc/turnserver.conf.
The configuration file is only created if it does not already exist. So you can extend the configuration file without losing your changes on startup.

 | Environment Variable | Description |
 | ---------------------- | ----------- |
 | TURN_SERVER_NAME | Server name used for the oAuth authentication purposes. The default value is the realm name.
 | TURN_SECRET | Static authentication secret value (a string) for TURN REST API only. If not set, then the turn server will try to use the dynamic value in turn_secret table in user database (if present). The database-stored value can be changed on-the-fly by a separate program, so this is why that other mode is dynamic. Multiple shared secrets can be used (both in the database and in the "static" fashion). |
 | TURN_REALM | The default realm to be used for the users when no explicit origin/realm relationship was found in the database, or if the TURN server is not using any database (just the commands-line settings and the userdb file). Must be used with long-term credentials mechanism or with TURN REST API. |
 | TURN_PORT | TURN listener port for UDP and TCP listeners (Default: 3478). Note: actually, TLS & DTLS sessions can connect to the "plain" TCP & UDP port(s), too - if allowed by configuration. |
 | TURN_PORT_START | Lower bound of the UDP port range for relay endpoints allocation. Default value is 49152, according to RFC 5766. |
 | TURN_PORT_END | Upper bound of the UDP port range for relay endpoints allocation. Default value is 65535, according to RFC 5766. |
 | TURN_USE_AUTH_SECRET | TURN REST API flag. Flag that sets a special WebRTC authorization option that is based upon authentication secret. Enabled if set to true or not set. To disable set to false. |
 | TURN_NO_TCP_RELAY | Do not allow TCP relay endpoints defined in RFC 6062, use only UDP relay endpoints as defined in RFC 5766. Enabled if set to true or not set. To disable set to false. |
 | TURN_LT_CRED_MECH | Use long-term credentials mechanism (this one you need for WebRTC usage). Enabled if set to true or not set. To disable set to false. |
 | TURN_NO_STUN | Run as TURN server only, all STUN requests will be ignored. Option to suppress STUN functionality, only TURN requests will be processed. Enabled if set to true or not set. To disable set to false. |
 | TURN_USER_QUOTA | Per-user allocations quota: how many concurrent allocations a user can create. Default: 12|
 | TURN_TOTAL_QUOTA | Total allocations quota: global limit on concurrent allocations. Default: 1200|
 | TURN_NO_MUTICAST_PEERS | Disallow peers on well-known broadcast addresses (224.0.0.0 and above, and FFXX:*). Enabled if set to true or not set. To disable set to false. |
 | TURN_NO_TLSV1 | Do not allow TLSv1 protocol. Enabled if set to true or not set. To disable set to false. |
 | TURN_NO_TLSV1_1 | Do not allow TLSv1.1 protocol. Enabled if set to true or not set. To disable set to false. |
 | TURN_CERT_PATH | Certificate file, PEM format. Same file search rules applied as for the configuration file.|
 | TURN_PKEY_PATH | Private key file, PEM format. Same file search rules applied as for the configuration file.|
 | TURN_DENIED_PEER_IP | Options to ban specific ip addresses or ranges of ip addresses. Provide a comma seperated list like: 10.0.0.0-10.255.255.255,172.16.0.0-172.31.255.255,192.168.0.0-192.168.255.255.|

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
TURN_PORT=8478
TURN_PORT_START=49200
TURN_PORT_END=49500
TURN_USE_AUTH_SECRET=true
TURN_NO_TCP_RELAY=true
TURN_LT_CRED_MECH=true
TURN_NO_STUN=true
TURN_USER_QUOTA=12
TURN_TOTAL_QUOTA=1200
TURN_NO_MUTICAST_PEERS=true
TURN_NO_TLSV1=true
TURN_NO_TLSV1_1=true
TURN_CERT_PATH=/etc/turnserver/cert.pem
TURN_PKEY_PATH=/etc/turnserver/key.pem
TURN_DENIED_PEER_IP=10.0.0.0-10.255.255.255,172.16.0.0-172.31.255.255,192.168.0.0-192.168.255.255
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
docker create --restart always\
  --env-file ./env_file\
  --name coturn \
  -p 8478:8478\
  -p 49200-49500:49200-49500\
  -v /srv/docker/coturn/var/log:/var/log\
  -v /srv/docker/coturn/etc/turnserver:/etc/turnserver\
  --label=com.centurylinklabs.watchtower.enable=true \
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