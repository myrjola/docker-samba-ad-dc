# Docker container demonstrating Samba's Active Directory Domain Controller (AD DC) support

Run these commands to start the container
```
docker build -t samba-ad-dc .
docker run  -e "SAMBA_DOMAIN=smbdc1" -e "SAMBA_REALM=smbdc1.example.com" --name dc1 --dns 127.0.0.1 -d samba-ad-dc
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
docker pull sameersbn/redmine:latest
docker run --name redmine -d sameersbn/latest
REDMINE_IP=$(docker inspect redmine | grep IPAddres | awk -F'"' '{print $4}')
xdg-open "http://${REDMINE_IP}/auth_sources/new"
```

Refresh the browser until the login page shows. Login with both username and password as admin. Fill the form with these credentials:

```
Name: smbdc1
Host: smbdc1.example.com
Port: 389 [ ] LDAPS
Account: Administrator@smbdc1
Password: *samba_admin_password_here*
Base DN: CN=Users,DC=smbdc1,DC=example,DC=com
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
![JXplorer example][http://i.imgur.com/LniIp22.png]

## Resources
I followed the guide on Samba's wiki pages https://wiki.samba.org/index.php/Samba_AD_DC_HOWTO

## TODO

* [ ] NTP support seems to be important
* [ ] Backup support (Maybe mount Samba database folders as docker volumes)
* [ ] How to implement redundancy (Samba cluster doesn't seem to be production ready yet)
* [ ] Verify that Bind9 Dynamically Loadable Zones (DLZ) work
* [ ] Can this be used for UNIX logins as well?
* [ ] Probably a lot more to make this robust enough for production use
