#!/bin/bash

set -e

if [ -n "${PROXY_SOCKS_PORT}" ]; then
    DEFAULT_INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
    sed -i "s/EXTERNAL_INTERFACE/${DEFAULT_INTERFACE}/g" ./danted.conf
    echo "Danted using interface: ${DEFAULT_INTERFACE}"

    sed -i "s/PROXY_SOCKS_PORT/${PROXY_SOCKS_PORT}/g" ./danted.conf
    echo "Danted socks port: ${PROXY_SOCKS_PORT}"
fi

if [ -n "${PROXY_HTTP_PORT}" ]; then
    sed -i "s/PROXY_HTTP_PORT/${PROXY_HTTP_PORT}/g" ./tinyproxy.conf
    echo "Tinyproxy http port: ${PROXY_HTTP_PORT}"
fi