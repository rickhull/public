{ ... }:

{
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

  # OpenSSH
  services.openssh.enable = true;

  # SAMBA for hostname registry
  # note: /etc/resolv.conf: "domain mshome.net"
  services.samba = {
    enable = true;
    nsswins = true;
    extraConfig = ''
      netbios name = pihole
    '';
  };

  # protect power button from short-press shutdown
  # 5-second press cuts hard power
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
}
