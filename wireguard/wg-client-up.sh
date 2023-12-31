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

if [ -n "${PING_HOST}" ]; then
  if [ -z "${MIN_PING_DELAY}" ]; then
    export MIN_PING_DELAY=10
    echo "MIN_PING_DELAY not set, using default value: ${MIN_PING_DELAY}"
  fi
  if [ -z "${MAX_PING_DELAY}" ]; then
    export MAX_PING_DELAY=360
    echo "MAX_PING_DELAY not set, using default value: ${MAX_PING_DELAY}"
  fi

  /ping.sh &
fi

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
