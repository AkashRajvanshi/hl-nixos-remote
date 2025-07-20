{ config, pkgs, hostname, dbUser, dbName, ... }:

{
  services.keycloak = {
    enable = true;
    database = {
      createLocally = false;
      type = "postgresql";
      host = "127.0.0.1";
      port = 5432;
      username = dbUser;
      name = dbName;
      useSSL = false;
      passwordFile = config.sops.secrets."keycloak_db_password".path;
    };
    initialAdminPassword = "2jkvdTRxZRiTJovQh";
    settings = {
      "hostname" = "https://${hostname}";
      "http-enabled" = true;
      "http-host" = "127.0.0.1";
      "http-port" = 8080;
      "proxy-headers" = "xforwarded";
      "log-level" = "info";
      "metrics-enabled" = true;
    };
  };
}
