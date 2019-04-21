#!/bin/bash

#Start Cron
echo "Starting cron server"
/etc/init.d/anacron start
/etc/init.d/cron start

#Check Parameters and create configurationfile (only on first start)
if [ ! -e /etc/turnserver.conf ]
then
    if [ "$TURN_SERVER_NAME" = "" ]
    then
      TURN_SERVER_NAME=coturn
    fi
    echo "server-name ${TURN_SERVER_NAME}" > /etc/turnserver.conf
    
    if [ "$TURN_SECRET" = "" ]
    then
      TURN_SECRET=`date +%s | sha256sum | base64 | head -c 64`
    fi
    echo "static-auth-secret ${TURN_SECRET}" >> /etc/turnserver.conf
    
    if [ "$TURN_REALM" = "" ]
    then
      TURN_REALM=default.realm
    fi
    echo "realm ${TURN_REALM}" >> /etc/turnserver.conf
    
    if [ "$TURN_PORT" = "" ]
    then
      TURN_PORT=8478
    fi
    echo "listening-port ${TURN_PORT}" >> /etc/turnserver.conf
    
    if [ "$TURN_PORT_START" = "" ]
    then
      TURN_PORT_START=49152
    fi
    echo "min-port ${TURN_PORT_START}" >> /etc/turnserver.conf
    
    if [ "$TURN_PORT_END" = "" ]
    then
      TURN_PORT_END=65535
    fi
    echo "max-port ${TURN_PORT_END}" >> /etc/turnserver.conf
    
    if [ "$TURN_USE_AUTH_SECRET" = "" ] || [ "$TURN_USE_AUTH_SECRET" = "true" ]
    then
      echo "use-auth-secret" >> /etc/turnserver.conf
    fi
    
    if [ "$TURN_NO_TCP_RELAY" = "" ] || [ "$TURN_NO_TCP_RELAY" = "true" ]
    then
      echo "no-tcp-relay" >> /etc/turnserver.conf
    fi
    
    if [ "$TURN_LT_CRED_MECH" = "" ] || [ "$TURN_LT_CRED_MECH" = "true" ]
    then
      echo "lt-cred-mech" >> /etc/turnserver.conf
    fi
    if [ "$TURN_USER_QUOTA" = "" ]
    then
      $TURN_USER_QUOTA = 12
    fi
    echo "user-quota ${TURN_USER_QUOTA}" >> /etc/turnserver.conf
    
    if [ "$TURN_TOTAL_QUOTA" = "" ]
    then
      $TURN_TOTAL_QUOTA = 1200
    fi
    echo "total-quota ${TURN_TOTAL_QUOTA}" >> /etc/turnserver.conf
    
    if [ "$TURN_NO_STUN" = "" ] || [ "$TURN_NO_STUN" = "true" ]
    then
      echo "no-stun" >> /etc/turnserver.conf
    fi
    if [ "$TURN_NO_MUTICAST_PEERS" = "" ] || [ "$TURN_NO_MUTICAST_PEERS" = "true" ]
    then
      echo "no-multicast-peers" >> /etc/turnserver.conf
    fi
    if [ "$TURN_NO_TLSV1" = "" ] || [ "$TURN_NO_TLSV1" = "true" ]
    then
      echo "no-tlsv1" >> /etc/turnserver.conf
    fi
    if [ "$TURN_NO_TLSV1_1" = "" ] || [ "$TURN_NO_TLSV1_1" = "true" ]
    then
      echo "no-tlsv1_1" >> /etc/turnserver.conf
    fi
    if [ ! "$TURN_CERT_PATH" = "" ]
    then
      echo "cert ${TURN_CERT_PATH}" >> /etc/turnserver.conf
    fi
    if [ ! "$TURN_PKEY_PATH" = "" ]
    then
      echo "pkey ${TURN_PKEY_PATH}" >> /etc/turnserver.conf
    fi
    if [ ! $TURN_DENIED_PEER_IP = "" ]
    then
      peers=$(echo $TURN_DENIED_PEER_IP | tr "," "\n")
      for peer in $peers
      do
        echo "denied-peer-ip ${peer}" >> /etc/turnserver.conf
      done 
    fi
    
    echo "log-file /var/log/turnserver" >> /etc/turnserver.conf
    
fi

echo "Starting TURN/STUN server"
#start coturn service
service coturn start

#turnserver -v -L 0.0.0.0 --server-name "${TURN_SERVER_NAME}" --static-auth-secret="${TURN_SECRET}" --realm=${TURN_REALM}  -p ${TURN_PORT} --min-port ${TURN_PORT_START} --max-port ${TURN_PORT_END} --user-quota ${TURN_USER_QUOTA} --total-quota ${$TURN_TOTAL_QUOTA} ${TURN_USE_AUTH_SECRET} ${TURN_NO_TCP_RELAY} ${TURN_LT_CRED_MECH} ${TURN_NO_STUN} ${TURN_NO_MUTICAST_PEERS} ${TURN_CERT} ${TURN_PKEY} ${TURN_EXTRA}
touch /var/log/turnserver
tail -f /var/log/turnserver
