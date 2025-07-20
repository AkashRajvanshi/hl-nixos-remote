{ config, pkgs, ... }:

{
  sops.secrets."traefik-oidc-middleware" = {
    sopsFile = ../secrets/oidc-middleware.toml;
    path = "/etc/traefik/dynamic/oidc-middleware.toml";
    owner = config.services.traefik.user;
    group = config.services.traefik.group;
  };
}
