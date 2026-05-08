{ config, lib, pkgs, ... }:

let
  repos = [
    "EyalLitvin/game_logic"
    "EyalLitvin/Thesis"
    "EyalLitvin/personal-site"
    "EyalLitvin/opti-do"
  ];
in
{
  home.activation.cloneRepos = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/dev
    ${lib.concatMapStrings (repo:
      let name = lib.last (lib.splitString "/" repo);
      in ''
        if [ ! -d "${config.home.homeDirectory}/dev/${name}" ]; then
          echo "Cloning ${repo}..."
          GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh" \
          ${pkgs.git}/bin/git clone git@github.com:${repo}.git \
            ${config.home.homeDirectory}/dev/${name}
        fi
      ''
    ) repos}
  '';
}
