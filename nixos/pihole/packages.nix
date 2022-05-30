{ config, lib, pkgs, ... }:

{
  # refuse any X11 stuff in package defaults
  environment.noXlibs = true;

  environment.systemPackages = with pkgs; [
    # basics
    busybox
    mlocate
    tree
    file
    ripgrep

    # ops
    lshw
    lm_sensors
    cpufrequtils
    htop
    iotop
    # wireshark-cli

    # editors
    (emacs.override {
      withX = false;
      withGTK2 = false;
      withGTK3 = false;
    })

    # dev environment
    asdf-vm
    direnv
    (git.override {
      pythonSupport = false;
      withpcre2 = false;
      guiSupport = false;
      withManual = false;
    })

    # build tools
    gcc
    gnumake
    bison
    binutils
  ];

  # Make mlocate work properly
  users.groups.mlocate = {};
}
