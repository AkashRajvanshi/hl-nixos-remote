{ config, pkgs, dbUser, dbName, ... }:

{
  sops.secrets."keycloak_db_password" = {
    sopsFile = ../secrets/secrets-enc.yaml;
    format = "yaml";
    owner = config.users.users.root.name;
    group = config.users.groups.secrets.name;
    mode = "0440";
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    extensions = [ pkgs.postgresql_16.pkgs.pgvector ];
    authentication = pkgs.lib.mkOverride 10 ''
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 scram-sha-256
    '';

    ensureDatabases = [ dbName ];
    ensureUsers = [{
      name = dbUser;
      ensureClauses.login = true;
      ensureClauses.superuser = true;
    }];

    initialScript = pkgs.writeShellScript "keycloak-db-init" ''
      PASSWORD=$(cat "${config.sops.secrets.keycloak_db_password.path}")
      psql -c "ALTER USER postgres WITH PASSWORD '$PASSWORD';"
      psql -d "${dbName}" -c "ALTER USER \"${dbUser}\" WITH PASSWORD '$PASSWORD';"
      psql -d "${dbName}" -c "GRANT ALL PRIVILEGES ON DATABASE \"${dbName}\" TO \"${dbUser}\";"
    '';
  };
}
