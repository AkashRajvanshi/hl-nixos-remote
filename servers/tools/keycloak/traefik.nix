{ config, pkgs, hostname, ... }:

let
  appName = "keycloak";
  keycloakPort = toString config.services.keycloak.settings.http-port;
in
{
  services.traefik.dynamicConfigOptions.http = {
    middlewares = {
      keycloak-security-headers = {
        headers = {
          forceSTSHeader = true;
          stsIncludeSubdomains = true;
          stsPreload = true;
          stsSeconds = 31536000;
          browserXssFilter = true;
          contentTypeNosniff = true;
          sslRedirect = true;
          customFrameOptionsValue = "SAMEORIGIN";  
        };
      };
    };
    routers = {
      "${appName}-bypass" = {
        entrypoints = [ "https" ];
        rule = "Host(`${hostname}`) && (PathPrefix(`/js/`) || PathPrefix(`/realms/`) || PathPrefix(`/resources/`))";
        service = appName;
        priority = 100;
        middlewares = [ "keycloak-security-headers" "gzip" ];
      };
      "${appName}-main" = {
        entrypoints = [ "https" ];
        rule = "Host(`${hostname}`)";
        service = appName;
        priority = 99;
        middlewares = [ "keycloak-security-headers" "gzip" ];
      };
      "${appName}-insecure" = {
        entrypoints = [ "http" ];
        rule = "Host(`${hostname}`)";
        service = appName;
        middlewares = [ "redirect-to-https" ];
      };
    };
    services."${appName}".loadBalancer.servers = [{
      url = "http://127.0.0.1:${keycloakPort}";
    }];
  };
}
