# FROM quay.io/centos/centos:stream8
# FROM quay.io/sclorg/httpd-24-c8s
FROM registry.access.redhat.com/ubi9/httpd-24
USER 0

RUN dnf install -y dnf-plugins-core https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
# RUN dnf config-manager --set-enabled crb

RUN dnf -y --setopt=tsflags=nodocs install \
    koji \
    python3

### END OF COMMON PART

# enable installation of gettext message objects
RUN rm /etc/rpm/macros.image-language-conf

RUN dnf -y --setopt=tsflags=nodocs install \
    /usr/bin/pg_isready \
    csdiff \
    gzip \
    python3-bugzilla \
    python3-csdiff \
    python3-django3 \
    python3-gssapi \
    python3-jira \
    python3-psycopg2 \
    python3-qpid-proton \
    xz

#TODO: How to enable installation of a specifiec commit?
RUN dnf copr enable -y @openscanhub/devel

# TODO: This would install osh-hub configurations from the `hub-conf-devel` package. How to install
# non-devel configurations for fedora infrastrucutre?
# TODO: There may be a race condition here, as it installs latest `osh-hub` package, that may have
# been built after a specific commit.
RUN dnf install -y osh-hub osh-hub-conf-devel openssl

# Setup OpenScanHub settings
# TODO: If we leave this file stale in non-development environments, would it cause any issues?
# COPY settings_local.ci.py /usr/lib/python3.9/site-packages/osh/hub/settings_local.py
# COPY osh-hub-httpd.conf /etc/httpd/conf.d/osh-hub-httpd.conf
# RUN rm -f /etc/httpd/conf.d/ssl.conf

# TODO: This certificate should not be used in non-development environments.
# openssl req -newkey rsa:4096 -nodes -keyout fedora-osh-hub.key -x509 -sha256 -days 365 -addext "subjectAltName = DNS:fedora-osh-hub, DNS:fedora-osh-hub, DNS:127.0.0.1" -subj "/C=CZ/ST=/L=/O=Red Hat/OU=Plumbers/CN=fedora-osh-hub" -out fedora-osh-hub.crt
# COPY fedora-osh-hub.crt /etc/httpd/conf
# COPY fedora-osh-hub.key /etc/httpd/conf
# RUN cp /etc/httpd/conf/fedora-osh-hub.crt /etc/pki/ca-trust/source/anchors/ && update-ca-trust
# RUN sed -i 's#/etc/pki/tls/certs/localhost#/etc/httpd/conf/fedora-osh-hub#g' /etc/httpd/conf.d/ssl.conf
# RUN sed -i 's#/etc/pki/tls/private/localhost#/etc/httpd/conf/fedora-osh-hub#g' /etc/httpd/conf.d/ssl.conf
# RUN sed -i "s/localhost/fedora-osh-hub/g" /etc/httpd/conf.d/osh-hub-httpd.conf

# TODO: Shall `/var/log/osh/` be a persistennt path? Shall this log be redirected to another logging
# service like splunk?
RUN touch /var/log/osh/hub/hub.log && chown :root /var/log/osh/hub/hub.log
RUN rpm -ql osh-hub
RUN touch /usr/lib/python3.9/site-packages/osh/hub/settings_local.py && chown :root /usr/lib/python3.9/site-packages/osh/hub/settings_local.py
RUN touch /etc/httpd/conf.d/osh-hub-httpd.conf && chown :root /etc/httpd/conf.d/osh-hub-httpd.conf
# TODO: Set correct permissions on below files.
RUN chown :root /usr/lib/python3.9/site-packages/osh/hub/settings_local.py /etc/httpd/conf.d/osh-hub-httpd.conf
RUN chown -R :root /var/log/osh/hub /var/lib/osh/ /opt/app-root/ /var/run/
# RUN chmod g+r /usr/lib/python3.9/site-packages/osh/hub/settings_local.py /etc/httpd/conf.d/osh-hub-httpd.conf
#TODO: Shall /var/lib/osh be a persistent path? Remove chmod command for it?
RUN chmod -R g+rw /var/log/osh/hub  /opt/app-root/ /var/run/ /usr/lib/python3.9/site-packages/osh/hub/settings_local.py /etc/httpd/conf.d/osh-hub-httpd.conf # /var/lib/osh/

EXPOSE 8080
EXPOSE 8443

COPY run_hub.sh /run_hub.sh
RUN chmod a+x /run_hub.sh
# TODO: Is it safe to keep this user as it is?
USER 1001
CMD /run_hub.sh
