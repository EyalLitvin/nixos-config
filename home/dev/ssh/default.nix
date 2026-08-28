{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      User = "git";
      Hostname = "github.com";
      IdentityFile = "~/.ssh/id_ed25519";
    };
  };
}
