{ config, lib, pkgs, modulesPath, hardware, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];
  boot.blacklistedKernelModules = [ "rtl8821ae" ];
  boot.extraModulePackages = [ ];

  # explicitly disable radeon support and enable
  # amdgpu for "Sea Islands" architecture (CIK)
  boot.kernelParams = [ "radeon.cik_support=0" "amdgpu.cik_support=1" ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "xfs";
      options = [ "defaults" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/efi";
      fsType = "vfat";
      options = [ "defaults" "noatime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "conservative";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;


  #
  # OpenGL / Vulkan
  #

  hardware.opengl = {
    enable = true;     # OpenGL
    driSupport = true; # Vulkan

    extraPackages = with pkgs; [
      # enable OpenCL; confirm with `clinfo`
      rocm-opencl-icd
      rocm-opencl-runtime

      # enable AMD's Vulkan driver, in addition to Mesa's radv
      # amdvlk
    ];
  };

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
}
