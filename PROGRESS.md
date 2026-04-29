# Progress

## Done
- [x] Install NixOS in QEMU VM (minimal ISO, manual partitioning, systemd-boot)
- [x] Stage 1 — Flakes + dotfiles (~/.dotfiles, nixos-unstable, flake.lock)
- [x] Stage 2 — Standalone home-manager as flake output
- [x] Stage 3 — Hyprland + greetd/tuigreet + kitty
- [x] Stage 4 — zsh + starship, fzf/zoxide/bat/eza/ripgrep, fonts (FiraCode Nerd Font)
- [x] Deep dive: terminal → kitty
- [x] Deep dive: shell → zsh
- [x] Deep dive: editor → neovim (via nixvim)
- [x] Stage 5 — General apps (browser, file manager, screenshots, notifications)
- [x] Stage 6 — Theming (stylix, waybar, Hyprland visuals)
- [x] direnv configured globally (with nix-direnv)
- [x] First boot on real hardware
- [x] Realtek RTL88x2bu WiFi driver (boot.extraModulePackages)

## Immediate (blocking)
- [ ] Fix Realtek WiFi chip — driver not loading on real hardware
- [ ] Redo sops-nix setup — private key was accidentally deleted; need to regenerate and re-encrypt secrets
- [ ] Switch git remote auth from HTTPS/PAT to SSH (was partially done via sops-nix, needs redo after key regeneration)

## Soon
- [ ] Write new-machine bootstrap README — full bring-up sequence, noting that the sops private key must be placed before running home-manager switch
- [ ] Fix initialPassword → proper hashed password

## Stage 7 — Dev environment
- [ ] SSH configured declaratively (key path, ~/.ssh/config)
- [ ] Repo cloning — declared list in home-manager, cloned once to ~/dev/, graceful per-repo failure
- [ ] Project templates in ~/.dotfiles/templates/ (base, rust, flutter)

## Later
- [ ] Better WiFi management UI (nmcli works but something like nmtui or a waybar widget would be nicer)
- [ ] Persistent Hyprland workspaces — always 5, never disappear, easy movement between them
- [ ] DemiBold font fix
- [ ] Fix uwsm/hyprland-start warning
- [ ] Stage 8 — LibrePhoenix config review + refactor
- [ ] Add folder categories to dotfiles once enough modules exist
