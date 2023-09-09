#!/bin/bash

set -e

if [ -z "${REMOTE_IP}" ]; then
    echo "Error: environment variable REMOTE_IP is required."
    exit 1
fi

/gen-ck-client-config.sh

./ck-client -u -c ./ck-client.json -s ${REMOTE_IP} -i 0.0.0.0 &

# Save PID of ck-client process
PID=$!

# Wait for SIGTERM signal
trap 'kill -TERM $PID' TERM
wait $PID