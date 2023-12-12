#!/bin/bash

set -e

_term() {
  echo "Request to STOP received"
  wg-quick down /wg0.conf
  echo "STOPPED"
  kill -TERM "$child" 2>/dev/null
}

/gen-proxy-config.sh

if [ -n "${PROXY_SOCKS_PORT}" ]; then
  tinyproxy -c /tinyproxy.conf
  echo "Tinyproxy started"
fi

if [ -n "${PROXY_HTTP_PORT}" ]; then
  danted -D -f /danted.conf
  echo "Danted started"
fi

/gen-wg-client-config.sh
wg-quick up /wg0.conf

# Sets up a handler for the SIGTERM signal to gracefully terminate a process
trap _term SIGTERM
# Displays information about the current WireGuard interface state
#wg show
# Launches an indefinitely sleeping process in the background
sleep infinity &
# Stores the process ID of the background sleep process in the variable child
child=$!
# Pauses the script until the sleep process, stored in child, completes
wait "$child"
