#!/bin/bash

main_pid=$1

_term() {
  echo "Ping script stopped"
  exit 0
}

trap _term SIGTERM

while true
do    
    random_delay=$((MIN_PING_DELAY + RANDOM % (MAX_PING_DELAY - MIN_PING_DELAY + 1)))    
    ping -c 1 ${PING_HOST}
    sleep ${random_delay}

    if ! kill -0 "$main_pid" 2>/dev/null; then        
        exit 0
    fi
done
