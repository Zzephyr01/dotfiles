# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  # rpcs3-latest = pkgs.rpcs3.overrideAttrs (old: {
  #   version = "0.0.40";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "RPCS3";
  #     repo = "rpcs3";
  #     rev = "e6cf05cfb73e156818685495814b0b7b8edaa97b";
  #     postCheckout = ''
  #       cd $out/3rdparty
  #       git submodule update --init \
  #         fusion/fusion asmjit/asmjit yaml-cpp/yaml-cpp SoundTouch/soundtouch stblib/stb \
  #         feralinteractive/feralinteractive
  #     '';
  #     hash = "sha256-KrWsiDQcdbBBDQlui9bXWsxit/fiv7mQoJA2VQlu9fU=";
  #   };
  #   buildInputs = old.buildInputs ++ [ pkgs.protobuf ];
  #   cmakeFlags = old.cmakeFlags ++ [
  #     (lib.cmakeBool "USE_SYSTEM_PROTOBUF" true)
  #     (lib.cmakeBool "USE_SYSTEM_FLATBUFFERS" false)
  #   ];
  # });
  RStudio-with-stuff = pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [
      ggplot2
      ggthemes
      ggrepel
      gridExtra
      dplyr
      dslabs
      base64enc
      digest
      evaluate
      highr
      htmltools
      jsonlite
      knitr
      mime
      rmarkdown
      stringi
      stringr
      xfun
      yaml
      zipR
      Biostrings
    ];
  };
  retroarch-with-stuff = pkgs.retroarch.withCores (
    cores: with cores; [
      desmume
      pcsx2
    ]
  );
  python-o = pkgs.python314.override {
    self = pkgs.python314;
    packageOverrides = pyfinal: pyprev: {
      djitellopy = pyfinal.callPackage ./dji.nix { };
    };
  };
  python314-with-stuff = python-o.withPackages (
    python-pkgs: with python-pkgs; [
      # select Python packages here
      djitellopy
      numpy
      opencv-python
      pandas
      matplotlib
      scikit-learn
    ]
  );
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # inputs.windscribe-bin.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # Nuh uh, nvidia doesn't like that-
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # CPU-coking-itself fix
  # boot.kernelParams = [ "intel_pstate=active" ];
  boot.kernelParams = [ "amd_pstate=active" ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zeph = {
    isNormalUser = true;
    description = "zeph";
    extraGroups = [
      "networkmanager"
      "wheel"
      "windscribe"
    ];
    packages = with pkgs; [ ];

    #   home-manager.users.zeph = { pkgs, ... }: {
    #     home.packages = [ pkgs.atool pkgs.httpie ];
    #     programs.bash.enable = true;
    #     # This value determines the Home Manager release that your configuration is
    #     # compatible with. This helps avoid breakage when a new Home Manager release
    #     # introduces backwards incompatible changes.
    #     #
    #     # You should not change this value, even if you update Home Manager. If you do
    #     # want to update the value, then make sure to first check the Home Manager
    #     # release notes.
    #     home.stateVersion = "25.11"; # Please read the comment before changing.
    #   };
    #
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To
  # search, run:
  # $ nix search wget

  # - - - - - Custom Package Versions - - - - -

  nixpkgs.config.permittedInsecurePackages = [
    "electron-38.8.4"
  ];

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    xwayland-satellite
    htop
    quickshell
    acpi
    wl-clipboard
    # light
    # That's just disappointing...
    brightnessctl
    #python314
    python314-with-stuff
    # libinput, osu! won't detect the tablet tho-
    # opentabletdriver, not like this apparently-
    miktex
    gcc

    git
    kitty
    # yazi, now installed using home manager
    typst
    tinymist
    # neovim
    _7zz
    libreoffice-qt6-fresh
    R
    # rstudio, now installs packages declaratively
    RStudio-with-stuff
    jftui
    # jetbrains.clion, using neovim for now-
    graphite-cursors
    vscodium
    ltspice
    wl-mirror
    unrar
    ouch

    # librewolf
    obs-studio
    rpcs3
    # rpcs3-latest, now installed the proper way!
    shadps4
    # retroarch, now installs cores declaratively
    retroarch-with-stuff
    # inputs.upbge.packages.x86_64-linux.my-upbge, I give up
    davinci-resolve
    krita
    obsidian
    qalculate-qt
    qbittorrent
    tor-browser

    osu-lazer-bin
    prismlauncher
    starsector
    mindustry
    endless-sky
    unciv
    heroic
  ];

  # - - - - - Fonts - - - - -

  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    noto-fonts-cjk-sans
  ];

  # - - - - - Nvidia - - - - -

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    # May cause specific issues, apparently-
    sync.enable = true;

    amdgpuBusId = "PCI:7:0:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # - - - - - Custom - - - - -

  programs.niri.enable = true;

  programs.java.enable = true;

  services.flatpak.enable = true;

  hardware.opentabletdriver.enable = true;

  # services.windscribe.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.asusd.enable = true;

  # Brightness Up/Down not detected fix
  # Not working, used 'light' pkg instead
  # Deprecated, switched to 'brightnessctl'
  # hardware.i2c.enable = true;

  # Battery fix?
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.headset-roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
  };

  services.udev = {
    packages = [
      (pkgs.writeTextFile {
        name = "my-rules";
        text = ''
          KERNEL=="hidraw*", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
          # Wacom CTH-480
          KERNEL=="hidraw*", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", TAG+="uaccess", TAG+="udev-acl"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", TAG+="uaccess", TAG+="udev-acl"
        '';
        destination = "/etc/udev/rules.d/70-opentabletdriver.rules";
      })
    ]
    ++ [
      pkgs.oversteer
      pkgs.usb-modeswitch-data
    ];
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c294", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 046d -p c294 -m 01 -r 01 -C 03 -M '0f00010142'"
    '';
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    remotePlay.openFirewall = true; # ports for steam remote play
    dedicatedServer.openFirewall = true; # ports for Source dedicated servers
    localNetworkGameTransfers.openFirewall = true; # for local game transfers
  };

  # Fix for mic mute button (nixos-hardware rog-z-503)
  services.udev.extraHwdb = ''
    evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
     KEYBOARD_KEY_ff31007c=f20
  '';

  # programs.sway.enable = true;
  # programs.sway.wrapperFeatures.gtk = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gnome
    ];
    config = {
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
      };
    };
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/zeph";
  };

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableCalendarEvents = false;
  };
  programs.nvf = {
    enable = true;
    settings = import ./mike-nvf-config.nix;
  };

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
  system.stateVersion = "25.11"; # Did you read the comment?

}
