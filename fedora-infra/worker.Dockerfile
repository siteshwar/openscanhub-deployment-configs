FROM quay.io/centos/centos:stream8

RUN dnf install -y dnf-plugins-core epel-release
RUN dnf config-manager --set-enabled powertools

RUN dnf -y --setopt=tsflags=nodocs install \
    koji \
    python3-coverage \
    python3

RUN dnf -y --setopt=tsflags=nodocs install \
    csmock \
    file

RUN adduser csmock -G mock

# COPY worker-local.conf /etc/osh/worker.conf

RUN dnf copr enable -y @openscanhub/devel

RUN dnf install -y osh-worker

# TODO: This certificate should not be used in non-development environments.
# COPY fedora-osh-hub.crt /etc/pki/ca-trust/source/anchors/

COPY run_worker.sh /run_worker.sh
RUN chmod a+x /run_worker.sh

CMD /run_worker.sh
