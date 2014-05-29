FROM ubuntu:latest
MAINTAINER Martin Yrjölä <martin.yrjola@relex.fi>

# Setup ssh and install supervisord
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin Yes/g' /etc/ssh/sshd_config


# Install bind9 dns server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 dnsutils
ADD named.conf.options /etc/bind/named.conf.options

# Install samba and configure it to be an Active Directory Domain Controller
RUN apt-get install -y samba smbclient krb5-kdc krb5-admin-server
RUN rm /etc/samba/smb.conf
RUN samba-tool domain provision --use-rfc2307 --domain=relexsamba --realm=relexsamba.relex.fi --server-role=dc --dns-backend=BIND9_DLZ
RUN cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
RUN apt-get install -y expect
ADD kdb5_util_create.expect kdb5_util_create.expect
RUN expect kdb5_util_create.expect # Create Kerberos database

# Install rsyslog to get better logging of ie. bind9
RUN apt-get install -y rsyslog

RUN echo 'root:root' | chpasswd
EXPOSE 22 53
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
