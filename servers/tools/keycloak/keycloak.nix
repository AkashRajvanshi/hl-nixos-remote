{ config, pkgs, hostname, dbUser, dbName, ... }:

{
  services.keycloak = {
    enable = true;
    database = {
      createLocally = false;
      type = "postgres";
      host = "/run/postgresql";
      port = 5432;
      user = dbUser;
      name = dbName;
      passwordFile = config.sops.secrets."keycloak_db_password".path;
    };
    initialAdminPassword.path = config.sops.secrets."keycloak_admin_password".path;
    settings = {
      inherit hostname;
      "http-enabled" = true;
      proxy = "edge";
      "proxy-headers" = "xforwarded";
      "log-level" = "info";
      "metrics-enabled" = true;
    };
  };
}
