FROM quay.io/centos/centos:stream8

RUN dnf install -y dnf-plugins-core epel-release
RUN dnf config-manager --set-enabled powertools

RUN dnf -y --setopt=tsflags=nodocs install \
    koji \
    python3-coverage \
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

RUN dnf copr enable -y @openscanhub/devel

# TODO: This would install osh-hub configurations from the `hub-conf-devel` package. How to install
# non-devel configurations for fedora infrastrucutre?
RUN dnf install -y osh-hub openssl

# Setup OpenScanHub settings
# TODO: If we leave this file stale in non-development environments, would it cause any issues?
# COPY settings_local.ci.py /usr/lib/python3.6/site-packages/osh/hub/settings_local.py
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

RUN touch /var/log/osh/hub/hub.log && chown apache:apache /var/log/osh/hub/hub.log

EXPOSE 80
# EXPOSE 443

COPY run_hub.sh /run_hub.sh
RUN chmod a+x /run_hub.sh
CMD /run_hub.sh
