FROM quay.io/centos/centos:stream8

USER 0

RUN dnf install -y dnf-plugins-core epel-release
RUN dnf config-manager --set-enabled powertools

RUN dnf -y --setopt=tsflags=nodocs install \
    koji \
    python3

RUN dnf copr enable -y @openscanhub/devel
RUN dnf install -y osh-client

# TODO: This certificate should not be used in non-development environments.
# COPY fedora-osh-hub.crt /etc/pki/ca-trust/source/anchors/
# RUN /usr/bin/update-ca-trust

# COPY client-local.conf /etc/osh/client.conf
COPY run_client.sh /run_client.sh
RUN chmod a+x /run_client.sh

USER 1001
CMD /run_client.sh
