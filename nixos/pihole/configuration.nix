{ config, pkgs, ... }:

{
  imports =
    [ ./my-hardware-configuration.nix
      ./services.nix
      ./packages.nix
    ];

  #
  #		BOOT LOADER
  #

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 4; # boot images
  boot.loader.systemd-boot.consoleMode = "max";    # full res

  boot.loader.timeout = 4;
  boot.loader.efi.canTouchEfiVariables = true;


  #
  #		NETWORKING
  #

  networking.hostName = "pihole";
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" "8.8.8.8" ];

  # WIRED (enp2s0); static IP
  networking.interfaces.enp2s0 = {
    useDHCP = false;
    wakeOnLan.enable = true;
    ipv4.addresses = [ {
      address = "192.168.1.10";
      prefixLength = 24;
    }];
  };

  # WIRELESS (wlp1s0); disabled
  networking.wireless.enable = false;  # wpa_supplicant
  networking.interfaces.wlp1s0.useDHCP = false;
  networking.localCommands = ''
    ${pkgs.nettools}/bin/ifconfig wlp1s0 down
  '';


  #
  #		FIREWALL
  #

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Nixos services will punch their own holes by default
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  #
  #		MISC
  #

  # Enable Nix Flakes
  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Set TZ
  time.timeZone = "America/New_York";

  # Add users
  users.users.rwh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "mlocate" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
