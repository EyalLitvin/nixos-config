{ config, ... }:

{
  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user.name = "EyalLitvin";
      user.email = "eyalitvin@email.com";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };
  };
}
