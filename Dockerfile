FROM ubuntu:12.04.5
MAINTAINER Martin Yrjölä <martin.yrjola@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

VOLUME ["/var/lib/samba", "/etc/samba"]

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
RUN apt-get install -y build-essential libacl1-dev libattr1-dev \
      libblkid-dev libgnutls-dev libreadline-dev python-dev libpam0g-dev \
      python-dnspython gdb pkg-config libpopt-dev libldap2-dev \
      dnsutils libbsd-dev attr krb5-user docbook-xsl libcups2-dev acl python-xattr
RUN apt-get install -y samba smbclient krb5-kdc

# Install utilities needed for setup
RUN apt-get install -y expect pwgen
ADD kdb5_util_create.expect kdb5_util_create.expect

# Install rsyslog to get better logging of ie. bind9
RUN apt-get install -y rsyslog

# Create run directory for bind9
RUN mkdir -p /var/run/named
RUN chown -R bind:bind /var/run/named

# Install sssd for UNIX logins to AD
RUN apt-get install -y sssd sssd-tools
ADD sssd.conf /etc/sssd/sssd.conf
RUN chmod 0600 /etc/sssd/sssd.conf

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD init.sh /init.sh
RUN chmod 755 /init.sh
EXPOSE 22 53 389 88 135 139 138 445 464 3268 3269
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
