{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      anthropic.claude-code
      eamodio.gitlens
      editorconfig.editorconfig
      esbenp.prettier-vscode
      jnoortheen.nix-ide
      ms-python.python
      ms-python.vscode-pylance
    ];

    # VS Code's built-in auto-updater silently overwrites Nix-managed
    # extensions with raw marketplace builds, which aren't patched for
    # NixOS's non-FHS layout (breaks native binaries, e.g. claude-code).
    profiles.default.userSettings."extensions.autoUpdate" = false;
  };
}
