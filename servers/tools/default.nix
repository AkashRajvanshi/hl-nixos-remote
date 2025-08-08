{ config, pkgs, ... }:

{
  imports = [
    ./networking.nix
    ./traefik.nix
    ./oidc-middleware.nix
    ./komodo.nix
    ./keycloak
  ];

  sops.secrets."traefik.env" = {
    sopsFile = ./secrets/traefik-enc.env;
    format = "dotenv";
    path = "/etc/secrets/traefik.env";
    owner = "traefik";
    group = "traefik";
    mode = "0400";
  };

  sops.secrets."komodo-extended.env" = {
    sopsFile = ./secrets/komodo-enc.env;
    format = "dotenv";
    path = "/etc/secrets/komodo-extended.env";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  environment.etc."secrets/komodo-base.env" = {
    source = ./secrets/komodo-base.env;
    mode = "0400";
    uid = config.users.users.root.uid;
    gid = config.users.groups.root.gid;
  };
}
