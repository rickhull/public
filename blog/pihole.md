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
towards AMD because they have a much better relationship with Linux and the
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
6. 60 GB for files

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
* (/dev/sda6) 60 GB  [ext4]             "files60"
