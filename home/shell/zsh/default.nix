{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    plugins = [
      {
        name = "zsh-vi-mode";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
    ];

    # zsh-vi-mode overrides all keybindings on init, so history-substring-search
    # must be rebound inside its post-init hook to survive.
    initContent = ''
      zvm_after_init() {
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
      }
    '';

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      cat = "bat";
      oil = "nvim .";
      cs  = "z";
      vim = "nvim";
      vi  = "nvim";
    };
  };
}
