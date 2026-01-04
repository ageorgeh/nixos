{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.plex = {
    enable = true;
    openFirewall = true; # TCP 32400
    user = "plex";
    group = "plex";
  };

  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    openFirewall = true;
    serverConfig = {
      # https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent
      LegalNotice.Accepted = true;
      Application = {
        MemoryWorkingSetLimit = "2048";
      };
      BitTorrent = {
        Session = {
          DefaultSavePath = "/srv/downloads/complete";
          Interface = "wg0"; # kill switch
          InterfaceAddress = "10.139.52.237"; # second kill switch
          InterfaceName = "wg0";
          MaxUploads = "30";
          MaxUploadsPerTorrent = "8";
          Port = "20882";
          TempPath = "/srv/downloads/incomplete";
          TempPathEnabled = "true";
        };
      };
      Preferences = {
        WebUI = {
          Username = "user";
        };
      };
    };
  };
}
