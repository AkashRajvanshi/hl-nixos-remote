{ config, pkgs, ... }:

let
  trustedIPs = [
    "173.245.48.0/20" "103.21.244.0/22" "103.22.200.0/22"
    "103.31.4.0/22"  "141.101.64.0/18" "108.162.192.0/18"
    "190.93.240.0/20" "188.114.96.0/20" "197.234.240.0/22"
    "198.41.128.0/17" "162.158.0.0/15"  "104.16.0.0/12"
    "172.64.0.0/13"  "131.0.72.0/22"   "10.0.1.0/24"
    "2400:cb00::/32"  "2606:4700::/32"  "2803:f800::/32"
    "2405:b500::/32"  "2405:8100::/32"  "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];

  domain = config.networking.domain;
  email = "hello@${domain}";
in
{
  networking.firewall.allowedTCPPorts = [ 80 443 8082 ];
  environment.etc."secrets/traefik-enc.env".source = ./secrets/traefik-enc.env;
  users.users.traefik.extraGroups = [ "docker" ];

  systemd.tmpfiles.rules = [
      "d /var/lib/traefik 0750 traefik traefik - -"
      "Z /var/lib/traefik/acme.json 0600 traefik traefik - -"
      "Z /var/lib/traefik/acme-staging.json 0600 traefik traefik - -"
      "d /var/log/traefik 0755 traefik traefik - -"
      "Z /var/log/traefik/access.log 0644 traefik traefik - -"
      "d /etc/traefik/dynamic 0755 traefik traefik - -"
    ];

  systemd.services.traefik.serviceConfig.WorkingDirectory = config.services.traefik.dataDir;

  environment.etc."traefik/dynamic/base.yaml" = {
      source = (pkgs.formats.yaml {}).generate "base.yaml" config.services.traefik.dynamicConfigOptions;
      mode = "0444";
    };

  services.traefik = {
    enable = true;
    environmentFiles = [ "/etc/secrets/traefik.env" ];

    staticConfigOptions = {
      log = {
        level = "INFO";
      };

      accessLog = {
        format = "json";
        filePath = "/var/log/traefik/access.log";
        fields = {
          defaultMode = "keep";
          headers = {
            defaultMode = "keep";
            names = {
              "User-Agent" = "redact";
              Authorization = "drop";
            };
          };
        };
      };

      api = {
        dashboard = true;
      };

      global = {
        checkNewVersion = true;
        sendAnonymousUsage = false;
      };

      entryPoints = {
        http = {
          address = ":80";
          forwardedHeaders = {
            trustedIPs = trustedIPs;
          };
          http.redirections.entryPoint = {
            to = "https";
            scheme = "https";
            permanent = true;
          };
        };
        https = {
          address = ":443";
          forwardedHeaders = {
            trustedIPs = trustedIPs;
          };
          http.tls = {
            certResolver = "production";
            domains = [{
              main = "${domain}";
              sans = [ "*.${domain}" ];
            }];
          };
          #http.middlewares = [ "security-headers@file" "gzip@file" ];
        };
        metrics = { address = ":8082"; };
      };

      experimental.plugins.traefik-oidc-auth = {
        moduleName = "github.com/sevensolutions/traefik-oidc-auth";
        version = "v0.13.0";
      };

      providers = {
        docker = {
          watch = true;
          network = "proxy";
          defaultRule = "Host(`{{ index .Labels \"com.docker.compose.service\" }}.${domain}`)";
          endpoint = "unix:///var/run/docker.sock";
          exposedByDefault = false;
        };
        file = {
          directory = "/etc/traefik/dynamic";
          watch = true;
        };
      };

      certificatesResolvers = {
        production = {
          acme = {
            email = email;
            storage = "/var/lib/traefik/acme.json";
            caServer = "https://acme-v02.api.letsencrypt.org/directory";
            dnsChallenge = {
              provider = "cloudflare";
              resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
            };
          };
        };
        staging = {
          acme = {
            email = email;
            storage = "/var/lib/traefik/acme-staging.json";
            caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
            dnsChallenge = {
              provider = "cloudflare";
              resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
            };
          };
        };
      };

      metrics.prometheus = {
        entryPoint = "metrics";
        addServicesLabels = true;
      };
    };

    dynamicConfigOptions = {
      http = {
        middlewares = {
          security-headers = {
            headers = {
              forceSTSHeader = true;
              stsIncludeSubdomains = true;
              stsPreload = true;
              stsSeconds = 31536000;
              browserXssFilter = true;
              contentTypeNosniff = true;
              frameDeny = true;
              sslRedirect = true;
            };
          };

          gzip = { compress = {}; };

          traefik-auth = {
            basicAuth = {
              users = [ "hacstac:$2y$05$UMAW3B6fZKqcakKF3/u4a.ToKb/Cvj95G4Df7EL6ZO.XBHpr6uxuO" ];
            };
          };

          redirect-to-https = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
            };
          };
        };

        routers = {
          traefik-dashboard = {
            entryPoints = [ "https" ];
            rule = "Host(`nix-traefik.${domain}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
            middlewares = [ "traefik-auth" ];
            service = "api@internal";
            tls = true;
          };
        };
      };

      tls.options.default = {
        minVersion = "VersionTLS12";
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
          "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
          "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
          "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
        ];
      };
    };
  };
}
