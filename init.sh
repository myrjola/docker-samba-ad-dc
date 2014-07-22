#!/bin/bash

set -e

SAMBA_DOMAIN=${SAMBA_DOMAIN:-samdom}
SAMBA_REALM=${SAMBA_REALM:-samdom.example.com}

if [[ $SAMBA_HOST_IP ]]; then
    SAMBA_HOST_IP="--host-ip=${SAMBA_HOST_IP}"
fi

appSetup () {
    touch /etc/samba/.alreadysetup

    # Generate passwords
    ROOT_PASSWORD=$(pwgen -c -n -1 12)
    SAMBA_ADMIN_PASSWORD=$(pwgen -cny 10 1)
    export KERBEROS_PASSWORD=$(pwgen -cny 10 1)
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo Root password: $ROOT_PASSWORD
    echo Samba administrator password: $SAMBA_ADMIN_PASSWORD
    echo Kerberos KDC database master key: $KERBEROS_PASSWORD

    # Provision Samba
    rm -f /etc/samba/smb.conf
    rm -rf /var/lib/samba/private/*
    samba-tool domain provision --use-rfc2307 --domain=$SAMBA_DOMAIN --realm=$SAMBA_REALM --server-role=dc\
      --dns-backend=BIND9_DLZ --adminpass=$SAMBA_ADMIN_PASSWORD $SAMBA_HOST_IP
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
    # Create Kerberos database
    expect kdb5_util_create.expect
    # Export kerberos keytab for use with sssd
    samba-tool domain exportkeytab /etc/krb5.keytab --principal ${HOSTNAME}\$
    sed -i "s/SAMBA_REALM/${SAMBA_REALM}/" /etc/sssd/sssd.conf
}

appStart () {
    [ -f /etc/samba/.alreadysetup ] && echo "Skipping setup..." || appSetup

    # Start the services
    /usr/bin/supervisord
}

appHelp () {
	echo "Available options:"
	echo " app:start          - Starts all services needed for Samba AD DC"
	echo " app:setup          - First time setup."
	echo " app:help           - Displays the help"
	echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
	app:start)
		appStart
		;;
	app:setup)
		appSetup
		;;
	app:help)
		appHelp
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0
