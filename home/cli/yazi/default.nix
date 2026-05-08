{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings = {
      mgr.show_hidden = true;
      opener.image = [
        { run = ''imv "$@"''; desc = "imv"; block = false; }
      ];
      open.rules = [
        { mime = "image/*"; use = "image"; }
      ];
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "<C-w>" ];
          run = ''shell -- bash -c 'cp "$1" ~/.dotfiles/assets/wallpapers/' _ "$1"'';
          desc = "Copy to wallpapers";
        }
      ];
    };
  };
}
