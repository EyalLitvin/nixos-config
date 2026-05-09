{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      user = "git";
      hostname = "github.com";
      identityFile = "~/.ssh/id_ed25519";
    };
  };
}
