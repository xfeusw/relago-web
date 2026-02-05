flake: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.relago-website;

  server = flake.packages.${pkgs.stdenv.hostPlatform.system}.default;

  site = cfg.package;

  caddy = lib.mkIf (cfg.enable && cfg.proxy.enable && cfg.proxy.proxy == "caddy") {
    services.caddy.virtualHosts."${cfg.proxy.domain}".extraConfig = ''
      root * ${site}
      encode zstd gzip

      try_files {path} /index.html

      file_server
    '';
  };

  nginx = lib.mkIf (cfg.enable && cfg.proxy.enable && cfg.proxy.proxy == "nginx") {
    services.nginx.virtualHosts = {
      enable = true;
      "${cfg.proxy.domain}" = {
        enableACME = true;
        addSSL = true;
        root = site;
        locations."/" = {
          extraConfig = ''
            try_files $uri $uri/ /index.html
          '';
        };
      };
    };
  };

  service = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      description = "Relago Website user";
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups.${cfg.group} = {};

    systemd.services.relago-website = {
      description = "Official website of Relago";
      documentation = ["https://github.com/xfeusw/relago-website"];

      environment = {
        PORT = "${toString cfg.port}";
        HOSTNAME = cfg.host;
        NODE_ENV = "production";
      };

      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        ExecStart = "${lib.getExe cfg.package}";
        StateDirectory = cfg.user;
        StateDirectoryMode = "0750";
        CapabilityBoundingSet = [
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];
        DeviceAllow = ["/dev/stdin r"];
        DevicePolicy = "strict";
        IPAddressAllow = "localhost";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = ["/"];
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
          "@pkey"
        ];
        UMask = "0027";
      };
    };
  };

  asserts = lib.mkIf cfg.enable {
    warnings = [
      (lib.mkIf (
        cfg.proxy.enable && cfg.proxy.domain == null
      ) "services.relago-website.proxy.domain must be set in order to properly generate certificate!")
    ];
  };
in {
  options = with lib; {
    services.relago-website = {
      enable = mkEnableOption ''
        Relago website.
      '';

      proxy = {
        enable = mkEnableOption ''
          Proxy reversed method of deployment
        '';

        domain = mkOption {
          type = with types; nullOr str;
          default = null;
          example = "relago.uz";
          description = "Domain to use while adding configuration to web proxy server";
        };

        proxy = mkOption {
          type = with types;
            nullOr (enum [
              "nginx"
              "caddy"
            ]);
          default = "caddy";
          description = "Proxy reverse software for hosting website";
        };
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Hostname for nextjs server to bind";
      };

      port = mkOption {
        type = types.int;
        default = 5173;
        description = "Port to use for passing overy proxy";
      };

      user = mkOption {
        type = types.str;
        default = "relago-www";
        description = "User for running system + accessing keys";
      };

      group = mkOption {
        type = types.str;
        default = "relago-www";
        description = "Group for running system + accessing keys";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/relago/www";
        description = ''
          The path where Relago Website server keeps data and possibly logs.
        '';
      };

      package = mkOption {
        type = types.package;
        default = server;
        description = ''
          Packaged relago.uz website contents for service.
        '';
      };
    };
  };

  config = lib.mkMerge [
    asserts
    service
    caddy
    nginx
  ];
}
