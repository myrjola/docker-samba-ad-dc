FROM ubuntu:latest
MAINTAINER Martin Yrjölä <martin.yrjola@relex.fi>

ENV DEBIAN_FRONTEND noninteractive

# Setup ssh and install supervisord
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin Yes/g' /etc/ssh/sshd_config

# Install bind9 dns server
RUN apt-get install -y bind9 dnsutils
ADD named.conf.options /etc/bind/named.conf.options

# Install samba and dependencies to make it an Active Directory Domain Controller
RUN apt-get install -y samba smbclient krb5-kdc

# Install utilities needed for setup
RUN apt-get install -y expect pwgen
ADD kdb5_util_create.expect kdb5_util_create.expect

# Install rsyslog to get better logging of ie. bind9
RUN apt-get install -y rsyslog

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD init.sh /init.sh
RUN chmod 755 /init.sh
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
