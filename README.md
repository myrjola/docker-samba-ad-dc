# Docker container demonstrating Samba's Active Directory Domain Controller (AD DC) support

This repository is unmaintained. Check if one of the forks are up to date.

Run these commands to start the container
```
docker build -t samba-ad-dc .
docker run --privileged -v ${PWD}/samba:/var/lib/samba  -e "SAMBA_DOMAIN=samdom" -e "SAMBA_REALM=samdom.example.com" --name dc1 --dns 127.0.0.1 -d samba-ad-dc
```
You can of course change the domain and realm to your liking.

You get the IP-address of the running machine by issuing `docker inspect dc1 | grep IPAddress` and the root user's
password as well as other passwords by running `docker logs dc1 2>&1 | head -3`. You should then be able to log in with SSH.

One fast check to see that Kerberos talks with Samba:
```
root@1779834e202b:~# kinit administrator@SMBDC1.EXAMPLE.COM
Password for administrator@SMBDC1.EXAMPLE.COM:
Warning: Your password will expire in 41 days on Thu Jul 10 19:36:55 2014
root@1779834e202b:~# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: administrator@SMBDC1.EXAMPLE.COM

Valid starting     Expires            Service principal
05/29/14 19:45:53  05/30/14 05:45:53  krbtgt/SMBDC1.EXAMPLE.COM@SMBDC1.EXAMPLE.COM
        renew until 05/30/14 19:45:43

```

## Redmine client

Now you can test Redmine ldap login to the host.
```
docker run --name redmine -d sameersbn/redmine:latest
REDMINE_IP=$(docker inspect redmine | grep IPAddres | awk -F'"' '{print $4}')
xdg-open "http://${REDMINE_IP}/auth_sources/new"
```

Refresh the browser until the login page shows. Login with both username and password as admin. Fill the form with these credentials:

```
Name: samdom
Host: *samba_ad_dc_ip*
Port: 389 [ ] LDAPS
Account: Administrator@smbdc1
Password: *samba_admin_password_here*
Base DN: CN=Users,DC=samdom,DC=example,DC=com
LDAP filter:
Timeout (in seconds):

On-the-fly user creation [X]
Attributes:
    Login attribute: sAMAccountName
    Firstname attribute: givenName
    Lastname attribute: sn
    Email attribute: userPrincipalName
```

Now log out and log in with the samba administrator credentials (username: administrator, password: *check with docker log dc1*)

## Windows client

[This](http://vimeo.com/11527979#t=3m15s) is a nice guide to join your Windows 7 client to the DC. Just make sure to have your Docker container as the
[primary DNS server for Windows](http://www.opennicproject.org/configure-your-dns/how-to-change-dns-servers-in-windows-7/).

## LDAP explorers

I used [JXplorer](http://jxplorer.org/) to explore the LDAP-schema. To log in you need to input something like this:
![JXplorer example](http://i.imgur.com/LniIp22.png)

## Testing UNIX login with sssd

```
root@e936157c0bc1:~# getent passwd Administrator
administrator:*:935000500:935000513:Administrator:/:
root@e936157c0bc1:~# getent group "Domain Users"
domain users:*:935000513:administrator
root@e936157c0bc1:~# ssh Administrator@localhost
Administrator@localhost's password:
Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.14.4-1-ARCH x86_64)
```

## Resources
I followed the guide on Samba's wiki pages https://wiki.samba.org/index.php/Samba_AD_DC_HOWTO

Port usage: https://wiki.samba.org/index.php/Samba_port_usage

## Port forwarding command
If you want the DC to be reachable through the host's IP you can start the container with this command:
```
docker run --privileged -p 53:53 -p 53:53/udp -p 88:88 -p 88:88/udp -p 135:135 -p 137:137/udp -p 138:138/udp -p 139:139 -p 389:389 -p 389:389/udp -p 445:445 -p 464:464 -p 464:464/udp -p 636:636 -p 3268:3268 -p 3269:3269 -p 1024:1024 -p 1025:1025 -p 1026:1026 -p 1027:1027 -p 1028:1028 -p 1029:1029 -p 1030:1030 -p 1031:1031 -p 1032:1032 -p 1033:1033 -p 1034:1034 -p 1035:1035 -p 1036:1036 -p 1037:1037 -p 1038:1038 -p 1039:1039 -p 1040:1040 -p 1041:1041 -p 1042:1042 -p 1043:1043 -p 1044:1044 -v ${HOME}/dockervolumes/samba:/var/lib/samba  -e "SAMBA_DOMAIN=samdom" -e "SAMBA_REALM=samdom.example.com" -e "SAMBA_HOST_IP=$(hostname --all-ip-addresses |cut -f 1 -d' ')" --name samdom --dns 127.0.0.1 -d samba-ad-dc
```

The problem is that the port range 1024 and upwards are used for dynamic RPC-calls, luckily Samba goes through them in
order, so the first 20 or so should suffice for testing purposes. Windows complains otherwise that "The RPC server is
unavailable". It's also possible to eliminate long command line parameters by using `$(for port in $(seq 135 139); do
echo -n "-p $port:$port "; done;)` instead.

## TODO

* [X] xattr and acl support for docker containers
* [ ] NTP support
* [ ] Try to join other Samba4 servers with a Samba4 DC
* [ ] How to implement redundancy and fail-safes?
* [X] Verify that Bind9 Dynamically Loadable Zones (DLZ) work
* [X] Can this be used for UNIX logins as well?
* [ ] Probably a lot more to make this robust enough for production use
* [ ] Fix rare BIND9 startup problems. Failed to connect to /var/lib/samba/private/dns/sam.ldb.
