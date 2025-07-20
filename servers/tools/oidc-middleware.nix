{ config, pkgs, ... }:

{
  sops.secrets.oidc_client_secret = {
    sopsFile = ./secrets/secrets-enc.yaml;
    #owner = "traefik";
    #group = config.services.traefik.group;
    neededForUsers = false;
  };

  sops.templates."oidc-middleware.toml" = {
    content = ''
      [http.middlewares."oidc-auth".plugin."traefik-oidc-auth"]
      Scopes = [ "openid", "profile", "email" ]

      [http.middlewares."oidc-auth".plugin."traefik-oidc-auth".Provider]
      Url = "https://nix-keycloak.thinkncode.biz/realms/master"
      ClientId = "nix-traefik"
      ClientSecret = "${config.sops.placeholder.oidc_client_secret}"
      UsePkce = true
      ValidAudience = "account"
    '';
    owner = "traefik";
    group = "traefik";
    mode = "0600";
  };

  environment.etc."traefik/dynamic/oidc-middleware.toml" = {
    source = config.sops.templates."oidc-middleware.toml".path;
    user = "traefik";
    group = "traefik";
  };
}
