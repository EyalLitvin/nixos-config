{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty-{kitty_pid}";
      scrollback_pager_history_size = 10240;
    };

    # ctrl+shift+h → full scrollback in nvim (colors preserved)
    # ctrl+shift+g → last command output only
    extraConfig = ''
      action_alias kitty_scrollback_nvim kitten ${pkgs.vimPlugins.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py
      map ctrl+shift+h kitty_scrollback_nvim
      map ctrl+shift+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
    '';
  };
}
