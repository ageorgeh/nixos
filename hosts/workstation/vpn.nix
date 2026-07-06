{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  ns = "airvpn";
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.identityPaths = [ "/home/alex/.ssh/id_ed25519_agenix" ];

  age.secrets."airvpn-private-key" = {
    file = inputs.self + "/secrets/airvpn-private-key.age";
    mode = "600";
  };

  age.secrets."airvpn-preshared-key" = {
    file = inputs.self + "/secrets/airvpn-preshared-key.age";
    mode = "600";
  };

  environment.etc."netns/${ns}/resolv.conf".text = ''
    nameserver 10.128.0.1
    nameserver fd7d:76ee:e68f:a993::1
  '';

  networking.wireguard.interfaces.wg-airvpn = {
    ips = [
      "10.139.52.237/32"
      "fd7d:76ee:e68f:a993:97df:96cb:44e6:32e7/128"
    ];

    privateKeyFile = config.age.secrets."airvpn-private-key".path;
    mtu = 1320;

    interfaceNamespace = ns;
    allowedIPsAsRoutes = false;

    preSetup = ''
      ${pkgs.iproute2}/bin/ip netns add ${ns} 2>/dev/null || true
    '';

    postSetup = ''
      ${pkgs.iproute2}/bin/ip -n ${ns} link set lo up
      ${pkgs.iproute2}/bin/ip -n ${ns} route replace default dev wg-airvpn
      ${pkgs.iproute2}/bin/ip -n ${ns} -6 route replace default dev wg-airvpn
    '';

    postShutdown = ''
      ${pkgs.iproute2}/bin/ip netns del ${ns} 2>/dev/null || true
    '';

    peers = [
      {
        publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
        presharedKeyFile = config.age.secrets."airvpn-preshared-key".path;
        endpoint = "oceania3.vpn.airdns.org:1637";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        persistentKeepalive = 15;
      }
    ];
  };

  systemd.services.wireguard-wg-airvpn.wantedBy = lib.mkForce [ ];

  # Starts Firefox but attaches its networking syscalls to the airvpn namespace.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "vpn-firefox" ''
      set -euo pipefail

      user="''${SUDO_USER:-$USER}"
      home="$(${pkgs.getent}/bin/getent passwd "$user" | cut -d: -f6)"

      sudo ${pkgs.systemd}/bin/systemctl start wireguard-wg-airvpn.service

      exec sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XDG_RUNTIME_DIR,DBUS_SESSION_BUS_ADDRESS,XAUTHORITY \
        ${pkgs.iproute2}/bin/ip netns exec ${ns} \
        ${pkgs.sudo}/bin/sudo -u "$user" \
        env HOME="$home" USER="$user" LOGNAME="$user" \
        DISPLAY="''${DISPLAY:-}" \
        WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-}" \
        XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-}" \
        DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-}" \
        XAUTHORITY="''${XAUTHORITY:-}" \
        ${pkgs.firefox}/bin/firefox --no-remote --profile "$home/.mozilla/firefox/airvpn"
    '')
  ];
}
