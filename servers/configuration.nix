{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  #boot.loader.grub.enable = true;
  #boot.loader.grub.device = "/dev/sda";
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";  # Required for EFI
  };

  boot.kernelPackages =
    pkgs.linuxPackages_6_1 or
    pkgs.linuxPackages_latest;

  boot.kernelPackages = let
    baseKernel =
      pkgs.linux_6_1 or
      pkgs.linux_latest;
    customKernel = baseKernel.override {
      structuredExtraConfig = with pkgs.lib.kernel; {
        MODULES = yes;
      };
    };
  in pkgs.linuxPackagesFor customKernel;


  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.hacstac = ./home.nix;
    backupFileExtension = "backup";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      warn-dirty = false;
      auto-optimise-store = true;
      download-buffer-size = 128 * 1024 * 1024;
      trusted-users = [ "hacstac" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.vim
  ];

  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  security.sudo.wheelNeedsPassword = lib.mkForce false;
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  systemd.services.docker-proxy-network = {
    description = "Create Docker proxy network";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "create-proxy-network" ''
        if ! ${pkgs.docker}/bin/docker network inspect proxy >/dev/null 2>&1; then
          ${pkgs.docker}/bin/docker network create proxy
        fi
      '';
    };
  };

  programs.zsh = {
    enable = true;
  };

  users.users.hacstac = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5ZqSa7YeUmeOKnmzmPLHErdtty1BFOLux1r5TplEy9 hacstac"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "hacstac" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  system.extraDependencies = with config.boot.kernelPackages; [
    kernel
    kernel.dev
  ];


  time.timeZone = "Asia/Kolkata";
  networking.firewall.enable = true;
  nix.extraOptions = "keep-outputs = true";

  system.stateVersion = "25.05";
  services.journald = {
    extraConfig = ''
      SystemMaxUse=2G
      MaxRetentionSec=1month
    '';
  };
}
