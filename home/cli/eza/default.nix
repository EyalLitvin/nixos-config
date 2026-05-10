{ ... }:

{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
  };

  programs.zsh.shellAliases = {
    ls = "eza";
    ll = "eza -l --git";
    la = "eza -la --git";
  };
}
