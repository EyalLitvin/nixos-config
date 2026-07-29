{ config, lib, pkgs, ... }:

let
  openacp = pkgs.buildNpmPackage rec {
    pname   = "openacp";
    version = "2026.518.2";

    src = pkgs.fetchurl {
      url  = "https://registry.npmjs.org/@openacp/cli/-/cli-${version}.tgz";
      hash = "sha512-6Zw5ft1STPq6hi66YOqVA43JD0W76p4DKr61k8wWuD2QN36dhGBylSeYOw5M8AijgEFNqlreIfr8PRrVcfBizA==";
    };

    # npm tarballs unpack to "package/" — inject the vendored lock file there
    postPatch = ''
      cp ${./openacp-package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-y9RbeZilwKEUoYIAEI+gAc/0FFatgHjboSHEWFJ8xjM=";

    # dist/ is already compiled in the npm tarball; nothing to build
    dontNpmBuild = true;
  };
in {
  options.userSettings.apps.openacp.enable =
    lib.mkEnableOption "openACP AI-agent messaging bridge (Telegram/Discord/Slack)";

  config = lib.mkIf config.userSettings.apps.openacp.enable {
    home.packages = [ openacp ];
  };
}
