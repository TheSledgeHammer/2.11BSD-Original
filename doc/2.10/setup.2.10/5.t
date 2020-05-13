.\" Copyright (c) 1980 Regents of the University of California.
.\" All rights reserved.  The Berkeley software License Agreement
.\" specifies the terms and conditions for redistribution.
.\"
.\"	@(#)5.t	6.2 (Berkeley) 10/1/88
.\"
.ds lq ``
.ds rq ''
.ds LH "Installing/Operating \*(2B
.ds RH Network setup
.ds CF \*(DY
.LP
.nr H1 5
.nr H2 0
.bp
.LG
.B
.ce
5. NETWORK SETUP
.sp 2
.R
.NL
.PP
The following section has been lightly edited to correspond to
the current \*(2B networking.  Several parts of it do not really apply to
\*(2B, for example, it is unlikely that anyone will connect a PDP to
an IMP, or that anyone will need to run the nameserver.
The ``correct''
use of the networking in \*(2B is probably with a list of the local net
addresses in the \fI/etc/hosts\fP file and with one default gateway for
all network traffic.  In particular, do not run
.IR routed (8)
unless you're extremely sure that you know what you're doing.  This is
doubly true if SLIP is being used as the primary connection to the
outside world.  Much of the \*(2B networking is ported but untested.
This means that sites that wish to hook \*(2B into more than a simple
local ethernet may have to do some kernel work.
.PP
The networking in \*(2B, runs in supervisor
mode, separate from the mainstream kernel.  This is a major win, as
it allows the networking to maintain its mbufs in normal data space,
among other things.  The networking portion of the kernel resides in
``/netnix'', and is
loaded after the kernel is running.  As the kernel looks for this
file only, and will not run if it's unable to load it, sites should
build and keep a non-networking kernel in ``/'' at all times, as a
backup.
.PP
\*(2B provides support for the DARPA standard Internet
protocols IP, ICMP, TCP, and UDP.  These protocols may be used
on top of a variety of hardware devices ranging from the
IMP's (PSN's) used in the ARPANET to local area network controllers
for the Ethernet.  Network services are split between the
kernel (communication protocols) and user programs (user
services such as TELNET and FTP).  This section describes
how to configure your system to use the Internet networking support.
\*(2B also includes code to support the Xerox Network Systems (NS)
protocols; the basic porting work has been done, but it is completely
untested.  IDP and SPP are implemented in the kernel, and other
protocols such as Courier run at the user level.
.NH 2
System configuration
.PP
To configure the kernel to include the Internet communication
protocols, define the UCB_NET option.  This automatically defines
the INET, TCP_COMPAT_42, and NLOOP options.  Xerox NS support is
enabled with the NS option.
In either case, include the pseudo-device
``pty'' in your machine's configuration
file, using the NPTY options.
The ``pty'' pseudo-device forces the pseudo terminal device driver
to be configured into the system, see \fIpty\fP\|(4).  The NLOOP
option forces inclusion of the software loopback interface driver.
The loop driver is used in network testing.
.PP
If you are planning to use the Internet network facilities on a 10Mb/s
Ethernet, the pseudo-device ``ether'' should also be included
in the configuration using the NETHER option; this forces inclusion of
the Address Resolution Protocol module used in mapping between 48-bit
Ethernet and 32-bit Internet addresses.  Also, if you have an IMP
connection, you will need to include the pseudo-device ``imp'', using
the option NIMP.  The IMP software is ported, but untested.
.PP
Before configuring the appropriate networking hardware, you should
consult the manual pages in section 4 of the Programmer's Manual.
The following table lists the devices for which software support
exists.  Again, much of this software is unported and untested; only
the basic networking has been stressed at all.  Many other devices
are available, but unported.  Porting should simply be a matter of
making the hardware device work.  The directories ``/sys/pdpif'' and
``/sys/vaxif'' contain many drivers.  The ones in ``pdpif'' are
either the current, working drivers, or drivers that, at some time,
worked on pdp-11's.  The ones in ``vaxif'' are the current VAX drivers,
and, as such, will have to have their memory usage changed, but serve
as an excellent example of how the hardware works.~
.DS
.TS
l l.
Device name	Manufacturer and product
_
de	DEC DEUNA/DELUA 10Mb/s Ethernet
qe	DEC DEQNA 10Mb/s Ethernet
ec	3Com 10Mb/s Ethernet
il	Interlan 1010 and 10101A 10Mb/s Ethernet interfaces
.TE
.DE
.PP
SLIP is also available.  It is currently fairly slow, as the interface
between the supervisor and kernel mode sections of the kernel for SLIP
are quite painful, in that it passes single characters to the networking
portion of the kernel.  A few days work in fixing this interface could be
quite rewarding in terms of real throughput.
.PP
All network interface drivers including the loopback interface,
require that their host address(es) be defined at boot time.
This is done with
.IR ifconfig (8C)
commands included in the \fI/etc/rc.local\fP file.
Interfaces that are able to dynamically deduce the host
part of an address may check that the host part of the address is correct.
The manual page for each network interface
describes the method used to establish a host's address.
.IR Ifconfig (8)
can also be used to set options for the interface at boot time.
Options are set independently for each interface, and
apply to all packets sent using that interface.
These options include disabling the use of the Address Resolution Protocol;
this may be useful if a network is shared with hosts running software
that does not yet provide this function.
Alternatively, translations for such hosts may be set in advance
or ``published'' by a \*(2B host by use of the
.IR arp (8c)
command.  Note that the use of trailer link-level is now negotiated
between \*(2B hosts using ARP, and it is thus no longer necessary to
disable the use of trailers with \fIifconfig\fP.  It is \fBSTRONGLY\fP
recommended, however, that \*(2B networking be run without trailers,
as the trailer code in most of the drivers has either been commented
out as untested or is \fBknown\fP not to work.  This is a problem with
certain releases of \fIUltrix\fP, which has to be explicitly configured
not to send trailers if it and \*(2B are to coexist.
.PP
To use the pseudo terminals just configured, device
entries must be created in the ``/dev'' directory.  To create 32
pseudo terminals (plenty, you can probably get by with many less)
execute the following commands.
.DS
\fB#\fP cd /dev
\fB#\fP MAKEDEV pty0 pty1
.DE
More pseudo terminals may be made by specifying \fIpty2\fP, \fIpty3\fP,
etc.  The kernel normally includes support for 16 pseudo terminals
unless the configuration file specifies a different number.
Each pseudo terminal really consists of two files in /dev:
a master and a slave.  The master pseudo terminal file is named
/dev/ptyp?, while the slave side is /dev/ttyp?.  Pseudo terminals
are also used by several programs not related to the network.
In addition to creating the pseudo terminals,
be sure to install them in the
.I /etc/ttys
file (with a `none' in the second column so no
.I getty
is started).
.NH 2
Local subnetworks
.PP
In \*(2B the DARPA Internet support
includes the notion of ``subnetworks''.  This is a mechanism
by which multiple local networks may appears as a single Internet
network to off-site hosts.  Subnetworks are useful because
they allow a site to hide their local topology, requiring only a single
route in external gateways;
it also means that local network numbers may be locally administered.
The standard describing this change in Internet addressing is RFC-950.
.PP
To set up local subnetworks one must first decide how the available
address space (the Internet ``host part'' of the 32-bit address)
is to be partitioned.
Sites with a class A network
number have a 24-bit address space with which to work,
sites with a class B network number have a 16-bit address space,
while sites with a class C network number have an 8-bit address space*.
.FS
* If you are unfamiliar with the Internet addressing structure, consult
``Address Mappings'', Internet RFC-796, J. Postel; available from
the Internet Network Information Center at SRI.
.FE
To define local subnets you must steal some bits
from the local host address space for use in extending the network
portion of the Internet address.  This reinterpretation of Internet
addresses is done only for local networks; i.e. it is not visible
to hosts off-site.  For example, if your site has a class B network
number, hosts on this network have an Internet address that contains
the network number, 16 bits, and the host number, another
16 bits.  To define 254 local subnets, each
possessing at most 255 hosts, 8 bits may be taken from the local part.
(The use of subnets 0 and all-1's, 255 in this example, is discouraged
to avoid confusion about broadcast addresses.)
These new network
numbers are then constructed by concatenating the original 16-bit network
number with the extra 8 bits containing the local subnetwork number.
.PP
The existence of local subnetworks is communicated to the system at the time a
network interface is configured with the
.I netmask
option to the
.I ifconfig
program.  A ``network mask'' is specified to define the
portion of the Internet address that is to be considered the network part
for that network.
This mask normally contains the bits corresponding to the standard
network part as well as the portion of the local part
that has been assigned to subnets.
If no mask is specified when the address is set,
it will be set according to the class of the network.
For example, at Berkeley (class B network 128.32) 8 bits
of the local part have been reserved for defining subnetworks;
consequently the /etc/rc.local file contains lines of the form
.DS
/etc/ifconfig en0 netmask 0xffffff00 128.32.1.7
.DE
This specifies that for interface ``en0'', the upper 24 bits of
the Internet address should be used in calculating network numbers
(netmask 0xffffff00), and the interface's Internet address is
``128.32.1.7'' (host 7 on network 128.32.1).  Hosts \fIm\fP on
sub-network \fIn\fP of this network would then have addresses of
the form ``128.32.\fIn\fP.\fIm\fP'';  for example, host
99 on network 129 would have an address ``128.32.129.99''.
For hosts with multiple interfaces, the network mask should
be set for each interface,
although in practice only the mask of the first interface on each network
is actually used.
.NH 2
Internet broadcast addresses
.PP
The address defined as the broadcast address for Internet networks
according to RFC-919 is the address with a host part of all 1's.
The address used by 4.2BSD was the address with a host part of 0.
\*(2B uses the standard broadcast address (all 1's) by default,
but allows the broadcast address to be set (with \fIifconfig\fP)
for each interface.
This allows networks consisting of both 4.2BSD and \*(2B hosts
to coexist.
In the presence of subnets, the broadcast address uses the subnet field
as for normal host addresses, with the remaining host part set to 1's
(or 0's, on a network that has not yet been converted).
\*(2B hosts recognize and accept packets
sent to the logical-network broadcast address as well as those sent
to the subnet broadcast address, and when using an all-1's broadcast,
also recognize and receive packets sent to host 0 as a broadcast.
.NH 2
Routing
.PP
If your environment allows access to networks not directly
attached to your host you will need to set up routing information
to allow packets to be properly routed.  Two schemes are
supported by the system.  The first scheme
employs the routing table management daemon \fI/etc/routed\fP
to maintain the system routing tables.  The routing daemon
uses a variant of the Xerox Routing Information Protocol
to maintain up to date routing tables in a cluster of local
area networks.  By using the \fI/etc/gateways\fP
file created by
.IR htable (8),
the routing daemon can also be used to initialize static routes
to distant networks (see the next section for further discussion).
When the routing daemon is started up
(usually from \fI/etc/rc.local\fP) it reads \fI/etc/gateways\fP if it exists
and installs those routes defined there, then broadcasts on each local network
to which the host is attached to find other instances of the routing
daemon.  If any responses are received, the routing daemons
cooperate in maintaining a globally consistent view of routing
in the local environment.  This view can be extended to include
remote sites also running the routing daemon by setting up suitable
entries in \fI/etc/gateways\fP; consult
.IR routed (8C)
for a more thorough discussion.
.PP
The second approach is to define a default or wildcard
route to a smart
gateway and depend on the gateway to provide ICMP routing
redirect information to dynamically create a routing data
base.  This is done by adding an entry of the form
.DS
/etc/route add default \fIsmart-gateway\fP 1
.DE
to \fI/etc/rc.local\fP; see
.IR route (8C)
for more information.  The default route
will be used by the system as a ``last resort''
in routing packets to their destination.  Assuming the gateway
to which packets are directed is able to generate the proper
routing redirect messages, the system will then add routing
table entries based on the information supplied.  This approach
has certain advantages over the routing daemon, but is
unsuitable in an environment where there are only bridges (i.e.
pseudo gateways that, for instance, do not generate routing
redirect messages).  Further, if the
smart gateway goes down there is no alternative, save manual
alteration of the routing table entry, to maintaining service.
.PP
The system always listens, and processes, routing redirect
information, so it is possible to combine both of the above
facilities.  For example, the routing table management process
might be used to maintain up to date information about routes
to geographically local networks, while employing the wildcard
routing techniques for ``distant'' networks.  The
.IR netstat (1)
program may be used to display routing table contents as well
as various routing oriented statistics.  For example,
.DS
\fB#\fP\|netstat \-r
.DE
will display the contents of the routing tables, while
.DS
\fB#\fP\|netstat \-r \-s
.DE
will show the number of routing table entries dynamically
created as a result of routing redirect messages, etc.
.NH 2
Use of \*(2B machines as gateways
.PP
Only sheer insanity could prompt the use of \*(2B machines as gateways.
However, if you have no choice, several changes have been made in \*(2B
in the area of gateway support
(or packet forwarding, if one prefers).
A new configuration option, GATEWAY, is used when configuring
a machine to be used as a gateway.
This option increases the size of the routing hash tables in the kernel.
Unless configured with that option,
hosts with only a single non-loopback interface never attempt
to forward packets or to respond with ICMP error messages to misdirected
packets.
This change reduces the problems that may occur when different hosts
on a network disagree as to the network number or broadcast address.
Another change is that \*(2B machines that forward packets back through
the same interface on which they arrived
will send ICMP redirects to the source host if it is on the same network.
This improves the interaction of \*(2B gateways with hosts that configure
their routes via default gateways and redirects.
The generation of redirects may be disabled with the configuration option
IPSENDREDIRECTS=0 in environments where it may cause difficulties.
.PP
Local area routing within a group of interconnected Ethernets
and other such networks may be handled by
.IR routed (8c).
Gateways between the Arpanet or Milnet and one or more local networks
require an additional routing protocol, the Exterior Gateway Protocol (EGP),
to inform the core gateways of their presence
and to acquire routing information from the core.
An EGP implementation for 4.2BSD was done by Paul Kirton
while visiting ISI, and any sites requiring such support that have not
already obtained a copy should contact Joyce Reynolds
(JKReynolds@usc-isif.arpa) for information.
That implementation works with \*(2B without kernel modifications.
It must be modified, as packets from the ICMP raw socket include
the IP header like other raw sockets in \*(2B.
If necessary, contact the Berkeley Computer Systems Research Group
for assistance.
.NH 2
Network servers
.PP
In \*(2B most of the server programs are started up by a
``super server'', the Internet daemon.  The Internet
daemon, \fI/etc/inetd\fP, acts as a master server for
programs specified in its configuration file, \fI/etc/inetd.conf\fP,
listening for service requests for these servers, and starting
up the appropriate program whenever a request is received.
The configuration file contains lines containing a service
name (as found in \fI/etc/services\fP), the type of socket the
server expects (e.g. stream or dgram), the protocol to be
used with the socket (as found in \fI/etc/protocols\fP), whether
to wait for each server to complete before starting up another,
the user name as which the server should run, the server
program's name, and at most five arguments to pass to the
server program.
Some trivial services are implemented internally in \fIinetd\fP,
and their servers are listed as ``internal.''
For example, an entry for the file
transfer protocol server would appear as
.DS
ftp	stream	tcp	nowait	root	/etc/ftpd	ftpd
.DE
Consult
.IR inetd (8c)
for more detail on the format of the configuration file
and the operation of the Internet daemon.
.NH 2
Network data bases
.PP
Several data files are used by the network library routines
and server programs.  Most of these files are host independent
and updated only rarely.
.DS
.TS
l l l.
File	Manual reference	Use
_
/etc/hosts	\fIhosts\fP\|(5)	host names
/etc/networks	\fInetworks\fP\|(5)	network names
/etc/services	\fIservices\fP\|(5)	list of known services
/etc/protocols	\fIprotocols\fP\|(5)	protocol names
/etc/hosts.equiv	\fIrshd\fP\|(8C)	list of ``trusted'' hosts
/etc/rc.local	\fIrc\fP\|(8)	command script for starting servers
/etc/ftpusers	\fIftpd\fP\|(8C)	list of ``unwelcome'' ftp users
/etc/hosts.lpd	\fIlpd\fP\|(8C)	list of hosts allowed to access printers
/etc/inetd.conf	\fIinetd\fP\|(8)	list of servers started by \fIinetd\fP
.TE
.DE
The files distributed are set up for ARPANET or other Internet hosts.
Local networks and hosts should be added to describe the local
configuration; the Berkeley entries may serve as examples
(see also the next section).
Network numbers will have to be chosen for each Ethernet.
For sites not connected to the Internet,
these can be chosen more or less arbitrarily,
otherwise the normal channels should be used for allocation of network
numbers.
.NH 3
Regenerating /etc/hosts and /etc/networks
.PP
When using the host address routines that use the Internet name server,
the file \fI/etc/hosts\fP is only used for setting interface addresses
and at other times that the server is not running,
and therefore it need only contain addresses for local hosts.
There is no equivalent service for network names yet.
The full host and network name data bases are normally derived from
a file retrieved from the Internet Network Information Center at
SRI.
To do this you should use the program /etc/gettable
to retrieve the NIC host data base, and the program
.IR htable (8)
to convert it to the format used by the libraries.
You should change to the directory where you maintain your local
additions to the host table and execute the following commands.
.DS
\fB#\fP /etc/gettable sri-nic.arpa
\fBConnection to sri-nic.arpa opened.\fP
\fBHost table received.\fP
\fBConnection to sri-nic.arpa closed.\fP
\fB#\fP /etc/htable hosts.txt
\fBWarning, no localgateways file.\fP
\fB#\fP
.DE
The \fIhtable\fP program generates three files
in the local directory: \fIhosts\fP, \fInetworks\fP and \fIgateways\fP.
If a file ``localhosts'' is present in the working directory its
contents are first copied to the output file.  Similarly, a
``localnetworks'' file may be prepended to the output created
by \fIhtable\fP,
and `localgateways'' will be prepended to \fIgateways\fP.
It is usually wise to run \fIdiff\fP\|(1) on
the new host and network data bases before installing them in /etc.
If you are using the host table for host name and address
mapping, you should run \fImkhosts\fP\|(8) after installing
\fI/etc/hosts\fP.
If you are using the name server for the host name and address mapping,
you only need to install \fInetworks\fP and a small copy of \fIhosts\fP
describing your local machines.  The full host table in this case might
be placed somewhere else for reference by users.
The gateways file may be installed in \fI/etc/gateways\fP if you use
.IR routed (8c)
for local routing and wish to have static external routes installed
when \fIrouted\fP is started.
This procedure is essentially obsolete, however, except for individual hosts
that are on the Arpanet or Milnet and do not forward packets from a local
network.
Other situations require the use of an EGP server.
.PP
If you are connected to the DARPA Internet, it is highly recommended that
you use the name server for your host name and address mapping, as this
provides access to a much larger set of hosts than are provided in the
host table.  Many large organization on the network, currently have
only a small percentage of their hosts listed in the host table retrieved
from NIC.
.NH 3
/etc/hosts.equiv
.PP
The remote login and shell servers use an
authentication scheme based on trusted hosts.  The \fIhosts.equiv\fP
file contains a list of hosts that are considered trusted
and, under a single administrative control.  When a user
contacts a remote login or shell server requesting service,
the client process passes the user's name and the official
name of the host on which the client is located.  In the simple
case, if the host's name is located in \fIhosts.equiv\fP and
the user has an account on the server's machine, then service
is rendered (i.e. the user is allowed to log in, or the command
is executed).  Users may expand this ``equivalence'' of
machines by installing a \fI.rhosts\fP file in their login directory.
The root login is handled specially, bypassing the \fIhosts.equiv\fP
file, and using only the \fI/.rhosts\fP file.
.PP
Thus, to create a class of equivalent machines, the \fIhosts.equiv\fP
file should contain the \fIofficial\fP names for those machines.
If you are running the name server, you may omit the domain part
of the host name for machines in your local domain.
For example, several machines on our local
network are considered trusted, so the \fIhosts.equiv\fP file is
of the form:
.DS
ucbarpa
calder
dali
ernie
kim
degas
.DE
.NH 3
/etc/rc.local
.PP
Most network servers are automatically started up at boot time
by the command file /etc/rc (if they are installed in their
presumed locations) or by the Internet daemon (see above).
These include the following:
.DS
.TS
l l l.
Program	Server	Started by
_
/etc/rshd	shell server	inetd
/etc/rexecd	exec server	inetd
/etc/rlogind	login server	inetd
/etc/telnetd	TELNET server	inetd
/etc/ftpd	FTP server	inetd
/etc/fingerd	Finger server	inetd
/etc/tftpd	TFTP server	inetd
/etc/rwhod	system status daemon	/etc/rc
/etc/syslogd	error logging server	/etc/rc
/usr/lib/sendmail	SMTP server	/etc/rc
/etc/routed	routing table management daemon	/etc/rc
.TE
.DE
Consult the manual pages and accompanying documentation (particularly
for sendmail) for details about their operation.
.PP
To have other network servers started up as well,
the appropriate line should be added
to the Internet daemon's configuration file \fI/etc/inetd.conf\fP, or
commands of the following sort should be placed in the site dependent
file \fI/etc/rc.local\fP.
.DS
if [ -f /etc/routed ]; then
	/etc/routed & echo -n ' routed'			>/dev/console
f\&i
.DE
.NH 3
/etc/ftpusers
.PP
The FTP server included in the system provides support for an
anonymous FTP account.  Because of the inherent security problems
with such a facility you should read this section carefully if
you consider providing such a service.
.PP
An anonymous account is enabled by creating a user \fIftp\fP.
When a client uses the anonymous account a \fIchroot\fP\|(2)
system call is performed by the server to restrict the client
from moving outside that part of the file system where the
user ftp home directory is located.  Because a \fIchroot\fP call
is used, certain programs and files used by the server 
process must be placed in the ftp home directory. 
Further, one must be
sure that all directories and executable images are unwritable.
The following directory setup is recommended.
.DS
\fB#\fP cd ~ftp
\fB#\fP chmod 555 .; chown ftp .; chgrp ftp .
\fB#\fP mkdir bin etc pub
\fB#\fP chown root bin etc
\fB#\fP chmod 555 bin etc
\fB#\fP chown ftp pub
\fB#\fP chmod 777 pub
\fB#\fP cd bin
\fB#\fP cp /bin/sh /bin/ls .
\fB#\fP chmod 111 sh ls
\fB#\fP cd ../etc
\fB#\fP cp /etc/passwd /etc/group .
\fB#\fP chmod 444 passwd group
.DE
When local users wish to place files in the anonymous
area, they must be placed in a subdirectory.  In the
setup here, the directory \fI~ftp/pub\fP is used.
.PP
Another issue to consider is the copy of \fI/etc/passwd\fP
placed here.  It may be copied by users who use the
anonymous account.  They may then try to break the 
passwords of users on your machine for further access.
A good choice of users to include in this copy might
be root, daemon, uucp, and the ftp user.  All passwords
here should probably be ``*''.
.PP
Aside from the problems of directory modes and such,
the ftp server may provide a loophole for interlopers
if certain user accounts are allowed.
The file \fI/etc/ftpusers\fP is checked on each connection.
If the requested user name is located in the file, the
request for service is denied.  This file normally has
the following names on our systems.
.DS
uucp
root
.DE
Accounts with nonstandard shells should be listed in
this file.  Accounts without passwords
need not be listed in this file, the ftp server will
not service these users.
