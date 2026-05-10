{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      # Required by kitty-scrollback.nvim to read terminal content
      allow_remote_control = "yes";
      scrollback_pager_history_size = 10240;
    };

    # kitty_scrollback_nvim      → browse full scrollback in nvim  (ctrl+shift+h)
    # ksb_builtin_last_cmd_output → browse only last command output (ctrl+shift+g)
    extraConfig = ''
      action_alias kitty_scrollback_nvim kitten ${pkgs.vimPlugins.kitty-scrollback-nvim}/python_kittens/kitty_scrollback_nvim.py
      map ctrl+shift+h kitty_scrollback_nvim
      map ctrl+shift+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
    '';
  };
}
