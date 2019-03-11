# ipv4-use-first

Sometimes the system will think that oyu have ipv6 when yggdrasill / cjdns are active. This casues some sites that have both an A and AAAA record not to load  (because it tries the AAAA record).

This script changes gia.conf to lower ipv6 address preferences below ipv4 making ipv4 preferred. gai stands for getaddrinfo, the standard system call for resolving host names.

**USAGE**

`ipv4-first`
