# Global instructions (all projects, all machines)

<!-- Managed declaratively by ~/.dotfiles/home/dev/claude/user-instructions.md -->
<!-- This file is a read-only /nix/store symlink: edit it in the repo and re-run home-manager switch. -->

## This machine

- **NixOS**, configured declaratively by a flake at `~/.dotfiles` (hosts: `onyx`, `phoenix`).
- Nothing is installed or configured imperatively. Packages, services, dotfiles
  and settings all come from modules in `~/.dotfiles`, applied by
  `home-manager switch` / `nixos-rebuild switch`.
- Most of `~/.config` is a read-only symlink into `/nix/store`. Editing those
  files directly fails, and any change that lands is wiped on the next rebuild.

## Required

**Invoke the `nixos-system-changes` skill before doing anything that touches the
OS or user environment** - installing, removing or upgrading any package, app,
CLI tool, font, driver or language toolchain; enabling or configuring a service;
changing a system, desktop or shell setting; editing anything under `/etc` or
`~/.config`; or reaching for a tool that isn't on PATH. This applies even when
the request looks like a one-line install command - especially then.

Never run `nix-env -i`, `nix profile install`, `npm i -g`, `pip install`,
`cargo install`, `go install`, or `curl ... | sh` on this machine. If you need a
tool only for the task at hand, use an ephemeral shell instead:
`nix shell nixpkgs#<pkg> -c <cmd>`.
