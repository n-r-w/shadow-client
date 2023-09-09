#!/bin/bash

set -e

if [ -z "${CK_UID}" ]; then
    echo "Error: environment variable CK_UID is required."
    exit 1
fi

if [ -z "${CK_PUBLIC_KEY}" ]; then
    echo "Error: environment variable CK_PUBLIC_KEY is required."
    exit 1
fi

if [ -z "${CK_TRANSPORT}" ]; then
    CK_TRANSPORT="direct" # direct, cdn
    echo "CK_TRANSPORT is not set. Defaulting to ${CK_TRANSPORT}."
fi

if [ -z "${CK_ENCRYPTION_METHOD}" ]; then
    CK_ENCRYPTION_METHOD="aes-128-gcm" # aes-128-gcm, aes-256-gcm, chacha20-poly1305
    echo "CK_ENCRYPTION_METHOD is not set. Defaulting to ${CK_ENCRYPTION_METHOD}."
fi

if [ -z "${CK_NUM_CONN}" ]; then
    CK_NUM_CONN=4
    echo "CK_NUM_CONN is not set. Defaulting to ${CK_NUM_CONN}."
fi

if [ -z "${CK_BROWSER_SIG}" ]; then
    CK_BROWSER_SIG="chrome"
    echo "CK_BROWSER_SIG is not set. Defaulting to ${CK_BROWSER_SIG}."
fi

if [ -z "${CK_STREAM_TIMEOUT}" ]; then
    CK_STREAM_TIMEOUT=300
    echo "CK_STREAM_TIMEOUT is not set. Defaulting to ${CK_STREAM_TIMEOUT}."
fi

if [ -z "${CK_SERVER_NAME}" ]; then
    CK_SERVER_NAME="cloudflare.com" 
    echo "CK_SERVER_NAME is not set. Defaulting to ${CK_SERVER_NAME}."
fi

if [ -z "${CK_ALTERNATIVE_NAMES}" ]; then
    CK_ALTERNATIVE_NAMES='github.com, bing.com, google.com, microsoft.com, intel.com, stackoverflow.com, leetcode.com'
    echo "CK_ALTERNATIVE_NAMES is not set. Defaulting to: ${CK_ALTERNATIVE_NAMES}."
fi
CK_ALTERNATIVE_NAMES=$(echo "${CK_ALTERNATIVE_NAMES}" | sed 's/ //g') # Remove spaces
CK_ALTERNATIVE_NAMES=$(echo "${CK_ALTERNATIVE_NAMES}" | sed 's/,/","/g') # Add quotes
CK_ALTERNATIVE_NAMES="\"${CK_ALTERNATIVE_NAMES}\"" # Add quotes to the beginning and end

cat <<EOF > ck-client.json
{
    "Transport": "${CK_TRANSPORT}",
    "ProxyMethod": "wireguard",
    "EncryptionMethod": "${CK_ENCRYPTION_METHOD}",
    "UID": "${CK_UID}",
    "PublicKey": "${CK_PUBLIC_KEY}",
    "ServerName": "${CK_SERVER_NAME}",
    "AlternativeNames": [${CK_ALTERNATIVE_NAMES}],
    "NumConn": ${CK_NUM_CONN},
    "BrowserSig": "${CK_BROWSER_SIG}",
    "StreamTimeout": ${CK_STREAM_TIMEOUT}
}
EOF

echo "Configuration file ck-client.json created successfully."