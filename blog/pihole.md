# A Small Fanless Linux Box Running PiHole

I want to have a small, unobtrusive, low-power, fanless linux box running 24/7
that provides some network services like black-holing most ad networks.  It
should also support login shells for emacs/vim/etc software development. If
this box can also provide fileserver / VM host / media center / gaming
functions, then great, but not strictly necessary.

Since this will run 24/7, I want it to be fanless (solid state) with low
power requirements and good energy efficiency.  This machine is never expected
to run a desktop environment, web browser, or graphical user interface, unless
some secondary objective (e.g. gaming / MAME / emulation) requires such.

I considered many options, lusting after current AMD Ryzen APUs which can be
stuffed into finely crafted fanless enclosures such as
[these](https://www.cirrus7.com/en/produkte/cirrus7-incus/).  I am also leaning
towards AMD because they have a good relationship with Linux and the
open source community.  But I ended up settling for an older AMD A6 quad core
chipset originally aimed at the netbook / airbook / laptop market, but adapted
to a fanless, aluminum heat sink chassis, with modern peripherals like HDMI,
USB 3.0, GbE, etc.  We will boot via UEFI (not BIOS).

## Arch + NixOS

I have been experimenting a lot with NixOS lately, and I plan to mostly run
NixOS on this box.  But I will have a smaller backup partition with Arch Linux
installed, either as a rescue partition or replacement if NixOS isn't working
out.  The box includes a 128 GB SSD, so here is the planned partition layout:

1. 512 MB for /boot
2. 1 GB for swap
3. 10 GB for arch
4. 20 GB for NixOS
5. 30 GB for files
6. 60 GB (whatever is left) for files

### Detailed Partitioning

#### /dev/sda
* type: SSD/SATA
* size: 128 GB

#### GPT partition table
* (/dev/sda1) 512 MB [FAT32]            "efi"
* (/dev/sda2) 1  GB  [swap]             "swap"
* (/dev/sda3) 10 GB  [ext4]             "arch"
* (/dev/sda4) 20 GB  [XFS -m reflink=1] "nixos"
* (/dev/sda5) 30 GB  [ext4]             "files30"
* (/dev/sda6) 100%   [ext4]             "files60"

#### Steps

I didn't take notes, unfortunately.  Per the Arch install guide, having booted
via USB, I created the partitions with fdisk, like:

```
new +512M
new +1G
new +10G
new +20G
new +30G
new 100%
```

It was important to me to label the partitions, and this happens generally
at filesystem creation time.  Again, no detailed notes, but it was mostly a
series of things like

```
mkfs.fat -B 32 -L efi ...
mkswap ...
mkfs.ext4 ...
mkfs.xfs -m reflink=1 ...
...
```

## Static Networking

### Use `systemd-networkd` and `systemd-resolved`

Be careful with
https://wiki.archlinux.org/title/Installation_guide#Network_configuration
recommending you visit
https://wiki.archlinux.org/title/Network_configuration
because you will get very confused if you are trying to use systemd for static
networking.

It's very simple, however, based on `$GATEWAY_IP` and `$STATIC_IP`, and this
assumes DNS comes from `$GATEWAY_IP`:

```
# WIRED_NAME=enp2s0
# STATIC_IP=192.168.1.10
# GATEWAY_IP=192.168.1.1

cat << EOF >> /etc/systemd/network/20-wired.conf
[Match]
Name=$WIRED_NAME

[Network]
Address=$STATIC_IP
Gateway=$GATEWAY_IP
DNS=$GATEWAY_IP
EOF

systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl start systemd-networkd
systemctl start systemd-resolved

ping archlinux.org
```

Having gotten static networking going, I haven't done much with DHCP or even
attempted WiFi.  I did install OpenSSH, but I haven't even attempted a login
yet.  Eventually I would like to get PiHole and a basic dev shell via SSH
going on Arch, but I paused here.

## NixOS

Having already created my partitions and filesystems, the NixOS install was
a breeze.  I used balenaEtcher again with the latest NixOS install ISO to
overwrite the Arch installer on my USB stick.  Plugged it in, booted into
NixOS, mounted /dev/disk/by-label/nixos at /mnt, and ran
`nixos-generate-config --root /mnt`.

I then wandered around `/mnt/etc/nixos/configuration.nix` and made sure
`boot.loader.systemd-boot.enable` was set.  Took a look at
`hardware-configuration.nix` as well. Then `nixos-install`, wait for the
system to build, and reboot successfully.

### DNS Blacklist

I looked into running pihole specifically, but it does not appear Nix-friendly.
I read a post that suggested dnsmasq could easily do DNS blacklisting, so
I played with that for a little while.  Here is the config I tried:

```
  # dnsmasq for pihole-like experience
  #services.dnsmasq = {
  #  enable = true;
  #  servers = [
  #    "8.8.8.8"
  #    "8.8.4.4"
  #  ];
  #  extraConfig = ''
  #    domain-needed
  #    bogus-priv
  #    no-resolv
  #
  #    listen-address=::1,127.0.0.1,192.168.1.10
  #    bind-interfaces
  #
  #    cache-size=10000
  #    local-ttl=300
  #
  #    log-queries
  #    log-facility=/tmp/dnsmasq.log
  #
  #    conf-file=/etc/nixos/assets/dnsmasq.blacklist.txt
  #  '';
  #};
```

Now, where does `dnsmasq.blacklist.txt` come from?

```
wget https://github.com/notracking/hosts-blocklists/raw/master/dnsmasq/dnsmasq.blacklist.txt -O /etc/nixos/assets/dnsmasq.blacklist.txt
```

Maybe you throw that into `cron.daily`?  I found that this wasn't working very
well for me, and I could not find any sort of logging.  I could not confirm
that the blacklist was working, and a lot of ads were still being displayed
in various browsers.

#### AdGuardHome

Next, I ran across AdGuardHome, particularly finding it to be a supported
nixpkg.  I got it running pretty easily, and the early, basic setup is in the
history of a local git repo.  I did run into some headaches though, mostly due
to my wireless access point / gateway / router.

Ideally, any device on the network will automatically be configured to use the
local DNS resolver (i.e. pihole / blacklisting) instead of, say, the gateway
itself or any upstream (ISP) DNS servers.  There are a couple ways to do this,
mostly revolving around configuration on the gateway itself, either where the
gateway itself only knows about the local DNS resolver and ignores upstream
resolvers, or where the gateway's DHCP server tells local devices only about
the local DNS resolver.

My particular gateway device is not capable of either operation, nor can its
DHCP server be disabled.  One option I just now considered at this very moment
is to restrict the DHCP address pool on the gateway to a single address.  But
this is a kludge and will result in one device on average not using the pihole.
If I could disable the gateyway's DHCP server, then I could just let the pihole
run DHCP and advertise itself as the DNS server.

As such, as long as I'm running this particular gateway device, I have to
configure each device's DNS server individually.  And I was shocked to find
that my Android phone's network config widget does allow static IP
configuration or any DNS configuration.  Go figure v0v.  Most other devices
I care about were able to be configured individually.

##### Features

* DNS blackhole
* Malware / Phishing blocklist
* DHCP
* Various logging and encryption options
* Encrypted DNS (DoH, DoT)

##### Upstream DNS

For upstream DNS, I ended up pointing to the gateway and then google's public
DNS servers.  I was finding some high latency, so I haven't enabled any sort
of upstream encrypted DNS, yet.  Speaking of latency, I was getting response
times on the order of 200 ms, whereas dnsmasq was responding under 5-10 ms.

When querying upstream directly, responses came back around 10-20 ms (IIRC).
So, something in AdGuardHome was slowing down the DNS queries that were not
already cached and required upstream queries.  I ultimately determined it to
be reverse DNS lookups, where AdGuardHome sees a local IP address and sends
an rDNS query to the gateway to get a hostname (for friendlier log entries,
at minimum).  These rDNS queries were timing out, as it turns out my gateway
does not support rDNS either.  Once I disabled the rDNS attempts, average
query response (not including cached responses) was reduced to ~20 ms.

##### Configuration

```
  # AdGuardHome for pihole-like experience
  services.adguardhome = {
    enable = true;

    # just the http(s) admin interface
    port = 3000;
    openFirewall = true;

    # corresponds to /var/lib/AdGuardHome/AdGuardHome.yaml
    settings = {
      schema_version = 12;
      dns = {
        bind_hosts = ["0.0.0.0"];

        # query logging
        querylog_enabled = true;
        querylog_file_enabled = true;
        querylog_interval = "24h";
        querylog_size_memory = 1000;   # entries
        anonymize_client_ip = false;   # for now

        # adguard
        protection_enabled = true;
        blocking_mode = "default";     # NXDOMAIN
        filtering_enabled = true;

        # upstream DNS
        upstream_dns = [
          # slow, secure
          # "https://cloudflare-dns.com/dns-query"
          # "https://dns10.quad9.net/dns-query"

          # fast, insecure
          "192.168.1.1" # google fiber gateway
          "8.8.8.8"     # google
          "8.8.8.4"     # google
        ];
        # if upstream has any hostnames
        bootstrap_dns = ["192.168.1.1"];  # ask the gateway

        # caching
        cache_size = 536870912;  # 512 MB
        cache_ttl_min = 1800;    # 30 min
        cache_optimistic = true; # return stale and then refresh

        # rDNS (get hostname for local ips)
        # disable for now; isn't working and creates latency
        use_private_ptr_resolvers = false;
        resolve_clients = false;
      };

      # note: DHCP is disabled, because gateway's DCHP cannot be diabled
      # But DHCP can be usefully enabled on a distinct address segment from the
      # gateway's DHCP pool.  However, if the gateway responds first, there
      # will always be at least one device getting DHCP from the gateway
      dhcp = {
        enabled = false;
        interface_name = "enp2s0";
        dhcpv4 = {
          gateway_ip = "192.168.1.1";
          subnet_mask = "255.255.255.0";
          range_start = "192.168.1.100";
          range_end = "192.168.1.200";
          lease_duration = 0;
        };
        local_domain_name = "local";
      };
    };
  };

  # AdGuardHome's DNS service ports
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
```

Note, particularly: `schema_version = 12;`.  There is a "bug" of some sorts,
either on the AGH side or the nixpgks side, where if the `schema_version` is
not explicitly specified, then the schema is interpreted from version 0 and is
progressively checked and upgraded up through schema version 12.  Well, if you
present schema version 0 with schema version 12 config, then schema version 0
will reject the newer config.  And this is what happens when you try to build
a modern config without specifying the `schema_version`.

I reported these findings:

* [AdGuardHome issue 4067](https://github.com/AdguardTeam/AdGuardHome/issues/4067#issuecomment-1133781835)
* [NixOS/nixpkgs issue 173938](https://github.com/NixOS/nixpkgs/issues/173938)
