{ config, pkgs, hostname, ... }:

let
  appName = "keycloak";
  keycloakPort = toString config.services.keycloak.settings.http-port;
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers = {
      "${appName}-bypass" = {
        entrypoints = [ "https" ];
        rule = "Host(`${hostname}`) && (PathPrefix(`/js/`) || PathPrefix(`/realms/`) || PathPrefix(`/resources/`))";
        service = appName;
        priority = 100;
      };
      "${appName}-main" = {
        entrypoints = [ "https" ];
        rule = "Host(`${hostname}`)";
        service = appName;
        priority = 99;
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
