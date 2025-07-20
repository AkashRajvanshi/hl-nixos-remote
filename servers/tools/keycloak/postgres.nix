{ config, pkgs, dbUser, dbName, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    extensions = [ pkgs.postgresql_16.pkgs.pgvector ];

    authentication = pkgs.lib.mkForce 10 ''
      local   all             all                                     scram-sha-256
      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';

    ensureDatabases = [ dbName ];
    ensureUsers = [{
      name = dbUser;
      passwordFile = config.sops.secrets."keycloak_db_password".path;
    }];

    initialScript = pkgs.writeText "keycloak-db-init" ''
      GRANT ALL PRIVILEGES ON DATABASE "${dbName}" TO "${dbUser}";
    '';
  };
}
