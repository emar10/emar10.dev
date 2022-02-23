+++ 
date = 2022-02-21T19:29:56-05:00
title = "Exposing Rootless Podman Containers to the Internet with Wireguard"
description = "In which I overcomplicate a game server by using local bare metal to do the heavy lifting and a cheap VPS to handle talking to the Internet."
slug = ""
authors = []
tags = ["containers", "podman", "wireguard", "networking"]
categories = []
externalLink = ""
series = []
+++

I run a small game server for myself and a handful of friends. Previously I had
done this entirely through a VPS, but the RAM requirements had gotten a bit
high for our tastes. The obvious solution was to leverage a spare machine I had
at home instead. The server was containerized with Podman, so migrating the
data and configuration would literally take minutes. This presented a new
challenge, however: *how do I expose it to the Internet?*

# Why not just port forward?

Easy mode for exposing services behind a home router's NAT is of course simple
port forwarding. A couple of router config changes and I would have been off to
the races. There would have been a few issues with this method, though. 

First off, my ISP may not have taken kindly to hosting a game server using my
connection. While I've never had a service provider expressly forbid hosting
services, I have had issues in the past with my public IP mysteriously changing
much more frequently than usual. Second, I'm generally not keen on opening
ports on my LAN to the public Internet.

In order to avoid directly exposing ports on my public IP, I decided to use a
cheap VPS as the public endpoint, then tunnel the service traffic to my bare
metal server at home via Wireguard. This way, I would get all the benefits of
using a VPS to begin with, at a much lower cost.

# VPS Setup

First I needed to set up a tiny VPS instance. [Linode](https://linode.com) is
my vendor of choice here; I like their no-nonsense "click a button, here's a
Linux box, do your thing" philosophy.[^1] My go-to distro for small,
single-purpose appliance machines like this is
[Alpine](https://alpinelinux.org/), but for readers following along most
anything should do since all we need is Wireguard and a firewall.

## Wireguard

Setting up a Wireguard server is a pretty well covered topic these days, so
I'll keep this description brief. On my Alpine box, I installed the userspace
Wireguard tools.

```
# apk install wireguard-tools
```

The Wireguard interface needed a public/private key pair:

```
# wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
```

I added the private key and listening port to `/etc/wireguard/wg0.conf` (the
peer will be set up later):

```conf
[Interface]
PrivateKey = <private key>
ListenPort = 51821
```

And defined the `ifupdown-ng` interface in `/etc/network/interfaces.d/wg0`:

```
auto wg0
iface wg0 inet static
	requires eth0
	use wireguard
	address 192.168.2.1
```

And, poof! When Alpine sets up networking, the `wg0` interface gets created.
Next, I needed to configure traffic routing.

## Firewall

Being on Alpine, I decided to use their own
[awall](https://gitlab.alpinelinux.org/alpine/awall). Naturally for those
following along, anything that supports port forwarding will work here, even
just adding some `iptables` rules to a `wg-quick` configuration. First, I
installed Alpine Wall:

```
# apk install awall
```

Then I verified that IPv4 Forwarding was enabled:

```
# sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
```

Alpine Wall is configured via JSON files. For a more detailed rundown, I
recommend the [user's guide](https://git.alpinelinux.org/awall/about/) and the
[Alpine Wiki](https://wiki.alpinelinux.org/wiki/Zero-To-Awall).

In `/etc/awall/base.json` I defined the main zones, policies, and enabled SNAT
(half of our port forwarding) for outgoing packets on the WAN interface.

```json
{
	"description": "Base zones and policies",

	"zone": {
		"inet": { "iface": "eth0" },
		"vpn":  { "iface": "wg0"  }
	},

	"policy": [
		{ "in": "vpn", "action": "accept" },
		{ "out": "vpn", "action": "accept" },
		{ "out": "inet", "action": "accept" },
		{ "in": "_fw", "action": "accept" },
		{ "in": "inet", "action": "drop" }
	],

	"snat": [ { "out": "inet" } ],
}
```

The policies define a fairly simple firewall that allows local/VPN traffic and
drops any unsolicited packets from the Internet.

Next I defined a couple of optional policies to allow SSH[^2] and Wireguard
traffic in `/etc/awall/optional/ssh.json` and
`/etc/awall/optional/wireguard.json`. 

```json
{
    "description": "Allow SSH from internet",

    "filter": [
        {
            "in": "inet",
            "out": "_fw",
            "service": "ssh",
            "action": "accept",
            "conn-limit": { "count": 3, "interval": 20 }
        }
    ]
}
```

```json
{
    "description": "Allow wireguard from internet",

    "filter": [
        {
            "in": "inet",
            "service": { "proto": "udp", "port": 51821 },
            "action": "accept"
        }
    ]
}
```

Then I defined an optional component in `/etc/awall/optional/game.json` to
open up the necessary ports and forward any traffic on them to the Wireguard
interface.

```json
{
    "description": "Forward game traffic to Wireguard peer",

    "service": {
        "game": [
            { "proto": "udp", "port": 12345 },
            { "proto": "tcp", "port": 12346 },
        ]
    }

    "filter": [
        {
            "in": "inet",
            "out": "vpn",
            "service": "game",
            "action": "accept"
        }
    ],

    "dnat": [
        {
            "in": "inet",
            "service": "game",
            "to-addr": "192.168.2.2"
        }
    ],

    "snat": [
        {
            "out": "vpn",
            "service": "game",
            "from-addr": "192.168.2.1"
        }
    ]
}
```

Let's break this down, since it's a bit more complex:

* `service`: Defines the ports and protocols used by our game. For this example
  we're using 12345/udp and 12346/tcp.
* `filter`: Accept packets from the Internet matching the defined service.
* `dnat`: Forward matching packets to the Wireguard client's IP.
* `snat`: Rewrite forwarded packets to appear as though they are coming from
  the server's Wireguard IP.[^3]

With all of the game-related policies defined, I enabled them and started up
the firewall.

```
# awall enable ssh
# awall enable wireguard
# awall enable game
# awall activate
```

On Alpine, enabling the `iptables` and `ipset` services ensures the firewall is
correctly restored on reboot.

```
# rc-update add iptables
# rc-update add ipset
```

# Local Machine Setup

Aside from migrating the game server data, I needed to do a couple of things on
my server at home: configure a Wireguard interface to connect to the VPS, open
up the necessary ports on that interface, and set up the Podman container to
direct all outgoing traffic back through the Wireguard interface. I run Fedora
Server on this device, but as with Alpine earlier my process should be fairly
simple to adapt for different distributions.

## Wireguard

As with the VPS, I'll be fairly brief with the local Wireguard configuration.
I also once again avoided `wg-quick` in favor of the native network
configuration tools on the system, in this case NetworkManager on Fedora.

After creating a second key pair for the local server, I created a base
Wireguard configuration at `/etc/wireguard/wg0.conf`:

```
[Interface]
Address = 192.168.2.2/24
PrivateKey = <local server private key>

[Peer]
PublicKey = <VPS public key>
AllowedIPs = 192.168.2.1/32
Endpoint = <VPS IP>:51821
PersistentKeepalive = 25
```

Next, I fed this configuration into NetworkManager to create a connection.

```
# nmcli connection import type wireguard file /etc/wireguard/wg0.conf
```

Finally, I added a `[Peer]` section to the Wireguard configuration on the VPS.

```
[Peer]
PublicKey = <local server public key>
AllowedIPs = 192.168.2.1/32
```

And with that, the two machines were connected!

## Firewall

The firewall configuration was thankfully much simpler on the local server.
Fedora uses [firewalld](https://firewalld.org/) by default, which allows ports
to be opened with a simple command (assuming the `wg0` interface is attached to
the public zone).


```
# firewall-cmd --zone=public --permanent --add-port=12345/udp
# firewall-cmd --zone=public --permanent --add-port=12346/tcp
```

And that's it! At least as far as incoming traffic is concerned...

## Podman

Finally, the moment of truth! Rootless Podman containers currently provide
networking using
[slirp4netns](https://github.com/rootless-containers/slirp4netns) by default.
This provides an `--outbound-addr=[IPv4 | INTERFACE]` option that allows
forcing outbound packets to use a particular source IP or interface.

Podman exposes this via the `--network` option in the CLI and `network_mode` in
Compose. I fired up a quick test container to try this:

```
$ podman run --rm -it --network="slirp4netns:outbound_addr=wg0" docker.io/alpine
```

And a `curl 1.1.1.1` gave me... nothing.

## Wireguard, Revisited

So what went wrong? Turns out there were a couple of issues. First, the
server's Wireguard configuration specified `AllowedIPs = 192.168.2.1/32` for
the VPS peer. This means that the Wireguard interface will simply refuse to do
anything with packets I sent through it that weren't aimed at `192.168.2.1`.
Second, the routing table generated by NetworkManager lacked a default route
for the interface.

And so, I set off to fix these issues by manually editing the NetworkManager
connection. System-level connections are stored at
`/etc/NetworkManager/system-connections/`.

There are three sections of interest in `wg0.nmconnection`: `[wireguard]`,
`[wireguard-peer]`, and `[ipv4]`.

```
[wireguard]
private-key=<local server private key>

[wireguard-peer.<VPS public key>]
endpoint=<VPS public IP>:51821
persistent-keepalive=25
allowed-ips=192.168.2.1/32

[ipv4]
address1=192.168.2.2/32
dns-priority=-50
dns-search=
method=manual
```

Right away I changed the peer's allowed IPs to `0.0.0.0/0` to allow any
traffic. Unfortunately this automatically sets up the routing table for a
"traditional" VPN use case, where *all* traffic is sent over the VPN.[^4]
Thankfully, NetworkManager provides the `ip4-auto-default-route` option to
disable this under the `[wireguard]` section.

Next, I needed to modify the routing tables to correctly send traffic from the
Wireguard IP through `wg0`, while allowing everything else to go out through
the main network interface as normal. A couple of extra options in the `[ipv4]`
section accomplished this:

* `route-table=201`: Forces all routes from this interface onto a different
  table. This prevents traffic from going over the Wireguard interface by
  default.
* `routing-rule1=priority 0 to 192.168.2.1 table 201`: A rule that sends any
  traffic aimed directly at VPS to the newly created table.
* `routing-rule2=priority 0 from 192.168.2.2/32 table 201`: A rule that sends
  any traffic with the local server's Wireguard IP as the source address to the
  new table.

With these changes, a Podman container attached to the Wireguard interface was
able to talk to the Internet with no problems! Finally, I was able to spin up
the game server. Here's a sample CLI invokation:

```
$ podman run --name game \
  --network="slirp4netns:outbound_addr=wg0" \
  -p 12345:12345/udp -p 12346:12346/tcp \
  <repo>/<image>
```

And a Compose version:

```yaml
version: "3.9"

services:
    game:
        image: <repo>/<image>
        network_mode: "slirp4netns:outbound_addr=wg0"
        ports:
            - "12345:12345/udp"
            - "12346:12346/tcp"

```

# Additional Reading

* [awall](https://gitlab.alpinelinux.org/alpine/awall) is a pretty swell
  iptables wrapper, and fits quite nicely with Alpine itself.

* [NetworkManager's
  documentation](https://networkmanager.dev/docs/api/latest/nm-settings-nmcli.html)
  for connection profiles was immensely valuable for figuring this out without
  resorting to janky scripts to jam in my own routing.

[^1]: I'm not being paid to say this, nice as that would be. I just genuinely
  think Linode is a good service.

[^2]: An SSH policy is not *strictly* required, but for most setups is helpful
  to avoid locking yourself out of your system.

[^3]: This has the consequence of rendering any IP-based
  whitelisting/blacklisting on the Wireguard client useless, but avoids needing
  to set `AllowedIPs = 0.0.0.0/0` in the server's Wireguard configuration.
  *Foreshadowing...*

[^4]: Notably, this behavior is not specific to NetworkManager. It actually
  mirrors similar functionality in `wg-quick`.
