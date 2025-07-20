{ config, ... }:

{
  networking = {
    hostName = "hl-nixos";
    domain = "thinkncode.biz";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    useNetworkd = true;
    interfaces.ens18.ipv4.addresses = [
      {
        address = "10.0.5.114";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "10.0.5.1";
      interface = "ens18";
    };
  };
}
