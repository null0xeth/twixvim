# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: let
in {
  imports = [
    ./hardware/apple.nix
    ./hardware/common/cpu/intel/default.nix
    ./hardware-configuration.nix
  ];

  # boot.kernelParams = [
  # "modeset=1"
  # "fbdev=1"
  # "nomodeset"
  # ];

  # boot.kernelPackages = pkgs.linuxPackages_5_19;

  # boot.extraModulePackages = with config.boot.kernelPackages; [
  # ];

  boot.initrd.kernelModules = [
    "i915"
  ];

  # boot.kernelModules = [
  # ];

  hardware.opengl = {
    enable = true;
    # extraPackages = with pkgs; [
    # ];
  };

  /*
  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "conservative";
  };
  services.fstrim.enable = lib.mkDefault true;
  */

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
    persistent = true;
  };
  nix.settings.auto-optimise-store = true;

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = true;
      configurationLimit = 5;
      # memtest86.enable = true;
    };
    efi.efiSysMountPoint = "/boot/efi";
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "hotplate"; # do not do this with secrets!
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";
  #console.font = "lat2-08";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  # hardware.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  # enable = true;
  # alsa.enable = true;
  # alsa.support32Bit = true;
  # pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  #jack.enable = true;

  # use the example session manager (no others are packaged yet so this is enabled by default,
  # no need to redefine it in your config for now)
  #media-session.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # virtualisation = {
  # waydroid.enable = true;
  # lxd.enable = true;
  # };

  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    shell = pkgs.fish;
  };
  users.users.alina = {
    isNormalUser = true;
    description = " ";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "wireshark"
      "plugdev"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      w3m
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  security.audit.enable = true;
  security.auditd.enable = true;
  security.pam.enableFscrypt = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    rsync
    wget
    pciutils
    usbutils
    lsof
    git
    btop
    sysz
    parted
    util-linux
    tealdeer
    neofetch
    dmidecode

    # security
    fscryptctl
    lynis
    rng-tools
    logrotate
    libpwquality
    audit
    clamav
    aide
    file
    binutils

    # shell
    fishPlugins.colored-man-pages
    fishPlugins.sponge
    fishPlugins.fzf-fish
    fishPlugins.hydro
    fishPlugins.done
    fishPlugins.grc
    oh-my-fish
    fzf
    grc
    fd
    gum
    broot
  ];

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  # services.dbus.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.openssh.settings.PasswordAuthentication = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
