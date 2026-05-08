# CLAUDE.md — Eyal's NixOS Dotfiles

## About this repo

Personal NixOS configuration for everyday use (includes development, file management, web browsing and so on). Managed with Nix flakes, standalone home-manager, and a growing set of modules.

## About the user

Eyal is a **novice to NixOS/Nix**, but enthusiastic and willing to go deep. The goal is not just a working system, but genuine understanding of every piece of it.

He uses Claude Code as an interactive tutor + pair programmer: explain concepts, deliberate decisions together, then act.

## Collaboration style

- **Explain before acting.** When introducing a concept, tool, or approach, give a short explanation of what it is and why it matters in NixOS terms.
- **Deliberate, don't just comply.** If Eyal questions a decision, don't immediately reverse it. Explain the reasoning, explore trade-offs, then reach a conclusion together.
- **Never make silent trade-offs.** If there are two ways to do something, say so briefly and recommend one — don't just pick one silently.

## Philosophy

Eyal cares deeply about doing things **the Nix Way**:

- Declarative over imperative wherever possible.
- Pure and reproducible — avoid `nix-env -i`, mutable state, or workarounds that break reproducibility.
- Everything should be expressible in the flake/modules; one-off shell commands are a last resort, not a first instinct.
- If there is a "proper" NixOS/home-manager option for something, use it rather than a raw package install + manual config file.

## What to avoid

- Don't make a change and then immediately reverse it when questioned — discuss first.
- Don't add things "just in case" or for hypothetical future needs.
- Don't leave imperative steps undocumented (if something *must* be done imperatively, note it clearly and explain why it can't be declarative yet).

---

## Repo Structure

```
dotfiles/
├── flake.nix                  # minimal bootstrap — inputs + flake-parts
├── flake-modules/
│   └── hosts.nix              # auto-discovers hosts/, builds nixosConfigurations + homeConfigurations
├── hosts/
│   └── <hostname>/
│       ├── hardware-configuration.nix
│       ├── configuration.nix  # sets systemSettings.* — the system control center for this machine
│       └── home.nix           # sets userSettings.* — the home control center for this machine
├── system/                    # NixOS modules (run as root, affect /etc)
│   ├── default.nix            # collector — imports all categories
│   ├── boot/                  # bootloader, kernel modules, initrd
│   ├── hardware/              # GPU (nvidia), audio (pipewire), wifi drivers
│   ├── networking/            # NetworkManager, firewall, sshd, known hosts
│   ├── display/               # greeter (greetd/tuigreet), hyprland system-level enable
│   ├── security/              # users, sudo, polkit
│   ├── nix/                   # nix daemon settings, substituters, GC
│   └── locale/                # timezone, i18n
├── home/                      # home-manager modules (user-level, affect ~/)
│   ├── default.nix            # collector — imports all categories
│   ├── shell/                 # zsh, starship
│   ├── terminal/              # kitty
│   ├── cli/                   # fzf, zoxide, bat, eza, ripgrep, yazi
│   ├── editor/                # nvim via nixvim
│   ├── desktop/               # hyprland user config, waybar, notifications, clipboard, screenshot
│   ├── browser/               # qutebrowser
│   ├── media/                 # imv, future: mpv, audio players
│   ├── dev/                   # git, direnv, languages, repo auto-clone
│   ├── theming/               # stylix, wallpaper rotation
│   ├── secrets/               # sops-nix home module
│   └── apps/                  # misc GUI apps
├── assets/
│   └── wallpapers/            # shared wallpapers, all machines
└── secrets/
    └── ssh_key                # sops-encrypted secrets
```

Each category folder contains single-responsibility leaf modules (`<tool>/default.nix`) and a `default.nix` collector that imports them all.

---

## How to add a new tool or app

1. **Decide the layer:** system-level (affects `/etc`, runs as root) → `system/`; user-level (affects `~/`) → `home/`
2. **Pick the right category** (e.g. a new CLI tool → `home/cli/`, a new hardware driver → `system/hardware/`)
3. **Create the leaf module:** `home/cli/newtool/default.nix`
   ```nix
   { pkgs, ... }: {
     home.packages = [ pkgs.newtool ];
   }
   ```
4. **Register it** in the category collector: add `./newtool` to `home/cli/default.nix` imports
5. It is now active on all machines. If it should be opt-in, wrap it with `lib.mkEnableOption` (see mkOption pattern below).

---

## How to add a new host

1. `mkdir hosts/newmachine`
2. Generate or copy `hardware-configuration.nix` for the new machine
3. Create `hosts/newmachine/configuration.nix` — set only the `systemSettings.*` that differ from defaults
4. Create `hosts/newmachine/home.nix` — set only the `userSettings.*` that differ from defaults
5. The flake auto-discovers it — no edits to `flake.nix` needed
6. Verify: `nixos-rebuild build --flake .#newmachine`

---

## The mkOption pattern (control center)

Modules declare options; host files set them. This is how machine-specific behaviour is expressed without touching module code.

**Declaring an option in a module:**
```nix
# system/hardware/nvidia/default.nix
{ config, lib, ... }: {
  options.systemSettings.hardware.nvidia.enable = lib.mkEnableOption "nvidia GPU";
  config = lib.mkIf config.systemSettings.hardware.nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.modesetting.enable = true;
    # ...
  };
}
```

**Setting it from a host:**
```nix
# hosts/onyx/configuration.nix
{ ... }: {
  systemSettings.hardware.nvidia.enable = true;
}
```

**Naming convention:**
- System options: `options.systemSettings.<category>.<tool>.<option>`
- Home options:   `options.userSettings.<category>.<tool>.<option>`
- Always provide a `default` so hosts that don't mention an option get something sensible

---

## CLI commands

```bash
# Build + activate NixOS config (run as root or with sudo on the target machine)
nixos-rebuild switch --flake .#onyx

# Build + activate home-manager config (run as the user)
home-manager switch --flake .#eyal@onyx

# Build without activating (safe test first)
nixos-rebuild build --flake .#onyx
home-manager build --flake .#eyal@onyx

# Validate the flake without building
nix flake check
```

---

## Rules

- Don't add packages directly to `environment.systemPackages` in host files — put them in the relevant module
- Don't bypass the mkOption interface by writing raw NixOS config directly in host files
- Don't create a new category unless none of the existing ones fit — the categories are intentionally broad
- Don't split a leaf module into sub-files unless it genuinely becomes unwieldy (>100 lines is a rough guide)
