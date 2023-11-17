#!/bin/bash

set -e

if [ -z "${WG_CLIENT_PRIVATE_KEY}" ]; then
    echo "Error: environment variable WG_CLIENT_PRIVATE_KEY is required."
    exit 1
fi
if [ -z "${WG_SERVER_PUBLIC_KEY}" ]; then
    echo "Error: environment variable WG_SERVER_PUBLIC_KEY is required."
    exit 1
fi
if [ -z "${CK_IP}" ]; then
    echo "Error: environment variable CK_IP is required."
    exit 1
fi

if [ -z "${WG_DNS}" ]; then
    WG_DNS="8.8.8.8,8.8.4.4"
    echo "WG_DNS is not set. Defaulting to ${WG_DNS}."
fi
if [ -z "${WG_MTU}" ]; then
    WG_MTU=1420
    echo "WG_MTU is not set. Defaulting to ${WG_MTU}."
fi
if [ -z "${WG_ALLOWED_IPS}" ]; then
    WG_ALLOWED_IPS="0.0.0.0/0"
    echo "WG_ALLOWED_IPS is not set. Defaulting to ${WG_ALLOWED_IPS}."
fi

if [ -n "${WG_EXCLUDED_DOMAINS}" ] || [ -n "${WG_EXCLUDED_IPS}" ]; then
    if [ -n "${WG_EXCLUDED_IPS}" ]; then
        EXCLUDED_IPS=${WG_EXCLUDED_IPS}","
    else
        EXCLUDED_IPS=""
    fi
    IFS=',' read -ra DOMAIN_ARRAY <<< "$WG_EXCLUDED_DOMAINS"
    
    for DOMAIN in "${DOMAIN_ARRAY[@]}"
    do
        IP=$(dig +short "$DOMAIN" | tr '\n' ',' | sed 's/,$//')        
        if [ -z "${IP}" ] || [[ ! "${IP}" =~ ^[0-9,.]+$ ]]; then
            echo "IP for domain ${DOMAIN} not found. Skipping."
            continue
        fi

        EXCLUDED_IPS="$EXCLUDED_IPS$IP,"
        echo "IPs for domain ${DOMAIN} are ${IP}."        
    done
    EXCLUDED_IPS="${EXCLUDED_IPS%,}"
    echo "EXCLUDED_IPS calculated to be ${EXCLUDED_IPS}."
    if [ -n "${EXCLUDED_IPS}" ]; then        
        WG_ALLOWED_IPS=$(python3 wireguard-ip-calculator.py -a ${WG_ALLOWED_IPS} -d ${EXCLUDED_IPS})        
    fi
fi

echo "ALLOWED_IPS is set to ${WG_ALLOWED_IPS}."

cat <<EOF > wg0.conf
[Interface]
PrivateKey = ${WG_CLIENT_PRIVATE_KEY}
Address = 10.66.66.2/32
DNS = ${WG_DNS}
MTU = ${WG_MTU}

PostUp = iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE

[Peer]
PublicKey = ${WG_SERVER_PUBLIC_KEY}
Endpoint = ${CK_IP}:1984
AllowedIPs = ${WG_ALLOWED_IPS}
EOF

echo "Configuration file wg0.conf created successfully."