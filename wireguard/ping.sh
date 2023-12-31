#!/bin/bash

while true
do    
    random_delay=$((MIN_PING_DELAY + RANDOM % (MAX_PING_DELAY - MIN_PING_DELAY + 1)))
    ping -c 1 ${PING_HOST} 2>&1 > /dev/null    
    sleep ${random_delay}
done
