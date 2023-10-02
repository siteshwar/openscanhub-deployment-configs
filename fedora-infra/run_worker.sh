#!/bin/sh -x

if [[ -e /src ]]; then
    # Inside podman-compose
    cd /src
    cp worker-local.conf /etc/osh/worker.conf
fi

# TODO: Shall we enable this for non-development environments?
# /usr/bin/update-ca-trust
/usr/sbin/osh-worker -f
tail -f /var/log/osh/worker.log
