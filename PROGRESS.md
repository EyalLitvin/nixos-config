# Progress

## Done
- [x] Install NixOS in QEMU VM (minimal ISO, manual partitioning, systemd-boot)
- [x] Stage 1 — Flakes + dotfiles (~/.dotfiles, nixos-unstable, flake.lock)
- [x] Stage 2 — Standalone home-manager as flake output
- [x] Stage 3 — Hyprland + greetd/tuigreet + kitty
- [x] Stage 4 (partial) — zsh + starship, fzf/zoxide/bat/eza/ripgrep, fonts (FiraCode Nerd Font)
- [x] Deep dive: terminal → kitty
- [x] Deep dive: shell → zsh
- [x] Deep dive: editor → neovim (via nixvim)

## In Progress
- [ ] nixvim setup (wiring flake input, rewriting neovim.nix)
- [ ] Hyprland keybindings polish
- [ ] DemiBold font fix

## Todo
- [ ] Stage 5 — General apps (browser deep dive, file manager, screenshots, notifications)
- [ ] Stage 6 — Theming (stylix, waybar/eww, Hyprland visuals)
- [ ] Stage 7 — Nix shells + direnv
- [ ] Stage 8 — LibrePhoenix config review + refactor
- [ ] Switch git remote auth from HTTPS/PAT to SSH
- [ ] Fix initialPassword → proper hashed password
- [ ] Fix uwsm/hyprland-start warning
- [ ] Add folder categories to dotfiles once enough modules exist
