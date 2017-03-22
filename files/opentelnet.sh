#!/bin/sh

sed -i "s|:/root:/sbin/nologin|:/root:/bin/sh|" /etc/passwd
telnetd &
/etc/init.d/etcsync
