{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      mgr.show_hidden = true;
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "<C-w>" ];
          run = ''shell -- bash -c 'cp "$1" ~/.dotfiles/wallpapers/' _ "$1"'';
          desc = "Copy to wallpapers";
        }
      ];
    };
  };
}
