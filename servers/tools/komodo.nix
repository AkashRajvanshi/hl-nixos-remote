{ config, pkgs, ... }:

let
  komodoVersion = "1.18.4";
in
{
  environment.etc."secrets/komodo-extended.env".source = ./secrets/komodo-enc.env;
  environment.etc."secrets/komodo-base.env".source = ./secrets/komodo-base.env;

  virtualisation.oci-containers.containers = {
    komodo-mongo = {
      autoStart = true;
      image = "mongo:4.4.29-focal";
      cmd = [ "--quiet" "--wiredTigerCacheSizeGB" "0.25" ];
      volumes = [
        "mongodb_data:/data/db"
        "mongo-config:/data/configdb"
      ];
      environmentFiles = [ "/etc/secrets/komodo-base.env" "/etc/secrets/komodo-extended.env" ];
      labels = {
        "komodo.skip" = "";
      };
      extraOptions = [ "--network=proxy" ];
    };

    komodo-core = {
      autoStart = true;
      image = "ghcr.io/moghtech/komodo-core:${komodoVersion}";
      ports = [ "9120:9120" ];
      dependsOn = [ "komodo-mongo" ];
      volumes = [ "/home/${config.users.users.hacstac.name}/komodo/repos:/repo-cache" ];
      environmentFiles = [ "/etc/secrets/komodo-base.env" "/etc/secrets/komodo-extended.env" ];
      extraOptions = [ "--network=proxy" ];
    };

    komodo-periphery = {
      autoStart = true;
      image = "ghcr.io/moghtech/komodo-periphery:${komodoVersion}";
      environment = {
        PERIPHERY_REPO_DIR = "/etc/komodo/repos";
        PERIPHERY_STACK_DIR = "/etc/komodo/stacks";
        PERIPHERY_SSL_KEY_FILE = "/etc/komodo/ssl/key.pem";
        PERIPHERY_SSL_CERT_FILE = "/etc/komodo/ssl/cert.pem";
      };
      environmentFiles = [ "/etc/secrets/komodo-base.env" "/etc/secrets/komodo-extended.env" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/proc:/proc"
        "/etc/komodo:/etc/komodo"
        "/home/${config.users.users.hacstac.name}/komodo/docker-manifests:/mnt/user/compose"
        "/home/${config.users.users.hacstac.name}/homelab:/homelab"
      ];
      labels = {
        "komodo.skip" = "";
      };
      extraOptions = [ "--network=proxy" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 9120 ];

  services.traefik.dynamicConfigOptions.http = {
    routers.komodo = {
      entrypoints = [ "https" ];
      rule = "Host(`nix-komodo.${config.networking.domain}`)";
      service = "komodo";
      middlewares = [ "security-headers@file" "gzip@file" ];
    };
    routers."komodo-insecure" = {
      entrypoints = [ "http" ];
      rule = "Host(`nix-komodo.${config.networking.domain}`)";
      service = "komodo";
      middlewares = [ "redirect-to-https" ];
    };
    services.komodo = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          {
            url = "http://127.0.0.1:9120";
          }
        ];
      };
    };
  };
}
