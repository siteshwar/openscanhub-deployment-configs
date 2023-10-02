#!/bin/sh
#

if [[ -e /src ]]; then
    # Inside podman-compose
    cd /src
    cp client-local.conf /etc/osh/client.conf
fi
sleep inf
