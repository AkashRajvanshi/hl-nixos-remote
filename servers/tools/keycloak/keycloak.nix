{ config, pkgs, ... }:

{
  services.keycloak = {
    enable = true;
    database = {
      createLocally = false;
      type = "postgres";
      host = "/run/postgresql";
      port = 5432;
      user = config.services.postgresql.ensureUsers."${config.nix-keycloak.dbUser}".name;
      name = config.nix-keycloak.dbName;
      passwordFile = config.sops.secrets."keycloak_db_password".path;
    };
    initialAdminPassword.path = config.sops.secrets."keycloak_admin_password".path;
    settings = {
      hostname = config.nix-keycloak.hostname;
      "http-enabled" = true;
      proxy = "edge";
      "proxy-headers" = "xforwarded";
      "log-level" = "info";
      "metrics-enabled" = true;
    };
  };
}
