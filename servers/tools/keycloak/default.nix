{ config, pkgs, ... }:

let
  hostname = "nix-keycloak.thinkncode.biz";
  dbUser = "keycloak";
  dbName = "keycloak";
in
{
  _module.args = { inherit hostname dbUser dbName; };
  imports = [
    ./postgres.nix
    ./keycloak.nix
    ./traefik.nix
  ];

  users.groups.secrets = {};
  users.groups.keycloak = {};

  users.users.keycloak = {
    isSystemUser = true;
    group = "keycloak";
    extraGroups = [ "secrets" ];
  };

  users.users.postgres.extraGroups = [ "secrets" ];

  sops.secrets = {
    "keycloak_db_password" = {
      sopsFile = ../secrets/secrets-enc.yaml;
      format = "yaml";
      owner = config.users.users.root.name;
      group = config.users.groups.secrets.name;
      mode = "0440";
    };

    "keycloak_admin_password" = {
      sopsFile = ../secrets/secrets-enc.yaml;
      format = "yaml";
      owner = config.users.users.keycloak.name;
      group = config.users.groups.keycloak.name;
      mode = "0400";
    };

  };
}
